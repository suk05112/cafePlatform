// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receiver_refund_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReceiverAccount _$ReceiverAccountFromJson(Map<String, dynamic> json) =>
    ReceiverAccount(
      accountHolder: json['account_holder'] as String,
      bankCode: json['bank_code'] as String,
      bankName: json['bank_name'] as String,
      accountNumber: json['account_number'] as String,
    );

Map<String, dynamic> _$ReceiverAccountToJson(ReceiverAccount instance) =>
    <String, dynamic>{
      'account_holder': instance.accountHolder,
      'bank_code': instance.bankCode,
      'bank_name': instance.bankName,
      'account_number': instance.accountNumber,
    };

ReceiverRefundRequest _$ReceiverRefundRequestFromJson(
        Map<String, dynamic> json) =>
    ReceiverRefundRequest(
      receiverAccount: ReceiverAccount.fromJson(
          json['receiver_account'] as Map<String, dynamic>),
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$ReceiverRefundRequestToJson(
        ReceiverRefundRequest instance) =>
    <String, dynamic>{
      'receiver_account': instance.receiverAccount,
      'reason': instance.reason,
    };
