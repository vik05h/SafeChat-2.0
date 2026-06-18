// frontend/lib/shared/widgets/image_crop_sheet.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Full-screen crop/zoom sheet. The user pinch-zooms and pans the picked image
/// inside a fixed frame; on confirm the framed region is rendered to a new
/// image file (the crop is *baked in*), so the stored photo is already framed
/// everywhere it appears — no per-render transform needed.
///
/// Returns the baked [File] via `Navigator.pop`, or null if cancelled.
class ImageCropSheet extends StatefulWidget {
  final File file;

  /// width / height of the crop frame (1.0 = square avatar, 2.0 = banner).
  final double aspectRatio;

  /// Circular guide overlay (the baked output is still the bounding rectangle,
  /// so it works in any circular display).
  final bool circle;

  /// Target width in pixels of the baked image.
  final double targetWidth;

  const ImageCropSheet({
    super.key,
    required this.file,
    this.aspectRatio = 1.0,
    this.circle = false,
    this.targetWidth = 1080,
  });

  @override
  State<ImageCropSheet> createState() => _ImageCropSheetState();
}

class _ImageCropSheetState extends State<ImageCropSheet> {
  final GlobalKey _repaintKey = GlobalKey();
  final TransformationController _controller = TransformationController();

  double? _imageAspect; // intrinsic width / height
  bool _saving = false;
  bool _didCenter = false;

  @override
  void initState() {
    super.initState();
    _loadAspect();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadAspect() async {
    try {
      final bytes = await widget.file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      if (!mounted) return;
      setState(() {
        _imageAspect = frame.image.width / frame.image.height;
      });
    } catch (_) {
      if (mounted) setState(() => _imageAspect = 1.0);
    }
  }

  // Size the image so its shorter side covers the frame, then centre it.
  Size _coverSize(Size frame) {
    final imgAspect = _imageAspect ?? 1.0;
    final frameAspect = frame.width / frame.height;
    if (imgAspect > frameAspect) {
      // Image is wider — match height, overflow horizontally.
      return Size(frame.height * imgAspect, frame.height);
    }
    return Size(frame.width, frame.width / imgAspect);
  }

  void _centerInitial(Size frame, Size cover) {
    final tx = (frame.width - cover.width) / 2;
    final ty = (frame.height - cover.height) / 2;
    _controller.value = Matrix4.identity()
      ..setEntry(0, 3, tx)
      ..setEntry(1, 3, ty);
  }

  Future<void> _confirm(double frameWidth) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final boundary =
          _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final pixelRatio = (widget.targetWidth / frameWidth).clamp(1.0, 4.0);
      final image = await boundary.toImage(pixelRatio: pixelRatio.toDouble());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        if (mounted) setState(() => _saving = false);
        return;
      }
      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final out = File(
        '${Directory.systemTemp.path}/crop_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await out.writeAsBytes(pngBytes);
      if (mounted) Navigator.of(context).pop(out);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not crop image: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 80,
        leading: TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
        ),
        title: const Text('Adjust photo'),
        centerTitle: true,
        actions: [
          _saving
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  ),
                )
              : Builder(
                  builder: (context) => TextButton(
                    onPressed: () =>
                        _confirm(MediaQuery.of(context).size.width - 32),
                    child: const Text('Done',
                        style: TextStyle(
                            color: Colors.lightBlueAccent,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
        ],
      ),
      body: _imageAspect == null
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final frameW = constraints.maxWidth - 32;
                  final frameH = frameW / widget.aspectRatio;
                  final frame = Size(frameW, frameH);
                  final cover = _coverSize(frame);

                  // Centre once we know the sizes (post-frame to avoid build-time set).
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!_didCenter) {
                      _didCenter = true;
                      _centerInitial(frame, cover);
                    }
                  });

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Captured region = the framed image only.
                          RepaintBoundary(
                            key: _repaintKey,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  widget.circle ? frameW : 12),
                              child: SizedBox(
                                width: frameW,
                                height: frameH,
                                child: InteractiveViewer(
                                  transformationController: _controller,
                                  constrained: false,
                                  minScale: 1.0,
                                  maxScale: 5.0,
                                  boundaryMargin: EdgeInsets.zero,
                                  child: SizedBox(
                                    width: cover.width,
                                    height: cover.height,
                                    child: Image.file(
                                      widget.file,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Circular guide ring (not captured — sits above boundary).
                          if (widget.circle)
                            IgnorePointer(
                              child: Container(
                                width: frameW,
                                height: frameH,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white70, width: 2),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.pinch, color: Colors.white54, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Pinch to zoom · drag to reposition',
                            style: TextStyle(color: Colors.white54, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }
}
