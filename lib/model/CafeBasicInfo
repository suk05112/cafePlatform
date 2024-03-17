import 'package:cloud_firestore/cloud_firestore.dart';

class CafeBasicInfo {
  String? logo;
  String? store_name;
  String? store_telephone;
  DocumentReference? reference;

  CafeBasicInfo(
      {required this.logo,
      required this.store_name,
      required this.store_telephone,
      this.reference});

  CafeBasicInfo.fromJson(dynamic json, this.reference) {
    logo = json['logo'];
    store_name = json['store_name'];
    store_telephone = json['store_telephone'];
  }

  CafeBasicInfo.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapShot)
      : this.fromJson(snapShot.data(), snapShot.reference);

  CafeBasicInfo.fromQuerySnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data(), snapshot.reference);

  factory CafeBasicInfo.fromDocumentSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic> data = snapshot.data()!;
    return CafeBasicInfo(
      logo: data['logo'],
      store_name: data['store_name'],
      store_telephone: data['store_telephone'],
    );
  }
}
