import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tube_sync/model/playlist.dart';

class PlaylistEntryBuilder extends StatelessWidget {
  final Playlist playlist;
  final void Function()? onTap;

  const PlaylistEntryBuilder(this.playlist, {super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.only(left: 16, right: 8),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Hero(
          tag: "PlaylistThumbnailHero",
          child: CachedNetworkImage(
            width: 80,
            imageUrl: playlist.thumbnail.low,
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(
        playlist.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitleTextStyle: Theme.of(context).textTheme.bodySmall,
      subtitle: Text(
        "${playlist.author} \u2022 ${playlist.videoCount} videos",
      ),
      trailing: IconButton(
        onPressed: () {},
        icon: const Icon(Icons.more_vert_rounded, size: 18),
      ),
    );
  }
}
