import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../models/sermon.dart';
import '../../utils/colors.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Sermon sermon;
  const VideoPlayerScreen({super.key, required this.sermon});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _initializing = true;
  bool _showControls = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    VideoPlayerController? controller;
    try {
      final file = File(widget.sermon.filePath);
      if (widget.sermon.filePath.isNotEmpty && await file.exists()) {
        controller = VideoPlayerController.file(file);
      } else if (widget.sermon.fileUrl.isNotEmpty) {
        controller = VideoPlayerController.networkUrl(Uri.parse(widget.sermon.fileUrl));
      } else {
        if (mounted) setState(() { _error = 'Video file not found'; _initializing = false; });
        return;
      }
      await controller.initialize();
      controller.addListener(_onUpdate);
      if (mounted) {
        setState(() { _controller = controller; _initializing = false; });
        await controller.play();
      } else {
        controller.dispose();
      }
    } catch (e) {
      controller?.dispose();
      if (mounted) setState(() { _error = 'Could not load video: $e'; _initializing = false; });
    }
  }

  void _onUpdate() { if (mounted) setState(() {}); }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _controller?.removeListener(_onUpdate);
    _controller?.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.sermon.title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
            Text(widget.sermon.speaker,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
      body: _initializing
          ? const Center(child: CircularProgressIndicator(color: AppColors.accentPurple))
          : _error != null
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(_error!, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentPurple),
                      onPressed: () { setState(() { _error = null; _initializing = true; }); _initPlayer(); },
                      child: const Text('Retry', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ))
              : _buildPlayer(),
    );
  }

  Widget _buildPlayer() {
    final controller = _controller!;
    final value = controller.value;
    final aspectRatio = value.isInitialized ? value.aspectRatio : 16 / 9;

    return GestureDetector(
      onTap: () => setState(() => _showControls = !_showControls),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: aspectRatio,
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(controller),
                if (_showControls) _buildControls(controller),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: AppColors.darkBg,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VideoProgressIndicator(
                    controller,
                    allowScrubbing: true,
                    colors: VideoProgressColors(
                      playedColor: AppColors.accentPurple,
                      bufferedColor: AppColors.darkBorder,
                      backgroundColor: AppColors.darkSurface2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_fmt(value.position),
                          style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(_fmt(value.duration),
                          style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(widget.sermon.title,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(widget.sermon.speaker,
                      style: const TextStyle(color: AppColors.accentPurple, fontSize: 14)),
                  if (widget.sermon.description.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(widget.sermon.description,
                        style: const TextStyle(color: Colors.white54, fontSize: 13)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(VideoPlayerController controller) {
    final isPlaying = controller.value.isPlaying;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.2), Colors.black.withValues(alpha: 0.65)],
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.replay_10, color: Colors.white, size: 34),
              onPressed: () {
                final p = controller.value.position - const Duration(seconds: 10);
                controller.seekTo(p < Duration.zero ? Duration.zero : p);
              },
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: () => isPlaying ? controller.pause() : controller.play(),
              child: Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: AppColors.accentPurple,
                  shape: BoxShape.circle,
                  boxShadow: AppColors.glowPurple(radius: 22, opacity: 0.4),
                ),
                child: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white, size: 36),
              ),
            ),
            const SizedBox(width: 20),
            IconButton(
              icon: const Icon(Icons.forward_30, color: Colors.white, size: 34),
              onPressed: () {
                final p = controller.value.position + const Duration(seconds: 30);
                final dur = controller.value.duration;
                controller.seekTo(p > dur ? dur : p);
              },
            ),
          ],
        ),
      ),
    );
  }
}
