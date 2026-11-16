import 'package:flutter/foundation.dart';

/// Represents different device categories and target platforms.
enum DeviceType {
  mobile,
  tablet,
  desktop,
  web,
  android,
  ios,
  macos,
  windows,
  linux,
  fuchsia;

  /// Returns `true` if this is [DeviceType.mobile].
  bool get isMobile => this == DeviceType.mobile;

  /// Returns `true` if this is [DeviceType.tablet].
  bool get isTablet => this == DeviceType.tablet;

  /// Returns `true` if this is [DeviceType.desktop].
  bool get isDesktop => this == DeviceType.desktop;

  /// Returns `true` if this is [DeviceType.web].
  bool get isWeb => this == DeviceType.web;

  /// Returns `true` if this is a mobile platform ([android] or [ios]).
  bool get isMobilePlatform =>
      this == DeviceType.android || this == DeviceType.ios;

  /// Returns `true` if this is a desktop platform ([macos], [windows], or [linux]).
  bool get isDesktopPlatform =>
      this == DeviceType.macos ||
      this == DeviceType.windows ||
      this == DeviceType.linux;

  /// Attempts to parse a string into a [DeviceType].
  ///
  /// Returns `null` if the string cannot be parsed.
  /// Accepts case-insensitive names and common aliases (e.g. 'phone' -> mobile, 'pc' -> desktop).
  static DeviceType? tryParse(String value) {
    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'mobile':
      case 'phone':
      case 'cellphone':
      case 'handset':
        return DeviceType.mobile;
      case 'tablet':
      case 'tab':
      case 'ipad':
        return DeviceType.tablet;
      case 'desktop':
      case 'pc':
      case 'laptop':
      case 'mac':
      case 'computer':
        return DeviceType.desktop;
      case 'web':
      case 'browser':
      case 'webpage':
        return DeviceType.web;
      case 'android':
        return DeviceType.android;
      case 'ios':
      case 'iphone':
        return DeviceType.ios;
      case 'macos':
      case 'osx':
        return DeviceType.macos;
      case 'windows':
      case 'win':
        return DeviceType.windows;
      case 'linux':
        return DeviceType.linux;
      case 'fuchsia':
        return DeviceType.fuchsia;
      default:
        return null;
    }
  }

  /// Parses a string into a [DeviceType], throwing [ArgumentError] if invalid.
  static DeviceType fromString(String value) {
    final result = tryParse(value);
    if (result == null) {
      throw ArgumentError.value(value, 'value', 'Unknown device type');
    }
    return result;
  }

  /// Converts an object (either a [DeviceType] or a [String]) into a [DeviceType].
  ///
  /// Returns `null` if the object is neither or cannot be parsed.
  static DeviceType? from(dynamic value) {
    if (value is DeviceType) return value;
    if (value is String) return tryParse(value);
    return null;
  }

  /// Determines the screen [DeviceType] based on [width] and the given [breakpoints].
  static DeviceType fromWidth(
    double width, {
    DeviceBreakpoints breakpoints = DeviceBreakpoints.defaults,
  }) {
    if (width < breakpoints.mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < breakpoints.tabletBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }
}

/// Defines screen width breakpoints for categorizing devices.
@immutable
class DeviceBreakpoints {
  /// Maximum width for mobile devices (exclusive). Default is `600.0`.
  final double mobileBreakpoint;

  /// Maximum width for tablet devices (exclusive). Default is `1024.0`.
  final double tabletBreakpoint;

  const DeviceBreakpoints({
    this.mobileBreakpoint = 600.0,
    this.tabletBreakpoint = 1024.0,
  }) : assert(
          mobileBreakpoint < tabletBreakpoint,
          'mobileBreakpoint must be less than tabletBreakpoint',
        );

  /// Default breakpoints: mobile < 600, tablet < 1024, desktop >= 1024.
  static const DeviceBreakpoints defaults = DeviceBreakpoints();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceBreakpoints &&
          runtimeType == other.runtimeType &&
          mobileBreakpoint == other.mobileBreakpoint &&
          tabletBreakpoint == other.tabletBreakpoint;

  @override
  int get hashCode => mobileBreakpoint.hashCode ^ tabletBreakpoint.hashCode;

  @override
  String toString() =>
      'DeviceBreakpoints(mobile: <$mobileBreakpoint, tablet: <$tabletBreakpoint, desktop: >=$tabletBreakpoint)';
}
