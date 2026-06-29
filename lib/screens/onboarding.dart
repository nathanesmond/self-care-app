import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:self_care_app/auth/auth_provider.dart';
import 'mainlayout.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _headerGreen = Color(0xFF1E4030);
  static const _bodyBg = Color(0xFFF2F6F3);
  static const _buttonActiveGreen = Color(0xFF2E6644);
  static const _buttonDisabledSage = Color(0xFFCBDCD3);
  static const _textDark = Color(0xFF1A2E22);
  static const _labelGrey = Color(0xFF6B7F73);
  static const _accentGreen = Color(0xFF3D7A56);

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String? _selectedGender;

  String? _selectedFitnessLevel;
  String? _gymMembership;

  final List<String> _selectedEquipment = [];

  String? _selectedGoal;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  // --- VALIDATION LOGIC ---

  String? get _ageError {
    final text = _ageController.text.trim();
    if (text.isEmpty) return null; // Don't show error before they type
    final age = int.tryParse(text);
    if (age == null) return 'Invalid number';
    if (age < 12 || age > 100) return 'Must be 12 - 100';
    return null;
  }

  String? get _heightError {
    final text = _heightController.text.trim();
    if (text.isEmpty) return null;
    final height = double.tryParse(text);
    if (height == null) return 'Invalid number';
    if (height < 50 || height > 300) return 'Must be 50 - 300 cm';
    return null;
  }

  String? get _weightError {
    final text = _weightController.text.trim();
    if (text.isEmpty) return null;
    final weight = double.tryParse(text);
    if (weight == null) return 'Invalid number';
    if (weight < 20 || weight > 400) return 'Must be 20 - 400 kg';
    return null;
  }

  bool _isCurrentPageValid() {
    switch (_currentPage) {
      case 0:
        return _nameController.text.trim().isNotEmpty &&
            _ageController.text.trim().isNotEmpty &&
            _ageError == null && // Must pass validation
            _heightController.text.trim().isNotEmpty &&
            _heightError == null && // Must pass validation
            _weightController.text.trim().isNotEmpty &&
            _weightError == null && // Must pass validation
            _selectedGender != null;
      case 1:
        return _selectedFitnessLevel != null && _gymMembership != null;
      case 2:
        return _selectedEquipment.isNotEmpty;
      case 3:
        return _selectedGoal != null;
      default:
        return false;
    }
  }

  // ------------------------

  void _nextPage() {
    if (!_isCurrentPageValid()) return;

    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitSurveyData();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitSurveyData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final payload = {
      'name': _nameController.text.trim(),
      'age': int.tryParse(_ageController.text.trim()),
      'gender': _selectedGender,
      'height': double.tryParse(_heightController.text.trim()),
      'weight': double.tryParse(_weightController.text.trim()),
      'fitness_level': _selectedFitnessLevel,
      'gym_membership': _gymMembership,
      'goal': _selectedGoal,
      'equipments': _selectedEquipment,
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E6644)),
        ),
      ),
    );

    final result = await authProvider.submitOnboardingData(payload);

    if (mounted) Navigator.pop(context);

    if (result['success'] == true) {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainLayoutScreen()),
          (route) => false,
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Terjadi kesalahan sistem.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bodyBg,
      body: Column(
        children: [
          _buildStaticHeader(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: [
                _buildStep1AboutYou(),
                _buildStep2Fitness(),
                _buildStep3Equipment(),
                _buildStep4Goals(),
              ],
            ),
          ),
          _buildBottomActionBar(),
        ],
      ),
    );
  }

  Widget _buildStaticHeader() {
    final titles = ['About You', 'Fitness', 'Equipment', 'Goals'];
    return Container(
      width: double.infinity,
      color: _headerGreen,
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (_currentPage > 0)
                GestureDetector(
                  onTap: _previousPage,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              Text(
                'STEP ${_currentPage + 1} OF 4',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            titles[_currentPage],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: List.generate(4, (index) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index == 3 ? 0 : 8),
                  decoration: BoxDecoration(
                    color: index <= _currentPage
                        ? Colors.white
                        : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    bool isValid = _isCurrentPageValid();

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      color: _bodyBg,
      width: double.infinity,
      child: SizedBox(
        height: 54,
        child: ElevatedButton(
          onPressed: isValid ? _nextPage : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isValid ? _buttonActiveGreen : _buttonDisabledSage,
            disabledBackgroundColor: _buttonDisabledSage,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _currentPage == 3 ? 'Get Started' : 'Continue',
                style: TextStyle(
                  color: isValid ? Colors.white : Colors.white.withOpacity(0.6),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: isValid ? Colors.white : Colors.white.withOpacity(0.6),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1AboutYou() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputLabel('YOUR NAME'),
          _buildTextField(_nameController, hint: 'Enter your name'),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align to top in case of error text
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel('AGE'),
                    _buildTextField(
                      _ageController,
                      isNumber: true,
                      errorText: _ageError,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel('GENDER'),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: _inputDecoration(hint: 'Select'),
                      dropdownColor: Colors.white,
                      items: ['Male', 'Female']
                          .map(
                            (g) => DropdownMenuItem(value: g, child: Text(g)),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _selectedGender = val),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align to top in case of error text
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel('HEIGHT (CM)'),
                    _buildTextField(
                      _heightController,
                      isNumber: true,
                      errorText: _heightError,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel('WEIGHT (KG)'),
                    _buildTextField(
                      _weightController,
                      isNumber: true,
                      errorText: _weightError,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Fitness() {
    final levels = [
      {'title': 'Beginner', 'sub': 'Just starting out'},
      {'title': 'Intermediate', 'sub': 'Working out 2–3× per week'},
      {'title': 'Advanced', 'sub': 'Consistent training for 2+ years'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputLabel('FITNESS LEVEL'),
          ...levels.map((lvl) {
            bool isSelected = _selectedFitnessLevel == lvl['title'];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? _accentGreen : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: ListTile(
                onTap: () =>
                    setState(() => _selectedFitnessLevel = lvl['title']!),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                title: Text(
                  lvl['title']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                subtitle: Text(
                  lvl['sub']!,
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          _buildInputLabel('DO YOU HAVE A GYM MEMBERSHIP?'),
          Row(
            children: [
              Expanded(
                child: _buildSelectCard(
                  'Yes, I do 🏪',
                  _gymMembership == 'Yes',
                  () => setState(() => _gymMembership = 'Yes'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildSelectCard(
                  'No, I train at home 🏠',
                  _gymMembership == 'No',
                  () => setState(() => _gymMembership = 'No'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Equipment() {
    final equipments = [
      {'name': 'Full Gym', 'icon': '🏋️‍♂️'},
      {'name': 'Dumbbells', 'icon': '💪'},
      {'name': 'Resistance Bands', 'icon': '🔗'},
      {'name': 'Barbell', 'icon': '🏗️'},
      {'name': 'Pull-up Bar', 'icon': '🧗'},
      {'name': 'No Equipment', 'icon': '🤸'},
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputLabel('Select all the equipment you have access to'),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.3,
              ),
              itemCount: equipments.length,
              itemBuilder: (context, index) {
                final eq = equipments[index]['name']!;
                final icon = equipments[index]['icon']!;
                bool isSelected = _selectedEquipment.contains(eq);

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? _accentGreen : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedEquipment.remove(eq);
                        } else {
                          if (eq == 'No Equipment') {
                            _selectedEquipment.clear();
                          } else {
                            _selectedEquipment.remove('No Equipment');
                          }
                          _selectedEquipment.add(eq);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(icon, style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 8),
                        Text(
                          eq,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _textDark,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4Goals() {
    final goals = [
      {
        'title': 'Lose Weight',
        'sub': 'Burn fat, lean out',
        'color': Colors.orangeAccent,
      },
      {
        'title': 'Build Muscle',
        'sub': 'Gain strength & size',
        'color': _headerGreen,
      },
      {
        'title': 'Improve Endurance',
        'sub': 'Cardio & stamina',
        'color': Colors.blueAccent,
      },
      {
        'title': 'Stay Active',
        'sub': 'General wellness',
        'color': Colors.lightGreenAccent,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputLabel("What's your primary exercise goal?"),
          ...goals.map((goal) {
            bool isSelected = _selectedGoal == goal['title'];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? _accentGreen : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: ListTile(
                onTap: () =>
                    setState(() => _selectedGoal = goal['title'] as String),
                leading: CircleAvatar(
                  radius: 8,
                  backgroundColor: (goal['color'] as Color).withOpacity(0.3),
                  child: CircleAvatar(
                    radius: 4,
                    backgroundColor: goal['color'] as Color,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                title: Text(
                  goal['title'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                subtitle: Text(
                  goal['sub'] as String,
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: _labelGrey,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    bool isNumber = false,
    String? hint,
    String? errorText, // ADDED: Allows us to pass the error message
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: _textDark, fontWeight: FontWeight.w500),
      onChanged: (_) => setState(() {}),
      decoration: _inputDecoration(hint: hint, errorText: errorText),
    );
  }

  InputDecoration _inputDecoration({String? hint, String? errorText}) {
    return InputDecoration(
      hintText: hint,
      errorText: errorText, // ADDED: Displays the error text under the field
      errorMaxLines: 2, // Prevents text cutting off on small screens
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      // Optional: Give it a nice red border when there's an error so it matches the aesthetic
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  Widget _buildSelectCard(String label, bool isSelected, VoidCallback onTap) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? _accentGreen : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: _textDark,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
