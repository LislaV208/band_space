import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:band_space/comments/repository/comments_repository.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({super.key});

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
        title: Text('Dyskusja'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: _commentsRepository.getComments(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.active) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    throw Exception(snapshot.error);
                  }

                  final comments = snapshot.data!;

                  return comments.isEmpty
                      ? const Center(
                          child: Text('Brak komentarzy. Rozpocznij dyskusję!'),
                        )
                      : ListView(
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
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    focusNode: _focusNode,
                    autofocus: true,
                    controller: _textController,
                    decoration: InputDecoration(hintText: 'Zostaw komentarz'),
                    onSubmitted: (_) => _onSubmit(),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: _onSubmit,
                  icon: Icon(Icons.send),
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
