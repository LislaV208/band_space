import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:band_space/core/service_locator.dart';
import 'package:band_space/file_storage/upload_task_manager.dart';
import 'package:band_space/project/repository/project_repository.dart';
import 'package:band_space/project/widgets/uploading_song_list_tile.dart';
import 'package:band_space/song/model/song_model.dart';
import 'package:band_space/widgets/hover_widget.dart';

class SongsList extends StatefulWidget {
  const SongsList({super.key, required this.songs});

  final List<SongModel> songs;

  @override
  State<SongsList> createState() => _SongsListState();
}

class _SongsListState extends State<SongsList> {
  int? _hoveredItemIndex;

  @override
  Widget build(BuildContext context) {
    final headers = ['Nazwa', 'Komentarze', 'Rozmiar', 'Data utworzenia', 'Autor'];
    final uploadManager = sl<UploadTaskManager>();

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2.0),
      },
      children: [
        TableRow(
          children: headers
              .map((header) => Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(header),
                  ))
              .toList(),
        ),
        ...widget.songs.mapIndexed((index, song) {
          final uploadTask = uploadManager.getUploadTask(song.current_version_id);

          return TableRow(
            children: [
              _buildRowElement(
                index: index,
                content: song.title,
                disable: uploadTask != null,
                builder: (content, isHovered) {
                  if (uploadTask != null) {
                    return UploadingSongListTile(song: song, uploadTask: uploadTask);
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          child: Icon(
                            Icons.music_note,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          content,
                          style: TextStyle(color: Colors.white.withOpacity(isHovered ? 1.0 : 0.7)),
                        ),
                      ],
                    ),
                  );
                },
              ),
              _buildRowElement(
                index: index,
                content: song.comments_count.toString(),
                disable: uploadTask != null,
                builder: (content, isHovered) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.message,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(content),
                      ],
                    ),
                  );
                },
              ),
              _buildRowElement(
                index: index,
                content: song.size.toString(),
                disable: uploadTask != null,
              ),
              _buildRowElement(
                index: index,
                content: song.created_at != null ? DateFormat('dd-MM-yyyy HH:mm').format(song.created_at!) : '-',
                disable: uploadTask != null,
              ),
              _buildRowElement(
                index: index,
                content: song.uploader != null ? song.uploader!.email : '-',
                disable: uploadTask != null,
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildRowElement({
    required int index,
    required String content,
    bool markOnHover = false,
    bool disable = false,
    Widget Function(String content, bool isHovered)? builder,
  }) {
    return GestureDetector(
      onTap: disable
          ? null
          : () async {
              context.goNamed(
                'song',
                pathParameters: {
                  'project_id': context.read<ProjectRepository>().projectId,
                  'song_id': widget.songs[index].id,
                },
              );
            },
      child: HoverWidget(
        showCursor: !disable,
        onHoverEnter: () {
          setState(() {
            _hoveredItemIndex = index;
          });
        },
        onHoverExit: () {
          setState(() {
            _hoveredItemIndex = null;
          });
        },
        builder: (context, hoverDetected) {
          final isHovered = _hoveredItemIndex == index;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (index == 0) const Divider(),
              builder != null
                  ? builder.call(content, isHovered)
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                      child: Text(
                        content,
                        style: TextStyle(color: Colors.white.withOpacity(isHovered && markOnHover ? 1.0 : 0.7)),
                      ),
                    ),
              if (index < widget.songs.length - 1) const Divider()
            ],
          );
        },
      ),
    );
  }
}
