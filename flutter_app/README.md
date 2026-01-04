# 資格手当管理アプリ - Flutter版

資格取得と手当を管理するためのクロスプラットフォームアプリケーションです。

## 対応プラットフォーム

- ✅ iOS
- ✅ Android
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 機能

- 取得した資格の月額手当合計表示（上限10万円）
- 資格の取得日入力と有効期限の自動計算
- 有効期限が近い資格（90日以内）のアラート表示
- 資格一覧のフィルタリング機能（すべて/更新必要/有効）
- ローカルデータベースによるデータ永続化
- Material Design 3対応のモダンUI

## セットアップ

### 前提条件

- Flutter SDK 3.0以上
- Dart SDK 3.0以上

### インストール

```bash
# 依存関係をインストール
flutter pub get

# 実行（デバイスを選択）
flutter run

# ビルド（リリース版）
flutter build apk        # Android
flutter build ios        # iOS
flutter build web        # Web
flutter build windows    # Windows
flutter build macos      # macOS
flutter build linux      # Linux
```

## プロジェクト構成

```
lib/
├── main.dart              # アプリのエントリーポイント
├── models/                # データモデル
│   ├── certification.dart # 資格マスターモデル
│   └── acquired_cert.dart # 取得済み資格モデル
├── providers/             # 状態管理
│   └── cert_provider.dart # 資格データプロバイダー
├── services/              # サービス層
│   └── storage_service.dart # ローカルストレージ
├── screens/               # 画面
│   ├── home_screen.dart   # ホーム画面
│   ├── add_cert_screen.dart # 資格追加画面
│   ├── cert_list_screen.dart # 資格一覧画面
│   └── master_screen.dart # 資格マスター画面
├── widgets/               # 再利用可能なウィジェット
│   ├── summary_card.dart  # サマリーカード
│   ├── cert_card.dart     # 資格カード
│   └── alert_banner.dart  # アラートバナー
└── constants/             # 定数
    ├── certification_data.dart # 資格マスターデータ
    └── app_theme.dart     # アプリテーマ
```

## 対応資格（18資格）

### Google Cloud - Foundational / Associate（5資格）
- 月額手当: ¥5,000 / 有効期限: 3年

### Google Cloud - Professional（9資格）
- 月額手当: ¥10,000 / 有効期限: 2年

### その他（4資格）
- CNCF Kubernetes（2資格）: ¥10,000/月、3年
- PMP: ¥10,000/月、3年
- ChromeOS Administrator: ¥5,000/月、3年

## ライセンス

このプロジェクトは社内利用を目的としています。

