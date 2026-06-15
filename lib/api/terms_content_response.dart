class TermsContentResponse {
  final String content;
  final String termType;
  final String version;

  TermsContentResponse({
    required this.content,
    required this.termType,
    required this.version,
  });

  factory TermsContentResponse.fromJson(Map<String, dynamic> json) {
    return TermsContentResponse(
      content: json['content'] as String? ?? '',
      termType: json['term_type'] as String? ?? '',
      version: json['version'] as String? ?? '',
    );
  }
}
