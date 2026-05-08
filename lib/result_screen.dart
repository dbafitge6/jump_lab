import 'package:flutter/material.dart';
import 'database_helper.dart';

class ResultScreen extends StatefulWidget {
  final List<double> results;

  const ResultScreen({super.key, required this.results});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _saved = false;

  Future<void> _saveRecord() async {
    final avg = widget.results.reduce((a, b) => a + b) / widget.results.length;
    final best = widget.results.reduce((a, b) => a > b ? a : b);

    final record = JumpRecord(
      date: DateTime.now(),
      jump1: widget.results[0],
      jump2: widget.results[1],
      jump3: widget.results[2],
      average: avg,
      best: best,
    );

    await DatabaseHelper.instance.insertRecord(record);
    setState(() => _saved = true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('保存しました！'),
          backgroundColor: Color(0xFF00E5FF),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final avg = widget.results.reduce((a, b) => a + b) / widget.results.length;
    final best = widget.results.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('結果'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    ...List.generate(
                      widget.results.length,
                      (i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${i + 1}回目',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${widget.results[i]}cm',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '平均',
                          style: TextStyle(
                            color: Color(0xFF00E5FF),
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          '${avg.toStringAsFixed(1)}cm',
                          style: const TextStyle(
                            color: Color(0xFF00E5FF),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ベスト',
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          '${best.toStringAsFixed(1)}cm',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // 保存ボタン
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saved ? null : _saveRecord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _saved
                        ? Colors.green
                        : const Color(0xFF00E5FF),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _saved ? '✅ 保存済み' : '💾 記録を保存',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // もう一回ボタン
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00E5FF),
                    side: const BorderSide(color: Color(0xFF00E5FF)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'もう一回',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
