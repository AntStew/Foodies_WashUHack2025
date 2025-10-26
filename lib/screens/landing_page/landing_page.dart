// lib/screens/landing_page/landing_page.dart
import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

/// Brand palette
const kTomatoRed = Color(0xFFE74C3C);
const kEggYellow = Color(0xFFF39C12);
const kHerbGreen = Color(0xFF27AE60);
const kCream     = Color(0xFFFFF8DC);
const kCharcoal  = Color(0xFF2C3E50);

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Full screen background
          Positioned.fill(
            child: Image.asset('design/background/delicious-lobster-gourmet-seafood.jpg', fit: BoxFit.cover),
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

          // Content with safe area
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Add top padding to avoid overlap with fixed header
                  const SizedBox(height: 100),
                  // HERO
                  SizedBox(
                    height: size.height * 0.9,
                    child: Center(
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
                                  Text.rich(
                                  TextSpan(children: [
                                    TextSpan(
                                      text: "Cook",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900, 
                                        color: kCharcoal,
                                        fontSize: size.width < 600 ? 56 : 84,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withValues(alpha: 0.3),
                                            offset: const Offset(3, 3),
                                            blurRadius: 6,
                                          ),
                                          Shadow(
                                            color: Colors.black.withValues(alpha: 0.1),
                                            offset: const Offset(6, 6),
                                            blurRadius: 12,
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextSpan(
                                      text: "N",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: size.width < 600 ? 56 : 84,
                                        foreground: Paint()
                                          ..shader = const LinearGradient(
                                            colors: [kTomatoRed, Color(0xFFE67E22)],
                                          ).createShader(const Rect.fromLTWH(0, 0, 300, 60)),
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withValues(alpha: 0.3),
                                            offset: const Offset(3, 3),
                                            blurRadius: 6,
                                          ),
                                          Shadow(
                                            color: Colors.black.withValues(alpha: 0.1),
                                            offset: const Offset(6, 6),
                                            blurRadius: 12,
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextSpan(
                                      text: "Up",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900, 
                                        color: kCharcoal,
                                        fontSize: size.width < 600 ? 56 : 84,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withValues(alpha: 0.3),
                                            offset: const Offset(3, 3),
                                            blurRadius: 6,
                                          ),
                                          Shadow(
                                            color: Colors.black.withValues(alpha: 0.1),
                                            offset: const Offset(6, 6),
                                            blurRadius: 12,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "What's cookin'?",
                                  textAlign: TextAlign.center, 
                                  style: TextStyle(color: Colors.black54, fontSize: 18, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Turn your fridge chaos into delicious meals — powered by AI.",
                                  textAlign: TextAlign.center, 
                                  style: TextStyle(color: Colors.black54, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
          ),

          // Fixed header with buttons - positioned last so it's on top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.transparent,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white, width: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          ),
                          child: const Text(
                            "Login",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        height: 56,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [kTomatoRed, kEggYellow]),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: ElevatedButton(
                            onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                            ),
                            child: const Text(
                              "Get Started",
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32, vertical: isMobile ? 40 : 60),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Column(
          children: [
            Text(
              "Why CookNUp?",
              style: TextStyle(
                fontSize: isMobile ? 28 : 36,
                fontWeight: FontWeight.w800,
                color: kCharcoal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "Turn your fridge chaos into delicious meals with AI-powered recipe suggestions",
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 32 : 48),
            Wrap(
              spacing: isMobile ? 16 : 24,
              runSpacing: isMobile ? 16 : 24,
              alignment: WrapAlignment.center,
              children: [
                const _FeatureCard(
                  icon: Icons.smart_toy,
                  title: "AI-Powered",
                  description: "Get personalized recipe suggestions based on your ingredients",
                  color: kTomatoRed,
                ),
                const _FeatureCard(
                  icon: Icons.inventory_2,
                  title: "Smart Inventory",
                  description: "Track your fridge contents and get expiration alerts",
                  color: kHerbGreen,
                ),
                const _FeatureCard(
                  icon: Icons.restaurant_menu,
                  title: "Recipe Variety",
                  description: "Discover new cuisines and cooking techniques",
                  color: kEggYellow,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    
    return Container(
      width: isMobile ? double.infinity : 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: kCharcoal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// ===================  CTA (full-bleed)  ===================
class _CtaTransform extends StatelessWidget {
  const _CtaTransform();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    
    return Container(
      color: const Color(0xFFF8F9FA),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32, vertical: isMobile ? 40 : 60),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Column(
          children: [
            Text(
              "About CookNUp",
              style: TextStyle(
                fontSize: isMobile ? 28 : 36,
                fontWeight: FontWeight.w800,
                color: kCharcoal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "CookNUp is your AI-powered kitchen companion that helps you make the most of what's in your fridge. No more wasted ingredients or boring meals!",
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 24 : 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isMobile) ...[
                  Expanded(
                    child: Image.asset(
                      'design/background/foodbg.jpg',
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _AboutItem(
                        icon: Icons.auto_awesome,
                        title: "AI Recipe Generation",
                        description: "Get personalized recipes based on your available ingredients",
                      ),
                      const SizedBox(height: 16),
                      const _AboutItem(
                        icon: Icons.timer,
                        title: "Quick & Easy",
                        description: "Find recipes that fit your time constraints and skill level",
                      ),
                      const SizedBox(height: 16),
                      const _AboutItem(
                        icon: Icons.eco,
                        title: "Reduce Waste",
                        description: "Use ingredients before they expire and reduce food waste",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutItem extends StatelessWidget {
  const _AboutItem({
    required this.icon,
    required this.title,
    required this.description,
  });
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kTomatoRed.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: kTomatoRed),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: kCharcoal,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FooterList extends StatelessWidget {
  const _FooterList({
    required this.title,
    required this.items,
    required this.headingStyle,
    required this.itemStyle,
  });

  final String title;
  final List<String> items;
  final TextStyle headingStyle;
  final TextStyle itemStyle;

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
            isMobile
              ? Column(children: [
                  const Text("CookNUp", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  const Text("What's cookin'?", style: TextStyle(color: Colors.white70, fontSize: 16, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 16),
                  const Text("Turn your fridge chaos into delicious meals — powered by AI.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 24),
                  const Text("Created for WashU Hackathon 2025", textAlign: TextAlign.center, style: TextStyle(color: Colors.white60, fontSize: 14)),
                  const SizedBox(height: 8),
                  const Text("by Anthony Stewart, Elijah Brown, Navin Bhattarai, and Horlasy D.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white60, fontSize: 12)),
                ])
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("CookNUp", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 8),
                          const Text("What's cookin'?", style: TextStyle(color: Colors.white70, fontSize: 18, fontStyle: FontStyle.italic)),
                          const SizedBox(height: 12),
                          const Text("Turn your fridge chaos into delicious meals — powered by AI.", style: TextStyle(color: Colors.white70, fontSize: 16)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("Created for WashU Hackathon 2025", textAlign: TextAlign.right, style: TextStyle(color: Colors.white60, fontSize: 16)),
                          const SizedBox(height: 8),
                          const Text("by Anthony Stewart, Elijah Brown,\nNavin Bhattarai, and Horlasy D.", textAlign: TextAlign.right, style: TextStyle(color: Colors.white60, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
            const SizedBox(height: 24),
            const Divider(color: Colors.white30),
            const SizedBox(height: 16),
            const Text("© 2025 CookNUp. All rights reserved.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white60, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}