import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomText(
          text: 'Settings',
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Theme Section
              CustomText(
                text: 'Display',
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 16.h),

              // Dark Mode Toggle
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              themeProvider.isDark
                                  ? Icons.dark_mode
                                  : Icons.light_mode,
                              size: 24.sp,
                            ),
                            SizedBox(width: 12.w),
                            CustomText(
                              text: themeProvider.isDark
                                  ? 'Dark Mode'
                                  : 'Light Mode',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                        Switch(
                          value: themeProvider.isDark,
                          onChanged: (value) {
                            themeProvider.toggleTheme();
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 32.h),

              // About Section
              CustomText(
                text: 'About',
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 16.h),

              _SettingItem(
                icon: Icons.info_outline,
                title: 'App Version',
                subtitle: '0.1.0',
              ),
              _SettingItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'View our privacy policy',
              ),
              _SettingItem(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                subtitle: 'View terms and conditions',
              ),
              SizedBox(height: 32.h),

              // Support Section
              CustomText(
                text: 'Support',
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 16.h),

              _SettingItem(
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle: 'Contact our support team',
              ),
              _SettingItem(
                icon: Icons.feedback_outlined,
                title: 'Send Feedback',
                subtitle: 'Help us improve the app',
              ),
              SizedBox(height: 24.h),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Log out'),
                onTap: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Log out?'),
                      content: const Text(
                        'You will return to the sign-in screen.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: const Text('Log out'),
                        ),
                      ],
                    ),
                  );
                  if (shouldLogout != true || !context.mounted) return;
                  await UserService().signOut();
                  if (!context.mounted) return;
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/signin',
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24.sp),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: title,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: 4.h),
                  CustomText(
                    text: subtitle,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 24.sp),
          ],
        ),
      ),
    );
  }
}
