import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_background.dart';
import 'l10n_service.dart';

final _supabase = Supabase.instance.client;

class AuthScreen extends StatefulWidget {
  final bool isLegalEntity;
  const AuthScreen({super.key, required this.isLegalEntity});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Color get _color => widget.isLegalEntity ? const Color(0xFF00C853) : const Color(0xFF42A5F5);

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(t(msg), style: const TextStyle(color: Colors.white)),
      backgroundColor: const Color(0xFFFF1744),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(t(msg), style: const TextStyle(color: Colors.white)),
      backgroundColor: const Color(0xFF00C853),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  Future<void> _login() async {
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      _showError('auth_fill');
      return;
    }
    setState(() => _loading = true);
    try {
      await _supabase.auth.signInWithPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (mounted) {
        Navigator.pop(context, widget.isLegalEntity);
        Navigator.pop(context, widget.isLegalEntity);
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('auth_err');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _register() async {
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      _showError('auth_fill');
      return;
    }
    if (_passCtrl.text != _confirmPassCtrl.text) {
      _showError('auth_mismatch');
      return;
    }
    if (_passCtrl.text.length < 6) {
      _showError('auth_short');
      return;
    }
    setState(() => _loading = true);
    try {
      await _supabase.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        data: {'is_legal_entity': widget.isLegalEntity},
      );
      if (mounted) {
        _showSuccess('${t('auth_sent')} ${_emailCtrl.text.trim()}');
        _tabController.animateTo(0);
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('auth_err');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      _showError('auth_reset_email');
      return;
    }
    setState(() => _loading = true);
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      if (mounted) _showSuccess('${t('auth_reset_sent')} $email');
    } on AuthException catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: L10n.localeNotifier,
      builder: (context, locale, _) => AppBackground(
        child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(widget.isLegalEntity ? t('auth_bank') : t('auth_cabinet')),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: _color,
            labelColor: _color,
            unselectedLabelColor: Colors.white54,
            tabs: [Tab(text: t('auth_login')), Tab(text: t('auth_reg'))],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [_buildLogin(), _buildRegister()],
        ),
      ),
      ),
    );
  }

  Widget _buildLogin() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          _buildAvatar(),
          const SizedBox(height: 32),
          _emailField(),
          const SizedBox(height: 16),
          _passwordField(_passCtrl, t('auth_pass')),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _loading ? null : _forgotPassword,
              child: Text(t('auth_forgot'), style: TextStyle(color: _color)),
            ),
          ),
          const SizedBox(height: 16),
          _actionButton(t('auth_login'), _login),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => _tabController.animateTo(1),
            child: Text(t('auth_no_acc'),
                style: TextStyle(color: Colors.white.withOpacity(0.5))),
          ),
        ],
      ),
    );
  }

  Widget _buildRegister() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          _buildAvatar(),
          const SizedBox(height: 32),
          _emailField(),
          const SizedBox(height: 16),
          _passwordField(_passCtrl, t('auth_pass')),
          const SizedBox(height: 16),
          _passwordField(_confirmPassCtrl, t('auth_confirm_pass')),
          const SizedBox(height: 24),
          _actionButton(t('auth_reg'), _register),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => _tabController.animateTo(0),
            child: Text(t('auth_have_acc'),
                style: TextStyle(color: Colors.white.withOpacity(0.5))),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [_color, _color.withOpacity(0.5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [BoxShadow(color: _color.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Icon(
        widget.isLegalEntity ? Icons.account_balance : Icons.person,
        size: 44,
        color: Colors.white,
      ),
    );
  }

  Widget _emailField() {
    return TextField(
      controller: _emailCtrl,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Email',
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: const Icon(Icons.email_outlined, color: Colors.white38),
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _color, width: 1.5),
        ),
      ),
    );
  }

  Widget _passwordField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      obscureText: _obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.white38),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: Colors.white38),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _color, width: 1.5),
        ),
      ),
    );
  }

  Widget _actionButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _loading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}
