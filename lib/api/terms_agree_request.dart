class TermAgreementItem {
  final int termId;
  final int termVersionId;
  final bool agreed;

  TermAgreementItem({
    required this.termId,
    required this.termVersionId,
    required this.agreed,
  });

  Map<String, dynamic> toJson() => {
        'term_id': termId,
        'term_version_id': termVersionId,
        'agreed': agreed,
      };
}
