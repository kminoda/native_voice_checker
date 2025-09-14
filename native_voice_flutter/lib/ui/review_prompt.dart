import 'package:flutter/material.dart';
import 'package:native_voice_flutter/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

// Centralized review flow used by menu and auto-prompt
Future<bool> showReviewFlow(BuildContext context) async {
  final rating = await showRatingDialog(context);
  if (rating == null) return false;

  // Destinations
  final Uri reviewFormUri = Uri.parse('https://forms.gle/d6kMNCHZ9hfG9saF7');
  final Uri appStoreReviewUri = Uri.parse('https://apps.apple.com/jp/app/id6752515948?action=write-review');
  final Uri dest = rating <= 3 ? reviewFormUri : appStoreReviewUri;

  try {
    final ok = await launchUrl(dest, mode: LaunchMode.externalApplication);
    if (!ok) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.openLinkFailed)),
        );
      }
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.openLinkFailed)),
      );
    }
  }
  return true;
}

Future<int?> showRatingDialog(BuildContext context) async {
  int selected = 0;
  final isJa = Localizations.localeOf(context).languageCode == 'ja';
  final subtitle = isJa
      ? 'あなたの評価でアプリを応援しましょう'
      : 'Support the app with your rating';

  return showDialog<int>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(AppLocalizations.of(context)!.review),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final idx = i + 1;
                  final filled = selected >= idx;
                  return IconButton(
                    iconSize: 32,
                    onPressed: () {
                      setState(() => selected = idx);
                      Navigator.of(context).pop(idx);
                    },
                    icon: Icon(
                      filled ? Icons.star_rounded : Icons.star_border_rounded,
                      color: filled ? Colors.amber : Colors.white70,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        ],
      ),
    ),
  );
}
