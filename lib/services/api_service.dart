import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/group.dart';

class ApiService {
  static const String baseUrl = "http://13.127.170.51:8080/api";
  String? get token => User.currentUser?.authToken;

  // LOGIN API
  Future<User?> login(String mobileNumber) async {
    final url = Uri.parse("$baseUrl/v1/user/auth");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"dialCode": "+91", "mobileNumber": mobileNumber}),
    );
    print("Status: \\${res.statusCode}, Body: \\${res.body}");
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      if (data['status'] == true) {
        return User.fromJson(data['resources']['data']);
      }
    }
    return null;
  }

  // PROFILE API
  Future<bool> updateProfile(
    String first,
    String last,
    String referCode,
  ) async {
    final url = Uri.parse("$baseUrl/v2/user/profile");
    final res = await http.put(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode({
        "firstName": first,
        "lastName": last,
        "referCodeUsed": referCode, // Always use SYS1234
      }),
    );
    print("Profile update: \\${res.statusCode}, Body: \\${res.body}");
    return res.statusCode == 200 && json.decode(res.body)['status'] == true;
  }

  // GET GROUP LIST API
  Future<List<Group>> getGroupList() async {
    final url = Uri.parse("$baseUrl/v1/group/list");
    final res = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );
    print("Group list: \\${res.statusCode}, Body: \\${res.body}");
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      if (data['status'] == true) {
        return (data['resources']['data'] as List)
            .map((e) => Group.fromJson(e['group']))
            .toList();
      }
    }
    return [];
  }

  // SEND MESSAGE API
  Future<bool> sendMessage(
    String groupId,
    String content, {
    String? filePath,
  }) async {
    final url = Uri.parse("$baseUrl/v1/message/send");
    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = "Bearer $token";
    request.fields['group'] = groupId;
    request.fields['content'] = content;
    if (filePath != null) {
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
    }
    final streamedRes = await request.send();
    final res = await http.Response.fromStream(streamedRes);
    print("Send message: \\${res.statusCode}, Body: \\${res.body}");
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return data['status'] == true;
    }
    return false;
  }
}
