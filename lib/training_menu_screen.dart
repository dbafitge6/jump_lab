import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrainingItem {
  final String name;
  final String category;
  final String level;
  final String desc;
  final int sets;
  final String reps;
  final String tool;

  const TrainingItem({
    required this.name,
    required this.category,
    required this.level,
    required this.desc,
    required this.sets,
    required this.reps,
    required this.tool,
  });
}

const _items = <TrainingItem>[
  // プライオ系
  TrainingItem(name: 'スクワットジャンプ', category: 'プライオ系', level: '初級', desc: '膝を曲げてしゃがみ込み、全力で上に跳ぶ。着地は静かに吸収する。', sets: 4, reps: '8回', tool: '道具なし'),
  TrainingItem(name: 'アンクルホップ（両足）', category: 'プライオ系', level: '初級', desc: '足首だけを使って素早くリズミカルに弾む。膝をほぼ動かさない。', sets: 3, reps: '20回', tool: '道具なし'),
  TrainingItem(name: 'タックジャンプ', category: 'プライオ系', level: '中級', desc: 'ジャンプの頂点で膝を胸に引きつける。腸腰筋と爆発力を同時に鍛える。', sets: 4, reps: '6回', tool: '道具なし'),
  TrainingItem(name: 'デプスジャンプ', category: 'プライオ系', level: '中級', desc: '段差から落ちて即リバウンド。接地時間を最短にする。踵をつかない。', sets: 4, reps: '5回', tool: '段差（30〜60cm）'),
  TrainingItem(name: 'ボックスジャンプ', category: 'プライオ系', level: '中級', desc: '全力で踏み切りボックスに飛び乗る。着地は静かに膝を曲げて吸収。', sets: 4, reps: '5回', tool: 'ボックス'),
  TrainingItem(name: 'バウンディング', category: 'プライオ系', level: '中級', desc: '片足ずつ大きく跳び続ける。水平距離と滞空時間を意識する。', sets: 4, reps: '10歩', tool: '道具なし'),
  TrainingItem(name: '片足アンクルホップ', category: 'プライオ系', level: '中級', desc: '片足で足首だけを使って弾む。踏み切り足の剛性を高める。', sets: 3, reps: '15回（各足）', tool: '道具なし'),
  TrainingItem(name: '連続ボックスジャンプ', category: 'プライオ系', level: '上級', desc: '着地したら即踏み切り、連続でボックスに跳び続ける。リズムを切らさない。', sets: 4, reps: '5回', tool: 'ボックス'),
  TrainingItem(name: '横方向ボックスジャンプ', category: 'プライオ系', level: '中級', desc: '横からボックスに飛び乗る。着地の安定性と側方の爆発力を鍛える。', sets: 3, reps: '5回（各方向）', tool: 'ボックス'),
  TrainingItem(name: 'ジャンプロープ高速', category: 'プライオ系', level: '初級', desc: 'できるだけ速く縄跳びをする。足首の反射速度とリズム感を養う。', sets: 3, reps: '30秒', tool: '縄跳び'),
  TrainingItem(name: '片足デプスジャンプ', category: 'プライオ系', level: '上級', desc: '片足で段差から落ちて即リバウンド。踏み切り足の反射力を最大化。', sets: 3, reps: '4回（各足）', tool: '段差（20〜40cm）'),
  TrainingItem(name: 'ドロップジャンプ', category: 'プライオ系', level: '上級', desc: '高い段差から落下して最大高さにジャンプ。衝撃吸収と爆発を同時に行う。', sets: 4, reps: '4回', tool: '段差（50〜80cm）'),
  TrainingItem(name: 'スプリントジャンプ', category: 'プライオ系', level: '上級', desc: '短距離全力スプリント後に即最大ジャンプ。試合に近い爆発力を養う。', sets: 4, reps: '3回', tool: '道具なし'),
  TrainingItem(name: 'リバウンドジャンプ', category: 'プライオ系', level: '中級', desc: '着地の反動を使って連続で跳ぶ。SSC（伸張短縮サイクル）を強化。', sets: 4, reps: '10回', tool: '道具なし'),
  // 筋力系
  TrainingItem(name: 'バーベルスクワット', category: '筋力系', level: '中級', desc: '並行以下の深さで重量スクワット。ジャンプ力の最大の土台になる種目。', sets: 5, reps: '3〜5回', tool: 'バーベル'),
  TrainingItem(name: 'ルーマニアンデッドリフト', category: '筋力系', level: '中級', desc: 'ハムストリングと臀部を重点的に鍛える。踏み切りの爆発源になる。', sets: 4, reps: '5回', tool: 'バーベル or ダンベル'),
  TrainingItem(name: '片足カーフレイズ', category: '筋力系', level: '初級', desc: '片足で段差からかかとを落としてゆっくり上げる。踏み切りの最後の一押し。', sets: 3, reps: '15回（各足）', tool: '段差'),
  TrainingItem(name: 'ブルガリアンスプリットスクワット', category: '筋力系', level: '中級', desc: '後ろ足を台に乗せた片足スクワット。着地安定性と臀筋を同時に鍛える。', sets: 3, reps: '8回（各足）', tool: '椅子 or ベンチ'),
  TrainingItem(name: 'ノルディックハムストリングカール', category: '筋力系', level: '中級', desc: '膝立ちから体を前に倒してハムで耐える。ケガ予防に最も重要な種目。', sets: 3, reps: '5回', tool: '固定できる器具'),
  TrainingItem(name: 'ハングパワークリーン', category: '筋力系', level: '上級', desc: '全身の爆発力を使ってバーを引き上げる。重さより速さを優先する。', sets: 5, reps: '3回', tool: 'バーベル'),
  TrainingItem(name: 'レッグプレス（爆発的）', category: '筋力系', level: '初級', desc: '軽めの重量で足を素早く押し出す。ジムで使える爆発力トレーニング。', sets: 4, reps: '8回', tool: 'レッグプレスマシン'),
  TrainingItem(name: 'ヒップスラスト', category: '筋力系', level: '初級', desc: '臀部を鍛えるメイン種目。ジャンプの踏み切りと着地に直結する。', sets: 4, reps: '10回', tool: 'ベンチ・バーベル'),
  TrainingItem(name: 'シングルレッグデッドリフト', category: '筋力系', level: '中級', desc: '片足で行うデッドリフト。バランス力と踏み切り安定性を同時に強化。', sets: 3, reps: '8回（各足）', tool: 'ダンベル'),
  TrainingItem(name: 'コンプレックスジャンプ', category: '筋力系', level: '上級', desc: '重量スクワット3回→即ボックスジャンプ3回。PAPで神経系を最大覚醒させる。', sets: 5, reps: '3+3回', tool: 'バーベル・ボックス'),
  TrainingItem(name: 'ゴブレットスクワット', category: '筋力系', level: '初級', desc: 'ダンベルを胸に持ちスクワット。フォーム習得と大腿四頭筋の基礎強化。', sets: 3, reps: '10回', tool: 'ダンベル'),
  TrainingItem(name: 'ステップアップジャンプ', category: '筋力系', level: '初級', desc: '台に片足を乗せて踏み込み上に跳ぶ。片足の爆発力と臀部を強化。', sets: 3, reps: '8回（各足）', tool: 'ボックス or 段差'),
  TrainingItem(name: 'ランドマインジャンプ', category: '筋力系', level: '上級', desc: 'ランドマインを持ちながらジャンプ。加重状態で爆発力を鍛える上級種目。', sets: 4, reps: '5回', tool: 'ランドマイン'),
  // テクニック系
  TrainingItem(name: '踏み切りリズム練習', category: 'テクニック系', level: '初級', desc: '1・2・跳のリズムを繰り返す。助走ジャンプの基本パターンを体に覚えさせる。', sets: 3, reps: '10回', tool: '道具なし'),
  TrainingItem(name: '1ステップジャンプ', category: 'テクニック系', level: '初級', desc: '1歩踏み込んで片足で跳ぶ。踏み切り足の精度を高める基礎練習。', sets: 3, reps: '10回（各足）', tool: '道具なし'),
  TrainingItem(name: '3ステップジャンプ', category: 'テクニック系', level: '中級', desc: '3歩助走から片足で最大ジャンプ。バスケの実戦に最も近い踏み切り練習。', sets: 4, reps: '8回', tool: '道具なし'),
  TrainingItem(name: 'アームスイング練習', category: 'テクニック系', level: '初級', desc: '腕の振りだけでジャンプ。腕振りのタイミングがジャンプ高さに与える影響を体感する。', sets: 3, reps: '10回', tool: '道具なし'),
  TrainingItem(name: '踏み切り角度練習', category: 'テクニック系', level: '中級', desc: '真上・斜め前・斜め後ろと踏み切り角度を変えて跳ぶ。空間認識とコントロールを養う。', sets: 3, reps: '各5回', tool: '道具なし'),
  TrainingItem(name: '目標タッチジャンプ', category: 'テクニック系', level: '初級', desc: '壁の特定のポイントを毎回タッチする。目的意識がジャンプ力を引き出すことを体感する。', sets: 4, reps: '5回', tool: '壁'),
  TrainingItem(name: 'カウンタームーブメントジャンプ', category: 'テクニック系', level: '初級', desc: '素早く沈み込んで即座に跳ぶ。伸張反射を最大限に使う最も基本的なジャンプ。', sets: 4, reps: '8回', tool: '道具なし'),
  TrainingItem(name: '片手ダンクモーション練習', category: 'テクニック系', level: '上級', desc: 'ボールなしで片手でリムをタッチするモーションを繰り返す。空中でのコントロールを習得。', sets: 3, reps: '5回', tool: 'リム'),
  TrainingItem(name: '助走角度調整練習', category: 'テクニック系', level: '中級', desc: '正面・左45度・右45度から踏み切る。どの角度からでも最大高さが出るように調整する。', sets: 3, reps: '各5回', tool: '道具なし'),
  TrainingItem(name: '着地吸収練習', category: 'テクニック系', level: '初級', desc: '高い位置から静かに着地する練習。足首・膝・股関節で衝撃を分散させる技術を習得。', sets: 3, reps: '10回', tool: '段差'),
  TrainingItem(name: '視線固定ジャンプ', category: 'テクニック系', level: '中級', desc: 'リムだけを見続けてジャンプ。視線を固定すると神経出力が上がることを体感する。', sets: 4, reps: '6回', tool: 'リム or 目標物'),
  TrainingItem(name: '脱力→爆発切り替え練習', category: 'テクニック系', level: '上級', desc: '全身を完全に脱力した状態から瞬時に爆発するジャンプ。神経系の切り替え速度を高める。', sets: 4, reps: '6回', tool: '道具なし'),
  TrainingItem(name: 'イメージジャンプ', category: 'テクニック系', level: '中級', desc: 'リバウンドを取りに行くシチュエーションを強くイメージしてから跳ぶ。ゾーンへの入り口を作る練習。', sets: 3, reps: '5回', tool: '道具なし'),
];

const _categories = ['全て', 'プライオ系', '筋力系', 'テクニック系'];
const _levels = ['全て', '初級', '中級', '上級'];

const _levelColors = {
  '初級': Color(0xFF4CAF50),
  '中級': Color(0xFFFF9800),
  '上級': Color(0xFFF44336),
};

class TrainingMenuScreen extends StatefulWidget {
  const TrainingMenuScreen({super.key});

  @override
  State<TrainingMenuScreen> createState() => _TrainingMenuScreenState();
}

const _completedPrefsKey = 'training_completed_items';

class _TrainingMenuScreenState extends State<TrainingMenuScreen> {
  String _category = '全て';
  String _level = '全て';
  Set<String> _completed = {};

  @override
  void initState() {
    super.initState();
    _loadCompleted();
  }

  Future<void> _loadCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _completed = (prefs.getStringList(_completedPrefsKey) ?? []).toSet();
    });
  }

  Future<void> _toggleCompleted(String name) async {
    setState(() {
      if (_completed.contains(name)) {
        _completed.remove(name);
      } else {
        _completed.add(name);
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_completedPrefsKey, _completed.toList());
  }

  Future<void> _resetCompleted() async {
    setState(() => _completed = {});
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_completedPrefsKey);
  }

  List<TrainingItem> get _filtered => _items.where((item) {
        final catOk = _category == '全て' || item.category == _category;
        final lvlOk = _level == '全て' || item.level == _level;
        return catOk && lvlOk;
      }).toList();

  void _showDetail(TrainingItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _Badge(item.category, const Color(0xFF00E5FF)),
                const SizedBox(width: 8),
                _Badge(item.level, _levelColors[item.level] ?? Colors.grey),
              ],
            ),
            const SizedBox(height: 16),
            Text(item.desc,
                style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6)),
            const SizedBox(height: 16),
            _DetailRow(icon: Icons.repeat, label: '${item.sets}セット × ${item.reps}'),
            const SizedBox(height: 8),
            _DetailRow(icon: Icons.build_outlined, label: item.tool),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('トレーニングメニュー'),
        actions: [
          if (_completed.isNotEmpty)
            IconButton(
              onPressed: _resetCompleted,
              icon: const Icon(Icons.refresh),
              tooltip: '実施記録をリセット',
            ),
        ],
      ),
      body: Column(
        children: [
          _FilterRow(
            options: _categories,
            selected: _category,
            onSelected: (v) => setState(() => _category = v),
          ),
          _FilterRow(
            options: _levels,
            selected: _level,
            onSelected: (v) => setState(() => _level = v),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${filtered.length}種目',
                    style: const TextStyle(color: Colors.white38, fontSize: 12)),
                Text('実施済み ${_completed.length}/${_items.length}',
                    style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final item = filtered[i];
                final isDone = _completed.contains(item.name);
                return Card(
                  color: const Color(0xFF1A1A1A),
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: isDone
                        ? const BorderSide(color: Color(0xFF00E5FF), width: 1)
                        : BorderSide.none,
                  ),
                  child: ListTile(
                    onTap: () => _showDetail(item),
                    title: Text(item.name,
                        style: TextStyle(
                          color: isDone ? Colors.white54 : Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                        )),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          _Badge(item.category, const Color(0xFF00E5FF)),
                          const SizedBox(width: 6),
                          _Badge(item.level, _levelColors[item.level] ?? Colors.grey),
                        ],
                      ),
                    ),
                    trailing: IconButton(
                      onPressed: () => _toggleCompleted(item.name),
                      icon: Icon(
                        isDone ? Icons.check_circle : Icons.check_circle_outline,
                        color: isDone ? const Color(0xFF00E5FF) : Colors.white38,
                      ),
                      tooltip: isDone ? '実施済み' : '実施済みにする',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const _FilterRow({required this.options, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: options.map((o) {
          final isSelected = o == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(o,
                  style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontSize: 12)),
              selected: isSelected,
              onSelected: (_) => onSelected(o),
              backgroundColor: const Color(0xFF1A1A1A),
              selectedColor: const Color(0xFF00E5FF),
              checkmarkColor: Colors.black,
              side: BorderSide(color: isSelected ? const Color(0xFF00E5FF) : Colors.white24),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF00E5FF), size: 18),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      ],
    );
  }
}
