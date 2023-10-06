import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:band_space/comments/comments_screen.dart';
import 'package:band_space/comments/repository/comments_repository.dart';
import 'package:band_space/comments/repository/marker_comments_repository.dart';
import 'package:band_space/core/service_locator.dart';
import 'package:band_space/markers/marker_repository.dart';
import 'package:band_space/song/model/marker.dart';
import 'package:band_space/song/model/song_version_model.dart';
import 'package:band_space/song/repository/version_repository.dart';
import 'package:band_space/utils/duration_extensions.dart';
import 'package:band_space/widgets/app_popup_menu_button.dart';

class MarkersListView extends StatelessWidget {
  const MarkersListView({
    super.key,
    required this.version,
    required this.onSelected,
  });

  final SongVersionModel version;
  final void Function(Marker marker) onSelected;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: sl<VersionRepository>(param1: version.id).getMarkers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.active) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final markers = snapshot.data!;

        if (markers.isEmpty) {
          return const SizedBox();
        }

        return Align(
          alignment: Alignment.bottomCenter,
          child: Scrollbar(
            thumbVisibility: true,
            child: ListView(
              primary: true,
              shrinkWrap: true,
              children: markers.map((item) {
                return ListTile(
                  onTap: () => onSelected(item),
                  leading: Text(Duration(seconds: item.position).format()),
                  title: Text(item.name),
                  trailing: AppPopupMenuButton(
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
                          sl<MarkerRepository>(param1: item.id).delete();
                        },
                      )
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
