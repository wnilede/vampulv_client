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
  /// Links are created by writing '<shown>&<role>'.
  ///
  /// <shown> is the text that will be shown to the user. If it is missing the display name for the role will be used instead. If containing non-alphanumerical characters, it is neccessary to wrap <shown> in {}.
  ///
  /// <roles> is the name of the RoleType that the link should lead to a description of. It is case-sensitive in all characters except the first. The case of the first character only matter if <shown> is the empty string, in which case it will determine the case of the first character of the text shown.
  ///
  /// Surrounding a part of a text with [] makes it so that the text is only shown if every link within it leads to roles that are in the game. Within [] it is also possible to write <link> AND <link> AND <link> ... or <link> OR <link> OR <link> ... in order to only show the links that are in the game listed. If in such a list no links lead to roles that are present, the text inside [] that it is part of will not be shown.
  final String rawText;

  final TextStyle? style;
  final TextAlign? textAlign;

  ContextAwareText(this.rawText, {this.style, this.textAlign, super.key}) : assert(isValid(rawText), 'rawText is in an incorrect format.');

  @override
  ConsumerState<ContextAwareText> createState() => _ContextAwareTextState();

  static bool isValid(String rawText) {
    // Check that the [] and {} are paired correctly and not nested
    bool lastWasStartSquare = false;
    bool lastWasStartCurl = false;
    for (int i = 0; i < rawText.length; i++) {
      if (rawText[i] == '[') {
        if (lastWasStartSquare) return false;
        lastWasStartSquare = true;
      }
      if (rawText[i] == ']') {
        if (!lastWasStartSquare) return false;
        lastWasStartSquare = false;
      }
      if (rawText[i] == '{') {
        if (lastWasStartCurl) return false;
        lastWasStartCurl = true;
      }
      if (rawText[i] == '}') {
        if (!lastWasStartCurl) return false;
        lastWasStartCurl = false;
      }
    }
    if (lastWasStartSquare || lastWasStartCurl) return false;

    // Check that every & has a RoleType after and not a link before
    if (RegExp(_captureLink)
        .allMatches(rawText)
        .any((match) => (match[1] ?? match[2])!.contains('&') || RoleType.values.every((role) => _lowerFirst(role.name) != _lowerFirst(match[3]!)))) {
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
      if (after != null &&
          (!RegExp(_captureLink + r' $').hasMatch(rawText.substring(0, before)) ||
              !RegExp(r'^ ' + _captureLink).hasMatch(rawText.substring(after)))) {
        return false;
      }
    }

    // Check that AND and OR are not sharing any roles
    if (RegExp(r'AND[^&]*&[^&]*OR|OR[^&]*&[^&]*AND').hasMatch(rawText)) {
      return false;
    }

    // Check that every AND and OR are within []
    if (RegExp(r'(?:AND|OR)[^\]]*(?:\[|$)').hasMatch(rawText)) {
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
    final fixedText = widget.rawText.replaceAllMapped(
      RegExp(r'\[([^\]]*)\]'), // Captures text between [ and ]
      (match) {
        final insideSquare = match[1]!.replaceAllMapped(
          // Matches sequences of AND and OR with single links between
          RegExp(_captureLink + r'(?: (AND|OR) ' + _captureLink + r')*'),
          (match) {
            final entireChain = match[0]!;
            final separator = match[4];
            final roles = (separator == null ? [entireChain] : entireChain.split(' $separator '))
                .where((roleString) => rolesInGame.any((role) => role.name == roleString.split('&')[1]));
            if (roles.isEmpty) {
              return '[irrelevant]';
            }
            return switch (separator) {
              'AND' => roles.listedNicelyAnd,
              'OR' => roles.listedNicelyOr,
              _ => entireChain,
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
    final normalTexts = fixedText.split(RegExp(_captureLink));
    final links = RegExp(_captureLink).allMatches(fixedText).map((match) {
      final loweredRoleName = _lowerFirst(match[3]!);
      final role = RoleType.values.firstWhereOrDefault((role) => _lowerFirst(role.name) == loweredRoleName);
      String shownName = (match[1] ?? match[2])!;
      if (shownName.isEmpty) {
        shownName = role?.displayName ?? '[${match[0]}]';
        shownName = loweredRoleName == match[3] ? _lowerFirst(shownName) : _upperFirst(shownName);
      }
      return (role, shownName);
    }).toList();
    final List<InlineSpan> spans = [];
    for (int i = 0;; i++) {
      spans.add(TextSpan(text: normalTexts[i]));
      if (i == links.length) {
        break;
      }
      final recognizer = TapGestureRecognizer();
      _tapRecognizers.add(recognizer);
      recognizer.onTap = links[i].$1 == null
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => RoleTypeDescription(links[i].$1!),
                ),
              );
            };
      spans.add(TextSpan(
        text: links[i].$2,
        style: const TextStyle(
          color: Colors.brown,
          fontWeight: FontWeight.w500,
        ),
        recognizer: recognizer,
        mouseCursor: SystemMouseCursors.click,
      ));
    }

    // Assemble the InlineSpans into a widget and return it.
    return Text.rich(
      TextSpan(children: spans),
      style: widget.style,
      textAlign: widget.textAlign,
    );
  }
}

/// RegEx matching link constructs with 3 capturing groups. One of the first and the second groups captures the text that should be shown and one of them is null. The third captures the name of the RoleType to link to.
const String _captureLink = r'(?:(?:{([^{}]*)}|([\w&åäö]*))&([\wåäö]*))';

String _lowerFirst(String text) => text.substring(0, 1).toLowerCase() + text.substring(1);
String _upperFirst(String text) => text.substring(0, 1).toUpperCase() + text.substring(1);
