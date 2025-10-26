import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../models/user_model.dart';
import '../../../services/firestore_service.dart';

class PreferencesPanelWidget extends StatefulWidget {
  final UserModel userModel;

  const PreferencesPanelWidget({super.key, required this.userModel});

  @override
  State<PreferencesPanelWidget> createState() => _PreferencesPanelWidgetState();
}

class _PreferencesPanelWidgetState extends State<PreferencesPanelWidget> {
  final _firestoreService = FirestoreService();

  // Available options
  final List<String> _availableDietaryRestrictions = [
    'Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Dairy-Free',
    'Keto',
    'Paleo',
    'Low-Carb',
    'Halal',
    'Kosher',
  ];

  final List<String> _availableCuisines = [
    'Italian',
    'Mexican',
    'Chinese',
    'Japanese',
    'Indian',
    'Thai',
    'Mediterranean',
    'American',
    'French',
    'Korean',
    'Greek',
    'Spanish',
  ];

  void _showEditDialog(
    String title,
    List<String> currentValues,
    List<String> availableOptions,
    Function(List<String>) onSave,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        List<String> selectedValues = List.from(currentValues);
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: availableOptions.map((option) {
                    return CheckboxListTile(
                      title: Text(option),
                      value: selectedValues.contains(option),
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value == true) {
                            selectedValues.add(option);
                          } else {
                            selectedValues.remove(option);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    onSave(selectedValues);
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showTextInputDialog(
    String title,
    List<String> currentValues,
    Function(List<String>) onSave,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        List<String> values = List.from(currentValues);
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter allergy',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty && !values.contains(value)) {
                        setDialogState(() {
                          values.add(value);
                          controller.clear();
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: values
                        .map(
                          (allergy) => Chip(
                            label: Text(allergy),
                            onDeleted: () {
                              setDialogState(() {
                                values.remove(allergy);
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    onSave(values);
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showNameEditDialog() {
    final controller = TextEditingController(
      text: widget.userModel.displayName,
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Display Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter your display name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isNotEmpty &&
                    newName != widget.userModel.displayName) {
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    await _firestoreService.updateUserProfile(
                      widget.userModel.uid,
                      {'displayName': newName},
                    );
                    if (!mounted) return;
                    navigator.pop();
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Display name updated'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showServingSizeDialog() {
    int currentSize = widget.userModel.servingSize;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Default Serving Size'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Servings: $currentSize'),
                  Slider(
                    value: currentSize.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: currentSize.toString(),
                    onChanged: (value) {
                      setDialogState(() {
                        currentSize = value.toInt();
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    await _firestoreService.updateUserProfile(
                      widget.userModel.uid,
                      {'preferences.servingSize': currentSize},
                    );
                    if (!mounted) return;
                    navigator.pop();
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Serving size updated'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updatePreferences(String field, List<String> values) async {
    try {
      await _firestoreService.updateUserProfile(widget.userModel.uid, {
        'preferences.$field': values,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preferences updated'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 209, 38, 38),
                      Color.fromARGB(255, 255, 124, 30),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.settings, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    const Text(
                      'My Preferences',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: isMobile
                    ? _buildHorizontalScrollView()
                    : _buildVerticalScrollView(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVerticalScrollView() {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Info
          _buildClickableInfoCard(
            icon: Icons.person,
            title: widget.userModel.displayName,
            subtitle: widget.userModel.email,
            onTap: _showNameEditDialog,
          ),
          const SizedBox(height: 16),

          // Dietary Restrictions
          _buildPreferenceCard(
            icon: Icons.restaurant,
            title: 'Dietary Restrictions',
            values: widget.userModel.dietaryRestrictions,
            emptyMessage: 'No restrictions set',
            onTap: () => _showEditDialog(
              'Dietary Restrictions',
              widget.userModel.dietaryRestrictions,
              _availableDietaryRestrictions,
              (values) => _updatePreferences('dietaryRestrictions', values),
            ),
          ),
          const SizedBox(height: 12),

          // Cuisine Preferences
          _buildPreferenceCard(
            icon: Icons.public,
            title: 'Favorite Cuisines',
            values: widget.userModel.cuisinePreferences,
            emptyMessage: 'No preferences set',
            onTap: () => _showEditDialog(
              'Cuisine Preferences',
              widget.userModel.cuisinePreferences,
              _availableCuisines,
              (values) => _updatePreferences('cuisinePreferences', values),
            ),
          ),
          const SizedBox(height: 12),

          // Allergies
          _buildPreferenceCard(
            icon: Icons.warning,
            title: 'Allergies',
            values: widget.userModel.allergies,
            emptyMessage: 'No allergies set',
            onTap: () => _showTextInputDialog(
              'Allergies',
              widget.userModel.allergies,
              (values) => _updatePreferences('allergies', values),
            ),
          ),
          const SizedBox(height: 12),

          // Serving Size
          _buildClickableCard(
            icon: Icons.people,
            title: 'Default Serving Size',
            value: '${widget.userModel.servingSize} servings',
            onTap: _showServingSizeDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalScrollView() {
    final preferenceCards = [
      _buildCompactInfoCard(
        icon: Icons.person,
        title: widget.userModel.displayName,
        subtitle: widget.userModel.email,
        onTap: _showNameEditDialog,
      ),
      _buildCompactPreferenceCard(
        icon: Icons.restaurant,
        title: 'Diet',
        values: widget.userModel.dietaryRestrictions,
        emptyMessage: 'None',
        onTap: () => _showEditDialog(
          'Dietary Restrictions',
          widget.userModel.dietaryRestrictions,
          _availableDietaryRestrictions,
          (values) => _updatePreferences('dietaryRestrictions', values),
        ),
      ),
      _buildCompactPreferenceCard(
        icon: Icons.public,
        title: 'Cuisines',
        values: widget.userModel.cuisinePreferences,
        emptyMessage: 'None',
        onTap: () => _showEditDialog(
          'Cuisine Preferences',
          widget.userModel.cuisinePreferences,
          _availableCuisines,
          (values) => _updatePreferences('cuisinePreferences', values),
        ),
      ),
      _buildCompactPreferenceCard(
        icon: Icons.warning,
        title: 'Allergies',
        values: widget.userModel.allergies,
        emptyMessage: 'None',
        onTap: () => _showTextInputDialog(
          'Allergies',
          widget.userModel.allergies,
          (values) => _updatePreferences('allergies', values),
        ),
      ),
      _buildCompactValueCard(
        icon: Icons.people,
        title: 'Servings',
        value: '${widget.userModel.servingSize}',
        onTap: _showServingSizeDialog,
      ),
    ];

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        scrollDirection: Axis.horizontal,
        itemCount: preferenceCards.length,
        itemBuilder: (context, index) {
          return Container(
            width: 140,
            margin: EdgeInsets.only(
              right: index < preferenceCards.length - 1 ? 12 : 0,
            ),
            child: preferenceCards[index],
          );
        },
      ),
    );
  }

  Widget _buildClickableInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(// Optimized: removed BackdropFilter
          // Removed blur for performance
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.15),
                  Colors.white.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.blue, Colors.purple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.edit_rounded,
                  color: Colors.white.withValues(alpha: 0.6),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildPreferenceCard({
    required IconData icon,
    required String title,
    required List<String> values,
    required String emptyMessage,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(// Optimized: removed BackdropFilter
          // Removed blur for performance
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.15),
                  Colors.white.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.withValues(alpha: 0.8),
                        Colors.red.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      values.isEmpty
                          ? Text(
                              emptyMessage,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 14,
                              ),
                            )
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: values
                                  .map(
                                    (value) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        value,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                    ],
                  ),
                ),
                Icon(
                  Icons.edit_rounded,
                  color: Colors.white.withValues(alpha: 0.6),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClickableCard({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(// Optimized: removed BackdropFilter
          // Removed blur for performance
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.15),
                  Colors.white.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.green, Colors.teal],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.edit_rounded,
                  color: Colors.white.withValues(alpha: 0.6),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Compact card builders for mobile horizontal layout
  Widget _buildCompactInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(// Optimized: removed BackdropFilter
          // Removed blur for performance
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.blue, Colors.purple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.edit_rounded,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactPreferenceCard({
    required IconData icon,
    required String title,
    required List<String> values,
    required String emptyMessage,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(// Optimized: removed BackdropFilter
          // Removed blur for performance
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.withValues(alpha: 0.8),
                        Colors.red.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: values.isEmpty
                      ? Text(
                          emptyMessage,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            values.length == 1
                                ? values[0]
                                : '${values.length} items',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.edit_rounded,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactValueCard({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(// Optimized: removed BackdropFilter
          // Removed blur for performance
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green, Colors.teal],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.edit_rounded,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
