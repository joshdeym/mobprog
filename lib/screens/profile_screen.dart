import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  Map<String, dynamic> _userData = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await _userService.getUserData();
      if (!mounted) return;
      setState(() {
        _userData = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _editUsername() async {
    final controller = TextEditingController(
      text: (_userData['username'] ?? '').toString(),
    );
    final username = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Update username'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Username'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (username == null || username.trim().isEmpty) return;
    try {
      await _userService.updateUsername(username: username);
      await _loadProfile();
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _changePassword() async {
    final credentials = await showDialog<_PasswordChangeRequest>(
      context: context,
      builder: (_) => const _PasswordChangeDialog(),
    );
    if (credentials == null) return;
    try {
      await _userService.resetPasswordForCurrentPassword(
        currentPassword: credentials.currentPassword,
        newPassword: credentials.newPassword,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Password updated.')));
      }
    } catch (error) {
      if (error is FirebaseAuthException &&
          {
            'invalid-credential',
            'wrong-password',
            'user-mismatch',
          }.contains(error.code)) {
        _showError(
          'The current password is incorrect. Enter the password you use to sign in, or send yourself a password reset email.',
        );
      } else {
        _showError(error);
      }
    }
  }

  Future<void> _sendPasswordResetEmail() async {
    final email = (_userData['email'] ?? '').toString().trim();
    if (email.isEmpty) {
      _showError('There is no email address on this account.');
      return;
    }
    try {
      await _userService.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent to $email.')),
      );
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _deleteAccount() async {
    final currentPassword = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete account?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This permanently deletes your account and profile.'),
            TextField(
              controller: currentPassword,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, currentPassword.text),
            child: const Text('Delete account'),
          ),
        ],
      ),
    );
    currentPassword.dispose();
    if (password == null || password.isEmpty) return;
    try {
      await _userService.deleteAccount(currentPassword: password);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
    } catch (error) {
      _showError(error);
    }
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Account update failed: $error')));
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
          'Are you sure you want to log out of your account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await _logout();
    }
  }

  Future<void> _logout() async {
    await _userService.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final profileImage = (_userData['image'] ?? '').toString();
    final firstName = (_userData['fName'] ?? '').toString();
    final lastName = (_userData['lName'] ?? '').toString();
    final username = (_userData['username'] ?? '').toString();
    final fullName = '$firstName $lastName'.trim();
    final initials = firstName.isNotEmpty ? firstName[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF111827)
          : const Color(0xFFF5F1F8),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _ProfileSummaryCard(
                      imageUrl: profileImage,
                      initials: initials,
                      name: fullName.isEmpty ? username : fullName,
                      username: username,
                      isDark: isDark,
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1F2937) : Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF374151)
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        children: [
                          _ProfileInfoRow(
                            label: 'First name',
                            value: firstName,
                            icon: Icons.email_outlined,
                            isDark: isDark,
                          ),
                          _ProfileInfoRow(
                            label: 'Last name',
                            value: lastName,
                            icon: Icons.people_outline,
                            isDark: isDark,
                          ),
                          _ProfileInfoRow(
                            label: 'Age',
                            value: (_userData['age'] ?? '').toString(),
                            icon: Icons.cake_outlined,
                            isDark: isDark,
                          ),
                          _ProfileInfoRow(
                            label: 'Contact number',
                            value: (_userData['contactNo'] ?? '').toString(),
                            icon: Icons.phone_outlined,
                            isDark: isDark,
                          ),
                          _ProfileInfoRow(
                            label: 'Email',
                            value: (_userData['email'] ?? '').toString(),
                            icon: Icons.email_outlined,
                            isDark: isDark,
                          ),
                          _ProfileInfoRow(
                            label: 'Username',
                            value: username,
                            icon: Icons.alternate_email,
                            isDark: isDark,
                          ),
                          _ProfileInfoRow(
                            label: 'User ID',
                            value: (_userData['uid'] ?? '').toString(),
                            icon: Icons.badge_outlined,
                            isDark: isDark,
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _editUsername,
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Update username'),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _changePassword,
                        icon: const Icon(Icons.lock_reset),
                        label: const Text('Change password'),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _sendPasswordResetEmail,
                      icon: const Icon(Icons.mark_email_unread_outlined),
                      label: const Text(
                        'Forgot current password? Send reset email',
                      ),
                    ),
                    SizedBox(height: 8.h),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: _deleteAccount,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete account'),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _confirmLogout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEA6B5A),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  final String imageUrl;
  final String initials;
  final String name;
  final String username;
  final bool isDark;

  const _ProfileSummaryCard({
    required this.imageUrl,
    required this.initials,
    required this.name,
    required this.username,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final primaryText = isDark ? Colors.white : const Color(0xFF171717);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 88.w,
            height: 88.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? const Color(0xFF263B55) : const Color(0xFFFFF8E5),
            ),
            child: ClipOval(
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          _InitialsAvatar(initials: initials, isDark: isDark),
                    )
                  : _InitialsAvatar(initials: initials, isDark: isDark),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            name,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: primaryText,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '@$username',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.amber.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String initials;
  final bool isDark;

  const _InitialsAvatar({required this.initials, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 34.sp,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.blue.shade900,
        ),
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isDark;
  final bool showDivider;

  const _ProfileInfoRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDark,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: isDark
                      ? const Color(0xFF374151)
                      : Colors.grey.shade200,
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDark ? const Color(0xFF8CD5FF) : Colors.amber.shade600,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF333333),
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12.sp,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordChangeRequest {
  const _PasswordChangeRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  final String currentPassword;
  final String newPassword;
}

class _PasswordChangeDialog extends StatefulWidget {
  const _PasswordChangeDialog();

  @override
  State<_PasswordChangeDialog> createState() => _PasswordChangeDialogState();
}

class _PasswordChangeDialogState extends State<_PasswordChangeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();

  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      _PasswordChangeRequest(
        currentPassword: _currentPassword.text,
        newPassword: _newPassword.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change password'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _currentPassword,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current password'),
              validator: (value) => value == null || value.isEmpty
                  ? 'Enter your current password'
                  : null,
            ),
            TextFormField(
              controller: _newPassword,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New password'),
              validator: (value) => value == null || value.length < 6
                  ? 'Use at least 6 characters'
                  : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Update')),
      ],
    );
  }
}
