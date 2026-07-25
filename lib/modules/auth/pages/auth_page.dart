import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/widgets/floating_logo.dart';
import '../controllers/auth_controller.dart';
import '../widgets/google_button.dart';
import '../widgets/login_form.dart';
import '../widgets/register_form.dart';

class AuthPage extends GetView<AuthController> {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Card(
                elevation: 12,
                shadowColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: isDesktop
                      ? const _DesktopLayout()
                      : const _MobileLayout(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 720,
      child: Row(
        children: [
          Expanded(flex: 5, child: _LeftPanel()),
          Expanded(flex: 5, child: _RightPanel()),
        ],
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 220, child: _LeftPanel()),
        _RightPanel(),
      ],
    );
  }
}

/// Branding side — was referenced by both layouts but never actually
/// defined anywhere in the files sent, which alone would fail to
/// compile.
class _LeftPanel extends StatelessWidget {
  const _LeftPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primaryDark,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FloatingLogo(
              image: "assets/images/app_logo.jpeg",
              size: 80,
              fit: BoxFit.cover,
              useCircleFrame: true,
            ),
            const SizedBox(height: 20),
            Text(
              'app_name'.tr,
              style: AppTextStyles.display.copyWith(
                fontSize: 28,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'splash_tagline'.tr,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: Colors.white.withOpacity(.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The actual form side — toggles between login and register based on
/// AuthController.isLogin, with a Google option and a mode switcher.
class _RightPanel extends GetView<AuthController> {
  const _RightPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
      child: Obx(() {
        final isLogin = controller.isLogin.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              (isLogin ? 'welcome_back' : 'create_account_heading').tr,
              style: AppTextStyles.headline,
            ),
            const SizedBox(height: 8),
            Text(
              (isLogin ? 'login_subtitle' : 'register_subtitle').tr,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 28),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isLogin
                  ? const LoginForm(key: ValueKey("login"))
                  : const RegisterForm(key: ValueKey("register")),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'or_divider'.tr,
                    style: AppTextStyles.caption,
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),

            const SizedBox(height: 20),

            const GoogleButton(),

            const SizedBox(height: 24),

            Center(
              child: TextButton(
                onPressed: controller.switchMode,
                child: Text.rich(
                  TextSpan(
                    text: (isLogin
                        ? 'dont_have_account'
                        : 'already_have_account')
                        .tr,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      TextSpan(
                        text: (isLogin ? 'signup' : 'login').tr,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}