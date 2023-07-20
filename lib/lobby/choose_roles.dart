import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/game_configuration.dart';
import 'package:vampulv/network/message_sender_provider.dart';
import 'package:vampulv/network/synchronized_data_provider.dart';
import 'package:vampulv/role_card_view.dart';
import 'package:vampulv/roles/role_type.dart';

class ChooseRoles extends ConsumerWidget {
  const ChooseRoles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    GameConfiguration gameConfiguration =
        ref.watch(currentSynchronizedDataProvider.select((synchronizedData) => synchronizedData.game.configuration));
    return LayoutBuilder(builder: (context, constraints) {
      final listsAreHorizontal = 230 * constraints.maxWidth > 170 * constraints.maxHeight;
      return Flex(
        direction: listsAreHorizontal ? Axis.vertical : Axis.horizontal,
        children: [
          // The two DragTargets have different type variables so that they cannot react to the wrong Draggables.
          Expanded(
            child: DragTarget<RoleType>(
              onAccept: (dragged) {
                ref.read(currentMessageSenderProvider).sendGameConfiguration(gameConfiguration.copyWith(
                      roles: gameConfiguration.roles //
                          .append(dragged)
                          .orderBy((role) => role.index)
                          .toList(),
                    ));
              },
              builder: (context, candidateData, rejectedData) => ListView(
                  scrollDirection: listsAreHorizontal ? Axis.horizontal : Axis.vertical,
                  children: gameConfiguration.roles.indexed
                      .map((indexedRoleType) => LongPressDraggable<int>(
                            delay: const Duration(milliseconds: 200),
                            data: indexedRoleType.$1,
                            feedback: RoleTypeCardView(indexedRoleType.$2),
                            child: RoleTypeCardView(indexedRoleType.$2),
                          ))
                      .toList()),
            ),
          ),
          Expanded(
            child: DragTarget<int>(
              onAccept: (draggedIndex) {
                ref.read(currentMessageSenderProvider).sendGameConfiguration(gameConfiguration.copyWith(roles: [
                      // Should use exceptAt, but it does not work for first and last index.
                      ...gameConfiguration.roles.skipLast(gameConfiguration.roles.length - draggedIndex),
                      ...gameConfiguration.roles.skip(draggedIndex + 1),
                    ]));
              },
              builder: (context, candidateData, rejectedData) => ListView(
                scrollDirection: listsAreHorizontal ? Axis.horizontal : Axis.vertical,
                children: RoleType.values
                    .map(
                      (roleType) => LongPressDraggable<RoleType>(
                        delay: const Duration(milliseconds: 200),
                        data: roleType,
                        feedback: RoleTypeCardView(roleType),
                        child: RoleTypeCardView(roleType),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      );
    });
  }
}
