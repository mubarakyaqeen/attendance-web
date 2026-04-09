import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool showDownloads = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              /// 🔰 LOGO
              Image.asset(
                'assets/app_icon.png',
                height: 100,
              ),

              const SizedBox(height: 10),

              /// 🏷 TITLE
              const Text(
                "Project Information Hub",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 20),

              /// 👥 GRID (UNCHANGED)
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
                children: const [
                  PersonCard(
                    image: 'assets/person1.webp',
                    role: 'SUPERVISOR (LECTURER)',
                    name: 'Mr. Ogundele Isreal',
                    delay: 0,
                  ),
                  PersonCard(
                    image: 'assets/person2.webp',
                    role: 'PROJECT ENGINEER',
                    name: 'YAQEEN MUBARAK OPEYEMI',
                    delay: 200,
                  ),
                  PersonCard(
                    image: 'assets/person3.jpg',
                    role: 'PROJECT SUPPORTER',
                    name: 'OMOWO AYOBAMI ANTHONY',
                    delay: 400,
                  ),
                  PersonCard(
                    image: 'assets/person4.webp',
                    role: 'PROJECT SUPPORTER',
                    name: 'OLAOYE STEPHEN TIMILEYIN',
                    delay: 600,
                  ),
                ],
              ),

              const SizedBox(height: 25),

              /// 🔐 LOGIN BUTTON (UNCHANGED)
              AnimatedButton(
                text: "LOGIN",
                color: Colors.green.shade800,
                textColor: Colors.white,
                onTap: () {
                  Navigator.pushNamed(context, '/app');
                },
              ),

              const SizedBox(height: 15),

              /// 📥 DOWNLOAD BUTTON (UPDATED)
              AnimatedButton(
                text: showDownloads
                    ? "HIDE PROJECT REPORT ▲"
                    : "DOWNLOAD PROJECT APP ▼",
                color: Colors.amber,
                textColor: Colors.black,
                onTap: () {
                  setState(() {
                    showDownloads = !showDownloads;
                  });
                },
              ),

              /// 🔽 EXPANDABLE SECTION (NEW)
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                height: showDownloads ? 180 : 0,
                child: showDownloads
                    ? Column(
                  children: [
                    const SizedBox(height: 10),

                    reportItem(
                      "Download Project App (APK)",
                      "https://yabatech-attendance-v8.onrender.com/uploads/Attendance.apk",
                    ),

                    reportItem(
                      "Download Project Report (PDF)",
                      "https://yabatech-attendance-v8.onrender.com/uploads/feasibility.pdf",
                    ),

                  ],
                )
                    : null,
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////////
  /// 📄 REPORT ITEM
  ////////////////////////////////////////////////////////

  Widget reportItem(String title, String url) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 4,
          padding: const EdgeInsets.symmetric(vertical: 16), // 🔥 BIG HEIGHT
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () async {
          final Uri uri = Uri.parse(url);
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        },
        icon: const Icon(Icons.download, size: 22), // 🔥 bigger icon
        label: Text(
          title,
          style: const TextStyle(
            fontSize: 16, // 🔥 bigger text
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////
/// 👤 PERSON CARD WITH STAGGERED ANIMATION
////////////////////////////////////////////////////////

class PersonCard extends StatefulWidget {
  final String image;
  final String role;
  final String name;
  final int delay;

  const PersonCard({
    super.key,
    required this.image,
    required this.role,
    required this.name,
    required this.delay,
  });

  @override
  State<PersonCard> createState() => _PersonCardState();
}

class _PersonCardState extends State<PersonCard>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    fadeAnimation = Tween<double>(begin: 0, end: 1).animate(controller);

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    ));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) controller.forward();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber.shade300, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              )
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [

              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  widget.image,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                widget.role,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                widget.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////
/// 🔘 PREMIUM ANIMATED BUTTON
////////////////////////////////////////////////////////

class AnimatedButton extends StatefulWidget {
  final String text;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const AnimatedButton({
    super.key,
    required this.text,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  double scale = 1;

  void onTapDown(_) {
    setState(() => scale = 0.95);
  }

  void onTapUp(_) {
    setState(() => scale = 1);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTapCancel: () => setState(() => scale = 1),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: widget.textColor,
            ),
          ),
        ),
      ),
    );
  }
}