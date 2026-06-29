import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  final String initialName;
  final String initialHeight;
  final String initialWeight;
  final String initialAge;
  final String initialGoal;
  final List<String> initialEquipments;
  final String initialFitnessLevel;

  const EditProfileScreen({
    super.key,
    required this.initialName,
    required this.initialHeight,
    required this.initialWeight,
    required this.initialAge,
    required this.initialGoal,
    required this.initialEquipments,
    required this.initialFitnessLevel,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _ageController;

  String? _selectedGoal;
  String? _selectedFitnessLevel;

  final List<String> _selectedEquipments = [];

  final List<String> _allowedEquipmentsPool = [
    'Full Gym',
    'Barbell',
    'Dumbbell',
    'Cable',
    'Machine',
    'Bands',
    'Body Only',
  ];

  static const _textDark = Color(0xFF1A2E22);
  static const _headerGreen = Color(0xFF1E4030);
  static const _fieldBg = Color(0xFFEFF5F0);
  static const _labelGrey = Color(0xFF8A9E92);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _heightController = TextEditingController(text: widget.initialHeight);
    _weightController = TextEditingController(text: widget.initialWeight);
    _ageController = TextEditingController(text: widget.initialAge);

    _selectedGoal = widget.initialGoal;
    _selectedFitnessLevel = widget.initialFitnessLevel;

    // Gandakan data alat awal dari widget masuk ke state lokal
    _selectedEquipments.addAll(widget.initialEquipments);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _handleSaveChanges() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_selectedEquipments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select at least one equipment option (or Body Only)',
          ),
        ),
      );
      return;
    }

    final payload = {
      'name': _nameController.text.trim(),
      'age': int.tryParse(_ageController.text.trim()) ?? 0,
      'gender': authProvider.currentUser?.gender ?? 'Male',
      'height': double.tryParse(_heightController.text.trim()) ?? 0.0,
      'weight': double.tryParse(_weightController.text.trim()) ?? 0.0,
      'fitness_level': _selectedFitnessLevel,
      'gym_membership': authProvider.currentUser?.gymMembership ?? 'Yes',
      'goal': _selectedGoal,
      'equipments': _selectedEquipments,
    };

    final result = await authProvider.updateProfileData(payload);

    if (result['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Profile & Equipments successfully updated!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to update profile.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F2),
      appBar: AppBar(
        title: const Text(
          'Edit Information',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: _headerGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldLabel('FULL NAME'),
            _buildTextField(_nameController, TextInputType.name),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('HEIGHT (CM)'),
                      _buildTextField(_heightController, TextInputType.number),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('WEIGHT (KG)'),
                      _buildTextField(
                        _weightController,
                        const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildFieldLabel('AGE (YEARS)'),
            _buildTextField(_ageController, TextInputType.number),
            const SizedBox(height: 16),

            _buildFieldLabel('HEALTH GOAL'),
            DropdownButtonFormField<String>(
              value: _selectedGoal,
              decoration: _inputDecoration(),
              dropdownColor: Colors.white,
              items:
                  [
                        'Lose Weight',
                        'Build Muscle',
                        'Improve Endurance',
                        'Stay Active',
                      ]
                      .map(
                        (g) => DropdownMenuItem(
                          value: g,
                          child: Text(
                            g,
                            style: const TextStyle(color: _textDark),
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (val) => setState(() => _selectedGoal = val),
            ),
            const SizedBox(height: 16),

            _buildFieldLabel('EQUIPMENT ACCESS (SELECT MULTIPLE)'),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _allowedEquipmentsPool.map((equip) {
                bool isSelected = _selectedEquipments.contains(equip);
                return FilterChip(
                  label: Text(equip),
                  selected: isSelected,
                  selectedColor: const Color(0xFF2E6644),
                  checkmarkColor: Colors.white,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : _textDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.grey[300]!,
                    ),
                  ),
                  onSelected: (bool secure) {
                    setState(() {
                      if (secure) {
                        _selectedEquipments.add(equip);
                      } else {
                        _selectedEquipments.remove(equip);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            _buildFieldLabel('FITNESS LEVEL'),
            DropdownButtonFormField<String>(
              value: _selectedFitnessLevel,
              decoration: _inputDecoration(),
              dropdownColor: Colors.white,
              items: ['Beginner', 'Intermediate', 'Advanced']
                  .map(
                    (l) => DropdownMenuItem(
                      value: l,
                      child: Text(l, style: const TextStyle(color: _textDark)),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _selectedFitnessLevel = val),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: authProvider.isLoading ? null : _handleSaveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E6644),
                  disabledBackgroundColor: const Color(
                    0xFF2E6644,
                  ).withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: authProvider.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: _labelGrey,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, TextInputType type) {
    return TextField(
      controller: controller,
      keyboardType: type,
      style: const TextStyle(
        color: _textDark,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      decoration: _inputDecoration(),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: _fieldBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
