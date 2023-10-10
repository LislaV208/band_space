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
import 'package:band_space/utils/duration_extensions.dart';
import 'package:band_space/widgets/app_popup_menu_button.dart';

class MarkersListView extends StatelessWidget {
  const MarkersListView({
    super.key,
    required this.markers,
    required this.audioPlayer,
  });

  final List<Marker> markers;
  final AudioPlayerService audioPlayer;

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
                          ),
                        AppPopupMenuButton(
                          itemBuilder: (context) => [
                            AppPopupMenuButtonItem(
                              iconData: Icons.message,
                              text: 'Dyskusja',
                              onSelected: () {
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
