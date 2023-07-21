import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/game_provider.dart';
import 'package:vampulv/network/connected_device_provider.dart';
import 'package:vampulv/network/message_sender_provider.dart';
import 'package:vampulv/player.dart';
import 'package:vampulv/user_maps/circular_layout.dart';
import 'package:vampulv/user_maps/player_in_map.dart';

class PlayerMap extends ConsumerStatefulWidget {
  /// Decides how the players should appear. If non-null, every player is inputed into this function, and the resulting widget is placed at the position designated for that player. Cannot be set together with other properties deciding how the players look.
  final Widget Function(Player player)? playerAppearance;

  /// Decides which things are between the players. Generated from passing the neighbours into the function. If null, nothing is placed between players.
  final Widget Function(Player playerLeft, Player playerRight)? betweenPlayers;

  /// Determines the number of players that should be selected.
  final int numberSelected;

  /// Function to be called when user has clicked the OK button.
  final void Function(List<Player> selected)? onDone;

  /// If non-null, a PlayerInput will be sent with this identifier when player presses the OK button. The message from the user input will be a ; separated list of the ids of the players that were selected, or 'none' if no player were selected.
  final String? identifier;

  final String? description;
  final bool canChooseFewer;
  final bool deadPlayersSelectable;
  final bool canSelectSelf;
  final List<int> selectablePlayerFilter;
  final bool filterIsWhitelist;
  final void Function()? onCancel;

  PlayerMap({
    this.onDone,
    this.identifier,
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
    Key? key,
  })  : assert(onDone != null || identifier != null, 'At least one of onDone or identifier must be non-null.'),
        super(key: key ?? (identifier == null ? null : Key(identifier)));

  @override
  ConsumerState<PlayerMap> createState() => _UserMapState();
}

class _UserMapState extends ConsumerState<PlayerMap> {
  // Should perhaps save selected player ids instead.
  List<int> selectedIndices = [];

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(cGameProvider.select((game) => game!.players));
    final controlledPlayer = ref.watch(controlledPlayerProvider);
    final hasSelectedEnough = widget.canChooseFewer || selectedIndices.length == widget.numberSelected;
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
      final rotationCurrent =
          controlledPlayer == null ? .0 : -players.indexWhere((player) => player.id == controlledPlayer.id) * 2 * math.pi / players.length;
      final Widget playersWidget = CircularLayout(
          largerChildren: true,
          rotationOffset: rotationCurrent,
          inside: descriptionText,
          children: List.generate(
              players.length,
              (i) => widget.playerAppearance == null
                  ? PlayerInMap(
                      players[i],
                      selected: selectedIndices.contains(i),
                      onSelect: (selectedIndices.length < widget.numberSelected || widget.numberSelected == 1 || selectedIndices.contains(i)) &&
                              (players[i].alive || widget.deadPlayersSelectable) &&
                              (players[i].id != controlledPlayer?.id || widget.canSelectSelf) &&
                              (widget.selectablePlayerFilter.any((id) => id == players[i].id) == widget.filterIsWhitelist)
                          ? () {
                              if (selectedIndices.contains(i)) {
                                setState(() {
                                  selectedIndices.remove(i);
                                });
                              } else if (widget.numberSelected == 1) {
                                setState(() {
                                  selectedIndices = [i];
                                });
                              } else {
                                setState(() {
                                  selectedIndices.add(i);
                                });
                              }
                            }
                          : null,
                    )
                  : widget.playerAppearance!(players[i])));
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
                          if (widget.onDone != null) {
                            widget.onDone!(selectedIndices.map((i) => players[i]).toList());
                          }
                          if (widget.identifier != null) {
                            ref.read(cMessageSenderProvider).sendPlayerInput(
                                selectedIndices.isEmpty ? 'none' : selectedIndices.map((index) => players[index].id).join(';'),
                                widget.identifier!);
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
