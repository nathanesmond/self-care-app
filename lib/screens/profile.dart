import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:self_care_app/auth/auth_provider.dart';
import 'package:self_care_app/auth/workout_provider.dart';
import 'package:self_care_app/auth/history_provider.dart';
import 'package:self_care_app/screens/accountSettings.dart';
import 'package:self_care_app/screens/privacy.dart';
import 'editProfile.dart';
import 'login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ── Color Constants ───────────────────────────────────────────────────────
  static const _textDark = Color(0xFF1A2E22);
  static const _headerGreen = Color(0xFF1E4030);
  static const _midGreen = Color(0xFF2D5A40);
  static const _accentActiveGreen = Color(0xFF2E6644);
  static const _labelGrey = Color(0xFF7A8E81);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).fetchProfileData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final profile = authProvider.profileData;

    if (profile == null && authProvider.isLoading) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_accentActiveGreen),
          ),
        ),
      );
    }

    final String displayName = profile?['name'] ?? 'No Name';
    final String displayEmail = profile?['email'] ?? 'No Email Provided';
    return Column(
      children: [
        _buildProfileHeader(displayName, displayEmail),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionLabel('BODY INFO'),
                const SizedBox(height: 8),
                _buildBodyInfoCard(profile),
                const SizedBox(height: 12),

                _buildChangeInfoButton(profile),
                const SizedBox(height: 24),

                _buildSectionLabel('SETTINGS'),
                const SizedBox(height: 8),
                _buildSettingsCard(),
                const SizedBox(height: 24),

                _buildSignOutButton(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(String name, String email) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_headerGreen, _midGreen],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'serif',
                      ),
                    ),
                    const SizedBox(height: 2), // Tiny gap
                    Text(
                      email, // 🔥 Displaying the email here!
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _labelGrey,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildBodyInfoCard(Map<String, dynamic>? profile) {
    List<dynamic> equipmentList = profile?['equipments'] ?? [];

    return Column(
      children: [
        Row(
          children: [
            _buildMetricCard(
              Icons.straighten_rounded,
              'HEIGHT',
              '${profile?['height'] ?? '-'}',
              'cm',
            ),
            const SizedBox(width: 10),
            _buildMetricCard(
              Icons.scale_rounded,
              'WEIGHT',
              '${profile?['weight'] ?? '-'}',
              'kg',
            ),
            const SizedBox(width: 10),
            _buildMetricCard(
              Icons.cake_rounded,
              'AGE',
              '${profile?['age'] ?? '-'}',
              'yrs',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          child: Column(
            children: [
              _buildCleanRowInfo(
                Icons.track_changes_rounded,
                'Health Goal',
                profile?['goal'] ?? '-',
              ),
              const Divider(color: Color(0xFFEFF3F1), height: 1),
              _buildCleanRowInfo(
                Icons.bar_chart_rounded,
                'Fitness Level',
                profile?['fitness_level'] ?? '-',
              ),
              const Divider(color: Color(0xFFEFF3F1), height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.fitness_center_rounded,
                      color: _labelGrey,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Equipments',
                      style: TextStyle(
                        color: _textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: equipmentList.isEmpty
                          ? const Text(
                              '-',
                              style: TextStyle(
                                color: _accentActiveGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              alignment: WrapAlignment.end,
                              children: equipmentList.map((equip) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF5F1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    equip.toString(),
                                    style: const TextStyle(
                                      color: _accentActiveGreen,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    IconData icon,
    String label,
    String value,
    String unit,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: _labelGrey.withOpacity(0.6), size: 20),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: _labelGrey,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: _textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'serif',
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  unit,
                  style: const TextStyle(
                    color: _accentActiveGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCleanRowInfo(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: _labelGrey, size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: _textDark,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: _accentActiveGreen,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeInfoButton(Map<String, dynamic>? profile) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: () async {
          List<dynamic> eqList = profile?['equipments'] ?? [];
          List<String> currentEquipmentsList = eqList
              .map((e) => e.toString())
              .toList();

          final successUpdate = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfileScreen(
                initialName: profile?['name'] ?? '',
                initialHeight: (profile?['height'] ?? '').toString(),
                initialWeight: (profile?['weight'] ?? '').toString(),
                initialAge: (profile?['age'] ?? '').toString(),
                initialGoal: profile?['goal'] ?? 'Stay Active',
                initialEquipments: currentEquipmentsList,
                initialFitnessLevel: profile?['fitness_level'] ?? 'Beginner',
              ),
            ),
          );

          if (successUpdate == true) {
            if (mounted) {
              Provider.of<AuthProvider>(
                context,
                listen: false,
              ).fetchProfileData();
            }
          }
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _accentActiveGreen, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'Change Information',
          style: TextStyle(
            color: _accentActiveGreen,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Divider(color: Color(0xFFEFF3F1), height: 1),
          _buildNavigationSettingsTile(
            Icons.shield_outlined,
            'Privacy & Data',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyScreen()),
            ),
          ),
          const Divider(color: Color(0xFFEFF3F1), height: 1),
          _buildNavigationSettingsTile(
            Icons.person_outline_rounded,
            'Account Settings',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AccountSettingsScreen()),
            ),
          ),
        ],
      ),
    );
  }

  // Notice we added VoidCallback onTap here
  Widget _buildNavigationSettingsTile(
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: _labelGrey, size: 22),
            const SizedBox(width: 14),
            Text(
              title,
              style: const TextStyle(
                color: _textDark,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey[350],
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: authProvider.isLoading
            ? null
            : () async {
                // 🔥 KUNCI UTAMA: Sapu bersih memori RAM internal aplikasi sebelum logout
                Provider.of<WorkoutProvider>(
                  context,
                  listen: false,
                ).clearState();
                Provider.of<HistoryProvider>(
                  context,
                  listen: false,
                ).clearState();

                // Eksekusi pembersihan token Sanctum ke backend Laravel
                await authProvider.logout();

                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFDF0ED),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: authProvider.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Color(0xFFC85A32),
                  strokeWidth: 2,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFC85A32),
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Sign Out',
                    style: TextStyle(
                      color: Color(0xFFC85A32),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
