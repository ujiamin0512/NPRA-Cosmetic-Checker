import 'package:flutter/material.dart';

import '../databases/skin_profile.dart';
import 'dashboard.dart';

class SkinProfileWizard extends StatefulWidget {
  const SkinProfileWizard({super.key});

  @override
  State<SkinProfileWizard> createState() => _SkinProfileWizardState();
}

class _SkinProfileWizardState extends State<SkinProfileWizard> {
  final List<String> _availableSkinTypes = [
    'Dry', 'Oily', 'Sensitive', 'Combination'
  ];

  final List<String> _availableSkinConcerns = [
    'Acne / Pimples',
    'Blackheads & Whiteheads',
    'Cystic Acne',
    'Hyperpigmentation',
    'Dark Spots / Sun Spots',
    'Acne Scar',
    'Dullness',
    'Fine Lines & Wrinkles',
    'Loss of Firmness',
    'Dehydration',
    'Dryness / Flakiness',
    'Redness / Rosacea',
    'Enlarged Pores',
    'Excess Oiliness',
    'Dark Circles'
  ];

  final List<String> _selectedSkinTypes = [];
  final List<String> _selectedSkinConcerns = [];
  final TextEditingController _allergiesController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _allergiesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);

    final String allergiesText = _allergiesController.text.trim();
    List<String> allergiesList = [];
    if (allergiesText.isNotEmpty) {
      allergiesList = allergiesText.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }

    final String? errorMessage = await SkinProfileDatabase.updateSkinProfile(
      skinTypes: _selectedSkinTypes,
      skinConcerns: _selectedSkinConcerns,
      allergies: allergiesList,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (errorMessage == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const Dashboard(showProfileBanner: false)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: $errorMessage')),
        );
      }
    }
  }

  Future<void> _handleSkip() async {
    setState(() => _isSaving = true);
    await SkinProfileDatabase.incrementWizardSkipCount();
    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Dashboard(showProfileBanner: true)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Personalize Your Experience',
          style: TextStyle(color: Color(0xFF1D0CC2), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Help us provide better analysis by completing your skin profile.',
                style: TextStyle(fontSize: 16, color: Color(0xFF333752)),
              ),
              const SizedBox(height: 24),
              
              _buildSectionTitle('Skin Types'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableSkinTypes.map((type) {
                  final isSelected = _selectedSkinTypes.contains(type);
                  return FilterChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSkinTypes.add(type);
                        } else {
                          _selectedSkinTypes.remove(type);
                        }
                      });
                    },
                    selectedColor: const Color(0xFF1D0CC2).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF1D0CC2),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF1D0CC2) : const Color(0xFF8A8DA4),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              _buildSectionTitle('Skin Concerns'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableSkinConcerns.map((concern) {
                  final isSelected = _selectedSkinConcerns.contains(concern);
                  return FilterChip(
                    label: Text(concern),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSkinConcerns.add(concern);
                        } else {
                          _selectedSkinConcerns.remove(concern);
                        }
                      });
                    },
                    selectedColor: const Color(0xFF1D0CC2).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF1D0CC2),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF1D0CC2) : const Color(0xFF8A8DA4),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              _buildSectionTitle('Allergies'),
              const SizedBox(height: 8),
              const Text(
                'Enter any allergies separated by commas (e.g. Paraben, Fragrance)',
                style: TextStyle(fontSize: 13, color: Color(0xFF8A8DA4)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _allergiesController,
                decoration: InputDecoration(
                  hintText: 'Your allergies...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE4E6FF)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF1D0CC2), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),

              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D0CC2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _isSaving ? null : _handleSkip,
                  child: const Text(
                    'Skip this time',
                    style: TextStyle(
                      color: Color(0xFF8A8DA4),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1D0CC2),
      ),
    );
  }
}
