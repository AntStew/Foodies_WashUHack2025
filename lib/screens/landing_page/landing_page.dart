import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

const kTomatoRed = Color(0xFFE74C3C);
const kEggYellow = Color(0xFFF39C12);
const kHerbGreen = Color(0xFF27AE60);
const kCream     = Color(0xFFFFF8DC);
const kCharcoal  = Color(0xFF2C3E50);

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: kCream,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HERO
            SizedBox(
              height: size.height * 0.9,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset('design/Assestss/1.jpeg', fit: BoxFit.cover),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0x99000000), Color(0x33000000)],
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Card(
                        color: Colors.white.withValues(alpha: .95),
                        elevation: 14,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "WHAT'S FOR DINNER?",
                                style: TextStyle(
                                  letterSpacing: 2, color: Colors.black54, fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text.rich(
                                TextSpan(children: [
                                  TextSpan(
                                    text: "Cook",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800, color: kCharcoal,
                                      fontSize: size.width < 600 ? 42 : 64,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "N",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: size.width < 600 ? 42 : 64,
                                      foreground: Paint()
                                        ..shader = const LinearGradient(
                                          colors: [kTomatoRed, Color(0xFFE67E22)],
                                        ).createShader(const Rect.fromLTWH(0, 0, 300, 60)),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Up",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800, color: kCharcoal,
                                      fontSize: size.width < 600 ? 42 : 64,
                                    ),
                                  ),
                                ]),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "What's cookin'? Turn your fridge chaos into delicious meals — powered by AI.",
                                textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 18),
                              ),
                              const SizedBox(height: 24),
                              Column(
                                children: [
                                  _GradientButton(
                                    label: "🍳 Get Started",
                                    onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
                                  ),
                                  const SizedBox(height: 12),
                                  OutlinedButton(
                                    onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: kCharcoal, width: 2),
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    ),
                                    child: const Text("Login",
                                      style: TextStyle(color: kCharcoal, fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // FEATURES
            const _Features(),

            // ABOUT
            const _About(),


            // FOOTER
            const _Footer(),
          ],
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.label, required this.onPressed});
  final String label; final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [kEggYellow, kTomatoRed]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 6))],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        ),
      ),
    );
  }
}


class _Features extends StatelessWidget {
  const _Features();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    
    return Container(
      color: kCream, 
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: isMobile ? 40 : 48),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Column(children: [
          Text("How It Works",
              style: TextStyle(
                fontWeight: FontWeight.w800, 
                fontSize: isMobile ? 32 : 38, 
                color: kCharcoal
              )),
          const SizedBox(height: 6),
          Text("Three simple steps to culinary brilliance",
              style: TextStyle(
                color: Colors.black54, 
                fontSize: isMobile ? 16 : 18
              )),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16, runSpacing: 16, alignment: WrapAlignment.center,
            children: const [
              _FeatureCard(
                icon: Icons.camera_alt_outlined,
                title: "📸 Snap Your Fridge",
                text: "Take a photo. Our AI handles the rest—no typing.",
                border: kTomatoRed,
              ),
              _FeatureCard(
                icon: Icons.auto_awesome,
                title: "🤖 Instant Recipe Magic",
                text: "Personalized recipes in seconds. Zero guesswork.",
                border: kEggYellow,
              ),
              _FeatureCard(
                icon: Icons.recycling_outlined,
                title: "♻️ Save Food, Save Money",
                text: "Reduce waste and cook smarter every week.",
                border: kHerbGreen,
              ),
            ],
          ),
        ]),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.icon, required this.title, required this.text, required this.border});
  final IconData icon; final String title; final String text; final Color border;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: isMobile ? 300 : 340),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16 : 18),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: border.withValues(alpha: .25), width: 2),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 8))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: isMobile ? 40 : 44, 
            height: isMobile ? 40 : 44, 
            decoration: BoxDecoration(color: border, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: isMobile ? 20 : 24)
          ),
          SizedBox(height: isMobile ? 10 : 12),
          Text(title, style: TextStyle(
            fontWeight: FontWeight.w700, 
            fontSize: isMobile ? 18 : 20, 
            color: kCharcoal
          )),
          SizedBox(height: isMobile ? 6 : 8),
          Text(text, style: TextStyle(
            color: Colors.black54,
            fontSize: isMobile ? 14 : 16
          )),
        ]),
      ),
    );
  }
}

class _About extends StatelessWidget {
  const _About();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: isMobile 
          ? Column(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset('design/Assestss/2.webp', fit: BoxFit.cover, height: 280),
              ),
              const SizedBox(height: 24),
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Built for Real Kitchens, Not Just Recipes.",
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 28, color: kCharcoal)),
                SizedBox(height: 12),
                Text("We help you turn what you already have into meals you love—saving time, money, and the planet.",
                    style: TextStyle(color: Colors.black87, fontSize: 16)),
              ]),
            ])
          : Row(children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset('design/Assestss/2.webp', fit: BoxFit.cover, height: 360),
                ),
              ),
              const SizedBox(width: 24),
              const Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Built for Real Kitchens, Not Just Recipes.",
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 32, color: kCharcoal)),
                  SizedBox(height: 12),
                  Text("We help you turn what you already have into meals you love—saving time, money, and the planet.",
                      style: TextStyle(color: Colors.black87, fontSize: 16)),
                ]),
              ),
            ]),
      ),
    );
  }
}


class _Footer extends StatelessWidget {
  const _Footer();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    
    return Container(
      color: const Color(0xFF1F2A36),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: isMobile ? 32 : 48),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Column(
          children: [
            // Main footer content
            isMobile 
              ? Column(children: [
                  const Text(
                    "CookNUp",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "What's cookin'?",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Turn your fridge chaos into delicious meals — powered by AI.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Created for WashU Hackathon 2025",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "by Anthony Stewart, Elijah Brown, Navin Bhattarai, and Horlasy D.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ])
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "CookNUp",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "What's cookin'?",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Turn your fridge chaos into delicious meals — powered by AI.",
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            "Created for WashU Hackathon 2025",
                            textAlign: TextAlign.right,
                            style: TextStyle(color: Colors.white60, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "by Anthony Stewart, Elijah Brown,\nNavin Bhattarai, and Horlasy D.",
                            textAlign: TextAlign.right,
                            style: TextStyle(color: Colors.white60, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            const SizedBox(height: 24),
            const Divider(color: Colors.white30),
            const SizedBox(height: 16),
            const Text(
              "© 2025 CookNUp. All rights reserved.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
