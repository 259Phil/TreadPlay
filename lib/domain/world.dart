import 'dart:ui';

/// Home of a companion species. Worlds with a [background] photo show it on
/// Home; the others use their [placeholder] colour until art exists. The placeholder
/// also tints shelf cards.
enum World {
  medieval(placeholder: Color(0xFF4A4F57)),
  space(
    background: 'assets/worlds/space.jpg',
    placeholder: Color(0xFF1E2433),
    groundPlane: Color(0xFF5E6168),
    ground: 0.78,
  ),
  underwater(
    background: 'assets/worlds/underwater.jpg',
    placeholder: Color(0xFF1F4650),
    ground: 0.8,
  ),
  egypt(background: 'assets/worlds/egypt.jpg', placeholder: Color(0xFF5A4A30)),
  jungle(
    background: 'assets/worlds/jungle.jpg',
    placeholder: Color(0xFF2C4630),
    ground: 0.8,
  ),
  pirate(placeholder: Color(0xFF34505E)),
  robot(placeholder: Color(0xFF454D55)),
  rococo(placeholder: Color(0xFF5E5058)),
  steampunk(placeholder: Color(0xFF5C4A36)),
  candy(placeholder: Color(0xFF5E4A57));

  const World({
    this.background,
    this.placeholder = const Color(0xFF2A3038),
    this.groundPlane,
    this.ground = 0.76,
  });

  /// Photo backdrop, or null while the world has no art yet.
  final String? background;
  final Color placeholder;

  /// Tone of a flat painted floor laid over the photo, for photos whose own
  /// floor is not flat. Null when the photo already shows a walkable plane.
  final Color? groundPlane;

  /// Where the companion's feet stand, as a share of the scene height. Always
  /// in the lower third.
  final double ground;
}
