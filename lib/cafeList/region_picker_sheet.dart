import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cafeplatform/provider/store_provider.dart';

/// API [StoreProvider.availableRegions]를 불러온 뒤 바텀시트로 지역 목록을 보여 줍니다.
Future<void> showStoreRegionPickerBottomSheet(BuildContext context) async {
  final storeProvider = Provider.of<StoreProvider>(context, listen: false);
  await storeProvider.fetchAvailableRegions();
  if (!context.mounted) return;

  final availableRegions = storeProvider.availableRegions;
  if (availableRegions.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('지역 목록을 불러오지 못했습니다.')),
    );
    return;
  }

  final selectedRegionCode = storeProvider.selectedRegionCode;

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      final maxH = MediaQuery.sizeOf(ctx).height * 0.55;
      return SafeArea(
        child: SizedBox(
          height: maxH,
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '지역 선택',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: availableRegions.length,
                  itemBuilder: (context, index) {
                    final region = availableRegions[index];
                    final isSel = region.region_code == selectedRegionCode;
                    return ListTile(
                      leading: Icon(
                        Icons.place_outlined,
                        color: isSel ? Colors.black87 : Colors.grey.shade400,
                      ),
                      title: Text(
                        region.region_name,
                        style: TextStyle(
                          fontWeight:
                              isSel ? FontWeight.w600 : FontWeight.normal,
                          color: Colors.black87,
                          fontSize: 15,
                        ),
                      ),
                      trailing: isSel
                          ? const Icon(Icons.check, color: Colors.black87)
                          : null,
                      onTap: () async {
                        Navigator.pop(ctx);
                        final sp =
                            Provider.of<StoreProvider>(context, listen: false);
                        sp.setSelectedRegionCode(region.region_code);
                        try {
                          final districtCode =
                              region.districts?.isNotEmpty == true
                                  ? region.districts!.first.district_code
                                  : region.region_code;
                          sp.resetPagination();
                          await sp.fetchListViewStoresByDistrict(
                            districtCode,
                            cursor: null,
                            limit: 10,
                          );
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('해당 지역 매장을 불러오지 못했습니다.'),
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

