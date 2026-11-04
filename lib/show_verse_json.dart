import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ShowVerseJson extends StatefulWidget {
  const ShowVerseJson({super.key});

  @override
  State<ShowVerseJson> createState() => _ShowVerseJsonState();
}

class _ShowVerseJsonState extends State<ShowVerseJson> {
  String? verseJson;
  bool isLoading = false;

  final String clientId = "e3af92df-f3d7-4d3a-9ccc-152c532492ee";
  final String clientSecret = "1tfKz8HWd3w9iyGkBTkv_b~N8t";
  final String tokenEndpoint = "https://oauth2.quran.foundation/oauth2/token";

  String? accessToken;

  // 🟢 لتحديد السورة والآية (مثلاً الشعراء: 26:110)
  final TextEditingController surahController =
      TextEditingController(text: "26");
  final TextEditingController ayahController = TextEditingController(text: "110");

  Future<void> fetchAccessToken() async {
    setState(() {
      isLoading = true;
    });
    try {
      final auth =
          'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}';

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
        debugPrint("✅ تم الحصول على التوكن: $accessToken");
      } else {
        debugPrint("❌ خطأ في الحصول على التوكن: ${response.body}");
      }
    } catch (e) {
      debugPrint("🔥 استثناء أثناء الحصول على التوكن: $e");
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchVerseJson() async {
    setState(() => isLoading = true);

    // 🟡 تكوين رقم الآية مثل "26:110"
    final verseKey = "${surahController.text}:${ayahController.text}";

    if (accessToken == null) await fetchAccessToken();

    try {
      final response = await http.get(
        Uri.parse(
          "https://apis.quran.foundation/content/api/v4/verses/by_key/$verseKey?words=true&audio=7",
        ),
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
          verseJson = formatted;
        });

        debugPrint("🔹 JSON Response for $verseKey:\n$formatted");
      } else {
        setState(() {
          verseJson = "فشل في جلب البيانات: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        verseJson = "حدث خطأ: $e";
      });
      debugPrint("🔥 استثناء: $e");
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("عرض JSON من API")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // حقل رقم السورة
                Expanded(
                  child: TextField(
                    controller: surahController,
                    decoration: const InputDecoration(
                      labelText: "رقم السورة",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                // حقل رقم الآية
                Expanded(
                  child: TextField(
                    controller: ayahController,
                    decoration: const InputDecoration(
                      labelText: "رقم الآية",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: isLoading ? null : fetchVerseJson,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("جلب البيانات من API"),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(
                  verseJson ?? "أدخل رقم السورة والآية ثم اضغط على الزر",
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
