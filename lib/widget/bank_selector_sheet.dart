import 'package:flutter/material.dart';
import 'package:cafeplatform/utils/bank_list.dart';

/// 은행 선택 바텀시트 — 텍스트 리스트
void showBankSelectorSheet(
  BuildContext context, {
  required void Function(String name, String code) onSelected,
}) {
  final height = MediaQuery.of(context).size.height * 0.7;
  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              "은행을 선택해주세요",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF101010),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: BankList.banks.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[100]),
              itemBuilder: (context, index) {
                final item = BankList.banks[index];
                final name = item['name'] ?? '';
                final code = item['code'] ?? '';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF101010),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onSelected(name, code);
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
