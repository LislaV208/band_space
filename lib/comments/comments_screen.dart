import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:band_space/comments/repository/comments_repository.dart';
import 'package:band_space/widgets/app_stream_builder.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({super.key, required this.title});

  final String title;

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  late final _commentsRepository = context.read<CommentsRepository>();

  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          title: Text(widget.title),
          subtitle: const Text('Dyskusja'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: AppStreamBuilder(
                stream: _commentsRepository.getComments(),
                builder: (context, comments) {
                  return ListView(
                    children: comments
                        .map(
                          (e) => ListTile(
                            title: Text(e.created_by),
                            subtitle: Text(e.content),
                          ),
                        )
                        .toList(),
                  );
                },
                noDataText: 'Brak komentarzy. Rozpocznij dyskusję!',
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    focusNode: _focusNode,
                    autofocus: true,
                    controller: _textController,
                    decoration: const InputDecoration(hintText: 'Zostaw komentarz'),
                    onSubmitted: (_) => _onSubmit(),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: _onSubmit,
                  icon: const Icon(Icons.send),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _onSubmit() {
    if (_textController.text.isNotEmpty) {
      _commentsRepository.addComment(
        _textController.text,
      );

      _textController.clear();
      _focusNode.requestFocus();
    }
  }
}
