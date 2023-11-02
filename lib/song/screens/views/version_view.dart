import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:band_space/song/cubit/version_cubit.dart';
import 'package:band_space/song/screens/widgets/comments_panel.dart';
import 'package:band_space/song/screens/widgets/version_comment_input.dart';
import 'package:band_space/song/widgets/song_player.dart';

class VersionView extends StatefulWidget {
  const VersionView({super.key});

  @override
  State<VersionView> createState() => _VersionViewState();
}

class _VersionViewState extends State<VersionView> {
  final _commentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _commentFocusNode.addListener(_commentFocusNodeListener);
  }

  @override
  void dispose() {
    _commentFocusNode.removeListener(_commentFocusNodeListener);

    _commentFocusNode.dispose();

    super.dispose();
  }

  void _commentFocusNodeListener() {
    if (!_commentFocusNode.hasFocus) {
      context.read<VersionCubit>().keyboardFocusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      autofocus: true,
      focusNode: context.read<VersionCubit>().keyboardFocusNode,
      onKey: (event) => context.read<VersionCubit>().onKeyPressed(event, _commentFocusNode),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Expanded(
                    child: SongPlayer(),
                  ),
                  const SizedBox(height: 16),
                  VersionCommentInput(focusNode: _commentFocusNode),
                ],
              ),
            ),
            const SizedBox(width: 24),
            const CommentsPanel(),
          ],
        ),
      ),
    );
  }
}
