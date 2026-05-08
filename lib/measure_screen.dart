import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'result_screen.dart';
import 'ad_helper.dart';

class MeasureScreen extends StatefulWidget {
  const MeasureScreen({super.key});

  @override
  State<MeasureScreen> createState() => _MeasureScreenState();
}

class _MeasureScreenState extends State<MeasureScreen> {
  int _jumpCount = 0;
  List<double> _results = [];
  bool _isWaiting = false;
  bool _isInAir = false;
  DateTime? _takeoffTime;
  String _status = '準備完了\nボタンを押してジャンプ！';
  StreamSubscription? _subscription;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _loadAndShowAd();
  }

  Future<void> _loadAndShowAd() async {
    _interstitialAd = await AdHelper.loadInterstitialAd();
    if (_interstitialAd != null && mounted) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
        },
      );
      await Future.delayed(const Duration(milliseconds: 500));
      _interstitialAd!.show();
    }
  }

  void _onJumpButtonPressed() {
    setState(() {
      _isWaiting = true;
      _isInAir = false;
      _takeoffTime = null;
      _status = '踏み切りを検出中...';
    });

    _subscription?.cancel();
    _subscription = accelerometerEventStream().listen((event) {
      final double magnitude =
          (event.x * event.x + event.y * event.y + event.z * event.z);

      if (!_isInAir && magnitude > 250) {
        setState(() {
          _isInAir = true;
          _takeoffTime = DateTime.now();
          _status = '滞空中...';
        });
      }

      if (_isInAir && _takeoffTime != null) {
        final elapsed = DateTime.now()
            .difference(_takeoffTime!)
            .inMilliseconds;

        if (elapsed > 300 && magnitude > 200) {
          final landingTime = DateTime.now();
          _isInAir = false;
          _subscription?.cancel();

          final t = landingTime
                  .difference(_takeoffTime!)
                  .inMilliseconds /
              1000.0;

          final airTime = (t * 0.5).clamp(0.1, 1.0);
          final h = 0.5 * 9.8 * (airTime / 2) * (airTime / 2) * 100;
          final height = double.parse(h.toStringAsFixed(1));

          setState(() {
            _jumpCount++;
            _results.add(height);
            _isWaiting = false;
            _status = _jumpCount < 3
                ? 'あと${3 - _jumpCount}回！\nボタンを押してジャンプ！'
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
        }
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('センサー計測'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 注意書き
            Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.orange.withOpacity(0.5)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('⚠️ ', style: TextStyle(fontSize: 14)),
                      Text(
                        'センサー計測は目安です',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    '正確な計測は動画計測をご利用ください',
                    style: TextStyle(
                        color: Colors.white54, fontSize: 12),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text('📱 ', style: TextStyle(fontSize: 14)),
                      Text(
                        '使い方',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'スマホをズボンのポケットや腰に固定してジャンプ！\n固定するほど精度UP！',
                    style: TextStyle(
                        color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              _status,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF00E5FF),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (i) {
                final done = i < _jumpCount;
                final height = done ? _results[i] : 0.0;
                return Container(
                  width: 100,
                  height: 120,
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
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        done ? '${height}cm' : '--',
                        style: TextStyle(
                          color: done ? Colors.white : Colors.white38,
                          fontSize: done ? 20 : 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 40),
            if (!_isWaiting)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 80,
                  child: ElevatedButton(
                    onPressed: _jumpCount < 3 ? _onJumpButtonPressed : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _jumpCount == 0
                          ? '🦘 ジャンプ準備！'
                          : '🦘 次のジャンプ',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
            else
              Column(
                children: [
                  const CircularProgressIndicator(
                    color: Color(0xFF00E5FF),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isInAir ? '着地を待ってます...' : '踏み切りを待ってます...',
                    style: const TextStyle(color: Colors.white54),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
