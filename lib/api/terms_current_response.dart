class TermItem {
  final int termId;
  final int termVersionId;
  final String termType;
  final String title;
  final bool required;
  final String version;

  TermItem({
    required this.termId,
    required this.termVersionId,
    required this.termType,
    required this.title,
    required this.required,
    required this.version,
  });

  factory TermItem.fromJson(Map<String, dynamic> json) {
    return TermItem(
      termId: json['term_id'] as int,
      termVersionId: json['term_version_id'] as int,
      termType: json['term_type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      required: json['required'] as bool? ?? false,
      version: json['version'] as String? ?? '',
    );
  }
}

class TermsCurrentResponse {
  final List<TermItem> terms;

  TermsCurrentResponse({required this.terms});

  factory TermsCurrentResponse.fromJson(Map<String, dynamic> json) {
    final list = json['terms'] as List<dynamic>? ?? [];
    return TermsCurrentResponse(
      terms: list.map((e) => TermItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
