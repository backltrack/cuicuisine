import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../generated/l10n.dart';
import '../../themes/theme_mgr.dart';

class CreditsPage extends StatelessWidget {
  static const String route = '/credits';

  static const String _licenseUrl = 'https://www.gnu.org/licenses/gpl-3.0.html';
  static const String _githubUrl = 'https://github.com/backltrack';
  static const String _fontAwesomeUrl = 'https://fontawesome.com/license/free';

  static const List<String> _plugins = [
    "app_links",
    "clipboard",
    "cupertino_icons",
    "diacritic",
    "duration_picker",
    "dynamic_themes",
    "encrypt",
    "file_picker",
    "flutter_alarm_clock",
    "flutter_html",
    "flutter_image_slideshow",
    "flutter_inappwebview",
    "flutter_native_splash",
    "flutter_quill",
    "flutter_quill_delta_from_html",
    "flutter_tags_x",
    "flutter_to_pdf",
    "flutter_typeahead",
    "font_awesome_flutter",
    "google_fonts",
    "hive",
    "hive_flutter",
    "hive_generator",
    "html_editor_enhanced",
    "http",
    "image_picker",
    "intl",
    "intl_utils",
    "logging",
    "oauth2",
    "objectid",
    "package_info_plus",
    "path",
    "path_provider",
    "pdf",
    "qr_code_scanner_plus",
    "qr_flutter",
    "reorderables",
    "share_plus",
    "toastification",
    "url_launcher",
    "uuid",
    "wakelock_plus",
    "window_size",
  ];

  const CreditsPage({super.key});

  Widget _linkTile(BuildContext context, {required IconData icon, required String title, required String url}) {
    return ListTile(
      leading: FaIcon(icon),
      title: Text(title, style: ThemeMgr.getTheme(context)!.textTheme.displayMedium),
      trailing: const FaIcon(FontAwesomeIcons.upRightFromSquare, size: 14),
      onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication, webOnlyWindowName: '_blank'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).credits_title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: ThemeMgr.getTheme(context)!.colorScheme.surface,
                    child: Image.asset('assets/icons/splash_icon.png', width: 80),
                  ),
                  const SizedBox(height: 12),
                  Text("Cuicuisine", style: ThemeMgr.getTheme(context)!.textTheme.displayLarge),
                ],
              ),
            ),

            const Divider(),
            _linkTile(
              context,
              icon: FontAwesomeIcons.scaleBalanced,
              title: "${S.of(context).credits_license_label}: GNU General Public License v3.0",
              url: _licenseUrl,
            ),

            const Divider(),
            _linkTile(
              context,
              icon: FontAwesomeIcons.github,
              title: "${S.of(context).credits_developed_by} backltrack",
              url: _githubUrl,
            ),

            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Text(S.of(context).credits_plugins_title, style: ThemeMgr.getTheme(context)!.textTheme.displayMedium),
                  const SizedBox(width: 8),
                  const Expanded(child: Divider()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _plugins.map((name) => ActionChip(
                  label: Text(name),
                  onPressed: () => launchUrl(
                    Uri.parse('https://pub.dev/packages/$name'),
                    mode: LaunchMode.externalApplication,
                    webOnlyWindowName: '_blank',
                  ),
                )).toList(),
              ),
            ),

            const Divider(),
            _linkTile(
              context,
              icon: FontAwesomeIcons.fontAwesome,
              title: "Icons by Font Awesome (CC BY 4.0)",
              url: _fontAwesomeUrl,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
