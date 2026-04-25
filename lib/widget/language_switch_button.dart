import 'package:flutter/material.dart';
import 'package:lenpay/l10n/app_localizations.dart';

class LanguageSwitchButton extends StatelessWidget {
  const LanguageSwitchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, locale, child) {
        final String label = AppLocalizations.translateFormat(
          context,
          'Switch to {language}',
          {'language': AppLocalizations.nextLanguageName(context)},
        );

        return OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            side: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1.5,
            ),
            backgroundColor: Theme.of(context).colorScheme.surface.withAlpha(20),
          ),
          icon: const Icon(Icons.translate, size: 20),
          label: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          onPressed: () async {
            await AppLocalizations.toggleLocale();
          },
        );
      },
    );
  }
}
