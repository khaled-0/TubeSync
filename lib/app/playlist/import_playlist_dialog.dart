import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tube_sync/provider/library_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class ImportPlaylistDialog extends StatefulWidget {
  const ImportPlaylistDialog({super.key});

  @override
  State<ImportPlaylistDialog> createState() => _ImportPlaylistDialogState();
}

class _ImportPlaylistDialogState extends State<ImportPlaylistDialog> {
  final ytClient = YoutubeExplode().playlists;
  final TextEditingController input = TextEditingController();
  bool loading = false;
  String? error;

  Future<void> tryImportPlaylist() async {
    try {
      error = null;
      setState(() => loading = true);
      if (input.text.isEmpty) throw "Empty url!";
      await context.read<LibraryProvider>().importPlaylist(input.text);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      error = e.toString();
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Import Playlist"),
      icon: const Icon(Icons.link_rounded),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          TextFormField(
            controller: input,
            autofocus: true,
            maxLines: 5,
            minLines: 1,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Playlist URL",
              hintText: "https://youtu.be/playlist?list=...",
            ),
          ),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          if (error != null)
            Card(
              margin: const EdgeInsets.only(top: 12),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  error!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        FilledButton(onPressed: tryImportPlaylist, child: const Text("Import"))
      ],
    );
  }
}
