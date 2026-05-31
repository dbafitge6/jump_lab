import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'measure_screen.dart';
import 'history_screen.dart';
import 'database_helper.dart';
import 'ad_helper.dart';
import 'video_measure_screen.dart';
import 'purchase_manager.dart';
import 'share_manager.dart';
import 'training_menu_screen.dart';
import 'calendar_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await MobileAds.instance.initialize();
  } catch (e) {
    debugPrint('AdMob初期化エラー: $e');
  }
  await PurchaseManager.instance.initialize();
  await ShareManager.instance.initialize();
  runApp(const JumpLabApp());
}

class JumpLabApp extends StatelessWidget {
  const JumpLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JumpLab',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00E5FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double? _bestRecord;
  BannerAd? _bannerAd;
  bool _bannerReady = false;
  InterstitialAd? _interstitialAd;
  int _tapCount = 0;

  @override
  void initState() {
    super.initState();
    _loadBest();
    _loadBannerAd();
    _loadInterstitialAd();
  }

  Future<void> _loadInterstitialAd() async {
    _interstitialAd = await AdHelper.loadInterstitialAd();
  }

  Future<void> _loadBannerAd() async {
    final ad = AdHelper.createBannerAd();
    if (ad == null) return;
    await ad.load();
    setState(() {
      _bannerAd = ad;
      _bannerReady = true;
    });
  }

  Future<void> _loadBest() async {
    final best = await DatabaseHelper.instance.getBestRecord();
    setState(() {
      _bestRecord = best?.best;
    });
  }

  Future<void> _navigateWithAd(Widget screen) async {
    _tapCount++;
    final isPremium = PurchaseManager.instance.isPremium;
    if (!isPremium && _tapCount % 3 == 1 && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          _loadInterstitialAd();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          ).then((_) => _loadBest());
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _loadInterstitialAd();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          ).then((_) => _loadBest());
        },
      );
      _interstitialAd!.show();
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen),
      );
      _loadBest();
    }
  }

  Future<void> _showPremiumDialog() async {
    showDialog(
      context: context,
      builder: (_) => const _PremiumDialog(),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = PurchaseManager.instance.isPremium;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      'JumpLab',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00E5FF),
                        letterSpacing: 4,
                      ),
                    ),
                    const Text(
                      'ジャンプ計測アプリ',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white54,
                      ),
                    ),
                    if (isPremium)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber),
                        ),
                        child: const Text(
                          '⭐ プレミアム会員',
                          style: TextStyle(
                              color: Colors.amber, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 32),
                    Container(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '自己ベスト',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _bestRecord != null
                                ? '${_bestRecord!.toStringAsFixed(1)} cm'
                                : '-- cm',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 40),
                      child: SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: ElevatedButton(
                          onPressed: () => _navigateWithAd(
                              const VideoMeasureScreen()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E5FF),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            '🎬 動画で計測（高精度）',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 40),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () =>
                              _navigateWithAd(const MeasureScreen()),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF00E5FF),
                            side: const BorderSide(
                                color: Color(0xFF00E5FF)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            '📱 センサーで計測',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 40),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () =>
                              _navigateWithAd(const HistoryScreen()),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white54,
                            side:
                                const BorderSide(color: Colors.white24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            '📊 履歴を見る',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 40),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () => _navigateWithAd(
                              const TrainingMenuScreen()),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF00E5FF),
                            side: const BorderSide(
                                color: Color(0xFF00E5FF)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            '💪 トレーニングメニュー',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 40),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () => _navigateWithAd(
                              const CalendarScreen()),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white54,
                            side:
                                const BorderSide(color: Colors.white24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            '📅 カレンダー',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (!isPremium)
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 40),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _showPremiumDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              '⭐ プレミアムに登録（月180円）',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 40),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: _ShareButton(
                          onShared: () => setState(() {}),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          if (_bannerReady && _bannerAd != null && !isPremium)
            Container(
              color: const Color(0xFF0A0A0A),
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  final VoidCallback onShared;
  const _ShareButton({required this.onShared});

  @override
  Widget build(BuildContext context) {
    final hasShared = ShareManager.instance.hasShared;
    if (hasShared) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Color(0xFF00E5FF), size: 16),
          SizedBox(width: 6),
          Text('広告オフ中 ✓',
              style: TextStyle(color: Color(0xFF00E5FF), fontSize: 14)),
        ],
      );
    }
    return TextButton(
      onPressed: () async {
        await ShareManager.instance.shareApp();
        onShared();
      },
      child: const Text(
        '📣 シェアして広告をオフ',
        style: TextStyle(color: Colors.white38, fontSize: 14),
      ),
    );
  }
}

class _PremiumDialog extends StatefulWidget {
  const _PremiumDialog();

  @override
  State<_PremiumDialog> createState() => _PremiumDialogState();
}

class _PremiumDialogState extends State<_PremiumDialog> {
  bool _loading = false;

  Future<void> _purchase() async {
    setState(() => _loading = true);
    final result = await PurchaseManager.instance.purchasePremium();
    if (!mounted) return;
    setState(() => _loading = false);

    if (result.success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('プレミアム登録完了！'),
          backgroundColor: Color(0xFF00E5FF),
        ),
      );
    } else if (result.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error!)),
      );
    }
  }

  Future<void> _restore() async {
    setState(() => _loading = true);
    final success = await PurchaseManager.instance.restorePurchases();
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? '購入を復元しました！' : '復元できる購入が見つかりませんでした'),
        backgroundColor: success ? const Color(0xFF00E5FF) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text('プレミアムプラン', style: TextStyle(color: Colors.white)),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('月180円で以下が使えます！', style: TextStyle(color: Colors.white70)),
          SizedBox(height: 12),
          Text('✅ 広告なし', style: TextStyle(color: Color(0xFF00E5FF))),
          Text('✅ 動画計測無制限', style: TextStyle(color: Color(0xFF00E5FF))),
          Text('✅ 履歴無制限', style: TextStyle(color: Color(0xFF00E5FF))),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('キャンセル', style: TextStyle(color: Colors.white54)),
        ),
        TextButton(
          onPressed: _loading ? null : _purchase,
          child: _loading
              ? const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00E5FF)),
                )
              : const Text('登録する',
                  style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold)),
        ),
        TextButton(
          onPressed: _loading ? null : _restore,
          child: const Text('購入を復元', style: TextStyle(color: Colors.white54)),
        ),
      ],
    );
  }
}
