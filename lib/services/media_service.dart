import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:tube_sync/model/media.dart';
import 'package:tube_sync/services/downloader_service.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

class MediaService extends BaseAudioHandler {
  /// <-- Singleton
  static late final MediaService _instance;

  factory MediaService() => _instance;

  MediaService._();

  /// Singleton -->

  late final String mediaDir;
  final _ytClient = yt.YoutubeExplode().videos.streamsClient;
  AudioPlayer? _player;
  VoidCallback? _nextTrackCallback;
  VoidCallback? _previousTrackCallback;

  /// Must call before runApp
  static Future<void> init() async {
    _instance = await AudioService.init(
      builder: () => MediaService._(),
      config: AudioServiceConfig(
        rewindInterval: Duration(seconds: 5),
        androidNotificationChannelName: 'TubeSync',
        androidNotificationIcon: 'drawable/ic_launcher_foreground',
        preloadArtwork: true,
      ),
    );

    final dir = (await getApplicationSupportDirectory()).path;
    _instance.mediaDir = path.join(dir, "downloads");
    JustAudioMediaKit.ensureInitialized();
  }

  /// Call this method for back and forth communication
  void bind({
    required AudioPlayer player,
    required VoidCallback nextTrackCallback,
    required VoidCallback previousTrackCallback,
  }) {
    _player = player;
    _nextTrackCallback = nextTrackCallback;
    _previousTrackCallback = previousTrackCallback;
  }

  void unbind(AudioPlayer player) async {
    // No need to unbind if some other player is re binded
    if (_player != player) return;

    _player = null;
    _nextTrackCallback = null;
    _previousTrackCallback = null;
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      processingState: AudioProcessingState.idle,
    ));
  }

  File mediaFile(Media media) => File(path.join(mediaDir, media.id));

  Future<AudioSource> getMediaSource(Media media) async {
    // Try from offline
    final downloaded = mediaFile(media);
    if (downloaded.existsSync()) return AudioSource.file(downloaded.path);

    if (!await DownloaderService.hasInternet) {
      throw HttpException("No internet!");
    }

    final streamUri = await compute(
      (data) async {
        final ytClient = data[0] as yt.StreamClient;
        final videoManifest = await ytClient.getManifest(data[1]);
        return videoManifest.audioOnly.withHighestBitrate().url;
      },
      [_ytClient, media.id],
    );

    return AudioSource.uri(streamUri);
  }

  bool isDownloaded(Media media) => mediaFile(media).existsSync();

  void delete(Media media) {
    final file = mediaFile(media);
    if (file.existsSync()) file.deleteSync();
  }

  @override
  Future<void> play() async => _player?.play();

  @override
  Future<void> pause() async => _player?.pause();

  @override
  Future<void> stop() async => _player?.stop();

  @override
  Future<void> seek(Duration position) async => _player?.seek(position);

  @override
  Future<void> skipToPrevious() async => _previousTrackCallback?.call();

  @override
  Future<void> skipToNext() async => _nextTrackCallback?.call();

  @override
  Future<void> rewind() async {
    return _player?.seek(_player!.position - Duration(seconds: 5));
  }

  @override
  Future<void> fastForward() async {
    return _player?.seek(_player!.position + Duration(seconds: 5));
  }
}
