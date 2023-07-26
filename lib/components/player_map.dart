import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game_logic/game_provider.dart';
import '../game_logic/player.dart';
import '../network/connected_device_provider.dart';
import '../network/message_sender_provider.dart';
import 'circular_layout.dart';
import 'player_in_map.dart';

class PlayerMap extends ConsumerStatefulWidget {
  /// Decides how the players should appear. If non-null, every player is inputed into this function, and the resulting widget is placed at the position designated for that player. Cannot be set together with other properties deciding how the players look.
  final Widget Function(Player player)? playerAppearance;

  /// Decides which things are between the players. Generated from passing the neighbours into the function. If null, nothing is placed between players.
  final Widget Function(Player playerLeft, Player playerRight)? betweenPlayers;

  /// Determines the number of players that should be selected.
  final int numberSelected;

  /// Function to be called when user has clicked the OK button. If null, a PlayerInput will be sent instead. The message from the user input will be a ; separated list of the ids of the players that were selected, or 'none' if no player were selected.
  final void Function(List<Player> selected)? onDone;

  final String? description;
  final bool canChooseFewer;
  final bool deadPlayersSelectable;
  final bool canSelectSelf;
  final List<int> selectablePlayerFilter;
  final bool filterIsWhitelist;
  final String? reasonForbidden;
  final void Function()? onCancel;

  PlayerMap({
    this.onCancel,
    this.playerAppearance,
    this.description,
    this.betweenPlayers,
    this.numberSelected = 0,
    this.canChooseFewer = false,
    this.deadPlayersSelectable = false,
    this.canSelectSelf = true,
    this.selectablePlayerFilter = const [],
    this.filterIsWhitelist = false,
    this.reasonForbidden,
    required this.onDone,
    Key? key,
  }) : super(key: key ?? (description == null ? null : Key(description)));

  @override
  ConsumerState<PlayerMap> createState() => _UserMapState();

  String? playerIsSelectable(Player player, int? controlledPlayerId) {
    if (player.id == controlledPlayerId && !canSelectSelf) {
      return 'Du kan inte välja dig själv.';
    }
    if (!player.alive && !deadPlayersSelectable) {
      return 'Du kan inte välja döda personer.';
    }
    if ((selectablePlayerFilter.any((id) => id == player.id) != filterIsWhitelist)) {
      return reasonForbidden;
    }
    return null;
  }
}

class _UserMapState extends ConsumerState<PlayerMap> {
  // Should perhaps save selected player ids instead.
  List<int> selectedIndices = [];

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(cGameProvider.select((game) => game!.players));
    final controlledPlayer = ref.watch(controlledPlayerProvider);
    final hasSelectedEnough = widget.canChooseFewer || selectedIndices.length == widget.numberSelected;
    selectedIndices = selectedIndices.where((selected) => widget.playerIsSelectable(players[selected], controlledPlayer?.id) == null).toList();
    Widget descriptionText = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.description != null)
          Expanded(
            child: Center(
              child: AutoSizeText(
                widget.description!,
                minFontSize: 8,
                maxLines: 5,
                wrapWords: false,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 50),
              ),
            ),
          ),
        if (widget.numberSelected > 1)
          Text(
            '${selectedIndices.length}/${widget.numberSelected}',
            style: TextStyle(color: hasSelectedEnough ? Colors.green[900] : Colors.red[900]),
          ),
      ],
    );
    return LayoutBuilder(builder: (context, constraints) {
      final buttonsBelow = constraints.maxHeight >= constraints.maxWidth;
      final rotationCurrent = controlledPlayer == null ? .0 : -players.indexWhere((player) => player.id == controlledPlayer.id) * 2 * math.pi / players.length;
      final Widget playersWidget = CircularLayout(
          largerChildren: true,
          rotationOffset: rotationCurrent,
          inside: descriptionText,
          children: List.generate(players.length, (i) {
            late final SelectedLevel selectedLevel;
            if (selectedIndices.contains(i)) {
              selectedLevel = SelectedLevel.selected;
            } else if (widget.playerIsSelectable(players[i], controlledPlayer?.id) != null) {
              selectedLevel = SelectedLevel.forbidden;
            } else if (selectedIndices.length < widget.numberSelected || widget.numberSelected == 1) {
              selectedLevel = SelectedLevel.selectable;
            } else {
              selectedLevel = SelectedLevel.selectableButMax;
            }
            return widget.playerAppearance == null
                ? PlayerInMap(
                    players[i],
                    selectedLevel: selectedLevel,
                    reasonForbidden: widget.playerIsSelectable(players[i], controlledPlayer?.id),
                    onSelect: () {
                      if (selectedIndices.contains(i)) {
                        setState(() {
                          selectedIndices.remove(i);
                        });
                      } else if (widget.numberSelected == 1) {
                        setState(() {
                          selectedIndices = [
                            i
                          ];
                        });
                      } else {
                        setState(() {
                          selectedIndices.add(i);
                        });
                      }
                    },
                  )
                : widget.playerAppearance!(players[i]);
          }));
      return Flex(
        direction: buttonsBelow ? Axis.vertical : Axis.horizontal,
        children: [
          Expanded(
            child: widget.betweenPlayers == null
                ? playersWidget
                : Stack(children: [
                    playersWidget,
                    // The things between the players.
                    if (widget.betweenPlayers != null)
                      CircularLayout(
                          rotationOffset: rotationCurrent + math.pi / players.length,
                          children: List.generate(
                              players.length,
                              (i) => widget.betweenPlayers!(
                                    players[i],
                                    players[i + 1 == players.length ? 0 : i + 1],
                                  ))),
                  ]),
          ),
          Flex(
            direction: buttonsBelow ? Axis.horizontal : Axis.vertical,
            children: [
              if (widget.onCancel != null)
                Expanded(
                  child: MaterialButton(
                    onPressed: widget.onCancel,
                    child: const Text('Avbryt'),
                  ),
                ),
              Expanded(
                child: MaterialButton(
                  onPressed: hasSelectedEnough
                      ? () {
                          if (widget.onDone == null) {
                            ref.read(cMessageSenderProvider).sendPlayerInput(selectedIndices.isEmpty ? 'none' : selectedIndices.map((index) => players[index].id).join(';'));
                          } else {
                            widget.onDone!(selectedIndices.map((i) => players[i]).toList());
                          }
                        }
                      : null,
                  child: const Text('OK'),
                ),
              ),
            ],
          )
        ],
      );
    });
  }
}
