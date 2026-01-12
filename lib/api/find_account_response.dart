import 'package:json_annotation/json_annotation.dart';

part 'find_account_response.g.dart';

@JsonSerializable()
class FindAccountResponse {
  final bool success;
  final String type;
  final String? email; // 마스킹된 이메일 (find_id일 때)
  @JsonKey(name: 'full_email')
  final String? fullEmail; // 전체 이메일 (find_id일 때)
  final bool? verified; // 비밀번호 찾기 인증 성공 여부
  final String message;

  FindAccountResponse({
    required this.success,
    required this.type,
    this.email,
    this.fullEmail,
    this.verified,
    required this.message,
  });

  factory FindAccountResponse.fromJson(Map<String, dynamic> json) =>
      _$FindAccountResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FindAccountResponseToJson(this);
}

