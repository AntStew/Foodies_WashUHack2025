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
      body: SingleChildScrollView(
        child: Column(
          children: const [
            _HeroSplit(),
            _FeaturesWithImages(),
            _CtaTransform(),
            _FooterColumns(),
          ],
        ),
      ),
    );
  }
}

/// ===================  HERO (split)  ===================
class _HeroSplit extends StatelessWidget {
  const _HeroSplit();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 950;

    return SizedBox(
      height: size.height * 1.05,
      child: Stack(
        children: [
          // Food background
          Positioned.fill(
            child: Image.asset(
              'design/Assestss/1.jpeg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: const Color(0xFFFAEBD7)),
            ),
          ),
          // Darkening overlay
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Color(0xAA000000), Color(0x55000000)],
                ),
              ),
            ),
          ),

          // Content
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // LEFT: Logo + copy + CTAs
                    Expanded(
                      flex: isMobile ? 100 : 55,
                      child: Padding(
                        padding: EdgeInsets.only(right: isMobile ? 0 : 18, bottom: isMobile ? 20 : 0),
                        child: Card(
                          elevation: 20,
                          color: Colors.white.withOpacity(.97),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Big logo (no name text)
                                Center(
                                  child: Image.asset(
                                    'design/Assestss/LOGO.png',
                                    height: 190, // larger icon as requested
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.restaurant_menu_rounded, size: 150, color: kTomatoRed),
                                  ),
                                ),
                                const SizedBox(height: 22),
                                // Sub-headline @ ~75%
                                const Text.rich(
                                  TextSpan(children: [
                                    TextSpan(text: "What's For ", style: TextStyle(
                                      fontWeight: FontWeight.w800, fontSize: 30, color: kCharcoal)),
                                    TextSpan(text: "Dinner?", style: TextStyle(
                                      fontWeight: FontWeight.w800, fontSize: 30, color: kTomatoRed)),
                                  ]),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "Turn your fridge chaos into delicious meals — powered by AI.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "No more food waste. No more 6pm panic. Just good food.",
                                  textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 15),
                                ),
                                const SizedBox(height: 32),
                                _GradientButton(
                                  label: "Start Cooking Smart",
                                  icon: Icons.search_rounded,
                                  onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  height: 56, width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: kCharcoal, width: 2),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    ),
                                    child: const Text(
                                      'Already a Chef? Log In',
                                      style: TextStyle(color: kCharcoal, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // RIGHT: one fridge photo + static AI badge
                    if (!isMobile)
                      Expanded(
                        flex: 45,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 18),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.asset(
                                    'design/Assestss/1.jpeg',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: Colors.black12,
                                      alignment: Alignment.center,
                                      child: const Icon(Icons.kitchen_outlined, size: 72, color: Colors.white54),
                                    ),
                                  ),
                                ),
                                const _AiBadgeStatic(),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Scroll hint (chevron)
          const Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: _ScrollHint(),
          ),
        ],
      ),
    );
  }
}

class _AiBadgeStatic extends StatelessWidget {
  const _AiBadgeStatic();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16, right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: const [
          Icon(Icons.bolt_rounded, color: kEggYellow, size: 20),
          SizedBox(width: 8),
          Text('AI Analyzing… 23 ingredients found', style: TextStyle(fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

class _ScrollHint extends StatelessWidget {
  const _ScrollHint();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 34),
        Text('Scroll', style: TextStyle(color: Colors.white70)),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.label, required this.onPressed, this.icon});
  final String label; final IconData? icon; final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56, width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [kEggYellow, kTomatoRed]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 6))],
        ),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            foregroundColor: Colors.white, textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          icon: icon != null ? Icon(icon, size: 22) : const SizedBox.shrink(),
          label: Text(label),
        ),
      ),
    );
  }
}

/// ===================  How It Works (image cards)  ===================
class _FeaturesWithImages extends StatelessWidget {
  const _FeaturesWithImages();

  @override
  Widget build(BuildContext context) {
    const titleStyle = TextStyle(fontWeight: FontWeight.w800, fontSize: 44, color: kCharcoal);
    const subtitleStyle = TextStyle(color: Colors.black54, fontSize: 20);

    return Container(
      color: kCream,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("How It Works", style: titleStyle),
              const SizedBox(height: 8),
              const Text("Three simple steps to culinary brilliance",
                  style: subtitleStyle, textAlign: TextAlign.center),
              const SizedBox(height: 26),
              Wrap(
                spacing: 22, runSpacing: 22, alignment: WrapAlignment.center,
                children: const [
                  _ImageFeatureCard(
                    imagePath: 'design/Assestss/2.jpg', // swap as you like
                    badgeColor: kTomatoRed,
                    badgeIcon: Icons.photo_camera_outlined,
                    title: 'Snap Your Fridge',
                    text: 'Just take a photo. Our AI does the rest. No typing, no lists, no hassle.',
                    borderColor: kTomatoRed,
                  ),
                  _ImageFeatureCard(
                    imagePath: 'design/Assestss/3.jpg',
                    badgeColor: kEggYellow,
                    badgeIcon: Icons.auto_awesome_rounded,
                    title: 'Instant Recipe Magic',
                    text: 'Get personalized recipes in seconds, not hours. AI-powered culinary genius.',
                    borderColor: kEggYellow,
                  ),
                  _ImageFeatureCard(
                    imagePath: 'design/Assestss/4.jpg',
                    badgeColor: kHerbGreen,
                    badgeIcon: Icons.recycling_rounded,
                    title: 'Save Food, Save Money',
                    text: 'Use what you have. Waste less. Cook smarter, faster.',
                    borderColor: kHerbGreen,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageFeatureCard extends StatelessWidget {
  const _ImageFeatureCard({
    required this.imagePath,
    required this.badgeColor,
    required this.badgeIcon,
    required this.title,
    required this.text,
    required this.borderColor,
  });

  final String imagePath;
  final Color badgeColor;
  final IconData badgeIcon;
  final String title;
  final String text;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor.withOpacity(.35), width: 2),
          boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image header
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.black12,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_outlined, size: 56, color: Colors.white70),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    bottom: 14,
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
                      child: Icon(badgeIcon, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: kCharcoal)),
                  const SizedBox(height: 8),
                  Text(text, style: const TextStyle(color: Colors.black87, fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===================  CTA (full-bleed)  ===================
class _CtaTransform extends StatelessWidget {
  const _CtaTransform();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 72),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF2994A), kTomatoRed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              const Text(
                "Ready to Transform Your Kitchen?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontSize: 44,
                  letterSpacing: .2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Join thousands of home chefs cooking smarter, not harder",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
              const SizedBox(height: 26),
              // Big pill CTA
              SizedBox(
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: kTomatoRed,
                    elevation: 8,
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.rocket_launch_rounded),
                  label: const Text(
                    "Get Started Free",
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "No credit card required • 100% free to start",
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===================  Footer (columns, non-functional)  ===================
class _FooterColumns extends StatelessWidget {
  const _FooterColumns();

  @override
  Widget build(BuildContext context) {
    final heading = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      fontSize: 16,
    );
    final link = TextStyle(
      color: Colors.white70,
      fontSize: 14,
    );

    return Container(
      width: double.infinity,
      color: const Color(0xFF1F2A36),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // Columns
              Wrap(
                spacing: 40,
                runSpacing: 24,
                children: [
                  _FooterCol(
                    width: 280,
                    title: "COOKNUP",
                    headingStyle: heading,
                    body: const Text(
                     """Whats Cookin'? You Decide.
Making home cooking easy, sustainable, and delicious.""",
                  style: TextStyle(color: Colors.white70),
                  ),

                  ),
                  _FooterList(
                    title: "Product",
                    items: const ["Features", "How It Works", "Pricing"],
                    headingStyle: heading,
                    itemStyle: link,
                  ),
                  _FooterList(
                    title: "Company",
                    items: const ["About", "Blog", "Contact"],
                    headingStyle: heading,
                    itemStyle: link,
                  ),
                  _FooterList(
                    title: "Legal",
                    items: const ["Privacy", "Terms", "Cookies"],
                    headingStyle: heading,
                    itemStyle: link,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.white12),
              const SizedBox(height: 10),
              const Text(
                "© 2025 COOKNUP · Made with ❤️ by Anthony, Elijah, Navin and Horslay",
                style: TextStyle(color: Colors.white60),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterCol extends StatelessWidget {
  const _FooterCol({
    required this.title,
    required this.body,
    required this.headingStyle,
    this.width,
  });

  final String title;
  final Widget body;
  final TextStyle headingStyle;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: headingStyle),
          const SizedBox(height: 10),
          body,
        ],
      ),
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
    return _FooterCol(
      title: title,
      headingStyle: headingStyle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map((t) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(t, style: itemStyle),
                ))
            .toList(),
      ),
    );
  }
}
