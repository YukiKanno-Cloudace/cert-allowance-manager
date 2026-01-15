# 資格手当管理アプリ

資格取得と手当を管理するためのクロスプラットフォームアプリケーション。Google Cloud認証資格を中心とした18種類の資格の管理、有効期限アラート、通知機能を提供します。

## 特徴

- 📱 **マルチプラットフォーム対応**: Web版とFlutterアプリ版（Android/iOS/macOS/Windows/Linux）
- 💰 **手当管理**: 月額手当の自動集計（上限10万円）
- 📅 **有効期限管理**: 資格ごとに自動計算（2年または3年）
- 🔔 **通知機能**: バックグラウンド通知対応（Flutterアプリ版）
- 🎨 **カスタマイズ可能**: 7種類のカラーテーマとダークモード
- 📊 **ステータス管理**: 有効、更新必要、期限切れの視覚的表示

## スクリーンショット

| Web版          | Flutter版（モバイル） | Flutter版（デスクトップ） |
| -------------- | --------------------- | ------------------------- |
| ブラウザで動作 | iOS/Android対応       | macOS/Windows/Linux対応   |

## 対応資格（全18資格）

### Google Cloud認証（15資格）

#### Associate レベル（月額 ¥5,000 / 有効期限 3年）

- Cloud Digital Leader
- Generative AI Leader
- Associate Cloud Engineer
- Associate Google Workspace Administrator
- Associate Data Practitioner

#### Professional レベル（月額 ¥10,000 / 有効期限 2年）

- Professional Cloud Architect
- Professional Database Engineer
- Professional Cloud Developer
- Professional Data Engineer
- Professional Cloud DevOps Engineer
- Professional Cloud Security Engineer
- Professional Cloud Network Engineer
- Professional Machine Learning Engineer
- Professional Security Operations Engineer

#### Chrome OS（月額 ¥5,000 / 有効期限 3年）

- Professional ChromeOS Administrator

### その他の認証（3資格）

#### CNCF Kubernetes（月額 ¥10,000 / 有効期限 3年）

- Certified Kubernetes Administrator (CKA)
- Certified Kubernetes Application Developer (CKAD)

#### PMI（月額 ¥10,000 / 有効期限 3年）

- Project Management Professional (PMP)

## 機能一覧

### 共通機能（Web版・Flutter版）

- ✅ 資格の取得日記録と有効期限の自動計算
- ✅ 月額手当の自動集計（上限10万円）
- ✅ 有効期限アラート表示（90日以内）
- ✅ 資格のフィルタリング（すべて/更新必要/有効）
- ✅ 期限切れ資格の視覚的表示
- ✅ カラーテーマ切り替え（7種類）
- ✅ ダークモード対応

### Flutter版の追加機能

- 🔔 **バックグラウンド通知対応**（アプリを閉じていても通知が届く）
- 📅 給料日通知（毎月指定日の午前9時）
- 📝 資格更新通知（更新可能期間、1ヶ月前、1週間前、前日）
- 💾 SQLiteによる高速なデータベース管理
- 🎯 プラットフォームネイティブの通知センター統合

## インストールと実行

### Web版

#### 必要なもの

- モダンなWebブラウザ（Chrome、Firefox、Safari、Edge）
- Python 3（ローカルサーバー用）

#### 実行方法

```bash
# リポジトリをクローン
git clone git@github.com:YukiKanno-Cloudace/cert-allowance-manager.git
cd cert-allowance-manager

# ローカルサーバーを起動
python3 -m http.server 8000

# ブラウザで開く
# http://localhost:8000
```

### Flutter版

#### 必要なもの

- Flutter SDK 3.0以上
- Dart SDK 3.0以上

#### セットアップ

```bash
cd flutter_app

# 依存関係をインストール
flutter pub get

# 実行（デバイスを選択）
flutter run
```

#### プラットフォーム別ビルド

```bash
# Android APK
flutter build apk --release

# iOS（macOSのみ）
flutter build ios --release

# macOS（macOSのみ）
flutter build macos --release

# Windows（Windowsのみ）
flutter build windows --release

# Linux（Linuxのみ）
flutter build linux --release

# Web
flutter build web --release
```

詳細なセットアップ手順は [`flutter_app/SETUP.md`](flutter_app/SETUP.md) を参照してください。

## プロジェクト構造

```
cert-allowance-manager/
├── index.html              # Web版 - メインHTML
├── app.js                  # Web版 - アプリケーションロジック
├── notification.js         # Web版 - 通知管理
├── styles.css              # Web版 - メインスタイル
├── themes.css              # Web版 - テーマ定義
├── PROJECT_SUMMARY.md      # プロジェクト詳細仕様
└── flutter_app/            # Flutterアプリ
    ├── lib/
    │   ├── main.dart                      # エントリーポイント
    │   ├── models/                        # データモデル
    │   ├── providers/                     # 状態管理（Provider）
    │   ├── services/                      # サービス層
    │   ├── screens/                       # 画面
    │   ├── widgets/                       # 再利用可能なウィジェット
    │   └── constants/                     # 定数・マスターデータ
    ├── android/               # Android設定
    ├── ios/                   # iOS設定
    ├── macos/                 # macOS設定
    ├── windows/               # Windows設定
    ├── linux/                 # Linux設定
    ├── web/                   # Web設定
    ├── README.md              # Flutter版README
    └── SETUP.md               # セットアップガイド
```

## 技術スタック

### Web版

- **フロントエンド**: HTML5, CSS3, Vanilla JavaScript (ES6+)
- **データ永続化**: LocalStorage
- **通知**: Web Notifications API
- **スタイリング**: CSS Custom Properties（テーマ管理）

### Flutter版

- **フレームワーク**: Flutter 3.x
- **言語**: Dart 3.x
- **状態管理**: Provider
- **データベース**: SQLite (sqflite)
- **通知**: flutter_local_notifications
- **設定保存**: SharedPreferences
- **タイムゾーン**: timezone

## カラーテーマ

7種類のカラーテーマから選択可能：

1. **Light** - シンプルなブルーグレー（デフォルト）
2. **Neutral Grey** - Google風シンプル
3. **Soft Blue** - 落ち着いた青
4. **Soft Green** - 優しい緑
5. **Warm Grey** - 温かみのあるグレー
6. **Minimal Grey** - 最小限の色使い
7. **Dark** - 目に優しい暗色（ダークモード）

## 通知機能の詳細

### Web版

- ブラウザのWeb Notifications APIを使用
- ブラウザを開いている時のみ通知が届く
- 給料日通知と資格更新通知に対応

### Flutter版（Android/iOS/macOS等）

- **完全なバックグラウンド通知対応**
- アプリを完全に終了していても通知が届く
- プラットフォームネイティブの通知センターに統合
- 正確な時刻にスケジュール通知

#### 通知の種類

- 📅 **給料日通知**: 毎月指定日の午前9時に手当合計を通知
- 🔄 **更新可能通知**: 有効期限の180日前（更新可能期間開始時）
- ⚠️ **期限アラート**: 1ヶ月前、1週間前、前日に通知
- ✅ **テスト通知**: 動作確認用の即時通知

## データ管理

### Web版

- **LocalStorage**を使用
- ブラウザごとに独立してデータを保存
- ブラウザのキャッシュクリアでデータが削除される

### Flutter版

- **SQLite**データベースを使用
- アプリごとに独立した永続的なデータベース
- アンインストール時にデータが削除される

## 開発

### Web版の開発

```bash
# ファイルを編集後、ブラウザをリロードするだけ
# ローカルサーバーが起動していれば即座に反映
```

### Flutter版の開発

```bash
cd flutter_app

# デバッグモードで実行
flutter run

# ホットリロード（実行中に r キーを押す）

# コードフォーマット
dart format lib/

# 静的解析
flutter analyze
```

## トラブルシューティング

### Web版

- **通知が届かない**: ブラウザの通知許可を確認してください
- **データが消えた**: ブラウザのキャッシュクリアが原因です。定期的にバックアップをお勧めします

### Flutter版

- **ビルドエラー**: `flutter clean && flutter pub get` を実行してください
- **通知が届かない**: システムの通知設定を確認してください
  - Android: 設定 → アプリ → 通知
  - iOS: 設定 → 通知
  - macOS: システム環境設定 → 通知

詳細は [`flutter_app/SETUP.md`](flutter_app/SETUP.md) のトラブルシューティングセクションを参照してください。

## ドキュメント

- [`PROJECT_SUMMARY.md`](PROJECT_SUMMARY.md) - プロジェクトの詳細仕様と開発履歴
- [`flutter_app/README.md`](flutter_app/README.md) - Flutterアプリの概要
- [`flutter_app/SETUP.md`](flutter_app/SETUP.md) - 開発環境のセットアップ方法

## 今後の拡張可能性

### 機能拡張

- [ ] カスタムリマインダーの完全実装
- [ ] データのエクスポート/インポート機能
- [ ] 複数ユーザー対応
- [ ] クラウド同期機能
- [ ] 資格取得履歴の統計表示

### プラットフォーム拡張

- [ ] iOS版のビルドと配布
- [ ] Windows版のビルドと配布
- [ ] Linux版のビルドと配布
- [ ] Web版のPWA化

## ライセンス

このプロジェクトは社内利用を目的として開発されています。

## 参考資料

- [Google Cloud認証公式](https://cloud.google.com/learn/certification)
- [Google Cloud認証の更新について](https://support.google.com/cloud-certification/answer/9907853)
- [Flutter公式ドキュメント](https://flutter.dev/docs)

---

**最終更新**: 2026年01月05日




