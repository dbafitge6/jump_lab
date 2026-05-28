import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'database_helper.dart';
import 'ad_helper.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<JumpRecord> _records = [];
  bool _loading = true;
  BannerAd? _bannerAd;
  bool _bannerReady = false;

  @override
  void initState() {
    super.initState();
    _loadRecords();
    _loadBannerAd();
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

  Future<void> _loadRecords() async {
    final records = await DatabaseHelper.instance.getAllRecords();
    setState(() {
      _records = records;
      _loading = false;
    });
  }

  Future<void> _deleteRecord(int id) async {
    await DatabaseHelper.instance.deleteRecord(id);
    _loadRecords();
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('履歴'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00E5FF)),
                  )
                : _records.isEmpty
                    ? const Center(
                        child: Text(
                          'まだ記録がありません\nジャンプして記録しよう！',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // グラフ
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'ベスト推移',
                                  style: TextStyle(
                                      color: Colors.white54, fontSize: 12),
                                ),
                                const SizedBox(height: 12),
                                _buildBarChart(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // 記録一覧
                          ..._records.map((record) => Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1A1A),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _formatDate(record.date),
                                            style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Text(
                                                '平均 ${record.average.toStringAsFixed(1)}cm',
                                                style: const TextStyle(
                                                  color: Color(0xFF00E5FF),
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                'ベスト ${record.best.toStringAsFixed(1)}cm',
                                                style: const TextStyle(
                                                  color: Colors.amber,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${record.jump1}cm / ${record.jump2}cm / ${record.jump3}cm',
                                            style: const TextStyle(
                                              color: Colors.white38,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            backgroundColor:
                                                const Color(0xFF1A1A1A),
                                            title: const Text(
                                              '削除しますか？',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child:
                                                    const Text('キャンセル'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  _deleteRecord(record.id!);
                                                },
                                                child: const Text(
                                                  '削除',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.white38,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
          ),
          // バナー広告
          if (_bannerReady && _bannerAd != null)
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

  Widget _buildBarChart() {
    final data = _records.reversed.toList().take(10).toList();
    final maxVal =
        data.map((r) => r.best).reduce((a, b) => a > b ? a : b);
    const maxBarHeight = 100.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: data.map((record) {
        final ratio = maxVal > 0 ? (record.best / maxVal) : 0.0;
        final barHeight = maxBarHeight * ratio;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${record.best.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.white54, fontSize: 8),
            ),
            const SizedBox(height: 2),
            Container(
              width: 24,
              height: barHeight < 4 ? 4 : barHeight,
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${record.date.month}/${record.date.day}',
              style: const TextStyle(color: Colors.white38, fontSize: 8),
            ),
          ],
        );
      }).toList(),
    );
  }
}
