import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:band_space/audio/audio_player_service.dart';
import 'package:band_space/audio/loop_sections_manager.dart';
import 'package:band_space/comments/comments_screen.dart';
import 'package:band_space/comments/repository/comments_repository.dart';
import 'package:band_space/comments/repository/marker_comments_repository.dart';
import 'package:band_space/core/service_locator.dart';
import 'package:band_space/markers/marker_repository.dart';
import 'package:band_space/song/model/marker.dart';
import 'package:band_space/song/model/marker_dto.dart';
import 'package:band_space/song/screens/add_edit_marker_screen.dart';
import 'package:band_space/utils/duration_extensions.dart';
import 'package:band_space/widgets/app_popup_menu_button.dart';

class MarkersListView extends StatelessWidget {
  const MarkersListView({
    super.key,
    required this.markers,
    required this.audioPlayer,
    required this.maxMarkerPosition,
    required this.onMarkerEdit,
  });

  final List<Marker> markers;
  final AudioPlayerService audioPlayer;
  final int maxMarkerPosition;
  final Future<void> Function(Marker markerToEdit, MarkerDTO newMarkerData) onMarkerEdit;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Scrollbar(
        thumbVisibility: true,
        child: StreamBuilder(
          stream: audioPlayer.loopSectionsStream,
          builder: (context, snapshot) {
            final loopSections = snapshot.data ?? [];

            return ListView(
              primary: true,
              shrinkWrap: true,
              children: markers.map(
                (item) {
                  final isLooped = item.end_position != null
                      ? loopSections.contains(
                          LoopSection(start: item.start_position, end: item.end_position!),
                        )
                      : false;

                  return ListTile(
                    onTap: () => audioPlayer.seek(
                      Duration(seconds: item.start_position),
                    ),
                    leading: item.end_position == null
                        ? Text(Duration(seconds: item.start_position).format())
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(Duration(seconds: item.start_position).format()),
                              Text(Duration(seconds: item.end_position!).format()),
                            ],
                          ),
                    title: Text(item.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (item.end_position != null)
                          IconButton(
                            onPressed: () {
                              final loopSection = LoopSection(start: item.start_position, end: item.end_position!);

                              if (isLooped) {
                                audioPlayer.removeLoopSection(loopSection);
                              } else {
                                audioPlayer.addLoopSection(loopSection);
                              }
                            },
                            icon: Icon(
                              Icons.loop,
                              color: isLooped ? Theme.of(context).colorScheme.primary : null,
                            ),
                            tooltip: isLooped ? 'Wyłącz zapętlenie' : 'Włącz zapętlenie',
                          ),
                        IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              useSafeArea: true,
                              builder: (context) {
                                return Provider<CommentsRepository>(
                                  create: (context) => sl<MarkerCommentsRepository>(param1: item.id),
                                  child: CommentsScreen(title: 'Znacznik "${item.name}"'),
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.message),
                          tooltip: 'Dyskusja',
                        ),
                        AppPopupMenuButton(
                          itemBuilder: (context) => [
                            AppPopupMenuButtonItem(
                              iconData: Icons.edit,
                              text: 'Edytuj',
                              onSelected: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (_) => AddEditMarkerScreen(
                                    markers: markers,
                                    maxPositionValue: maxMarkerPosition,
                                    startPosition: item.start_position,
                                    markerToEdit: item,
                                    onAddEditMarker: (markerData) async => await onMarkerEdit(item, markerData),
                                  ),
                                );
                              },
                            ),
                            AppPopupMenuButtonItem(
                              iconData: Icons.delete,
                              text: 'Usuń',
                              onSelected: () {
                                if (item.end_position != null && isLooped) {
                                  audioPlayer.removeLoopSection(
                                    LoopSection(start: item.start_position, end: item.end_position!),
                                  );
                                }

                                sl<MarkerRepository>(param1: item.id).delete();
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ).toList(),
            );
          },
        ),
      ),
    );
  }
}
