import 'package:flutter/material.dart';
import 'dart:ui';

enum MealType {
  breakfast,
  lunch,
  dinner,
}

class RecipeGenerationForm extends StatefulWidget {
  final Function(String context, MealType mealType) onFormSubmit;
  final String? initialContext;
  final MealType? initialMealType;

  const RecipeGenerationForm({
    super.key,
    required this.onFormSubmit,
    this.initialContext,
    this.initialMealType,
  });

  @override
  State<RecipeGenerationForm> createState() => _RecipeGenerationFormState();
}

class _RecipeGenerationFormState extends State<RecipeGenerationForm> {
  late final TextEditingController _contextController;
  late MealType _selectedMealType;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _contextController = TextEditingController(text: widget.initialContext ?? '');
    _selectedMealType = widget.initialMealType ?? MealType.dinner;
  }

  @override
  void dispose() {
    _contextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    
    return Container(
      padding: EdgeInsets.all(isDesktop ? 40 : 24),
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 600 : double.infinity,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Padding(
                padding: EdgeInsets.all(isDesktop ? 40 : 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        'Generate Your Perfect Recipe',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isDesktop ? 32 : 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tell us more about what you\'re craving',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isDesktop ? 18 : 16,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      SizedBox(height: isDesktop ? 40 : 32),

                      // Meal Type Selector
                      _buildMealTypeSelector(isDesktop),
                      SizedBox(height: isDesktop ? 28 : 24),

                      // Context Input
                      _buildContextInput(isDesktop),
                      SizedBox(height: isDesktop ? 36 : 32),

                      // Generate Button
                      _buildGenerateButton(isDesktop),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMealTypeSelector(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meal Type',
          style: TextStyle(
            fontSize: isDesktop ? 20 : 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: MealType.values.map((mealType) {
                final isSelected = _selectedMealType == mealType;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMealType = mealType;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        vertical: isDesktop ? 16 : 12,
                        horizontal: isDesktop ? 20 : 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  Colors.orange.shade400,
                                  Colors.orange.shade600,
                                ],
                              )
                            : null,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.orange.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        _getMealTypeLabel(mealType),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isDesktop ? 16 : 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContextInput(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Context (Optional)',
          style: TextStyle(
            fontSize: isDesktop ? 20 : 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: _contextController,
            maxLines: isDesktop ? 4 : 3,
            maxLength: 500,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'e.g., "I want something spicy", "Looking for comfort food", "Need something quick and easy"',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(isDesktop ? 20 : 16),
              counterStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateButton(bool isDesktop) {
    return SizedBox(
      width: isDesktop ? 300 : double.infinity,
      child: Container(
        height: isDesktop ? 64 : 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade400, Colors.orange.shade700],
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _handleGenerate,
            borderRadius: BorderRadius.circular(32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Generate Recipe',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 18 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getMealTypeLabel(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
    }
  }

  void _handleGenerate() {
    if (_formKey.currentState!.validate()) {
      widget.onFormSubmit(_contextController.text.trim(), _selectedMealType);
    }
  }
}
