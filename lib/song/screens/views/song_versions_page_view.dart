import 'package:band_space/song/model/song_version_model.dart';
import 'package:band_space/song/screens/views/song_version_view.dart';
import 'package:flutter/material.dart';

class SongVersionsPageView extends StatefulWidget {
  const SongVersionsPageView({
    super.key,
    required this.controller,
    required this.versions,
  });

  final PageController controller;
  final List<SongVersionModel> versions;

  @override
  State<SongVersionsPageView> createState() => _SongVersionsPageViewState();
}

class _SongVersionsPageViewState extends State<SongVersionsPageView> {
  var _currentPage = 0;

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(_pageListener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_pageListener);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _NavButton(
          visible: _currentPage > 0,
          onPressed: () {
            widget.controller.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.linear,
            );
          },
          iconData: Icons.arrow_back,
        ),
        Expanded(
          child: PageView.builder(
            controller: widget.controller,
            itemCount: widget.versions.length,
            itemBuilder: (context, index) {
              final version = widget.versions[index];
              return SongVersionView(version: version);
            },
          ),
        ),
        _NavButton(
          visible: _currentPage < widget.versions.length - 1,
          onPressed: () {
            widget.controller.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.linear,
            );
          },
          iconData: Icons.arrow_forward,
        ),
      ],
    );
  }

  void _pageListener() {
    final page = widget.controller.page;
    if (page != null && page % 1 == 0) {
      setState(() {
        _currentPage = page.toInt();
      });
    }
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.visible,
    required this.onPressed,
    required this.iconData,
  });

  final bool visible;
  final VoidCallback? onPressed;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Visibility(
        visible: visible,
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(iconData),
          padding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
