import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DownloadPage extends StatelessWidget {
  const DownloadPage({super.key});

  /// 🔗 Replace with your real links
  final String apkUrl = "https://your-apk-link.com/app-release.apk";

  void openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: Colors.green.shade800,
        title: const Text("Downloads & Reports"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// 🔰 TITLE
            const Text(
              "DOWNLOADS & REPORTS",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 15),

            /// 📱 GET APP BUTTON
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.shade800,
                    Colors.green.shade600,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton.icon(
                onPressed: () {
                  openUrl(apkUrl);
                },
                icon: const Icon(Icons.android, color: Colors.white),
                label: const Text(
                  "GET ECO-BUILD APP",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 📄 REPORTS SECTION
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                  )
                ],
              ),
              child: Column(
                children: [

                  const Text(
                    "PROJECT REPORTS",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [

                      reportButton("Feasibility Report (PDF)"),
                      reportButton("Sustainability Analysis"),
                      reportButton("Construction Plan (PDF)"),
                      reportButton("Reports Center"),

                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 📥 VIEW ALL DOWNLOADS
            fullButton(
              text: "VIEW ALL DOWNLOADS",
              color: Colors.green.shade800,
              textColor: Colors.white,
              onTap: () {},
            ),

            const SizedBox(height: 15),

            /// 📊 REPORT CENTER
            fullButton(
              text: "REPORTS CENTER",
              color: Colors.amber,
              textColor: Colors.black,
              onTap: () {},
            ),

            const SizedBox(height: 20),

            /// 📞 CONTACT
            TextButton(
              onPressed: () {},
              child: const Text(
                "Contact Support",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////////
  /// 🔘 SMALL REPORT BUTTON
  ////////////////////////////////////////////////////////

  Widget reportButton(String text) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade200,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: () {},
      icon: const Icon(Icons.download, size: 18),
      label: Text(
        text,
        style: const TextStyle(fontSize: 13),
      ),
    );
  }

  ////////////////////////////////////////////////////////
  /// 🔘 FULL WIDTH BUTTON
  ////////////////////////////////////////////////////////

  Widget fullButton({
    required String text,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}