import 'dart:ui';

/// Home of a companion species. Worlds with a [background] image show it on
/// Home; the others use their [placeholder] colour until art exists. The
/// placeholder also tints shelf cards.
enum World {
  medieval(
    background: 'assets/worlds/medieval_bg.jpg',
    placeholder: Color(0xFF4A4F57),
  ),
  space(
    background: 'assets/worlds/space_bg.jpg',
    placeholder: Color(0xFF1E2433),
  ),
  underwater(
    background: 'assets/worlds/water_bg.jpg',
    placeholder: Color(0xFF1F4650),
  ),
  egypt(
    background: 'assets/worlds/egypt_bg.jpg',
    placeholder: Color(0xFF5A4A30),
  ),
  jungle(
    background: 'assets/worlds/jungle_bg.jpg',
    placeholder: Color(0xFF2C4630),
  ),
  pirate(placeholder: Color(0xFF34505E)),
  robot(placeholder: Color(0xFF454D55)),
  rococo(placeholder: Color(0xFF5E5058)),
  steampunk(placeholder: Color(0xFF5C4A36)),
  candy(placeholder: Color(0xFF5E4A57));

  const World({this.background, this.placeholder = const Color(0xFF2A3038)});

  /// Backdrop image (BoxFit.cover), or null while the world has no art yet.
  final String? background;
  final Color placeholder;

  /// Where the companion's feet stand, as a share of the scene height. Always
  /// in the lower third, on the visible floor of the backdrop.
  double get ground => 0.78;
}
