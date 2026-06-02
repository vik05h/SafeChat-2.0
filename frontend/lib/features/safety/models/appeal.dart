import 'package:freezed_annotation/freezed_annotation.dart';

part 'appeal.freezed.dart';
part 'appeal.g.dart';

enum AppealStatus { submitted, under_review, approved, rejected }

@freezed
class Appeal with _$Appeal {
  const factory Appeal({
    required String id,
    @JsonKey(name: 'moderation_log_id') required String moderationLogId,
    @JsonKey(name: 'content_preview') required String contentPreview,
    @JsonKey(name: 'reason_provided') required String reasonProvided,
    required String status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
    @JsonKey(name: 'admin_notes') String? adminNotes,
  }) = _Appeal;

  factory Appeal.fromJson(Map<String, dynamic> json) => _$AppealFromJson(json);
}

extension AppealStatusHelper on Appeal {
  AppealStatus get appealStatus {
    switch (status.toLowerCase()) {
      case 'under_review':
        return AppealStatus.under_review;
      case 'approved':
        return AppealStatus.approved;
      case 'rejected':
        return AppealStatus.rejected;
      case 'submitted':
      default:
        return AppealStatus.submitted;
    }
  }
}
