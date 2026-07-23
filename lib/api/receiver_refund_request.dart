import 'package:json_annotation/json_annotation.dart';

part 'receiver_refund_request.g.dart';

@JsonSerializable()
class ReceiverAccount {
  @JsonKey(name: 'account_holder')
  final String accountHolder;
  @JsonKey(name: 'bank_code')
  final String bankCode;
  @JsonKey(name: 'bank_name')
  final String bankName;
  @JsonKey(name: 'account_number')
  final String accountNumber;

  ReceiverAccount({
    required this.accountHolder,
    required this.bankCode,
    required this.bankName,
    required this.accountNumber,
  });

  factory ReceiverAccount.fromJson(Map<String, dynamic> json) =>
      _$ReceiverAccountFromJson(json);

  Map<String, dynamic> toJson() => _$ReceiverAccountToJson(this);
}

@JsonSerializable()
class ReceiverRefundRequest {
  @JsonKey(name: 'receiver_account')
  final ReceiverAccount receiverAccount;
  final String? reason;

  ReceiverRefundRequest({
    required this.receiverAccount,
    this.reason,
  });

  factory ReceiverRefundRequest.fromJson(Map<String, dynamic> json) =>
      _$ReceiverRefundRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ReceiverRefundRequestToJson(this);
}
