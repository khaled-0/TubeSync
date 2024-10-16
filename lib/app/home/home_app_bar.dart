import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: const Icon(Icons.queue_music_rounded),
      titleSpacing: 0,
      title: const Text("TubeSync"),
      actions: const [
        CircleAvatar(
          radius: 16,
          child: Icon(Icons.person_rounded),
        ),
        SizedBox(width: 12)
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
