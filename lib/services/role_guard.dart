import 'package:flutter/material.dart';
import 'role_service.dart';
import '../../ui_template/utils/template_theme.dart';
import '../../ui_template/utils/template_layout.dart';

/// Reusable RoleGuard widget - prevents unauthorized access
class RoleGuard extends StatelessWidget {
  final String feature;
  final Widget child;
  final Widget? lockedBuilder;

  const RoleGuard({
    super.key,
    required this.feature,
    required this.child,
    this.lockedBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: RoleService.canAccess(feature),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || snapshot.data != true) {
          return lockedBuilder ?? AccessDeniedScreen(feature: feature);
        }

        return child;
      },
    );
  }
}

/// Locked UI with upgrade prompt
class AccessDeniedScreen extends StatelessWidget {
  final String feature;

  const AccessDeniedScreen({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    final allowedRoles = RoleService.getAllowedRoles(feature);
    final roleText = allowedRoles.isEmpty 
        ? 'Premium users' 
        : allowedRoles.map((r) => r.toLowerCase()).join(', ');

    return Scaffold(
      backgroundColor: TemplateTheme.surface,
      body: TemplateLayout(
        brandTitle: 'PINA',
        brandSubtitle: 'Access Control',
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_rounded,
                  size: 120,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),
                Text(
                  '🔒 Access Denied',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'This feature is available for $roleText only.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: TemplateTheme.textMuted,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to profile/upgrade or login
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: TemplateTheme.primaryButtonStyle(),
                  child: const Text('Back to Home'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // Optional: Contact admin/upgrade
                  },
                  child: const Text('Need Access?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

