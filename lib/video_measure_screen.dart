import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'result_screen.dart';

class VideoMeasureScreen extends StatefulWidget {
  const VideoMeasureScreen({super.key});

  @override
  State<VideoMeasureScreen> createState() => _VideoMeasureScreenState();
}

class _VideoMeasureScreenState extends State<VideoMeasureScreen> {
  VideoPlayerController? _videoController;
  int _jumpCount = 0;
  List<double> _results = [];
  String _status = '動画を選択してください';
  int? _takeoffFrame;
  int? _landingFrame;
  bool _selectingTakeoff = false;
  bool _selectingLanding = false;
  double _fps = 240.0;
  int _totalFrames = 0;
  int _currentFrame = 0;
  bool _showTips = true;

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(source: ImageSource.gallery);
    if (video == null) return;

    final controller = VideoPlayerController.file(File(video.path));
    await controller.initialize();

    setState(() {
      _videoController?.dispose();
      _videoController = controller;
      _totalFrames = (controller.value.duration.inMilliseconds * _fps / 1000).toInt();
      _takeoffFrame = null;
      _landingFrame = null;
      _status = '離陸フレームを選択してください';
      _selectingTakeoff = true;
      _selectingLanding = false;
      _currentFrame = 0;
      _showTips = false;
    });

    await controller.play();
    controller.pause();
  }

  void _seekToFrame(int frame) {
    if (_videoController == null) return;
    final clamped = frame.clamp(0, _totalFrames);
    final ms = (clamped * 1000 / _fps).toInt();
    _videoController!.seekTo(Duration(milliseconds: ms));
    setState(() => _currentFrame = clamped);
  }

  void _setTakeoffFrame() {
    setState(() {
      _takeoffFrame = _currentFrame;
      _selectingTakeoff = false;
      _selectingLanding = true;
      _status = '着地フレームを選択してください';
    });
  }

  void _setLandingFrame() {
    if (_takeoffFrame == null) return;
    setState(() {
      _landingFrame = _currentFrame;
      _selectingLanding = false;
    });
    _calculateHeight();
  }

  void _calculateHeight() {
    if (_takeoffFrame == null || _landingFrame == null) return;

    final frames = (_landingFrame! - _takeoffFrame!).abs();
    final t = frames / _fps;
    final h = 0.5 * 9.8 * (t / 2) * (t / 2) * 100;
    final height = double.parse(h.toStringAsFixed(1));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('計測結果', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$height cm',
              style: const TextStyle(
                color: Color(0xFF00E5FF),
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '滞空時間: ${t.toStringAsFixed(3)}秒\nフレーム数: $frames',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _jumpCount++;
                _results.add(height);
                _takeoffFrame = null;
                _landingFrame = null;
                if (_jumpCount < 3) {
                  _status = '次の動画を選択してください\nあと${3 - _jumpCount}回';
                } else {
                  _status = '計測完了！';
                }
              });
              if (_jumpCount >= 3) {
                Future.delayed(const Duration(milliseconds: 300), () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResultScreen(results: _results),
                    ),
                  );
                });
              }
            },
            child: const Text('保存', style: TextStyle(color: Color(0xFF00E5FF))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _takeoffFrame = null;
                _landingFrame = null;
                _selectingTakeoff = true;
                _status = '離陸フレームを選択してください';
              });
            },
            child: const Text('やり直し', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Widget _buildJumpCountRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (i) {
          final done = i < _jumpCount;
          final height = done ? _results[i] : 0.0;
          return Container(
            width: 90,
            height: 56,
            decoration: BoxDecoration(
              color: done ? const Color(0xFF00E5FF).withOpacity(0.2) : const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: done ? const Color(0xFF00E5FF) : Colors.white24),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${i + 1}回目', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                Text(
                  done ? '${height}cm' : '--',
                  style: TextStyle(color: done ? Colors.white : Colors.white38, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: const Color(0xFF1A1A1A),
      child: Text(
        _status,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF00E5FF),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final videoLoaded = _videoController != null && _videoController!.value.isInitialized;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('動画計測'),
      ),
      body: SafeArea(
        child: videoLoaded
            ? Column(
                children: [
                  _buildStatusBar(),
                  _buildJumpCountRow(),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('フレーム: $_currentFrame',
                                style: const TextStyle(color: Colors.white54, fontSize: 11)),
                            Row(children: [
                              if (_takeoffFrame != null)
                                Text('離陸: $_takeoffFrame',
                                    style: const TextStyle(color: Colors.green, fontSize: 11)),
                              const SizedBox(width: 8),
                              if (_landingFrame != null)
                                Text('着地: $_landingFrame',
                                    style: const TextStyle(color: Colors.red, fontSize: 11)),
                            ]),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: const Color(0xFF00E5FF),
                            inactiveTrackColor: Colors.white24,
                            thumbColor: const Color(0xFF00E5FF),
                            overlayColor: const Color(0xFF00E5FF).withOpacity(0.2),
                          ),
                          child: Slider(
                            value: _currentFrame.toDouble(),
                            min: 0,
                            max: _totalFrames.toDouble(),
                            onChanged: (v) => _seekToFrame(v.toInt()),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(onPressed: () => _seekToFrame(_currentFrame - 10),
                                icon: const Icon(Icons.fast_rewind, color: Colors.white, size: 20)),
                            IconButton(onPressed: () => _seekToFrame(_currentFrame - 1),
                                icon: const Icon(Icons.skip_previous, color: Colors.white, size: 20)),
                            IconButton(onPressed: () => _seekToFrame(_currentFrame + 1),
                                icon: const Icon(Icons.skip_next, color: Colors.white, size: 20)),
                            IconButton(onPressed: () => _seekToFrame(_currentFrame + 10),
                                icon: const Icon(Icons.fast_forward, color: Colors.white, size: 20)),
                          ],
                        ),
                        if (!_selectingTakeoff && !_selectingLanding)
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _pickVideo,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00E5FF),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Text('📹 動画を選択', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        if (_selectingTakeoff)
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _setTakeoffFrame,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Text('🦘 ここが離陸！', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        if (_selectingLanding)
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _setLandingFrame,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Text('👟 ここが着地！', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildStatusBar(),
                    if (_showTips)
                      Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.withOpacity(0.5)),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Text('📹 ', style: TextStyle(fontSize: 14)),
                              Text('撮影のコツ', style: TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.bold)),
                            ]),
                            SizedBox(height: 6),
                            Text('・スローモーション（240fps）で撮影\n・真横から全身が映るように撮影\n・誰かに持ってもらうと精度UP',
                                style: TextStyle(color: Colors.white70, fontSize: 12)),
                            SizedBox(height: 8),
                            Row(children: [
                              Text('⚠️ ', style: TextStyle(fontSize: 14)),
                              Text('注意事項', style: TextStyle(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.bold)),
                            ]),
                            SizedBox(height: 6),
                            Text('・240fps非対応機種は精度が下がります\n・対応機種：iPhone 8以降',
                                style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                    _buildJumpCountRow(),
                    Container(
                      height: 120,
                      color: const Color(0xFF1A1A1A),
                      child: const Center(
                        child: Text('動画を選択してください', style: TextStyle(color: Colors.white38)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _pickVideo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E5FF),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('📹 動画を選択', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
      ),
    );
  }
}
