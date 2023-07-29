import 'package:darq/darq.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game_logic/game_provider.dart';
import '../game_logic/role_type.dart';
import '../network/synchronized_data_provider.dart';
import '../utility/list_strings_nicely.dart';
import 'role_description.dart';

class ContextAwareText extends ConsumerStatefulWidget {
  final String rawText;
  final TextStyle? style;
  final TextAlign? textAlign;

  ContextAwareText(this.rawText, {this.style, this.textAlign, super.key}) : assert(isValid(rawText), 'rawText is in an incorrect format.');

  @override
  ConsumerState<ContextAwareText> createState() => _ContextAwareTextState();

  static bool isValid(String rawText) {
    // Check that every & has nothing before and a RoleType after
    if (RegExp(r'(\w*)&(\w*)')
        .allMatches(rawText)
        .any((match) => match.group(1)!.isNotEmpty || RoleType.values.every((role) => role.name != match.group(2)))) {
      return false;
    }

    // Check that every AND and OR has links before and after
    for (int before = 0; before < rawText.length; before++) {
      int? after;
      if (before < rawText.length - 3 && rawText.substring(before, before + 3) == 'AND') {
        after = before + 3;
      }
      if (before < rawText.length - 2 && rawText.substring(before, before + 2) == 'OR') {
        after = before + 2;
      }
      if (after != null && (!RegExp(r'&\w+ $').hasMatch(rawText.substring(0, before)) || !RegExp(r'^ &').hasMatch(rawText.substring(after)))) {
        return false;
      }
    }

    // Check that AND and OR are not sharing any roles
    if (RegExp(r'AND[^&]*&[^&]*OR|OR[^&]*&[^&]*AND').hasMatch(rawText)) {
      return false;
    }

    // Check that the [ and ] are paired correctly and not nested
    bool lastWasStart = false;
    for (int i = 0; i < rawText.length; i++) {
      if (rawText[i] == '[') {
        if (lastWasStart) {
          return false;
        }
        lastWasStart = true;
      }
      if (rawText[i] == ']') {
        if (!lastWasStart) {
          return false;
        }
        lastWasStart = false;
      }
    }
    if (lastWasStart) {
      return false;
    }

    // Every test passed
    return true;
  }
}

class _ContextAwareTextState extends ConsumerState<ContextAwareText> {
  late List<TapGestureRecognizer> _tapRecognizers;

  @override
  void initState() {
    super.initState();
    _tapRecognizers = [];
  }

  @override
  void didUpdateWidget(ContextAwareText oldWidget) {
    for (final recognizer in _tapRecognizers) {
      recognizer.dispose();
    }
    _tapRecognizers = [];
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    for (final recognizer in _tapRecognizers) {
      recognizer.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get everything needed from riverpods ref
    final game = ref.watch(cGameProvider);
    final rolesInGame = game == null
        ? RoleType.values
        : ref
            .watch(gameConfigurationProvider.select((gameConfirguration) => gameConfirguration.forcedRoles + gameConfirguration.ordinaryRoles));

    // Remove text inside [] that contains links not in the game
    final fixedTexted = widget.rawText.replaceAllMapped(
      RegExp(r'\[([^\]]*)\]'), // Captures text between [ and ]
      (match) {
        final insideSquare = match[1]!.replaceAllMapped(
          RegExp(r'\w*&\w*(?: (AND|OR) \w*&\w*)*'), // Matches sequences of AND and OR with single links between
          (match) {
            final separator = match[1];
            final roles = (separator == null ? [match[0]!] : match[0]!.split(' $separator '))
                .where((roleString) => rolesInGame.any((role) => role.name == roleString.substring(1)));
            if (roles.isEmpty) {
              return '[irrelevant]';
            }
            return switch (separator) {
              'AND' => roles.listedNicelyAnd,
              'OR' => roles.listedNicelyOr,
              _ => match[0]!,
            };
          },
        );
        if (insideSquare.contains('[irrelevant]')) {
          return '';
        }
        return insideSquare;
      },
    );

    // Construct the list of inline spans that contains the text. Every other will be normal text, and every other will be clickable links.
    final findingLinksRegExp = RegExp(r'&(\w*)');
    final normalTexts = fixedTexted.split(findingLinksRegExp);
    final linkedRoles = findingLinksRegExp
        .allMatches(fixedTexted)
        .map((match) => RoleType.values.firstWhereOrDefault((role) => role.name == match.group(1)))
        .toList();
    final List<InlineSpan> spans = [];
    for (int i = 0; i < linkedRoles.length; i++) {
      spans.add(TextSpan(text: normalTexts[i]));
      final recognizer = TapGestureRecognizer();
      _tapRecognizers.add(recognizer);
      recognizer.onTap = linkedRoles[i] == null
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => RoleTypeDescription(linkedRoles[i]!),
                ),
              );
            };
      spans.add(TextSpan(
        text: linkedRoles[i]?.displayName ?? '[unknown role]',
        style: const TextStyle(
          color: Colors.brown,
          fontWeight: FontWeight.w500,
        ),
        recognizer: recognizer,
        mouseCursor: SystemMouseCursors.click,
      ));
    }
    spans.add(TextSpan(text: normalTexts.last));

    // Assemble the InlineSpans into a widget and return it.
    return Text.rich(
      TextSpan(children: spans),
      style: widget.style,
      textAlign: widget.textAlign,
    );
  }
}
