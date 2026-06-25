class TermsAgreeResponse {
  final bool success;
  final String message;
  final int agreedCount;

  TermsAgreeResponse({
    required this.success,
    required this.message,
    required this.agreedCount,
  });

  factory TermsAgreeResponse.fromJson(Map<String, dynamic> json) {
    return TermsAgreeResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      agreedCount: json['agreed_count'] as int? ?? 0,
    );
  }
}
