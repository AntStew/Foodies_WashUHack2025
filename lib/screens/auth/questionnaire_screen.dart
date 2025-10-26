import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';

/// Local brand colors (self-contained; no external theme dependency)
const _kTomatoRed = Color(0xFFE74C3C);
const _kEggYellow = Color(0xFFF39C12);
const _kHerbGreen = Color(0xFF27AE60);
const _kCream     = Color(0xFFFFF8DC);
const _kCharcoal  = Color(0xFF2C3E50);

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  // Selections (same lists you already used, plus skill level)
  String? _skillLevel; // single-select
  final List<String> _selectedDietary  = [];
  final List<String> _selectedCuisines = [];
  final List<String> _selectedAllergies = [];

  // Keep serving size for compatibility with your existing Firestore call.
  final int _servingSize = 2;

  bool _isLoading = false;
  int _stepIndex = 0; // 0..3

  // Wizard content
  final List<_StepMeta> _steps = const [
    _StepMeta(
      title: "What's your cooking skill level?",
      subtitle: "Help us match recipes to your experience",
      keyName: 'skill',
    ),
    _StepMeta(
      title: "Any dietary preferences?",
      subtitle: "We'll personalize your recipe suggestions",
      keyName: 'diet',
    ),
    _StepMeta(
      title: "What cuisines do you enjoy?",
      subtitle: "Choose the flavors you love most",
      keyName: 'cuisine',
    ),
    _StepMeta(
      title: "Any ingredients you can't eat?",
      subtitle: "Your safety is our top priority",
      keyName: 'allergy',
    ),
  ];

  // Options (from Figma-like UI)
  final List<_CardOption> _skillOptions = const [
    _CardOption(emoji: "🌱", title: "Beginner",     subtitle: "I'm just starting my cooking journey"),
    _CardOption(emoji: "🧑‍🍳", title: "Intermediate", subtitle: "I'm comfortable with basic techniques"),
    _CardOption(emoji: "⭐",  title: "Advanced",     subtitle: "I love experimenting with complex recipes"),
    _CardOption(emoji: "🎓", title: "Professional", subtitle: "I have culinary training or work in food"),
  ];

  final List<_CardOption> _allergyOptions = const [
    _CardOption(emoji: "✅", title: "No Allergies",  subtitle: "I'm all good"),
    _CardOption(emoji: "🥜", title: "Tree Nuts/Peanuts", subtitle: "Includes almond, cashew, etc."),
    _CardOption(emoji: "🥛", title: "Dairy", subtitle: "Milk, cheese, butter"),
    _CardOption(emoji: "🦐", title: "Shellfish", subtitle: "Shrimp, crab, lobster"),
    _CardOption(emoji: "🥚", title: "Eggs", subtitle: "Eggs and egg products"),
    _CardOption(emoji: "🌶️", title: "Other", subtitle: "Let me specify"),
  ];

  Future<void> _submitQuestionnaire() async {
    setState(() => _isLoading = true);

    try {
      final user = _authService.currentUser;
      if (user != null) {
        // NOTE: Your FirestoreService signature expects (dietary, cuisines, allergies, servingSize).
        // We keep that to avoid breaking anything. (You can extend the service later to store _skillLevel too.)
        await _firestoreService.completeQuestionnaire(
          user.uid,
          _selectedDietary,
          _selectedCuisines,
          _selectedAllergies,
          _servingSize,
        );

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ----- Navigation -----
  bool get _isLastStep => _stepIndex == _steps.length - 1;

  void _next() {
    if (_isLastStep) {
      _submitQuestionnaire();
    } else {
      setState(() => _stepIndex++);
    }
  }

  void _back() {
    if (_stepIndex > 0) setState(() => _stepIndex--);
  }

  void _skip() {
    // Skip the wizard; go home (or you can route to /home later after onboarding)
    Navigator.pushReplacementNamed(context, '/home');
  }

  // Validation: disable Next when nothing chosen for the current step
  bool get _canProceed {
    switch (_stepIndex) {
      case 0: return _skillLevel != null;
      case 1: return _selectedDietary.isNotEmpty;
      case 2: return _selectedCuisines.isNotEmpty;
      case 3: return _selectedAllergies.isNotEmpty || true; // allow empty -> treated as none
      default: return true;
    }
  }

  // Progress 0..1
  double get _progress => (_stepIndex + 1) / _steps.length;

  @override
  Widget build(BuildContext context) {
    final step = _steps[_stepIndex];
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _kCream,
      body: SafeArea(
        child: Stack(
          children: [
            // Background (soft)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Color(0xFFFFFAF0), Color(0xFFFFF0DC)],
                  ),
                ),
              ),
            ),

            // Content
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top progress bar & labels
                      _ProgressHeader(
                        stepLabel: "Question ${_stepIndex + 1} of ${_steps.length}",
                        progress: _progress,
                        percentText:
                            "${(_progress * 100).toStringAsFixed(0)}% Complete",
                      ),
                      const SizedBox(height: 18),

                      // Title + subtitle (hero-ish)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          children: [
                            Text(
                              step.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w800,
                                fontSize: size.width < 600 ? 26 : 36,
                                color: _kCharcoal,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              step.subtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 26),

                      // Cards grid per step
                      _buildStepGrid(),
                    ],
                  ),
                ),
              ),
            ),

            // Sticky footer with Back / Skip / Next
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Color(0x1A000000), blurRadius: 14, offset: Offset(0, -6)),
                  ],
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Row(
                      children: [
                        _SoftButton(
                          icon: Icons.chevron_left,
                          label: 'Back',
                          onTap: _stepIndex == 0 ? null : _back,
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _skip,
                          child: const Text('Skip for now', style: TextStyle(color: Colors.black45)),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 160,
                          height: 48,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: _canProceed
                                  ? const LinearGradient(colors: [_kEggYellow, _kTomatoRed])
                                  : const LinearGradient(colors: [Color(0xFFE0E0E0), Color(0xFFCFCFCF)]),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: _canProceed
                                  ? const [BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 6))]
                                  : const [],
                            ),
                            child: ElevatedButton(
                              onPressed: (_isLoading || !_canProceed) ? null : _next,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20, height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(_isLastStep ? 'Start Finding Recipes' : 'Next',
                                            style: const TextStyle(fontWeight: FontWeight.w700)),
                                        const SizedBox(width: 6),
                                        const Icon(Icons.chevron_right, size: 20),
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
            ),
          ],
        ),
      ),
    );
  }

  // ===== Step content switcher =====
  Widget _buildStepGrid() {
    switch (_stepIndex) {
      case 0:
        return _ResponsiveGrid(
          children: _skillOptions.map((o) {
            final selected = _skillLevel == o.title;
            return _SelectCard(
              option: o,
              selected: selected,
              onTap: () => setState(() => _skillLevel = o.title),
              singleSelect: true,
            );
          }).toList(),
        );

      case 1:
        return _ResponsiveGrid(
          children: AppConstants.dietaryOptions.map((name) {
            final selected = _selectedDietary.contains(name);
            final o = _CardOption(emoji: "🥗", title: name, subtitle: "");
            return _SelectCard(
              option: o,
              selected: selected,
              onTap: () {
                setState(() {
                  selected ? _selectedDietary.remove(name) : _selectedDietary.add(name);
                });
              },
            );
          }).toList(),
        );

      case 2:
        return _ResponsiveGrid(
          children: AppConstants.cuisineOptions.map((name) {
            final selected = _selectedCuisines.contains(name);
            final o = _CardOption(emoji: "🍽️", title: name, subtitle: "");
            return _SelectCard(
              option: o,
              selected: selected,
              onTap: () {
                setState(() {
                  selected ? _selectedCuisines.remove(name) : _selectedCuisines.add(name);
                });
              },
            );
          }).toList(),
        );

      case 3:
      default:
        return _ResponsiveGrid(
          children: _allergyOptions.map((o) {
            final selected = _selectedAllergies.contains(o.title) ||
                (o.title == "No Allergies" && _selectedAllergies.isEmpty);
            return _SelectCard(
              option: o,
              selected: selected,
              onTap: () {
                setState(() {
                  if (o.title == "No Allergies") {
                    _selectedAllergies.clear();
                  } else {
                    selected ? _selectedAllergies.remove(o.title) : _selectedAllergies.add(o.title);
                  }
                });
              },
            );
          }).toList(),
        );
    }
  }
}

/* ===================== UI atoms/molecules ===================== */

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.stepLabel,
    required this.progress,
    required this.percentText,
  });

  final String stepLabel;
  final double progress;
  final String percentText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top thin progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Text(stepLabel, style: const TextStyle(color: Colors.black54)),
              const Spacer(),
              Text(percentText, style: const TextStyle(color: _kTomatoRed)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: const Color(0xFFE8E8E8),
            valueColor: const AlwaysStoppedAnimation<Color>(_kTomatoRed),
          ),
        ),
      ],
    );
  }
}

class _ResponsiveGrid extends StatelessWidget {
  const _ResponsiveGrid({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final isWide = c.maxWidth >= 900;
      final spacing = 16.0;

      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: children
            .map((w) => SizedBox(
                  width: isWide ? (c.maxWidth - spacing) / 2 : c.maxWidth,
                  child: w,
                ))
            .toList(),
      );
    });
  }
}

class _SelectCard extends StatelessWidget {
  const _SelectCard({
    required this.option,
    required this.selected,
    required this.onTap,
    this.singleSelect = false,
  });

  final _CardOption option;
  final bool selected;
  final VoidCallback onTap;
  final bool singleSelect;

  @override
  Widget build(BuildContext context) {
    final border = selected ? _kEggYellow : const Color(0x22000000);
    final bg     = selected ? const Color(0xFFFFF3E3) : Colors.white;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border, width: 2),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 8))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Row(
            children: [
              Text(option.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(option.title,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: _kCharcoal,
                        )),
                    if (option.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(option.subtitle, style: const TextStyle(color: Colors.black54)),
                    ],
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle, color: _kHerbGreen),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoftButton extends StatelessWidget {
  const _SoftButton({required this.icon, required this.label, this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x22000000)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.black87),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardOption {
  final String emoji;
  final String title;
  final String subtitle;
  const _CardOption({required this.emoji, required this.title, required this.subtitle});
}

class _StepMeta {
  final String title;
  final String subtitle;
  final String keyName;
  const _StepMeta({required this.title, required this.subtitle, required this.keyName});
}
