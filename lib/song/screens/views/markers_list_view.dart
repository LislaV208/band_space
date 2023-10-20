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

class MarkersListView extends StatefulWidget {
  const MarkersListView({
    super.key,
    required this.markers,
    required this.audioPlayer,
    required this.songDuration,
    required this.onMarkerEdit,
  });

  final List<Marker> markers;
  final AudioPlayerService audioPlayer;
  final Duration songDuration;
  final Future<void> Function(Marker markerToEdit, MarkerDTO newMarkerData) onMarkerEdit;

  @override
  State<MarkersListView> createState() => _MarkersListViewState();
}

class _MarkersListViewState extends State<MarkersListView> {
  @override
  void didUpdateWidget(covariant MarkersListView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // jezeli jakis znacznik zostal usuniety
    if (widget.markers.length < oldWidget.markers.length) {
      // znajdujemy usuniete znaczniki
      final removedMarkers = oldWidget.markers.skipWhile((value) => widget.markers.contains(value));

      for (final marker in removedMarkers) {
        // jezeli usuniety znacznik moze byc zapętlony, to usuwamy zapętlenie
        if (marker.end_position != null) {
          widget.audioPlayer.removeLoopSection(
            LoopSection(start: marker.start_position, end: marker.end_position!),
          );
        }
      }
    }
    // jezeli liczba znacznikow sie nie zmieniła
    else if (widget.markers.length == oldWidget.markers.length) {
      // szukamy zmian w znacznikach
      for (var i = 0; i < widget.markers.length; ++i) {
        final currentMarker = widget.markers[i];
        final oldMarker = oldWidget.markers[i];

        // jezeli znajdziemy zmianę
        if (currentMarker != oldMarker) {
          // jezeli znacznik moze zostać zapętlony, to uaktualniamy zapętlenie
          if (currentMarker.end_position != null && oldMarker.end_position != null) {
            widget.audioPlayer.updateLoopSection(
              LoopSection(start: oldMarker.start_position, end: oldMarker.end_position!),
              LoopSection(start: currentMarker.start_position, end: currentMarker.end_position!),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Scrollbar(
        thumbVisibility: true,
        child: StreamBuilder(
          stream: widget.audioPlayer.loopSectionsStream,
          builder: (context, snapshot) {
            final loopSections = snapshot.data ?? [];

            return ListView(
              primary: true,
              shrinkWrap: true,
              children: widget.markers.map(
                (item) {
                  final isLooped = item.end_position != null
                      ? loopSections.contains(
                          LoopSection(start: item.start_position, end: item.end_position!),
                        )
                      : false;

                  return ListTile(
                    onTap: () => widget.audioPlayer.seek(item.start_position),
                    leading: item.end_position == null
                        ? Text(item.start_position.format())
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(item.start_position.format()),
                              Text(item.end_position!.format()),
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
                                widget.audioPlayer.removeLoopSection(loopSection);
                              } else {
                                widget.audioPlayer.addLoopSection(loopSection);
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
                                    markers: widget.markers,
                                    songDuration: widget.songDuration,
                                    startPosition: item.start_position,
                                    markerToEdit: item,
                                    onAddEditMarker: (markerData) async => await widget.onMarkerEdit(item, markerData),
                                  ),
                                );
                              },
                            ),
                            AppPopupMenuButtonItem(
                              iconData: Icons.delete,
                              text: 'Usuń',
                              onSelected: () {
                                if (item.end_position != null && isLooped) {
                                  widget.audioPlayer.removeLoopSection(
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
