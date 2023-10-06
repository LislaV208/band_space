import 'package:flutter/material.dart';

class AppPopupMenuButtonItem {
  final String text;
  final IconData? iconData;
  final VoidCallback onSelected;

  const AppPopupMenuButtonItem({
    required this.text,
    required this.onSelected,
    this.iconData,
  });
}

class AppPopupMenuButton extends StatelessWidget {
  const AppPopupMenuButton({
    super.key,
    required this.itemBuilder,
  });

  final List<AppPopupMenuButtonItem> Function(BuildContext context) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (context) {
        return itemBuilder(context)
            .map(
              (item) => PopupMenuItem(
                onTap: item.onSelected,
                child: ListTile(
                  leading: Icon(item.iconData),
                  title: Text(item.text),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            )
            .toList();
      },
      tooltip: 'Więcej',
    );
  }
}
