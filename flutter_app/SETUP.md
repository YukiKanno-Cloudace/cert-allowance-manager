# Flutter版 資格手当管理アプリ セットアップガイド

## 前提条件

### Flutter SDKのインストール

1. Flutter公式サイトからSDKをダウンロード
   - https://flutter.dev/docs/get-started/install

2. インストール確認
```bash
flutter doctor
```

すべてのチェックマークが緑になるまで指示に従ってください。

## プロジェクトのセットアップ

### 1. 依存関係のインストール

```bash
cd flutter_app
flutter pub get
```

### 2. 各プラットフォームでの実行

#### iOS（macOS のみ）

```bash
# iOS Simulatorで実行
flutter run -d ios

# リリースビルド
flutter build ios
```

#### Android

```bash
# Androidエミュレータで実行
flutter run -d android

# リリースビルド（APK）
flutter build apk

# リリースビルド（App Bundle）
flutter build appbundle
```

#### Web

```bash
# Webで実行
flutter run -d chrome

# リリースビルド
flutter build web

# ビルドしたWebアプリは build/web/ に出力されます
```

#### Windows（Windows のみ）

```bash
# Windowsで実行
flutter run -d windows

# リリースビルド
flutter build windows
```

#### macOS（macOS のみ）

```bash
# macOSで実行
flutter run -d macos

# リリースビルド
flutter build macos
```

#### Linux（Linux のみ）

```bash
# Linuxで実行
flutter run -d linux

# リリースビルド
flutter build linux
```

### 3. デバイスの確認

利用可能なデバイスを確認：

```bash
flutter devices
```

### 4. ホットリロード

アプリ実行中に `r` キーを押すとホットリロード（画面の再読み込み）が実行されます。

## トラブルシューティング

### pubspec.yamlのエラー

```bash
flutter pub get
```

### ビルドエラー

```bash
flutter clean
flutter pub get
flutter run
```

### iOS Podのエラー（macOS）

```bash
cd ios
pod install
cd ..
flutter run
```

### Androidのエラー

```bash
flutter clean
cd android
./gradlew clean
cd ..
flutter run
```

## 開発のヒント

### VSCodeでの開発

推奨拡張機能：
- Flutter
- Dart

### Android Studioでの開発

- Flutter pluginをインストール
- Dart pluginをインストール

### デバッグ

```bash
# デバッグモードで実行
flutter run

# プロファイルモードで実行（パフォーマンス測定）
flutter run --profile

# リリースモードで実行
flutter run --release
```

## よくある質問

**Q: どのプラットフォームで開発できますか？**

A: 
- macOS: iOS、Android、Web、macOS、Linuxアプリを開発可能
- Windows: Android、Web、Windowsアプリを開発可能
- Linux: Android、Web、Linuxアプリを開発可能

**Q: アプリのサイズが大きいです**

A: リリースビルドを使用してください。デバッグビルドは開発用の情報が含まれるため大きくなります。

```bash
flutter build apk --release
```

**Q: エミュレータが起動しません**

A: Android Studioまたは Xcodeからエミュレータを起動してから `flutter run` を実行してください。

## 参考リンク

- [Flutter公式ドキュメント](https://flutter.dev/docs)
- [Dart言語ツアー](https://dart.dev/guides/language/language-tour)
- [Flutter Widget カタログ](https://flutter.dev/docs/development/ui/widgets)
- [pub.dev（パッケージ検索）](https://pub.dev/)

