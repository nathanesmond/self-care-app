import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:self_care_app/auth/auth_provider.dart';
import 'package:self_care_app/auth/admin_provider.dart';
import 'package:self_care_app/screens/login.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  static const _primaryGreen = Color(0xFF1E4030);
  static const _accentActiveGreen = Color(0xFF2E6644);
  static const _coralOrange = Color(0xFFE57C5D);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token =
          Provider.of<AuthProvider>(context, listen: false).token ?? '';
      Provider.of<AdminProvider>(context, listen: false).loadUsers(token);
    });
  }

  void _showEditUserModal(Map<String, dynamic> user) {
    TextEditingController nameController = TextEditingController(
      text: user['name'] ?? '',
    );
    TextEditingController emailController = TextEditingController(
      text: user['email'] ?? '',
    );
    String currentStatus = user['status_akun'] ?? 'Active';
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Edit User Profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Account Status',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: RadioListTile<String>(
                      title: const Text(
                        'Active',
                        style: TextStyle(
                          color: _accentActiveGreen,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      value: 'Active',
                      groupValue: currentStatus,
                      activeColor: _accentActiveGreen,
                      onChanged: (value) =>
                          setModalState(() => currentStatus = value!),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: RadioListTile<String>(
                      title: const Text(
                        'Suspended',
                        style: TextStyle(
                          color: _coralOrange,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      value: 'Suspended',
                      groupValue: currentStatus,
                      activeColor: _coralOrange,
                      onChanged: (value) =>
                          setModalState(() => currentStatus = value!),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              setModalState(() => isSaving = true);

                              final token =
                                  Provider.of<AuthProvider>(
                                    context,
                                    listen: false,
                                  ).token ??
                                  '';
                              final adminProvider = Provider.of<AdminProvider>(
                                context,
                                listen: false,
                              );

                              final result = await adminProvider.editUser(
                                token,
                                user['id_user'],
                                nameController.text.trim(),
                                emailController.text.trim(),
                                currentStatus,
                              );

                              setModalState(() => isSaving = false);

                              if (result['success']) {
                                Navigator.pop(context); // Close the modal
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('User updated successfully!'),
                                    backgroundColor: _accentActiveGreen,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result['message']),
                                    backgroundColor: _coralOrange,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F2),
      appBar: AppBar(
        backgroundColor: _primaryGreen,
        title: const Text(
          'User Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              // 1. Call the logout API and clear the local token
              await Provider.of<AuthProvider>(context, listen: false).logout();

              // 2. Optional but good practice: Clear the admin data from memory
              if (context.mounted) {
                Provider.of<AdminProvider>(context, listen: false).clearState();

                // 3. Navigate back to Login and completely clear the routing history
                // (so they can't swipe back to the admin page)
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: adminProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: _primaryGreen))
          : adminProvider.users.isEmpty
          ? const Center(child: Text("No users found."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: adminProvider.users.length,
              itemBuilder: (context, index) {
                final user = adminProvider.users[index];
                final isActive = user['status_akun'] == 'Active';

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: isActive
                          ? const Color(0xFFE8F2EC)
                          : const Color(0xFFFDF0ED),
                      child: Icon(
                        Icons.person,
                        color: isActive ? _accentActiveGreen : _coralOrange,
                      ),
                    ),
                    title: Text(
                      user['name'] ?? 'No Name',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: _primaryGreen,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          user['email'] ?? '',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFFE8F2EC)
                                : const Color(0xFFFDF0ED),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            (user['status_akun'] ?? 'Unknown')
                                .toString()
                                .toUpperCase(),
                            style: TextStyle(
                              color: isActive
                                  ? _accentActiveGreen
                                  : _coralOrange,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.edit_note_rounded,
                        color: Colors.grey,
                      ),
                      onPressed: () => _showEditUserModal(user),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
