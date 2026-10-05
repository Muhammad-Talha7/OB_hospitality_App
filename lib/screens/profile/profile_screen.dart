import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../checkout/auth_sheet.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            Text(
              'Account',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF111111),
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),

            // ── Profile Card ───────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFEEEEEE)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE5BA73), Color(0xFFC4892A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        auth.isLoggedIn && user != null ? user.name[0].toUpperCase() : 'G',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.isLoggedIn && user != null ? user.name : 'Guest',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF111111),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          auth.isLoggedIn && user != null
                              ? user.email
                              : 'Sign in to unlock full features',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF9E9E9E),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Sign In / Out ──────────────────────────────────────────
            if (!auth.isLoggedIn)
              _GoldButton(
                label: 'Sign In or Create Account',
                onTap: () => AuthSheet.show(context, onAuthenticated: () {}),
              )
            else
              _OutlineButton(
                label: 'Log Out',
                color: const Color(0xFFD65839),
                onTap: () => auth.logout(),
              ),
            const SizedBox(height: 28),

            // ── Dev state control ──────────────────────────────────────
            _SectionLabel('DEV CONTROLS'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF6EE),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5BA73).withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tune_rounded, size: 15, color: Color(0xFFC4892A)),
                      const SizedBox(width: 7),
                      Text(
                        'TESTING STATE CONTROL',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFC4892A),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    auth.isLoggedIn
                        ? 'Logged in as ${user?.email}. Checkout proceeds directly.'
                        : 'Guest mode. Auth gate shown at checkout.',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF888888),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => auth.toggleMockAuth(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5BA73),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        auth.isLoggedIn ? 'Switch to Guest Mode' : 'Switch to Logged In',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Saved Addresses ────────────────────────────────────────
            if (auth.isLoggedIn && user != null && user.savedAddresses.isNotEmpty) ...[
              _SectionLabel('SAVED ADDRESSES'),
              const SizedBox(height: 10),
              ...user.savedAddresses.map(
                (addr) => _ListTile(
                  leading: Icons.home_outlined,
                  title: addr,
                  trailing: const Icon(Icons.check_rounded, size: 14, color: Color(0xFF5FB760)),
                ),
              ),
              const SizedBox(height: 28),
            ],

            // ── About ──────────────────────────────────────────────────
            _SectionLabel('ABOUT'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9FB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OB Hospitality',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF111111),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Ottawa Kabab & Grill, Sashimi Atelier, La Trattoria, and Harissa Sweets.',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF888888),
                      fontSize: 12,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Preferences ────────────────────────────────────────────
            _SectionLabel('PREFERENCES'),
            const SizedBox(height: 10),
            _ListTile(leading: Icons.notifications_outlined, title: 'Notifications', trailing: _Arrow()),
            _ListTile(leading: Icons.language_outlined, title: 'Language', trailing: _Arrow()),
            _ListTile(leading: Icons.help_outline_rounded, title: 'Help & Support', trailing: _Arrow()),
            _ListTile(leading: Icons.policy_outlined, title: 'Privacy Policy', trailing: _Arrow()),
          ],
        ),
      ),
    );
  }
}

// ─── Shared Widgets ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        color: const Color(0xFFAAAAAA),
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GoldButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFFE5BA73),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _OutlineButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _ListTile extends StatelessWidget {
  final IconData leading;
  final String title;
  final Widget trailing;
  const _ListTile({required this.leading, required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          Icon(leading, color: const Color(0xFF888888), size: 19),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF222222),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.chevron_right_rounded, color: Color(0xFFCCCCCC), size: 20);
  }
}
