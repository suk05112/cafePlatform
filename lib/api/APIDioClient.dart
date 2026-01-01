import 'dart:io';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

abstract class ApiDioClient {
  void uploadImage();
}

class ApiServiceImpl implements ApiDioClient {
  final Dio _dio = Dio();

  @override
  void uploadImage() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);

    Map<String, String> headers = {
      'Content-Type': 'image',
      'X-Amz-Algorithm': 'AWS4-HMAC-SHA256',
      'X-Amz-Credential':
          'AKIAQD4W7YEDZS7TU7NB%2F20230715%2Fap-northeast-2%2Fs3%2Faws4_request',
      'X-Amz-Date': '20230715T073619Z',
      'X-Amz-Expires': '3600',
      'X-Amz-SignedHeaders': 'host%3Bx-amz-acl',
      'X-Amz-Signature':
          'd65ef327e943b23738bf2c425ba90c192b1231870f506248063eeeba2b284636'
    };

    final bytes = File(pickedFile!.path).readAsBytesSync();
    http.Response response = await http.put(
        Uri.parse(
            "https://cafe-platform-bucket.s3.amazonaws.com/logo/s3_test6.png"),
        body: bytes);

    print("image upload");
    print(response.statusCode);
    // print("image path");
    // print(File(pickedFile!.path).path);
    // var path = await MultipartFile.fromFile(File(pickedFile!.path).path,
    //     filename: 'buis_test.jpeg');
    // print(path);

    // FormData formData = FormData.fromMap({
    //   "store_logo": path,
    //   "store_name": "John Smith",
    //   "store_telephone": "john.smith@example.com phone",
    //   "store_description": "john.smith@example.com desc",
    //   "store_photo": "john.smith@example.com photo",
    //   "store_address": "john.smith@example.com adr",
    //   "store_lat": 0,
    //   "store_lng": 0,
    //   "business_registration": 'path',
    // });

// FormData formData = FormData.fromMap({
//     "password": register.password,
//     "phone": register.phone,
//     "bankbook": await MultipartFile.fromFile(register.bankbook.path, filename: "bankbook.jpg"),
//     "buisiness_registration": await MultipartFile.fromFile(register.businessRegistration.path, filename: "business_registration.jpg"),
//   });

    // try {
    //   final response = await _dio.post(
    //     'https://ot113tt778.execute-api.us-east-2.amazonaws.com/staging/store/', // 변경해야 할 실제 엔드포인트 URL
    //     data: formData,
    //   );
    //   print("upload success");
    //   print(response);
    //   return response;
    // } catch (e) {
    //   print(e);
    //   throw Exception("Error uploading image: $e");
    // }
  }
}
