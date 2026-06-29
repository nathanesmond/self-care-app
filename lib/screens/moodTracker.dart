import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:self_care_app/auth/auth_provider.dart';
import 'package:self_care_app/auth/mood_provider.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  int? _selectedMoodIndex;
  final List<String> _selectedInfluences = [];
  final _noteController = TextEditingController();

  static const _textDark = Color(0xFF1A2E22);
  static const _labelGrey = Color(0xFF6B7F73);
  static const _accentGreen = Color(0xFF3D7A56);
  static const _buttonSage = Color(0xFFABC4B7);
  static const _fieldBg = Color(0xFFEFF5F0);

  final List<Map<String, String>> _moods = [
    {'emoji': '😔', 'label': 'Very Low'},
    {'emoji': '😟', 'label': 'Low'},
    {'emoji': '😐', 'label': 'Neutral'},
    {'emoji': '🙂', 'label': 'Good'},
    {'emoji': '🤩', 'label': 'Great'},
  ];

  final List<String> _influenceTags = [
    'Rested',
    'Stressed',
    'Energetic',
    'Tired',
    'Social',
    'Lonely',
    'Focused',
    'Anxious',
    'Calm',
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMoodSelectionCard(),
                const SizedBox(height: 16),
                _buildInfluencesCard(),
                const SizedBox(height: 16),
                _buildNotesCard(),
                const SizedBox(height: 20),
                _buildLogButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1E4030), Color(0xFF2D5A40)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'EMA CHECK-IN',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Mood Tracker',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'How are you feeling right now?',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodSelectionCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select your mood',
            style: TextStyle(
              color: _textDark,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_moods.length, (index) {
              bool isSelected = _selectedMoodIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedMoodIndex = index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE8F2EC)
                          : const Color(0xFFF5F7F6),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected
                            ? _accentGreen
                            : const Color(0xFFE2EAE5),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _moods[index]['emoji']!,
                          style: const TextStyle(fontSize: 22),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _moods[index]['label']!,
                          style: TextStyle(
                            color: isSelected ? _accentGreen : _labelGrey,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInfluencesCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What's influencing your mood?",
            style: TextStyle(
              color: _textDark,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _influenceTags.map((tag) {
              bool isSelected = _selectedInfluences.contains(tag);
              return InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedInfluences.remove(tag);
                    } else {
                      _selectedInfluences.add(tag);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE8F2EC)
                        : const Color(0xFFF5F7F6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? _accentGreen
                          : const Color(0xFFE2EAE5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: isSelected ? _accentGreen : _textDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add a note (optional)',
            style: TextStyle(
              color: _textDark,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            maxLines: 4,
            style: const TextStyle(
              color: _textDark,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: "What's on your mind today?",
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              filled: true,
              fillColor: _fieldBg,
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogButton() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final moodProvider = Provider.of<MoodProvider>(context);

    bool isReady = _selectedMoodIndex != null;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: (isReady && !moodProvider.isLoading)
            ? () async {
                int realScore = _selectedMoodIndex! + 1;
                String currentMoodText = _moods[_selectedMoodIndex!]['label']!;

                String userToken = authProvider.token ?? '';

                final result = await moodProvider.uploadDailyMood(
                  token: userToken,
                  skorMood: realScore,
                  mood: currentMoodText,
                  influences: _selectedInfluences,
                  notes: _noteController.text.trim(),
                );

                if (result['success'] == true) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          '🎉 Mood Anda hari ini berhasil disimpan!',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                    setState(() {
                      _selectedMoodIndex = null;
                      _selectedInfluences.clear();
                      _noteController.clear();
                    });
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['message']),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isReady ? _accentGreen : _buttonSage,
          disabledBackgroundColor: _buttonSage,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: moodProvider.isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Log Mood',
                    style: TextStyle(
                      color: isReady
                          ? Colors.white
                          : Colors.white.withOpacity(0.6),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
