import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/local_storage.dart';
import '../news/home_screen.dart';

class _Palette {
  static const primary = Color(0xFF315CBA);
  static const ink = Color(0xFF17243A);
  static const muted = Color(0xFF6B7484);
  static const border = Color(0xFFDCE1EA);
  static const surface = Color(0xFFF6F8FC);
}

const _appName = 'Context'; // change to your app's name

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static final _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _emailFocus = FocusNode();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final prefs = ref.read(sharedPreferencesProvider);
      if (prefs.getBool('is_logged_in') == true) _openApp();
    });
  }

  void _openApp() => Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (_) => const HomeScreen()),
  );

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('display_name', _name.text.trim());
      await prefs.setString('email', _email.text.trim());
      if (mounted) _openApp();
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String label, IconData icon) {
    OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 22),
      prefixIconColor: _Palette.muted,
      labelStyle: const TextStyle(color: _Palette.muted),
      floatingLabelStyle: const TextStyle(color: _Palette.primary, fontWeight: FontWeight.w600),
      filled: true,
      fillColor: _Palette.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      enabledBorder: border(_Palette.border),
      focusedBorder: border(_Palette.primary, 1.6),
      errorBorder: border(Colors.red.shade400),
      focusedErrorBorder: border(Colors.red.shade400, 1.6),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Palette.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                builder: (context, t, child) => Opacity(
                  opacity: t,
                  child: Transform.translate(offset: Offset(0, 16 * (1 - t)), child: child),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBrand(),
                    const SizedBox(height: 32),
                    const Text(
                      'Your world,\nin context.',
                      style: TextStyle(
                        fontSize: 34,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                        color: _Palette.ink,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'A calmer way to keep up with the stories shaping business and technology.',
                      style: TextStyle(fontSize: 15.5, height: 1.5, color: _Palette.muted),
                    ),
                    const SizedBox(height: 28),
                    _buildFormCard(),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        'Demo sign-in for this assignment.\nNo password or account is sent to a server.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, height: 1.5, color: _Palette.muted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrand() {
    return Row(
      children: [
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4A78E0), _Palette.primary],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: _Palette.primary.withOpacity(0.28),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 12),
        const Text(
          _appName,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: _Palette.ink,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _Palette.border),
        boxShadow: [
          BoxShadow(
            color: _Palette.ink.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Get started',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _Palette.ink),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tell us a little about you to personalise your feed.',
                style: TextStyle(fontSize: 13.5, color: _Palette.muted),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _name,
                enabled: !_loading,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.name],
                inputFormatters: [LengthLimitingTextInputFormatter(60)],
                onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                decoration: _decoration('Full name', Icons.person_outline_rounded),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _email,
                focusNode: _emailFocus,
                enabled: !_loading,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.email],
                onFieldSubmitted: (_) => _login(),
                decoration: _decoration('Email address', Icons.mail_outline_rounded),
                validator: (v) => (v == null || !_emailRegex.hasMatch(v.trim()))
                    ? 'Enter a valid email address'
                    : null,
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: _loading ? null : _login,
                  style: FilledButton.styleFrom(
                    backgroundColor: _Palette.primary,
                    disabledBackgroundColor: _Palette.primary.withOpacity(0.7),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _loading
                        ? const SizedBox(
                      key: ValueKey('loading'),
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                        : const Row(
                      key: ValueKey('label'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Continue',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}