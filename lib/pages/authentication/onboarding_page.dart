import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../database/database_mgr.dart';
import '../../generated/l10n.dart';
import '../../l10n/localeMgr.dart';
import '../../themes/theme_mgr.dart';
import '../home_page.dart';

class OnboardingPage extends StatefulWidget {
  static const String route = '/onboarding';

  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 4;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finish() async {
    await DatabaseMgr().localMgr.saveOnboardingDone();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        HomePage.route,
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeMgr.getTheme(context)!;
    final bool isLast = _currentPage == _totalPages - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(S.of(context).onboarding_skip,
                    style: theme.textTheme.bodyLarge!
                        .copyWith(color: theme.textTheme.bodyMedium!.color)),
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _OnboardingSlide(
                    icon: FontAwesomeIcons.bookOpen,
                    title: S.of(context).onboarding_books_title,
                    description: S.of(context).onboarding_books_desc,
                  ),
                  _OnboardingSlide(
                    icon: FontAwesomeIcons.utensils,
                    title: S.of(context).onboarding_recipes_title,
                    description: S.of(context).onboarding_recipes_desc,
                  ),
                  _OnboardingSlide(
                    icon: FontAwesomeIcons.userGroup,
                    title: S.of(context).onboarding_sharing_title,
                    description: S.of(context).onboarding_sharing_desc,
                  ),
                  _OnboardingSlide(
                    icon: FontAwesomeIcons.rocket,
                    title: S.of(context).onboarding_ready_title,
                    description: S.of(context).onboarding_ready_desc,
                    extra: _LanguagePicker(),
                  ),
                ],
              ),
            ),

            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_totalPages, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                  width: i == _currentPage ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _currentPage
                        ? theme.primaryColor
                        : theme.textTheme.bodyMedium!.color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),

            // Action button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLast ? _finish : _nextPage,
                  child: Text(
                    isLast
                        ? S.of(context).onboarding_start
                        : S.of(context).onboarding_next,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Widget? extra;

  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.description,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ThemeMgr.getTheme(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 56,
            backgroundColor: theme.colorScheme.surface,
            child: FaIcon(icon, size: 40, color: theme.primaryColor),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: theme.textTheme.displayLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (extra != null) ...[
            const SizedBox(height: 32),
            extra!,
          ],
        ],
      ),
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentLocale = LocaleMgr.getLocale(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LangButton(
          label: '🇫🇷  Français',
          selected: currentLocale == 'fr',
          onTap: () => LocaleMgr.setLocale(context, 'fr'),
        ),
        const SizedBox(width: 16),
        _LangButton(
          label: '🇬🇧  English',
          selected: currentLocale == 'en',
          onTap: () => LocaleMgr.setLocale(context, 'en'),
        ),
      ],
    );
  }
}

class _LangButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ThemeMgr.getTheme(context)!;

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: selected ? theme.primaryColor : theme.textTheme.bodyMedium!.color!,
          width: selected ? 2 : 1,
        ),
        foregroundColor:
            selected ? theme.primaryColor : theme.textTheme.bodyMedium!.color,
      ),
      child: Text(label),
    );
  }
}
