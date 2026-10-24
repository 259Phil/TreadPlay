import 'package:flutter/material.dart';

import '../domain/companion.dart';
import '../l10n/app_localizations.dart';
import 'format.dart';

/// Shown name of [r].
String recipeName(AppLocalizations l, Recipe r) => switch (r) {
  Recipe.ausdauer => l.recipeNameAusdauer,
  Recipe.faehrte => l.recipeNameFaehrte,
  Recipe.schutz => l.recipeNameSchutz,
  Recipe.wanderstern => l.recipeNameWanderstern,
  Recipe.spurenleser => l.recipeNameSpurenleser,
  Recipe.glutherz => l.recipeNameGlutherz,
};

/// The fixed hint an undiscovered recipe shows in the tree.
String recipeHint(AppLocalizations l, Recipe r) => switch (r) {
  Recipe.ausdauer => l.recipeHintAusdauer,
  Recipe.faehrte => l.recipeHintFaehrte,
  Recipe.schutz => l.recipeHintSchutz,
  Recipe.wanderstern => l.recipeHintWanderstern,
  Recipe.spurenleser => l.recipeHintSpurenleser,
  Recipe.glutherz => l.recipeHintGlutherz,
};

/// Who [r] suits.
String recipeFor(AppLocalizations l, Recipe r) => switch (r) {
  Recipe.ausdauer => l.recipeForAusdauer,
  Recipe.faehrte => l.recipeForFaehrte,
  Recipe.schutz => l.recipeForSchutz,
  Recipe.wanderstern => l.recipeForWanderstern,
  Recipe.spurenleser => l.recipeForSpurenleser,
  Recipe.glutherz => l.recipeForGlutherz,
};

/// What [r] does at [level], e.g. "Sweet-Spot ±0,4 km/h breiter".
String recipeEffectText(BuildContext context, Recipe r, int level) {
  final l = AppLocalizations.of(context);
  final v = r.at(level);
  String pts(double f) => formatNumber(context, f * 100);
  return switch (r.effect) {
    RecipeEffect.sweetSpotWidth => l.recipeFxSweetSpot(
      formatNumber(context, v, pattern: '0.0'),
    ),
    RecipeEffect.pouchChance => l.recipeFxPouch(pts(v)),
    RecipeEffect.failCut => l.recipeFxFail(pts(v)),
    RecipeEffect.messengerChance => l.recipeFxMessenger(pts(v)),
    RecipeEffect.pouchWarmth => l.recipeFxWarm(pts(v)),
    RecipeEffect.glutChance => l.recipeFxGlut(pts(v)),
  };
}

/// Stat split of a recipe seal at [level]: "+11 % / +7 %".
String recipeSplitText(BuildContext context, Recipe r, int level) {
  final s = r.tier == 1
      ? Seal.combined(r.a, r.b, level)
      : Seal.triple(r.a, r.b, r.extra!, level);
  return sealSplitText(context, s);
}

/// Bonus on every stat of [s], lead first: "+11 % / +7 %".
String sealSplitText(BuildContext context, Seal s) {
  final l = AppLocalizations.of(context);
  return [
    for (final t in s.stats)
      l.statBonus(formatNumber(context, s.bonusOn(t) * 100)),
  ].join(' / ');
}

/// Colour of a level-2 recipe (its seal art is tinted with it).
Color? recipeTint(Recipe r) => switch (r) {
  Recipe.wanderstern => const Color(0xFF7FB8FF),
  Recipe.spurenleser => const Color(0xFF9BE07A),
  Recipe.glutherz => const Color(0xFFFF8A5C),
  _ => null,
};

/// Emblem of [recipe] at [level] (its frame climbs with the level, see
/// [Seal.recipeAsset]) for the tree and the effect lists.
class RecipeArt extends StatelessWidget {
  const RecipeArt({
    super.key,
    required this.recipe,
    required this.size,
    this.level = 3,
  });

  final Recipe recipe;
  final double size;
  final int level;

  @override
  Widget build(BuildContext context) => Image.asset(
    Seal.recipeAsset(recipe, level),
    width: size,
    height: size,
    fit: BoxFit.contain,
    filterQuality: FilterQuality.medium,
  );
}

/// "Rezept-Effekte" of [companion]'s sockets, one line per recipe (the
/// highest level of each). They work only while it is taken along
/// ([along]); otherwise a note says so.
class RecipeEffects extends StatelessWidget {
  const RecipeEffects({
    super.key,
    required this.companion,
    required this.along,
  });

  final Companion companion;
  final bool along;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final active = companion.recipes;
    const accent = Color(0xFF8FF0E2);
    // Nothing to show without a recipe seal; the detail stays short.
    if (active.isEmpty) return const SizedBox.shrink();
    return Column(
      key: const Key('recipe-effects'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.recipeEffectsTitle,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        if (active.isEmpty)
          Text(
            l.recipeEffectsNone,
            style: const TextStyle(color: Color(0xFF9A8A78), fontSize: 13),
          )
        else ...[
          for (final MapEntry(key: r, value: lv) in active.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                key: Key('recipe-effect-${r.name}'),
                children: [
                  Opacity(
                    opacity: along ? 1 : .5,
                    child: RecipeArt(recipe: r, size: 28, level: lv),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l.recipeEffectLine(
                        recipeName(l, r),
                        lv,
                        recipeEffectText(context, r, lv),
                      ),
                      style: TextStyle(
                        color: along ? accent : const Color(0xFF9A8A78),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (!along)
            Text(
              l.recipeEffectsIdle(companion.name),
              style: const TextStyle(
                color: Color(0xFF9A8A78),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ],
    );
  }
}
