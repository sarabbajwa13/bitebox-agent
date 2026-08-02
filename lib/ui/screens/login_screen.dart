import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../config/app_strings.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../widgets/common.dart';

/// Firebase Phone OTP login: phone daalo → OTP → verify.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  void _sendOtp() {
    final digits = _phoneCtrl.text.trim();
    if (digits.length != AppConfig.phoneLength) return;
    context.read<AuthProvider>().sendOtp('${AppConfig.countryCode}$digits');
  }

  void _verify() {
    final code = _otpCtrl.text.trim();
    if (code.length != AppConfig.otpLength) return;
    context.read<AuthProvider>().verifyOtp(code);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isOtp = auth.step == AuthStep.otpSent;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: AppLogo(size: 76, radius: AppRadius.lg)),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    AppConfig.businessName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    AppStrings.loginTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isOtp
                        ? '${AppStrings.otpSentTo} ${auth.phone}'
                        : AppStrings.loginSubtitle,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  if (!isOtp) _phoneField() else _otpField(),

                  if (auth.error != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      auth.error!,
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton(
                    onPressed: auth.busy ? null : (isOtp ? _verify : _sendOtp),
                    child: auth.busy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(isOtp
                            ? AppStrings.verifyLogin
                            : AppStrings.sendOtp),
                  ),

                  if (isOtp) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: auth.busy
                              ? null
                              : () {
                                  _otpCtrl.clear();
                                  context.read<AuthProvider>().backToPhone();
                                },
                          child: const Text(AppStrings.changeNumber),
                        ),
                        TextButton(
                          onPressed: auth.busy
                              ? null
                              : () => context
                                  .read<AuthProvider>()
                                  .sendOtp(auth.phone),
                          child: const Text(AppStrings.resendOtp),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _phoneField() {
    return TextField(
      controller: _phoneCtrl,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(AppConfig.phoneLength),
      ],
      onSubmitted: (_) => _sendOtp(),
      decoration: InputDecoration(
        labelText: AppStrings.phoneNumber,
        prefixIcon: const Icon(Icons.phone_outlined),
        prefixText: '${AppConfig.countryCode} ',
      ),
    );
  }

  Widget _otpField() {
    return TextField(
      controller: _otpCtrl,
      keyboardType: TextInputType.number,
      autofocus: true,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(AppConfig.otpLength),
      ],
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: 8,
      ),
      textAlign: TextAlign.center,
      onSubmitted: (_) => _verify(),
      decoration: const InputDecoration(
        labelText: AppStrings.otpLabel,
        hintText: '••••••',
      ),
    );
  }
}
