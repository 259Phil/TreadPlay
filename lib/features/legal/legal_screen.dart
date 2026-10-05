import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import 'legal_texts.dart';

/// Full privacy policy or terms, rendered from the Markdown-like source:
/// `## ` headings, `- ` bullets, blank lines between paragraphs.
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.doc});

  final LegalDoc doc;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final text = legalText(doc, Localizations.localeOf(context).languageCode);
    final blocks = text.split(RegExp(r'\n\s*\n'));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          doc == LegalDoc.privacy ? l.settingsPrivacyTitle : l.settingsTerms,
        ),
      ),
      body: SelectionArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            for (final block in blocks) ..._block(block.trim(), theme),
          ],
        ),
      ),
    );
  }

  List<Widget> _block(String block, ThemeData theme) {
    final lines = block.split('\n').map((s) => s.trimRight()).toList();
    if (lines.first.startsWith('## ')) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 6),
          child: Text(
            lines.first.substring(3),
            style: theme.textTheme.titleMedium?.copyWith(
              color: TreadColors.brass,
            ),
          ),
        ),
        if (lines.length > 1) ..._block(lines.skip(1).join('\n'), theme),
      ];
    }
    if (lines.every((s) => s.startsWith('- '))) {
      return [
        for (final s in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('•  ', style: theme.textTheme.bodyMedium),
                Expanded(
                  child: Text(
                    s.substring(2),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
      ];
    }
    return [
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(lines.join('\n'), style: theme.textTheme.bodyMedium),
      ),
    ];
  }
}
