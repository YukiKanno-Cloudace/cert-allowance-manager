# 資格手当管理アプリ プロジェクト概要

**作成日**: 2025年12月25日  
**最終更新**: 2025年12月25日  
**バージョン**: 1.1.0

## プロジェクト概要

本プロジェクトは、Google Cloud認証資格を中心とした18種類の資格における手当管理を目的としたクロスプラットフォームアプリケーションである。資格の取得状況、有効期限、月額手当の管理機能に加え、期限切れアラートや更新可能期間の通知機能を提供する。

## 対応プラットフォーム

### 実装済みプラットフォーム

| プラットフォーム | 技術スタック | 通知機能 | 状態 |
|--------------|------------|---------|------|
| Web | HTML/CSS/JavaScript | ブラウザベース | 完成 |
| Android | Flutter/Dart | バックグラウンド対応 | 完成 |
| macOS | Flutter/Dart | バックグラウンド対応 | 完成 |

### 対応可能プラットフォーム（未実装）

- iOS（Flutter対応済み）
- Windows（Flutter対応済み）
- Linux（Flutter対応済み）

## 機能仕様

### コア機能

#### 1. 資格管理機能
- 18種類の対象資格の管理
- 資格取得日の記録
- 有効期限の自動計算（資格ごとに2年または3年）
- 月額手当の自動集計（上限10万円）

#### 2. 資格ステータス表示
- 有効な資格
- 更新が必要な資格（期限180日前から）
- 期限切れの資格（支給停止表示）

#### 3. 通知機能
- 初回起動時の通知許可リクエスト（自動）
- 給料日通知（毎月指定日の午前9時）
- 資格更新可能通知（更新可能期間開始時）
- 期限アラート（1ヶ月前、1週間前、前日）
- カスタムリマインダー（UI実装済み）
- テスト通知（動作確認用）

#### 4. UI機能
- テーマ切り替え（7種類のカラーテーマ）
- ダークモード対応
- レスポンシブデザイン
- 期限切れ資格の視覚的表示（取り消し線＋「支給停止」バッジ）

### 対象資格一覧

#### Google Cloud認証（15資格）

**Associate レベル（月額5,000円、有効期限3年）**
1. Cloud Digital Leader
2. Generative AI Leader
3. Associate Cloud Engineer
4. Associate Google Workspace Administrator
5. Associate Data Practitioner

**Professional レベル（月額10,000円、有効期限2年）**
6. Professional Cloud Architect
7. Professional Database Engineer
8. Professional Cloud Developer
9. Professional Data Engineer
10. Professional Cloud DevOps Engineer
11. Professional Cloud Security Engineer
12. Professional Cloud Network Engineer
13. Professional Machine Learning Engineer
14. Professional Security Operations Engineer

**Chrome OS（月額5,000円、有効期限3年）**
15. Professional ChromeOS Administrator

#### その他の認証（3資格）

**CNCF（月額10,000円、有効期限3年）**
16. Certified Kubernetes Application Developer (CKAD)
17. Certified Kubernetes Administrator (CKA)

**PMI（月額10,000円、有効期限3年）**
18. Project Management Professional (PMP)

### 手当計算ルール

1. **月額手当**: 対象資格ごとに定められた月額手当を支給
2. **上限**: 合計月額手当の上限は10万円
3. **期限切れ**: 有効期限を過ぎた資格は支給停止
4. **更新期間**: 有効期限の180日前から更新可能

## 技術仕様

### Web版

**技術スタック**
- HTML5
- CSS3（カスタムプロパティによるテーマ管理）
- Vanilla JavaScript（ES6+）
- LocalStorage（データ永続化）
- Web Notifications API

**主要ファイル**
```
/
├── index.html              # メインHTML
├── styles.css              # メインスタイル
├── themes.css              # テーマ定義
├── app.js                  # アプリケーションロジック
└── notification.js         # 通知管理
```

**実行方法**
```bash
cd /Users/user/sandbox/freedom/projects/qualification-allowance-app
python3 -m http.server 8000
# ブラウザで http://localhost:8000 を開く
```

### Flutter版（Android/macOS/iOS等）

**技術スタック**
- Flutter 3.x
- Dart 3.x
- Provider（状態管理）
- SQLite（データベース）
- SharedPreferences（設定保存）
- flutter_local_notifications（通知）
- timezone（タイムゾーン管理）

**主要依存関係**
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2
  sqflite: ^2.4.2
  shared_preferences: ^2.5.4
  intl: ^0.20.2
  flutter_local_notifications: ^17.2.4
  timezone: ^0.9.4
```

**プロジェクト構造**
```
flutter_app/
├── lib/
│   ├── main.dart                           # エントリーポイント
│   ├── models/                             # データモデル
│   │   ├── certification.dart              # 資格モデル
│   │   ├── acquired_cert.dart              # 取得済み資格モデル
│   │   └── notification_settings.dart      # 通知設定モデル
│   ├── providers/                          # 状態管理
│   │   ├── cert_provider.dart              # 資格データプロバイダー
│   │   ├── theme_provider.dart             # テーマプロバイダー
│   │   └── notification_provider.dart      # 通知プロバイダー
│   ├── services/                           # サービス層
│   │   ├── storage_service.dart            # データ永続化
│   │   └── notification_service.dart       # 通知管理
│   ├── constants/                          # 定数
│   │   ├── certification_data.dart         # 資格マスターデータ
│   │   └── app_theme.dart                  # テーマ定義
│   ├── screens/                            # 画面
│   │   ├── home_screen.dart                # ホーム画面
│   │   ├── add_cert_screen.dart            # 資格追加画面
│   │   ├── master_screen.dart              # 資格一覧画面
│   │   ├── theme_selector_screen.dart      # テーマ選択画面
│   │   └── notification_settings_screen.dart # 通知設定画面
│   └── widgets/                            # 再利用可能なウィジェット
│       ├── summary_card.dart               # サマリーカード
│       ├── cert_card.dart                  # 資格カード
│       └── alert_banner.dart               # アラートバナー
├── android/                                # Android設定
├── macos/                                  # macOS設定
├── ios/                                    # iOS設定
└── pubspec.yaml                            # 依存関係定義
```

**プラットフォーム固有の設定**

Android（`android/app/src/main/AndroidManifest.xml`）:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
```

macOS（`macos/Runner/Info.plist`）:
```xml
<key>NSUserNotificationAlertStyle</key>
<string>alert</string>
<key>UIBackgroundModes</key>
<array>
  <string>fetch</string>
  <string>remote-notification</string>
</array>
```

macOS（`macos/Runner/Release.entitlements`）:
```xml
<key>com.apple.security.app-sandbox</key>
<true/>
```

**ビルド方法**

macOS版:
```bash
cd flutter_app
flutter build macos --release
# 生成物: build/macos/Build/Products/Release/qualification_allowance_app.app
```

Android版:
```bash
cd flutter_app
flutter build apk --release
# 生成物: build/app/outputs/flutter-apk/app-release.apk
```

iOS版:
```bash
cd flutter_app
flutter build ios --release
```

## データ構造

### 資格データモデル

```dart
class Certification {
  final String id;
  final String name;
  final String category;
  final int allowance;      // 月額手当（円）
  final int validYears;     // 有効期限（年）
}
```

### 取得済み資格データモデル

```dart
class AcquiredCert {
  final String id;
  final String certId;
  final DateTime acquiredDate;
  final DateTime expiryDate;
  final bool isExpired;
  final bool needsRenewal;
}
```

### 通知設定データモデル

```dart
class NotificationSettings {
  final bool salaryDayNotificationEnabled;
  final int salaryDay;
  final bool renewalNotificationEnabled;
  final bool customReminderEnabled;
}
```

## UI/UXの特徴

### カラーテーマ（7種類）

1. **Light**: シンプルなブルーグレー
2. **Neutral Grey**: Google風シンプル
3. **Soft Blue**: 落ち着いた青
4. **Soft Green**: 優しい緑
5. **Warm Grey**: 温かみのあるグレー
6. **Minimal Grey**: 最小限の色使い
7. **Dark**: 目に優しい暗色

### アクセシビリティ

- WCAG準拠のコントラスト比
- ダークモード対応
- 視覚的なステータス表示（色＋テキスト）
- 明確なエラーメッセージ

### レスポンシブデザイン

- モバイル優先設計
- タブレット対応
- デスクトップ対応
- 適切なブレークポイント設定

## 通知機能の詳細

### 通知の種類

#### 1. 初回起動時の通知許可リクエスト
- アプリ初回起動時に自動的に表示
- ユーザーの選択結果を記録
- 2回目以降は表示しない

#### 2. 給料日通知
- 毎月指定日（デフォルト: 25日）の午前9時に通知
- 当月の資格手当合計金額を表示
- 日付は1〜31日で設定可能

#### 3. 資格更新通知
- 更新可能期間（有効期限の180日前）に通知
- 期限1ヶ月前に通知
- 期限1週間前に通知
- 期限前日に通知

#### 4. テスト通知
- 設定画面から即座に送信可能
- 通知機能の動作確認用

### 通知の実装

**Web版**: Web Notifications API
- ブラウザを開いている時のみ通知が届く
- Service Worker未実装（PWA化で対応可能）

**Flutter版（Android/iOS/macOS）**: flutter_local_notifications
- **完全なバックグラウンド通知対応**
- アプリを閉じていても通知が届く
- プラットフォームネイティブの通知センターに統合

#### バックグラウンド通知の実装詳細

**Android**:
- `AndroidScheduleMode.exactAllowWhileIdle`を使用
- `SCHEDULE_EXACT_ALARM`権限により正確な時刻に通知
- システムが通知をスケジュール管理
- アプリが終了していても確実に通知が届く

**iOS**:
- DarwinNotificationDetailsによるネイティブ通知
- バックグラウンドでの通知スケジューリング
- 通知センターに統合

**macOS**:
- `NSUserNotificationAlertStyle: alert`により永続的な通知
- バックグラウンドモード有効化
- システム通知センターに統合
- アプリを完全終了していても通知が届く

**スケジュール方式**:
- `zonedSchedule`メソッドによるタイムゾーン対応スケジューリング
- 毎月繰り返し通知：`matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime`
- 個別通知：特定の日時に1回のみ通知

## 開発履歴と主要な課題解決

### 初期開発
1. 仕様書の作成と資格情報の調査
2. Web版プロトタイプの実装
3. Flutter版への移植

### UI/UX改善
1. カラーテーマの全面見直し（過度な彩度の抑制）
2. ダークモードの読みやすさ向上
3. 期限切れ資格の視覚的表示（取り消し線＋バッジ）
4. 更新ステータスの統合表示

### 技術的課題の解決

#### 課題1: Google Cloud資格の有効期限の正確性
- 問題: 初期データに誤った有効期限が含まれていた
- 解決: 公式ドキュメントを調査し、Associate レベル資格を3年に修正

#### 課題2: 期限切れ資格の手当計算
- 問題: 期限切れの資格が手当に含まれていた
- 解決: `isExpired`チェックを追加し、有効な資格のみ集計

#### 課題3: 資格名の長さによるUI崩れ
- 問題: 長い資格名でテキストオーバーフローが発生
- 解決: `TextOverflow.ellipsis`と`maxLines`を設定

#### 課題4: Web版の通知が動作しない
- 問題: file://プロトコルでは通知機能に制限がある
- 解決: ローカルHTTPサーバーを使用してhttp://経由でアクセス

#### 課題5: macOS版の通知設定画面のローディング時間
- 問題: NotificationServiceの初期化に時間がかかる
- 解決: タイムアウト処理とエラーハンドリングを追加（3秒以内に表示）

#### 課題6: macOS版の通知許可チェック
- 問題: macOS用の許可チェックが実装されていなかった
- 解決: MacOSFlutterLocalNotificationsPluginを使用して正確な許可状態を取得

#### 課題7: macOS版のバックグラウンド通知
- 問題: macOSでアプリを閉じると通知が届かない可能性があった
- 解決: Info.plistに`NSUserNotificationAlertStyle`と`UIBackgroundModes`を追加し、Entitlementsファイルを更新してバックグラウンド通知を完全対応

## インストールと実行

### Web版

```bash
cd /Users/user/sandbox/freedom/projects/qualification-allowance-app
python3 -m http.server 8000
# ブラウザで http://localhost:8000 を開く
```

### macOS版

アプリケーションフォルダにインストール済み:
```
/Applications/qualification_allowance_app.app
```

起動方法:
- Spotlight検索（Command + Space）→「qualification」
- Launchpad
- Finderのアプリケーションフォルダから直接起動

### Android版

エミュレータで実行:
```bash
cd flutter_app
flutter run -d emulator-5554
```

またはAPKとしてビルド:
```bash
flutter build apk --release
```

## バックグラウンド通知のテスト方法

### Android/macOS版

1. **アプリを起動して通知設定を有効化**:
   - 右上のメニュー → 「通知設定」
   - 「給料日通知」または「資格更新通知」をONにする
   - 必要に応じて給料日を設定

2. **通知許可を確認**:
   - 「通知許可を確認」ボタンをタップ
   - システム設定で許可されているか確認

3. **テスト通知を送信**:
   - 「テスト通知を送信」ボタンをタップ
   - 即座に通知が表示されることを確認

4. **バックグラウンド通知をテスト**:
   - アプリを完全に終了（macOS: Command + Q、Android: アプリを閉じる）
   - スケジュールされた時刻に通知が届くことを確認
   - 給料日通知: 設定した日の午前9時
   - 更新通知: 資格の更新可能日（有効期限の180日前）

5. **通知センターで確認**:
   - macOS: 画面右上の通知センター
   - Android: 通知パネル

### 注意事項

**macOS**:
- 初回起動時にシステムから通知許可を求められる
- 一度拒否すると、システム環境設定から手動で許可が必要
- パス: システム環境設定 → 通知 → qualification_allowance_app

**Android**:
- Android 13以降では通知許可が必要
- 設定 → アプリ → qualification_allowance_app → 通知

## 今後の拡張可能性

### 機能拡張
1. カスタムリマインダーの完全実装（個別の日時設定）
2. データのエクスポート/インポート機能
3. 複数ユーザー対応
4. クラウド同期機能
5. 資格取得履歴の統計表示

### プラットフォーム拡張
1. iOS版のビルドと配布
2. Windows版のビルドと配布
3. Linux版のビルドと配布
4. PWA化（Web版の機能強化）

### UI/UX改善
1. アニメーション効果の追加
2. 資格カードのカスタマイズ
3. ウィジェット機能（スマートフォンのホーム画面）
4. Apple Watch対応

## ドキュメント

### 関連ドキュメント
- `資格手当仕様書.md`: 資格手当制度の詳細仕様
- `flutter_app/README.md`: Flutterアプリのセットアップ手順
- `flutter_app/SETUP.md`: 開発環境のセットアップ方法

### 参考資料
- Google Cloud認証公式ドキュメント: https://cloud.google.com/learn/certification
- Google Cloud認証の更新について: https://support.google.com/cloud-certification/answer/9907853

## ライセンスと著作権

本プロジェクトは社内利用を目的として開発されたものである。

---

**最終更新**: 2025年12月25日


