import 'package:flutter/material.dart';

class CreatePostView extends StatefulWidget {
  const CreatePostView({super.key});

  @override
  State<CreatePostView> createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<CreatePostView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Post'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _controller,
          maxLines: null,
          expands: true,
          decoration: const InputDecoration(
            hintText: 'What\'s on your mind? Select text to format it!',
            border: InputBorder.none,
            filled: false,
          ),
          contextMenuBuilder: (BuildContext context, EditableTextState editableTextState) {
            final List<ContextMenuButtonItem> buttonItems = editableTextState.contextMenuButtonItems;
            
            // Add custom formatting options
            buttonItems.insert(
              0,
              ContextMenuButtonItem(
                label: 'Bold',
                onPressed: () {
                  final text = _controller.text;
                  final selection = _controller.selection;
                  final selectedText = selection.textInside(text);
                  final newText = text.replaceRange(selection.start, selection.end, '**$selectedText**');
                  _controller.value = _controller.value.copyWith(
                    text: newText,
                    selection: TextSelection.collapsed(offset: selection.end + 4),
                  );
                  ContextMenuController.removeAny();
                },
              ),
            );
            buttonItems.insert(
              1,
              ContextMenuButtonItem(
                label: 'Highlight',
                onPressed: () {
                  final text = _controller.text;
                  final selection = _controller.selection;
                  final selectedText = selection.textInside(text);
                  final newText = text.replaceRange(selection.start, selection.end, '==$selectedText==');
                  _controller.value = _controller.value.copyWith(
                    text: newText,
                    selection: TextSelection.collapsed(offset: selection.end + 4),
                  );
                  ContextMenuController.removeAny();
                },
              ),
            );

            return AdaptiveTextSelectionToolbar.buttonItems(
              anchors: editableTextState.contextMenuAnchors,
              buttonItems: buttonItems,
            );
          },
        ),
      ),
    );
  }
}
