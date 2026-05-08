import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'result_screen.dart';

class LidarScreen extends StatefulWidget {
  const LidarScreen({super.key});

  @override
  State<LidarScreen> createState() => _LidarScreenState();
}

class _LidarScreenState extends State<LidarScreen> {
  CameraController? _cameraController;
  int _jumpCount = 0;
  List<double> _results = [];
  bool _isRecording = false;
  bool _isProcessing = false;
  String _status = 'カメラを準備中...';
  DateTime? _recordStart;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _cameraController = CameraController(
      cameras[0],
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    setState(() {
      _status = '準備完了\nボタンを押して録画開始！';
    });
  }

  Future<void> _startRecording() async {
    if (_cameraController == null) return;
    await _cameraController!.startVideoRecording();
    setState(() {
      _isRecording = true;
      _recordStart = DateTime.now();
      _status = '録画中...\nジャンプしてください！';
    });
  }

  Future<void> _stopRecording() async {
    if (_cameraController == null) return;

    final file = await _cameraController!.stopVideoRecording();
    setState(() {
      _isRecording = false;
      _isProcessing = true;
      _status = '解析中...';
    });

    // 録画時間から滞空時間を推定
    final totalMs = DateTime.now()
        .difference(_recordStart!)
        .inMilliseconds;

    // ユーザーに滞空時間を入力してもらう
    if (mounted) {
      _showResultDialog(file.path, totalMs);
    }
  }

  void _showResultDialog(String path, int totalMs) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AirTimeDialog(
        videoPath: path,
        onConfirm: (airTimeMs) {
          final t = airTimeMs / 1000.0;
          final h = 0.5 * 9.8 * (t / 2) * (t / 2) * 100;
          final height = double.parse(h.toStringAsFixed(1));

          setState(() {
            _isProcessing = false;
            _jumpCount++;
            _results.add(height);
            _status = _jumpCount < 3
                ? 'あと${3 - _jumpCount}回！\nボタンを押して録画開始！'
                : '計測完了！';
          });

          if (_jumpCount >= 3) {
            Future.delayed(const Duration(milliseconds: 500), () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ResultScreen(results: _results),
                ),
              );
            });
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('スロモ計測'),
      ),
      body: Column(
        children: [
          // カメラプレビュー
          if (_cameraController != null &&
              _cameraController!.value.isInitialized)
            AspectRatio(
              aspectRatio: _cameraController!.value.aspectRatio,
              child: CameraPreview(_cameraController!),
            )
          else
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF00E5FF),
                ),
              ),
            ),
          // UI
          Expanded(
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _status,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF00E5FF),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(3, (i) {
                      final done = i < _jumpCount;
                      final height = done ? _results[i] : 0.0;
                      return Container(
                        width: 90,
                        height: 70,
                        decoration: BoxDecoration(
                          color: done
                              ? const Color(0xFF00E5FF).withOpacity(0.2)
                              : const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: done
                                ? const Color(0xFF00E5FF)
                                : Colors.white24,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${i + 1}回目',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              done ? '${height}cm' : '--',
                              style: TextStyle(
                                color: done ? Colors.white : Colors.white38,
                                fontSize: done ? 16 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  if (!_isRecording && !_isProcessing)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed:
                              _jumpCount < 3 ? _startRecording : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            '🔴 録画開始',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  else if (_isRecording)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _stopRecording,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            '⏹ 録画停止',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    const CircularProgressIndicator(
                      color: Color(0xFF00E5FF),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AirTimeDialog extends StatefulWidget {
  final String videoPath;
  final Function(int) onConfirm;

  const _AirTimeDialog({
    required this.videoPath,
    required this.onConfirm,
  });

  @override
  State<_AirTimeDialog> createState() => _AirTimeDialogState();
}

class _AirTimeDialogState extends State<_AirTimeDialog> {
  double _airTimeMs = 500;

  @override
  Widget build(BuildContext context) {
    final h = 0.5 * 9.8 * (_airTimeMs / 1000 / 2) * (_airTimeMs / 1000 / 2) * 100;

    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text(
        '滞空時間を設定',
        style: TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '動画を見てジャンプしていた時間を\nスライダーで調整してください',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Text(
            '${_airTimeMs.toStringAsFixed(0)}ms',
            style: const TextStyle(
              color: Color(0xFF00E5FF),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Slider(
            value: _airTimeMs,
            min: 200,
            max: 1200,
            divisions: 100,
            activeColor: const Color(0xFF00E5FF),
            onChanged: (v) => setState(() => _airTimeMs = v),
          ),
          Text(
            '推定 ${h.toStringAsFixed(1)}cm',
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onConfirm(_airTimeMs.toInt());
          },
          child: const Text(
            '確定',
            style: TextStyle(
              color: Color(0xFF00E5FF),
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
