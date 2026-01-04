# 資格手当管理アプリ

資格取得と手当を管理するためのWebアプリケーションです。

## 機能

- 取得した資格の月額手当合計表示（上限10万円）
- 資格の取得日入力と有効期限の自動計算
- 有効期限が近い資格（90日以内）のアラート表示
- 資格一覧のフィルタリング機能（すべて/更新必要/有効）
- LocalStorageを使用したデータの永続化
- レスポンシブデザインで、PC・タブレット・スマートフォンに対応

## 使い方

1. `index.html`をブラウザで開く
2. 「資格を追加」セクションで資格を選択し、取得日を入力
3. 「資格を追加」ボタンをクリック
4. 取得済み資格一覧で確認

## 対応資格

### Google Cloud - Foundational / Associate レベル（5資格）
- 月額手当: ¥5,000
- 有効期限: 3年
- Cloud Digital Leader、Generative AI Leader、Associate Cloud Engineer、Associate Google Workspace Administrator、Associate Data Practitioner

### Google Cloud - Professional レベル（9資格）
- 月額手当: ¥10,000
- 有効期限: 2年
- Professional Cloud Architect、Professional Database Engineer、Professional Cloud Developer、Professional Data Engineer、Professional Cloud DevOps Engineer、Professional Cloud Security Engineer、Professional Cloud Network Engineer、Professional Machine Learning Engineer、Professional Security Operations Engineer

### その他（4資格）
- **CNCF Kubernetes（2資格）**: ¥10,000/月、3年（CKA、CKAD）
- **PMP**: ¥10,000/月、3年
- **ChromeOS Administrator**: ¥5,000/月、3年

**合計18資格に対応**

### 有効期限の詳細

- **Google Cloud Foundational / Associate資格**: 有効期限の180日前から更新可能
- **Google Cloud Professional資格**: 有効期限の60日前から更新可能
- **CNCF Kubernetes資格**: 3年間有効
- **PMP**: 3年間有効（60 PDU取得が必要）
- **ChromeOS Administrator**: 3年間有効

## アラート機能

有効期限まで90日以内の資格について：
- トップページに警告を表示
- 該当する資格を一覧表示
- 残り日数を表示

## 技術仕様

- HTML5
- CSS3（レスポンシブデザイン）
- Vanilla JavaScript（フレームワーク不要）
- LocalStorage（データ永続化）

## ブラウザ対応

- Chrome（推奨）
- Firefox
- Safari
- Edge

## データ管理

すべてのデータはブラウザのLocalStorageに保存されます。
- サーバー不要
- オフラインでも動作
- ブラウザのキャッシュをクリアするとデータが削除されます

## 注意事項

- データはブラウザごとに独立して保存されます
- 異なるブラウザ間でデータは共有されません
- 重要なデータは定期的にバックアップすることをお勧めします

## ライセンス

このプロジェクトは社内利用を目的としています。
