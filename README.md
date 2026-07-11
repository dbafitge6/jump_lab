# 🏃 jump_lab - Your Jump Height Tracker

<div align="center">

**スマホでジャンプ力を測定・記録・トレーニング**

毎日のジャンプで、体の成長を感じよう。

[App Store](https://apps.apple.com/app/id6772440429) • Google Play（リリース予定） • [GitHub](https://github.com/dbafitge6/jump_lab)

![Version](https://img.shields.io/badge/version-1.0.1-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.11+-blue)
![License](https://img.shields.io/badge/license-MIT-green)

</div>

---

## 🎯 jump_lab とは？

**ジャンプ力を簡単に測定できる、日本初のスマートアプリ。**

ジムに行かなくても、自宅でスマホ1つで「今のジャンプ力」が分かります。
毎日1回、その日の記録を残す。グラフで成長を実感する。

> "ジャンプ力を測定できるアプリなんて、日本にはほぼない。"
> だからこそ、jump_lab は可能性に満ちている。

---

## ✨ 主な機能

### 📏 ジャンプ高さ自動測定
- **センサー測定**: スマホの加速度センサーを使った簡易測定
- **ビデオ測定**: 撮影した動画の離陸・着地フレームを指定して正確に測定
- 誰でも簡単、追加機器不要

### 📊 毎日の記録・グラフ表示
- 日々のジャンプ高さを自動保存
- カレンダービューで「いつ測定したか」が一目瞭然
- 月間グラフで成長が見える化

### 🏋️ 4種類の日替わりトレーニング
毎日異なるトレーニングがランダムに提案される

- **Plyometric**（プライオメトリクス） - 爆発力を鍛える
- **Strength**（筋力） - 基礎体力を強化
- **Technique**（技術） - フォームを改善
- **Mobility**（可動域） - 柔軟性を高める

> "1日1つでいい。完璧を目指さない。継続が力。"

### 💾 完全ローカル保存
- クラウド必須ではない
- プライバシー第一

### 🎁 成長の実感
- ストリーク機能（連続日数カウント）
- ベストジャンプ記録の自動更新
- 達成バッジ

---

## 🚀 なぜ jump_lab なのか？

### 1️⃣ 市場に存在しない
日本でジャンプ力を簡単に測定できるアプリは**ほぼない**。
バスケ選手、バレーボール選手、フィットネス愛好家みんなが待ってた。

### 2️⃣ 必要な機材は スマホだけ
ジャンプマットは高い。ジムは遠い。
jump_lab なら自宅で、今すぐ測定できる。

### 3️⃣ 記録する理由がある
「測定できる」だけでなく、「継続したくなる仕組み」がある。
毎日のトレーニング、グラフで見える化、達成感。

### 4️⃣ 基本無料 + 軽量プレミアム
基本機能（測定・記録・トレーニング）は無料。

- **月200円のプレミアムプラン**: 広告オフ・動画計測無制限・履歴無制限
- **無料でも広告オフにできる**: アプリを1回シェアすると、その端末では広告が表示されなくなる

---

## 📥 インストール

### iOS
[App Store で jump_lab を見る](https://apps.apple.com/app/id6772440429)

### Android
Google Play から「jump_lab」で検索（リリース予定）

### 開発環境で試す
```bash
git clone https://github.com/dbafitge6/jump_lab.git
cd jump_lab
flutter pub get
flutter run
```

---

## 🛠️ 技術スタック

| 項目 | 技術 |
|------|------|
| **フレームワーク** | Flutter 3.11+ |
| **言語** | Dart |
| **センサー** | sensors_plus |
| **ローカルDB** | SQLite (sqflite) |
| **UI** | Material 3 |
| **カメラ** | camera, video_player |
| **課金** | RevenueCat (purchases_flutter) |
| **広告** | Google Mobile Ads |

---

## 📊 対応プラットフォーム

- ✅ iOS 13.0+
- ✅ Android 5.0+
- 🔜 Web（検討中）

---

## 🎯 ターゲットユーザー

- 🏃 ジャンプ力を上げたい全ての人
- 🏀 バスケ・バレー選手
- 💪 フィットネス愛好家
- 👨‍🏫 体育の先生・スポーツ指導者
- 🎓 学生（体力測定の自主訓練）

---

## 🤝 貢献ガイド

バグレポート、機能提案、コード貢献を歓迎します！

### 報告方法
- **バグ**: GitHub Issues で報告
- **機能提案**: Discussions で提案
- **コード**: Pull Request で提出

### 開発ルール
- Dart のコード規約に従う
- `flutter analyze` でエラーなし

---

## 📝 プロジェクトロードマップ

### v1.0 ✅ 完了
- 基本的なジャンプ測定
- カレンダー記録
- トレーニングメニュー
- iOS/Android対応

### v1.1 🔜 次予定
- AI トレーニングガイダンス
- インターバル訓練モード
- 友達とのスコア共有機能

### v2.0 🎯 検討中
- ウェブダッシュボード
- ソーシャル機能（ランキング）
- ウェアラブル連携

---

## 📧 お問い合わせ

- **Twitter**: @jump_lab（開設予定）
- **GitHub Issues**: [Issue を作成](https://github.com/dbafitge6/jump_lab/issues)

---

## 📄 ライセンス

MIT License - 詳しくは [LICENSE](LICENSE) を参照

---

## 🙏 謝辞

- Flutter コミュニティ
- ユーザーの皆さんの応援

<div align="center">

**毎日1回のジャンプが、あなたを変える。**

[App Store](https://apps.apple.com/app/id6772440429) • Google Play（リリース予定）

</div>
