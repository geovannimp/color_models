import 'package:meta/meta.dart';
import '../color_model.dart';
import '../helpers/color_adjustments.dart';
import '../helpers/color_converter.dart';
import '../helpers/random.dart';
import '../helpers/round_values.dart';

/// A color in the HSL color space.
///
/// The HSL color space contains channels for [hue],
/// [saturation], and [lightness].
@immutable
class HslColor extends ColorModel {
  /// A color in the HSL color space.
  ///
  /// [hue] must be `>= 0` and `<= 360`.
  ///
  /// [saturation] and [lightness] must both be `>= 0` and `<= 100`.
  ///
  /// [alpha] must be `>= 0` and `<= 1`.
  const HslColor(
    this.hue,
    this.saturation,
    this.lightness, [
    int alpha = 255,
  ])  : assert(hue >= 0 && hue <= 360),
        assert(saturation >= 0 && saturation <= 100),
        assert(lightness >= 0 && lightness <= 100),
        assert(alpha >= 0 && alpha <= 255),
        super(alpha);

  /// The hue value of this color.
  ///
  /// Ranges from `0` to `360`.
  @override
  final num hue;

  /// The saturation value of this color.
  ///
  /// Ranges from `0` to `100`.
  @override
  final num saturation;

  /// The lightness value of this color.
  ///
  /// Ranges from `0` to `100`.
  final num lightness;

  @override
  bool get isBlack => round(lightness) == 0;

  @override
  bool get isWhite => round(lightness) == 100;

  @override
  bool get isMonochromatic {
    final lightness = round(this.lightness);
    return lightness == 0 || lightness == 100 || round(saturation) == 0;
  }

  @override
  List<HslColor> lerpTo(
    ColorModel color,
    int steps, {
    bool? excludeOriginalColors = false,
  }) {
    assert(steps > 0);
    assert(excludeOriginalColors != null);

    if (color.runtimeType != HslColor) {
      color = color.toHslColor();
    }

    return List<HslColor>.from(
      ColorAdjustments.interpolateColors(
        this,
        color,
        steps,
        excludeOriginalColors: excludeOriginalColors!,
      ),
    );
  }

  /// Adjusts this colors [hue] by `180` degrees while inverting the
  /// [saturation] and [lightness] values.
  @override
  HslColor get inverted =>
      HslColor((hue + 180) % 360, 100 - saturation, 100 - lightness, alpha);

  @override
  HslColor get opposite => rotateHue(180);

  @override
  HslColor rotateHue(num amount) {
    return withHue((hue + amount) % 360);
  }

  @override
  HslColor warmer(num amount, {bool? relative = true}) {
    assert(amount > 0);
    assert(relative != null);
    if (relative!) assert(amount <= 100);

    return withHue(ColorAdjustments.warmerHue(hue, amount, relative: relative));
  }

  @override
  HslColor cooler(num amount, {bool? relative = true}) {
    assert(amount > 0);
    assert(relative != null);
    if (relative!) assert(amount <= 100);

    return withHue(ColorAdjustments.coolerHue(hue, amount, relative: relative));
  }

  /// Returns this [HslColor] modified with the provided [hue] value.
  @override
  HslColor withHue(num hue) {
    assert(hue >= 0 && hue <= 360);

    return HslColor(hue, saturation, lightness, alpha);
  }

  /// Returns this [HslColor] modified with the provided [saturation] value.
  HslColor withSaturation(num saturation) {
    assert(saturation >= 0 && saturation <= 100);

    return HslColor(hue, saturation, lightness, alpha);
  }

  /// Returns this [HslColor] modified with the provided [lightness] value.
  HslColor withLightness(num lightness) {
    assert(lightness >= 0 && lightness <= 100);

    return HslColor(hue, saturation, lightness, alpha);
  }

  /// Returns this [HslColor] modified with the provided [alpha] value.
  @override
  HslColor withAlpha(int alpha) {
    assert(alpha >= 0 && alpha <= 255);

    return HslColor(hue, saturation, lightness, alpha);
  }

  @override
  HslColor withOpacity(double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0);

    return withAlpha((opacity * 255).round());
  }

  @override
  RgbColor toRgbColor() => ColorConverter.hslToRgb(this);

  @override
  HslColor toHslColor() => this;

  /// Returns a fixed-length [List] containing the [hue],
  /// [saturation], and [lightness] values, in that order.
  @override
  List<num> toList() =>
      List<num>.from(<num>[hue, saturation, lightness], growable: false);

  /// Returns a fixed-length [List] containing the [hue], [saturation],
  /// [lightness], and [alpha] values, in that order.
  @override
  List<num> toListWithAlpha() =>
      List<num>.from(<num>[hue, saturation, lightness, alpha], growable: false);

  /// Returns a fixed-length list containing the [hue], [saturation],
  /// and [lightness] values factored to be on 0 to 1 scale.
  List<double> toFactoredList() => List<double>.from(<double>[
        hue / 360,
        saturation / 100,
        lightness / 100,
      ], growable: false);

  /// Returns a fixed-length list containing the [hue], [saturation],
  /// [lightness], and [alpha] values factored to be on 0 to 1 scale.
  List<double> toFactoredListWithAlpha() => List<double>.from(<double>[
        hue / 360,
        saturation / 100,
        lightness / 100,
        alpha / 255,
      ], growable: false);

  /// Constructs a [HslColor] from [color].
  factory HslColor.from(ColorModel color) {
    return color.toHslColor();
  }

  /// Constructs a [HslColor] from a list of [hsl] values.
  ///
  /// [hsl] must not be null and must have exactly `3` or `4` values.
  ///
  /// The hue must be `>= 0` and `<= 360`.
  ///
  /// The saturation and lightness must both be `>= 0` and `<= 100`.
  ///
  /// The [alpha] value, if included, must be `>= 0 && <= 255`.
  factory HslColor.fromList(List<num> hsl) {
    assert((hsl.length == 3 || hsl.length == 4));
    assert(hsl[0] >= 0 && hsl[0] <= 360);
    assert(hsl[1] >= 0 && hsl[1] <= 100);
    assert(hsl[2] >= 0 && hsl[2] <= 100);
    if (hsl.length == 4) {
      assert(hsl[3] >= 0 && hsl[3] <= 255);
    }

    final alpha = hsl.length == 4 ? hsl[3].round() : 255;

    return HslColor(hsl[0], hsl[1], hsl[2], alpha);
  }

  /// Constructs a [HslColor] from a [hex] color.
  ///
  /// [hex] is case-insensitive and must be `3` or `6` characters
  /// in length, excluding an optional leading `#`.
  factory HslColor.fromHex(String hex) {
    return ColorConverter.hexToRgb(hex).toHslColor();
  }

  /// Constructs a [HslColor] from a list of [hsl] values on a `0` to `1` scale.
  ///
  /// [hsl] must not be null and must have exactly `3` or `4` values.
  ///
  /// Each of the values must be `>= 0` and `<= 1`.
  factory HslColor.extrapolate(List<double> hsl) {
    assert((hsl.length == 3 || hsl.length == 4));
    assert(hsl[0] >= 0 && hsl[0] <= 1);
    assert(hsl[1] >= 0 && hsl[1] <= 1);
    assert(hsl[2] >= 0 && hsl[2] <= 1);
    if (hsl.length == 4) {
      assert(hsl[3] >= 0 && hsl[3] <= 1);
    }

    final alpha = hsl.length == 4 ? (hsl[3] * 255).round() : 255;

    return HslColor(hsl[0] * 360, hsl[1] * 100, hsl[2] * 100, alpha);
  }

  /// Generates a [HslColor] at random.
  ///
  /// [minHue] and [maxHue] constrain the generated [hue] value. If
  /// `minHue < maxHue`, the range will run in a clockwise direction
  /// between the two, however if `minHue > maxHue`, the range will
  /// run in a counter-clockwise direction. Both [minHue] and [maxHue]
  /// must be `>= 0 && <= 360` and must not be `null`.
  ///
  /// [minSaturation] and [maxSaturation] constrain the generated [saturation]
  /// value.
  ///
  /// [minLightness] and [maxLightness] constrain the generated [lightness]
  /// value.
  ///
  /// Min and max values, besides hues, must be `min <= max && max >= min`,
  /// must be in the range of `>= 0 && <= 100`, and must not be `null`.
  factory HslColor.random({
    num minHue = 0,
    num maxHue = 360,
    num minSaturation = 0,
    num maxSaturation = 100,
    num minLightness = 0,
    num maxLightness = 100,
  }) {
    assert(minHue >= 0 && minHue <= 360);
    assert(maxHue >= 0 && maxHue <= 360);
    assert(minSaturation >= 0 && minSaturation <= maxSaturation);
    assert(maxSaturation >= minSaturation && maxSaturation <= 100);
    assert(minLightness >= 0 && minLightness <= maxLightness);
    assert(maxLightness >= minLightness && maxLightness <= 100);

    return HslColor(
      randomHue(minHue, maxHue),
      random(minSaturation, maxSaturation),
      random(minLightness, maxLightness),
    );
  }

  @override
  String toString() => 'HslColor($hue, $saturation, $lightness, $alpha)';

  @override
  bool operator ==(Object o) =>
      o is HslColor &&
      round(hue) == round(o.hue) &&
      round(saturation) == round(o.saturation) &&
      round(lightness) == round(o.lightness) &&
      alpha == o.alpha;

  @override
  int get hashCode =>
      hue.hashCode ^ saturation.hashCode ^ lightness.hashCode ^ alpha.hashCode;
}
