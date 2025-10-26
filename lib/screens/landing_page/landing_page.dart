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
                                    text: "What's For\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800, color: kCharcoal,
                                      fontSize: size.width < 600 ? 42 : 64,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Dinner?",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: size.width < 600 ? 42 : 64,
                                      foreground: Paint()
                                        ..shader = const LinearGradient(
                                          colors: [kTomatoRed, Color(0xFFE67E22)],
                                        ).createShader(const Rect.fromLTWH(0, 0, 300, 60)),
                                    ),
                                  ),
                                ]),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Turn your fridge chaos into delicious meals — powered by AI.",
                                textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 18),
                              ),
                              const SizedBox(height: 24),
                              Wrap(
                                alignment: WrapAlignment.center, spacing: 12, runSpacing: 12,
                                children: [
                                  _GradientButton(
                                    label: "🍳 Start Cooking Smart",
                                    onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
                                  ),
                                  OutlinedButton(
                                    onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: kCharcoal, width: 2),
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    ),
                                    child: const Text("Already a Chef? Log In",
                                      style: TextStyle(color: kCharcoal, fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Wrap(
                                spacing: 16, runSpacing: 16,
                                children: const [
                                  _StatPill(color: kTomatoRed, value: "12K+", label: "Active Users"),
                                  _StatPill(color: Color(0xFFE67E22), value: "50K+", label: "Recipes"),
                                  _StatPill(color: kHerbGreen, value: "\$1.5K", label: "Avg. Saved"),
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

            // REVIEWS
            const _Reviews(),

            // CTA STRIP
            const _CtaStrip(),

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

class _StatPill extends StatelessWidget {
  const _StatPill({required this.color, required this.value, required this.label});
  final Color color; final String value; final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.black54)),
      ]),
    );
  }
}

class _Features extends StatelessWidget {
  const _Features();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: kCream, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Column(children: [
          const Text("How It Works",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 38, color: kCharcoal)),
          const SizedBox(height: 6),
          const Text("Three simple steps to culinary brilliance",
              style: TextStyle(color: Colors.black54, fontSize: 18)),
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
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: border.withValues(alpha: .25), width: 2),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 8))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: border, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white)),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: kCharcoal)),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(color: Colors.black54)),
        ]),
      ),
    );
  }
}

class _About extends StatelessWidget {
  const _About();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Row(children: [
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
              SizedBox(height: 8),
              Text("Created at WashU Hackathon with ❤️ for practical cooking.",
                  style: TextStyle(color: Colors.black54)),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Reviews extends StatelessWidget {
  const _Reviews();
  @override
  Widget build(BuildContext context) {
    final reviews = [
      ["Saved my weeknights!", "No more 6pm panic. The recipes actually match my fridge.", "— Taylor S."],
      ["Tastes + Savings", "I save ~\$20/week by using stuff I would've thrown out.", "— Jordan M."],
      ["So easy", "Snapped a photo, got dinner ideas in seconds. Wild.", "— Priya K."],
    ];
    return Container(
      color: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Column(children: [
          const Text("What People Say",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 34, color: kCharcoal)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16, runSpacing: 16, alignment: WrapAlignment.center,
            children: reviews.map((r) => _ReviewCard(title: r[0], body: r[1], author: r[2])).toList(),
          ),
        ]),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.title, required this.body, required this.author});
  final String title; final String body; final String author;
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: kCharcoal)),
            const SizedBox(height: 8),
            Text(body, style: const TextStyle(color: Colors.black87)),
            const SizedBox(height: 10),
            Text(author, style: const TextStyle(color: Colors.black54, fontStyle: FontStyle.italic)),
          ]),
        ),
      ),
    );
  }
}

class _CtaStrip extends StatelessWidget {
  const _CtaStrip();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 42),
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [kEggYellow, kTomatoRed])),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Column(children: [
          const Text("Ready to cook smarter?",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 28)),
          const SizedBox(height: 12),
          Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, foregroundColor: kTomatoRed,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Create your free account"),
            ),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white, width: 2), foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Log in"),
            ),
          ]),
        ]),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1F2A36),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: const Text(
        "© 2025 What's For Dinner? | Made with ❤️ at WashU Hackathon",
        textAlign: TextAlign.center, style: TextStyle(color: Colors.white70),
      ),
    );
  }
}
