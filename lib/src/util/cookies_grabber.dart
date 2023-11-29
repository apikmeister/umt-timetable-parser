import 'package:cookie_jar/cookie_jar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
// import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

// Assuming 'getUserData' is a Dart function that you've implemented
import 'get_user_data.dart';

class LoginResponse {
  bool success;
  String? name;
  String? address;
  String? phoneNo;

  LoginResponse({
    required this.success,
    this.name,
    this.address,
    this.phoneNo,
  });
}

class LoginParams {
  String login;
  String uid;
  String pwd;

  LoginParams({
    required this.login,
    required this.uid,
    required this.pwd,
  });
}

Future<LoginResponse> studentLogin(LoginParams params) async {
  var dio = Dio();
  var cookieJar = CookieJar();
  dio.interceptors.add(CookieManager(cookieJar));

  var data = {
    'login': 'student',
    'uid': params.uid,
    'pwd': params.pwd,
    'submit': 'submit',
  };

  try {
    var response = await dio.post(
      Platform.environment['LOGIN_PAGE']!,
      data: data,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    if (response.statusCode == 200) {
      var profileResponse = await dio.get(
        Platform.environment['PROFILE_PAGE']!,
      );

      if (profileResponse.statusCode == 200) {
        var userData = getUserData(jsonDecode(profileResponse.data));
        return LoginResponse(
            success: true,
            name: userData['name'],
            address: userData['address'],
            phoneNo: userData['phoneNo']);
      }
    }

    return LoginResponse(success: false);
  } catch (error) {
    print(error);
    return LoginResponse(success: false);
  }
}

// Future<LoginResponse> studentLogin(LoginParams params) async {
//   final dio = Dio();
//   final cookieJar = CookieJar();
//   dio.interceptors.add(CookieManager(cookieJar));
//   var headers = {
//     'Content-Type': 'application/x-www-form-urlencoded'
//   };

//   var uri = Uri.parse(Platform.environment['LOGIN_PAGE']!);
//   var profileUri = Uri.parse(Platform.environment['PROFILE_PAGE']!);
  

//   var client = http.Client();
//   try {
//     // var response = await client.post(
//     //   uri,
//     //   headers: headers,
//     //   body: {
//     //     'login': params.login,
//     //     'uid': params.uid,
//     //     'pwd': params.pwd,
//     //     'submit': 'submit',
//     //   },
//     // );

//     // Use dio
//     var response = await dio.post(
//       uri.toString(),
//       data: {
//         'login': params.login,
//         'uid': params.uid,
//         'pwd': params.pwd,
//         'submit': 'submit',
//       }
//     );

//     // Handle cookies if necessary
//     var cookie = response.headers['set-cookie'];

//     if (cookie != null) {
//       headers['Cookie'] = cookie;
//     }

//     var profileResponse = await client.get(profileUri, headers: headers);
    
//     if (profileResponse.statusCode == 200) {
//       // Parse the response body to get user data
//       var userData = getUserData(profileResponse.body); // Assuming getUserData returns a Future
//       return LoginResponse(success: true, ...userData);
//     } else {
//       return LoginResponse(success: false);
//     }
//   } catch (e) {
//     print(e);
//     return LoginResponse(success: false);
//   } finally {
//     client.close();
//   }
// }
