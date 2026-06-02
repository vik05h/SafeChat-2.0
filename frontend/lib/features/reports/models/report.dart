import 'package:freezed_annotation/freezed_annotation.dart';

part 'report.freezed.dart';
part 'report.g.dart';

enum ReportTargetType { user, post, comment, message }

enum ReportReason {
  harassment,
  hate_speech,
  spam,
  nudity,
  violence,
  self_harm,
  other
}

@freezed
class Report with _$Report {
  const factory Report({
    required String id,
    @JsonKey(name: 'target_id') required String targetId,
    @JsonKey(name: 'target_type') required String targetType,
    required String reason,
    @JsonKey(name: 'additional_info') String? additionalInfo,
    required String status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Report;

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
}

// Helpers
extension ReportEnumHelper on String {
  ReportTargetType get toReportTargetType {
    return ReportTargetType.values.firstWhere(
      (e) => e.name == toLowerCase(),
      orElse: () => ReportTargetType.post,
    );
  }

  ReportReason get toReportReason {
    return ReportReason.values.firstWhere(
      (e) => e.name == toLowerCase(),
      orElse: () => ReportReason.other,
    );
  }
}

extension ReportReasonFormatting on ReportReason {
  String get displayName {
    return name.split('_').map((w) => '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
  }
}
