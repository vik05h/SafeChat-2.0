enum ModerationStatus {
  safe,
  warning,
  blocked
}

class ModerationResult {
  final ModerationStatus status;
  final String? category;
  final String? reason;

  ModerationResult({
    required this.status,
    this.category,
    this.reason,
  });

  factory ModerationResult.fromJson(Map<String, dynamic> json) {
    // The backend endpoint returns a "blocked" boolean, "layer", "category", and "reason".
    // Alternatively, the prompt specified responses SAFE, WARNING, BLOCKED. 
    // We will map the response to our enum.
    final result = json['result'] ?? {};
    final bool blocked = result['blocked'] ?? false;
    // For warning, it might be returned differently, but let's assume a generic status check if provided,
    // otherwise fallback to blocked/safe.
    final String statusStr = json['status']?.toString().toLowerCase() ?? '';
    
    ModerationStatus status = ModerationStatus.safe;
    if (statusStr == 'blocked' || blocked) {
      status = ModerationStatus.blocked;
    } else if (statusStr == 'warning') {
      status = ModerationStatus.warning;
    }

    return ModerationResult(
      status: status,
      category: result['category'],
      reason: result['reason'],
    );
  }
}
