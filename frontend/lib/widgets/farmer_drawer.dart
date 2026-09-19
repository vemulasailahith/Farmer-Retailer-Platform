import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/language_service.dart';
import '../screens/farmer/farmer_input_screen.dart';

class FarmerDrawer extends StatelessWidget {
  const FarmerDrawer({super.key});

  void _showComingSoonDialog(BuildContext context, String title) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.access_time_filled, color: Color(0xFF2E7D32), size: 36),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          l10n.featureComingSoon,
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentCode = languageService.currentLocale.languageCode;

    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Row(
          children: [
            const Icon(Icons.language, color: Color(0xFF2E7D32)),
            const SizedBox(width: 10),
            Text(l10n.chooseLanguage),
          ],
        ),
        children: [
          _buildLanguageOption(
            ctx: ctx,
            title: 'English',
            code: 'en',
            isSelected: currentCode == 'en',
          ),
          _buildLanguageOption(
            ctx: ctx,
            title: 'తెలుగు (Telugu)',
            code: 'te',
            isSelected: currentCode == 'te',
          ),
          _buildLanguageOption(
            ctx: ctx,
            title: 'हिन्दी (Hindi)',
            code: 'hi',
            isSelected: currentCode == 'hi',
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext ctx,
    required String title,
    required String code,
    required bool isSelected,
  }) {
    return SimpleDialogOption(
      onPressed: () {
        languageService.setLanguage(code);
        Navigator.of(ctx).pop();
      },
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF2E7D32) : Colors.black87,
            ),
          ),
          if (isSelected)
            const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentUser = AuthService().currentUser;

    // Safely extract display name or email prefix
    final rawName = currentUser?.userMetadata?['full_name'] as String?;
    final displayName = (rawName != null && rawName.trim().isNotEmpty)
        ? rawName.trim()
        : (currentUser?.email?.split('@').first ?? l10n.farmer);
    final email = currentUser?.email ?? '';

    return Drawer(
      child: Column(
        children: [
          // Drawer Header with User/Farmer Information
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'F',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
            accountName: Text(
              displayName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (email.isNotEmpty)
                  Text(
                    email,
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(50),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${l10n.appName} • ${l10n.farmer}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Drawer Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // 1. Dashboard
                ListTile(
                  leading: const Icon(Icons.home_outlined, color: Color(0xFF2E7D32), size: 26),
                  title: Text(
                    l10n.dashboard,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.of(context).pop(); // Closes the drawer
                  },
                ),

                // 2. New Recommendation
                ListTile(
                  leading: const Icon(Icons.eco_outlined, color: Color(0xFF2E7D32), size: 26),
                  title: Text(
                    l10n.newRecommendation,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.of(context).pop(); // Closes the drawer
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FarmerInputScreen(),
                      ),
                    );
                  },
                ),

                const Divider(height: 1),

                // 3. My Orders (Coming Soon)
                ListTile(
                  leading: const Icon(Icons.inventory_2_outlined, color: Colors.blueGrey, size: 26),
                  title: Text(
                    l10n.myOrders,
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      l10n.comingSoon,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showComingSoonDialog(context, l10n.myOrders);
                  },
                ),

                // 4. Transport Tracking (Coming Soon)
                ListTile(
                  leading: const Icon(Icons.local_shipping_outlined, color: Colors.blueGrey, size: 26),
                  title: Text(
                    l10n.transportTracking,
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      l10n.comingSoon,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showComingSoonDialog(context, l10n.transportTracking);
                  },
                ),

                // 5. Settings (Coming Soon)
                ListTile(
                  leading: const Icon(Icons.settings_outlined, color: Colors.blueGrey, size: 26),
                  title: Text(
                    l10n.settings,
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      l10n.comingSoon,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showComingSoonDialog(context, l10n.settings);
                  },
                ),

                const Divider(height: 1),

                // 6. Language Selection
                ListTile(
                  leading: const Icon(Icons.language, color: Color(0xFF2E7D32), size: 26),
                  title: Text(
                    l10n.language,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showLanguageDialog(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
