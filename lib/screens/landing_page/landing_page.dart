// lib/screens/landing_page/landing_page.dart
import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

/// Brand palette
const kTomatoRed = Color(0xFFE74C3C);
const kEggYellow = Color(0xFFF39C12);
const kHerbGreen = Color(0xFF27AE60);
const kCream     = Color(0xFFFFF8DC);
const kCharcoal  = Color(0xFF2C3E50);

/// Shared section padding (uniform everywhere)
const kSectionPad = EdgeInsets.symmetric(horizontal: 24, vertical: 56);

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _whySectionKey = GlobalKey();
  final GlobalKey _howItWorksSectionKey = GlobalKey();
  final GlobalKey _reviewsSectionKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(GlobalKey key) {
    final RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero).dy;
    final scrollPosition = position - 100; // Offset for app bar height
    
    _scrollController.animateTo(
      scrollPosition,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      // IMPORTANT: body is NOT behind the app bar anymore
      extendBodyBehindAppBar: false,
      appBar: _TopBar(
        onWhyPressed: () => _scrollToSection(_whySectionKey),
        onHowItWorksPressed: () => _scrollToSection(_howItWorksSectionKey),
        onReviewsPressed: () => _scrollToSection(_reviewsSectionKey),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            const _HeroSplit(),
            _WhyCookNUp(key: _whySectionKey),
            _FeaturesWithImages(key: _howItWorksSectionKey),
            _Reviews(key: _reviewsSectionKey),
            const _CtaTransform(),
            const _FooterColumns(),
          ],
        ),
      ),
    );
  }
}

/// ===================  Top Navigation Bar  ===================
/// Semi-opaque background so text is readable over any content.
/// Sits above the hero now (no overlap).
class _TopBar extends StatelessWidget implements PreferredSizeWidget {
  const _TopBar({
    required this.onWhyPressed,
    required this.onHowItWorksPressed,
    required this.onReviewsPressed,
  });

  final VoidCallback onWhyPressed;
  final VoidCallback onHowItWorksPressed;
  final VoidCallback onReviewsPressed;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 6,
      centerTitle: false,
      backgroundColor: const Color(0xF21F2A36), // ~95% opaque dark blue-gray
      // If you prefer slightly lighter: const Color(0xE61F2A36)
      shadowColor: Colors.black.withOpacity(0.25),
      titleSpacing: 8,
      title: Row(
        children: [
          Image.asset(
            'design/Assestss/CookNUpLogoNoBGNoText.png',
            height: 28,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 10),
          const Text(
            'COOKNUP',
            style: TextStyle(
              color: Colors.white,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
      actions: [
        _TopLink(label: 'Why', onPressed: onWhyPressed),
        _TopLink(label: 'How it works', onPressed: onHowItWorksPressed),
        _TopLink(label: 'Reviews', onPressed: onReviewsPressed),
        const SizedBox(width: 8),
        // Login
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white, width: 2),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            icon: const Icon(Icons.login_rounded, size: 18),
            label: const Text('Login', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(width: 10),
        // Sign Up
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [kTomatoRed, kEggYellow]),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 18, color: Colors.white),
              label: const Text(
                'Sign Up',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TopLink extends StatelessWidget {
  const _TopLink({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Center(
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
            ),
          ),
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
      // slightly shorter so the down arrow is visible on first paint
      height: (size.height * .88).clamp(560, 720),
      child: Stack(
        children: [
          // Food background
          Positioned.fill(
            child: Image.asset(
              'design/Assestss/2.webp',
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
                                    'design/Assestss/LOGO-removebg-preview (1).png',
                                    height: 280,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.restaurant_menu_rounded, size: 200, color: kTomatoRed),
                                  ),
                                ),
                                const SizedBox(height: 32),
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
                                  height: 56, 
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: kCharcoal, width: 2),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isMobile ? 16 : 20,
                                        vertical: 12,
                                      ),
                                    ),
                                    child: Text(
                                      isMobile ? 'Already a Chef? Log In' : 'Already a Chef? Log In',
                                      style: TextStyle(
                                        color: kCharcoal, 
                                        fontWeight: FontWeight.w600,
                                        fontSize: isMobile ? 15 : 16,
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

                    // RIGHT: one fridge photo + static AI badge
                    if (!isMobile)
                      Expanded(
                        flex: 45,
                        child: Padding(
                          // keep horizontal left spacing but reduce vertical padding
                          padding: const EdgeInsets.only(left: 18, top: 12, bottom: 12),
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
    final isMobile = MediaQuery.of(context).size.width < 600;
    final buttonText = isMobile ? "Start Cooking" : label;
    
    return SizedBox(
      height: 56, 
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [kEggYellow, kTomatoRed]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 6))],
        ),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent, 
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            foregroundColor: Colors.white, 
            textStyle: TextStyle(
              fontWeight: FontWeight.w700, 
              fontSize: isMobile ? 15 : 16,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 20,
              vertical: 12,
            ),
          ),
          icon: icon != null ? Icon(icon, size: isMobile ? 20 : 22) : const SizedBox.shrink(),
          label: Text(buttonText),
        ),
      ),
    );
  }
}

/// ===================  Why CookNUp?  ===================
class _WhyCookNUp extends StatelessWidget {
  const _WhyCookNUp({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: kSectionPad,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const Text(
                "Why CookNUp?",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 40, color: kCharcoal),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                "Make the most of what’s already in your kitchen with less waste, less stress, and more flavor.",
                style: TextStyle(color: Colors.black54, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 18,
                runSpacing: 18,
                alignment: WrapAlignment.center,
                children: const [
                  _ValueCard(
                    icon: Icons.auto_awesome_rounded,
                    title: "Personalized by AI",
                    text: "Your ingredients, your tastes — tailored recipes in seconds.",
                    color: kEggYellow,
                  ),
                  _ValueCard(
                    icon: Icons.timer_rounded,
                    title: "Fast & Easy",
                    text: "Pick time and skill level, we’ll fit recipes to your day.",
                    color: kTomatoRed,
                  ),
                  _ValueCard(
                    icon: Icons.eco_rounded,
                    title: "Waste Less, Save More",
                    text: "Use what you have before it expires and cut grocery costs.",
                    color: kHerbGreen,
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

class _ValueCard extends StatelessWidget {
  const _ValueCard({
    required this.icon,
    required this.title,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(.25), width: 2),
          boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(backgroundColor: color, radius: 22, child: Icon(icon, color: Colors.white)),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: kCharcoal)),
            const SizedBox(height: 6),
            Text(text, style: const TextStyle(color: Colors.black87, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

/// ===================  How It Works (image cards)  ===================
class _FeaturesWithImages extends StatelessWidget {
  const _FeaturesWithImages({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kCream,
      padding: kSectionPad,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("How It Works",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 40, color: kCharcoal)),
              const SizedBox(height: 8),
              const Text("Three simple steps to culinary brilliance",
                  style: TextStyle(color: Colors.black54, fontSize: 18), textAlign: TextAlign.center),
              const SizedBox(height: 26),
              Wrap(
                spacing: 22, runSpacing: 22, alignment: WrapAlignment.center,
                children: const [
                  _ImageFeatureCard(
                    imagePath: 'design/Assestss/6.jpeg',
                    badgeColor: kTomatoRed,
                    badgeIcon: Icons.photo_camera_outlined,
                    title: 'Snap Your Fridge',
                    text: 'Just take a photo. Our AI does the rest. No typing, no lists, no hassle.',
                    borderColor: kTomatoRed,
                  ),
                  _ImageFeatureCard(
                    imagePath: 'design/Assestss/7.jpeg',
                    badgeColor: kEggYellow,
                    badgeIcon: Icons.auto_awesome_rounded,
                    title: 'Instant Recipe Magic',
                    text: 'Get personalized recipes in seconds, not hours. AI-powered culinary genius.',
                    borderColor: kEggYellow,
                  ),
                  _ImageFeatureCard(
                    imagePath: 'design/Assestss/8.jpg',
                    badgeColor: kHerbGreen,
                    badgeIcon: Icons.recycling_rounded,
                    title: 'Save Time, Save Money',
                    text: 'Cook smarter and faster. Enjoy delicious homemade meals.',
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

/// ===================  Reviews  ===================
class _Reviews extends StatelessWidget {
  const _Reviews({super.key});

  @override
  Widget build(BuildContext context) {
    final reviews = const [
      ["Navin Bhattarai", "Saved my weeknights! The AI actually matches what’s in my fridge."],
      ["Elijah Brown", "Fast, tasty suggestions. I’m cooking more and wasting less."],
      ["Anthony Stewart", "Took a photo, got dinner ideas in seconds. Super clean UI too."],
    ];

    return Container(
      color: Colors.white,
      padding: kSectionPad,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "What People Say",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 40,
                  color: kCharcoal,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 18,
                runSpacing: 18,
                alignment: WrapAlignment.center,
                children: reviews.map((r) {
                  return ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // ★★★★★ Stars Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                5,
                                (index) => const Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Review Text
                            Text(
                              r[1],
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.black87, fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            // Reviewer Name
                            Text(
                              "— ${r[0]}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontStyle: FontStyle.italic,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
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
                "Join fellow home chefs cooking smarter, not harder",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
              const SizedBox(height: 26),
              SizedBox(
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: kTomatoRed,
                    elevation: 8,
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width < 600 ? 20 : 26,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: Icon(
                    Icons.rocket_launch_rounded,
                    size: MediaQuery.of(context).size.width < 600 ? 20 : 24,
                  ),
                  label: Text(
                    MediaQuery.of(context).size.width < 600 ? "Get Started" : "Get Started Free",
                    style: TextStyle(
                      fontWeight: FontWeight.w800, 
                      fontSize: MediaQuery.of(context).size.width < 600 ? 16 : 18,
                    ),
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

/// ===================  Footer (columns)  ===================
class _FooterColumns extends StatelessWidget {
  const _FooterColumns();

  @override
  Widget build(BuildContext context) {
    const heading = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      fontSize: 16,
    );
    const link = TextStyle(
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
                children: const [
                  _FooterCol(
                    width: 280,
                    title: "COOKNUP",
                    body: Text(
                      "Making home cooking easy, sustainable, and delicious.",
                      style: TextStyle(color: Colors.white70),
                    ),
                    headingStyle: heading,
                  ),
                  _FooterList(
                    title: "Product",
                    items: ["Features", "How It Works", "Pricing"],
                    headingStyle: heading,
                    itemStyle: link,
                  ),
                  _FooterList(
                    title: "Company",
                    items: ["About", "Blog", "Contact"],
                    headingStyle: heading,
                    itemStyle: link,
                  ),
                  _FooterCol(
                    title: "Credits",
                    headingStyle: heading,
                    body: _CreditsRight(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.white12),
              const SizedBox(height: 10),
              const Text(
                "© 2025 COOKNUP. All rights reserved.",
                style: TextStyle(color: Colors.white60),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreditsRight extends StatelessWidget {
  const _CreditsRight();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.end, // right-align column to match textAlign
      children: [
        Text(
          "Created for WashU Hackathon 2025",
          textAlign: TextAlign.left,
          style: TextStyle(color: Colors.white60, fontSize: 16),
        ),
        SizedBox(height: 8),
        // Two names per line, simple and clean
        Text(
          "Anthony Stewart , Elijah Brown\nNavin Bhattarai & Horlasy D.",
          textAlign: TextAlign.left,
          style: TextStyle(color: Colors.white60, fontSize: 14, height: 1.35),
        ),
      ],
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

