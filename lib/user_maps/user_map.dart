import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/game_provider.dart';
import 'package:vampulv/player.dart';
import 'package:vampulv/user_maps/circular_layout.dart';

class UserMap extends ConsumerStatefulWidget {
  /// Decides how the players should appear. If non-null, every player is inputed into this function, and the resulting widget is placed at the position designated for that player. Cannot be set together with other properties deciding how the players look.
  final Widget Function(Player player)? playerAppearance;

  /// Decides which things are between the players. Generated from passing the neighbours into the function. If null, nothing is placed between players.
  final Widget Function(Player playerLeft, Player playerRight)? betweenPlayers;

  /// Determines the number of players that should be selected.
  final int numberSelected;

  final String? description;
  final bool canChooseFewer;
  final void Function(List<Player> selected) onDone;
  final void Function()? onCancel;

  const UserMap({required this.onDone, this.onCancel, this.playerAppearance, this.description, this.betweenPlayers, this.numberSelected = 0, this.canChooseFewer = false, super.key});

  @override
  ConsumerState<UserMap> createState() => _UserMapState();
}

class _UserMapState extends ConsumerState<UserMap> {
  List<int> selectedIndices = [];

  @override
  Widget build(BuildContext context) {
    List<Player> players = ref.watch(gameProvider.select((game) => game!.players));
    bool hasSelectedEnough = widget.canChooseFewer || selectedIndices.length == widget.numberSelected;
    return Column(
      children: [
        Expanded(
          child: Stack(children: [
            // The backgrounds of the players.
            CircularLayout(
                largerChildren: true,
                children: List.generate(
                    players.length,
                    (i) => Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.numberSelected == 0
                                ? Colors.orange[400]
                                : selectedIndices.contains(i)
                                    ? Colors.orange[700]
                                    : Colors.orange[300],
                          ),
                        ))),
            // The players.
            CircularLayout(
                inside: FittedBox(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.description != null) Text(widget.description!),
                      if (widget.numberSelected > 1)
                        Text(
                          '${selectedIndices.length}/${widget.numberSelected}',
                          style: TextStyle(color: hasSelectedEnough ? Colors.green[900] : Colors.red[900]),
                        ),
                    ],
                  ),
                ),
                children: List.generate(
                    players.length,
                    (i) => GestureDetector(
                          onTap: () {
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
                            } else if (selectedIndices.length < widget.numberSelected) {
                              setState(() {
                                selectedIndices.add(i);
                              });
                            }
                          },
                          child: widget.playerAppearance == null
                              ? FittedBox(
                                  child: Text(
                                    players[i].configuration.name,
                                  ),
                                )
                              : widget.playerAppearance!(players[i]),
                        ))),
            // The things between the players.
            if (widget.betweenPlayers != null)
              CircularLayout(
                  rotationOffset: math.pi / players.length,
                  children: List.generate(
                      players.length,
                      (i) => widget.betweenPlayers!(
                            players[i],
                            players[i + 1 == players.length ? 0 : i + 1],
                          ))),
          ]),
        ),
        Row(
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
                        widget.onDone(selectedIndices.map((i) => players[i]).toList());
                      }
                    : null,
                child: const Text('OK'),
              ),
            ),
          ],
        )
      ],
    );
  }
}
