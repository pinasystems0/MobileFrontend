import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioUrlPlayer extends StatefulWidget {
  final String url;
  const AudioUrlPlayer({super.key, required this.url});

  @override
  State<AudioUrlPlayer> createState() => _AudioUrlPlayerState();
}

class _AudioUrlPlayerState extends State<AudioUrlPlayer> {
  final AudioPlayer _player = AudioPlayer();
  bool _isLoading = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });
  }

  Future<void> _togglePlay() async {
    if (_isLoading) return;

    try {
      setState(() => _isLoading = true);

      if (_isPlaying) {
        await _player.pause();
        return;
      }

      await _player.play(UrlSource(widget.url));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: _togglePlay,
          icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Audio',
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (_isLoading)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }
}

