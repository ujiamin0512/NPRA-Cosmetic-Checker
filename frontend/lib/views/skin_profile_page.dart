import 'package:flutter/material.dart';

import '../databases/skin_profile.dart';
import '../databases/user_db.dart';
import '../models/user.dart';

class SkinProfilePage extends StatefulWidget {
  final bool isStandalone;
  const SkinProfilePage({super.key, this.isStandalone = false});

  @override
  State<SkinProfilePage> createState() => _SkinProfilePageState();
}

class _SkinProfilePageState extends State<SkinProfilePage> {
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

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final String? currentId = UserDatabase.currentUserId;
    if (currentId != null) {
      // 1. Fast load from local SQLite
      final User? localUser = await UserDatabase.getUserLocal(currentId);
      if (mounted && localUser != null) {
        setState(() {
          if (localUser.skinProfile.profileCompleted) {
            _selectedSkinTypes.clear();
            _selectedSkinConcerns.clear();
            _selectedSkinTypes.addAll(localUser.skinProfile.skinTypes);
            _selectedSkinConcerns.addAll(localUser.skinProfile.skinConcerns);
            _allergiesController.text = localUser.skinProfile.allergies.join(', ');
          }
          _isLoading = false;
        });
      }
    }

    // 2. Silent background fetch from Supabase
    final User? remoteUser = await UserDatabase.getCurrentUser();
    if (mounted && remoteUser != null) {
      setState(() {
        if (remoteUser.skinProfile.profileCompleted) {
          _selectedSkinTypes.clear();
          _selectedSkinConcerns.clear();
          _selectedSkinTypes.addAll(remoteUser.skinProfile.skinTypes);
          _selectedSkinConcerns.addAll(remoteUser.skinProfile.skinConcerns);
          _allergiesController.text = remoteUser.skinProfile.allergies.join(', ');
        }
        _isLoading = false;
      });
    } else if (mounted && _isLoading) {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Skin profile updated successfully')),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $errorMessage'), duration: const Duration(seconds: 5)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget content = SafeArea(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        selectedColor: const Color(0xFF1D0CC2).withValues(alpha: 0.2),
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
                        selectedColor: const Color(0xFF1D0CC2).withValues(alpha: 0.2),
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
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );

    if (widget.isStandalone) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Skin Profile',
            style: TextStyle(color: Color(0xFF1D0CC2), fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFF1D0CC2)),
        ),
        body: content,
      );
    }

    return content;
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
