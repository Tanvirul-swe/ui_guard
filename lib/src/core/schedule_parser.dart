class CronParseResult {
  final bool isValid;
  final String? error;

  const CronParseResult.valid()
      : isValid = true,
        error = null;

  const CronParseResult.invalid(this.error) : isValid = false;
}

/// Parses and evaluates cron expressions with support for
/// wildcards, lists, ranges, and steps (e.g. */5, 1-10/2).
class ScheduleParser {
  static const Map<String, String> _macros = {
    '@yearly': '0 0 1 1 *',
    '@annually': '0 0 1 1 *',
    '@monthly': '0 0 1 * *',
    '@weekly': '0 0 * * 0',
    '@daily': '0 0 * * *',
    '@midnight': '0 0 * * *',
    '@hourly': '0 * * * *',
  };

  static const Map<String, int> _months = {
    'jan': 1,
    'feb': 2,
    'mar': 3,
    'apr': 4,
    'may': 5,
    'jun': 6,
    'jul': 7,
    'aug': 8,
    'sep': 9,
    'oct': 10,
    'nov': 11,
    'dec': 12,
  };

  static const Map<String, int> _weekdays = {
    'sun': 0,
    'mon': 1,
    'tue': 2,
    'wed': 3,
    'thu': 4,
    'fri': 5,
    'sat': 6,
  };

  static String normalize(String cron) {
    final trimmed = cron.trim();
    if (_macros.containsKey(trimmed.toLowerCase())) {
      return _macros[trimmed.toLowerCase()]!;
    }
    return trimmed;
  }

  static CronParseResult validate(String cron) {
    final normalized = normalize(cron);
    final parts = normalized.split(RegExp(r'\s+'));
    if (parts.length != 5) {
      return const CronParseResult.invalid('Expected 5 cron fields.');
    }

    final validations = [
      _validatePart(parts[0], 0, 59),
      _validatePart(parts[1], 0, 23),
      _validatePart(parts[2], 1, 31),
      _validatePart(parts[3], 1, 12, aliases: _months),
      _validatePart(parts[4], 0, 7, aliases: _weekdays),
    ];

    for (final v in validations) {
      if (!v.isValid) return v;
    }

    return const CronParseResult.valid();
  }

  static bool matches(String cron, DateTime now) {
    final normalized = normalize(cron);
    final validation = validate(normalized);
    if (!validation.isValid) return false;

    final parts = normalized.split(RegExp(r'\s+'));
    final weekday = now.weekday % 7;

    return _matchPart(parts[0], now.minute, 0, 59) &&
        _matchPart(parts[1], now.hour, 0, 23) &&
        _matchPart(parts[2], now.day, 1, 31) &&
        _matchPart(parts[3], now.month, 1, 12, aliases: _months) &&
        _matchPart(parts[4], weekday, 0, 7, aliases: _weekdays);
  }

  static CronParseResult _validatePart(
    String rawPart,
    int min,
    int max, {
    Map<String, int>? aliases,
  }) {
    final part = rawPart.toLowerCase();
    for (final token in part.split(',')) {
      final slash = token.split('/');
      if (slash.length > 2) {
        return CronParseResult.invalid('Invalid step syntax in "$rawPart"');
      }

      final base = slash[0];
      final step = slash.length == 2 ? int.tryParse(slash[1]) : null;
      if (slash.length == 2 && (step == null || step <= 0)) {
        return CronParseResult.invalid('Invalid step value in "$rawPart"');
      }

      if (base == '*') continue;

      if (base.contains('-')) {
        final range = base.split('-');
        if (range.length != 2) {
          return CronParseResult.invalid('Invalid range in "$rawPart"');
        }
        final start = _parseValue(range[0], aliases);
        final end = _parseValue(range[1], aliases);
        if (start == null || end == null || start < min || end > max || start > end) {
          return CronParseResult.invalid('Range out of bounds in "$rawPart"');
        }
      } else {
        final value = _parseValue(base, aliases);
        if (value == null || value < min || value > max) {
          return CronParseResult.invalid('Value out of bounds in "$rawPart"');
        }
      }
    }

    return const CronParseResult.valid();
  }

  static bool _matchPart(
    String rawPart,
    int current,
    int min,
    int max, {
    Map<String, int>? aliases,
  }) {
    final part = rawPart.toLowerCase();
    return part.split(',').any((token) {
      final slash = token.split('/');
      final base = slash[0];
      final step = slash.length == 2 ? int.parse(slash[1]) : 1;

      if (base == '*') {
        return (current - min) % step == 0;
      }

      if (base.contains('-')) {
        final range = base.split('-');
        final start = _parseValue(range[0], aliases)!;
        final end = _parseValue(range[1], aliases)!;
        if (current < start || current > end) return false;
        return (current - start) % step == 0;
      }

      final value = _parseValue(base, aliases)!;
      return current == value;
    });
  }

  static int? _parseValue(String input, Map<String, int>? aliases) {
    final lowered = input.toLowerCase();
    if (aliases != null && aliases.containsKey(lowered)) {
      return aliases[lowered];
    }
    return int.tryParse(lowered);
  }
}
