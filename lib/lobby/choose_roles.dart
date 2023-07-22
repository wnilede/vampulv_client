import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../components/role_card_view.dart';
import '../game_logic/game_configuration.dart';
import '../game_logic/role_type.dart';
import '../network/message_sender_provider.dart';
import '../network/synchronized_data_provider.dart';

part 'choose_roles.freezed.dart';

class ChooseRoles extends ConsumerWidget {
  const ChooseRoles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    GameConfiguration gameConfiguration =
        ref.watch(cSynchronizedDataProvider.select((synchronizedData) => synchronizedData.game.configuration));
    return LayoutBuilder(builder: (context, constraints) {
      final listsAreHorizontal = 230 * constraints.maxWidth > 170 * constraints.maxHeight;
      return Flex(
        direction: listsAreHorizontal ? Axis.vertical : Axis.horizontal,
        children: [
          // Forced roles
          _RoleList(
            title: 'Kommer vara med',
            horizontal: listsAreHorizontal,
            content: gameConfiguration.forcedRoles,
            onDraggedTo: (role, game) => game.copyWith(
              forcedRoles: game.forcedRoles //
                  .append(role)
                  .orderBy((role) => role.index)
                  .toList(),
            ),
            onDraggedFrom: (role, game) {
              final skippedIndex = game.forcedRoles.indexOf(role);
              return game.copyWith(forcedRoles: [
                ...game.forcedRoles.skipLast(gameConfiguration.forcedRoles.length - skippedIndex),
                ...game.forcedRoles.skip(skippedIndex + 1),
              ]);
            },
          ),
          // Ordinary roles
          _RoleList(
            title: 'Kanske blir med',
            horizontal: listsAreHorizontal,
            content: gameConfiguration.ordinaryRoles,
            onDraggedTo: (role, game) => game.copyWith(
              ordinaryRoles: game.ordinaryRoles //
                  .append(role)
                  .orderBy((role) => role.index)
                  .toList(),
            ),
            onDraggedFrom: (role, game) {
              final skippedIndex = game.ordinaryRoles.indexOf(role);
              return game.copyWith(ordinaryRoles: [
                ...game.ordinaryRoles.skipLast(gameConfiguration.ordinaryRoles.length - skippedIndex),
                ...game.ordinaryRoles.skip(skippedIndex + 1),
              ]);
            },
          ),
          // All roles
          _RoleList(
            title: 'Tillgängliga',
            horizontal: listsAreHorizontal,
            content: RoleType.values,
            onDraggedTo: (role, game) => game,
            onDraggedFrom: (role, game) => game,
          ),
        ],
      );
    });
  }
}

class _RoleList extends ConsumerWidget {
  final _listKey = GlobalKey<FormState>();
  final String title;
  final bool horizontal;
  final List<RoleType> content;
  final GameConfiguration Function(RoleType, GameConfiguration) onDraggedTo;
  final GameConfiguration Function(RoleType, GameConfiguration) onDraggedFrom;

  _RoleList({
    required this.title,
    required this.horizontal,
    required this.content,
    required this.onDraggedTo,
    required this.onDraggedFrom,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: DragTarget<_DraggedRole>(
        onWillAccept: (dragged) => dragged != null && dragged.keyLocation != _listKey,
        onAccept: (dragged) {
          ref.read(cMessageSenderProvider).sendGameConfiguration(onDraggedTo(dragged.role, dragged.modifiedConfiguration));
        },
        builder: (context, candidateData, rejectedData) => Column(
          children: [
            Text(title, textAlign: TextAlign.center),
            Expanded(
              child: Center(
                child: ListView(
                    scrollDirection: horizontal ? Axis.horizontal : Axis.vertical,
                    shrinkWrap: true,
                    children: content
                        .map((role) => LongPressDraggable<_DraggedRole>(
                              delay: const Duration(milliseconds: 200),
                              data: _DraggedRole(
                                role: role,
                                keyLocation: _listKey,
                                modifiedConfiguration: onDraggedFrom(role, ref.read(gameConfigurationProvider)),
                              ),
                              feedback: RoleTypeCardView(role),
                              child: RoleTypeCardView(role),
                            ))
                        .toList()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@freezed
class _DraggedRole with _$_DraggedRole {
  const factory _DraggedRole({
    required RoleType role,
    required Key keyLocation,
    required GameConfiguration modifiedConfiguration,
  }) = __DraggedRole;
}
