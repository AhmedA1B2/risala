import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ShowRecitersJson extends StatefulWidget {
  const ShowRecitersJson({super.key});

  @override
  State<ShowRecitersJson> createState() => _ShowRecitersJsonState();
}

class _ShowRecitersJsonState extends State<ShowRecitersJson> {
  String? recitersJson;
  bool isLoading = false;

  final String clientId = "e3af92df-f3d7-4d3a-9ccc-152c532492ee";
  final String clientSecret = "1tfKz8HWd3w9iyGkBTkv_b~N8t";
  final String tokenEndpoint = "https://oauth2.quran.foundation/oauth2/token";

  String? accessToken;

  Future<void> fetchAccessToken() async {
    setState(() => isLoading = true);
    try {
      final auth =
          'Basic ' + base64Encode(utf8.encode('$clientId:$clientSecret'));

      final response = await http.post(
        Uri.parse(tokenEndpoint),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': auth,
        },
        body: 'grant_type=client_credentials&scope=content',
        encoding: Encoding.getByName('utf-8'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        accessToken = data['access_token'];
        debugPrint("✅ Token: $accessToken");
      } else {
        debugPrint("❌ Token Error: ${response.body}");
      }
    } catch (e) {
      debugPrint("🔥 Token Exception: $e");
    }
    setState(() => isLoading = false);
  }

  Future<void> fetchRecitersJson() async {
    setState(() => isLoading = true);

    if (accessToken == null) await fetchAccessToken();

    try {
      final response = await http.get(
        Uri.parse(
            "https://apis.quran.foundation/content/api/v4/resources/recitations"),
        headers: {
          "Accept": "application/json",
          "x-auth-token": accessToken!,
          "x-client-id": clientId,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final formatted = const JsonEncoder.withIndent('  ').convert(jsonData);

        setState(() {
          if (jsonData is List) {
            recitersJson = "عدد القرّاء: ${jsonData.length}\n\n$formatted";
          } else {
            recitersJson = formatted;
          }
        });

        print("🔹 Reciters Response:\n$formatted");
      } else {
        setState(() {
          recitersJson = "فشل في جلب البيانات: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        recitersJson = "حدث خطأ: $e";
      });
      print("🔥 Exception: $e");
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("عرض JSON للقراء")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: isLoading ? null : fetchRecitersJson,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("جلب أسماء القراء"),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(
                  recitersJson ?? "اضغط على الزر لجلب قائمة القراء",
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
