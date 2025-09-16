# Pivotal Tracker Viewer

ローカルに保存された Pivotal Tracker エクスポートファイル（`stories.xlsx`）を解析し、検索・閲覧できる Rails 8 アプリケーションです。Turbo / Stimulus / Hotwire など Rails 8 標準スタックを活用したモダンなアーキテクチャで構築します。現時点では `rails new` 直後の状態から機能を実装していきます。

## 目的
- Pivotal Tracker から出力されたストーリー情報を正規化して内部 DB に保存し、ローカル環境で高速に検索・閲覧できるようにする。
- 過去のストーリーを参照したい PdM / スクラムマスター / 開発リーダーなどが、キーワード・ラベル・担当者・状態などで横断的に調査できるようにする。

## データ仕様
- 入力ファイル: `stories.xlsx`（Pivotal Tracker 標準エクスポート）。
- レコード数: 約 3,600 行、列数: 118。
- 主な列: `Id`, `Title`, `Labels`, `Type`, `Estimate`, `Priority`, `Current State`, `Created at`, `Accepted at`, `Requested By`, `Owned By`, `Description`, `URL`。
- 反復列: `Owned By`(3列), `Blocker`/`Blocker Status`(16セット), `Comment`(29列), `Task`/`Task Status`(13セット), `Pull Request`(8列), `Git Branch`(4列) など。
- イテレーション列 (`Iteration`, `Iteration Start`, `Iteration End`) は取り込まない。
- `stories.xlsx` の記載順（上から下、左から右）を保存順として踏襲する。

## 機能要件 (MVP)
- **ファイルインポート**: 利用者が `stories.xlsx` を指定して読み込み。既存データは完全置換。必須列欠損は警告。空セルは無視。
- **ストーリー一覧**: タイトル・タイプ・優先度・担当者・状態・ポイント等を表示。キーワード検索、ラベル/タイプ/状態/優先度/担当者の複数選択フィルタ、日付レンジフィルタ。Turbo Frame による差し替えとページング/無限スクロール。
- **ストーリー詳細**: Markdown 描画された説明、コメント、タスク、ブロッカー、PR、Git ブランチなどをセクション表示。担当者・ラベルはタグ表示。空セクションは折りたたみ。
- **エピックビュー**: エピック一覧と進捗サマリ（受け入れ済み割合、ポイント集計）。エピック選択時に関連ストーリーへフィルタ適用。
- **設定画面**: 最終インポート日時、再インポート、データ消去など。Turbo Stream で通知。

## 将来拡張候補
- 複数エクスポートファイルの管理や差分比較。
- ベロシティレポートなどのカスタム集計。
- Pivotal Tracker API との連携による最新データ取得。

## 非機能要件
- オフライン（ローカル）で完結し、外部ネットワーク依存なし。
- インポートは 1 分以内、通常検索は 1 秒以内を目標。
- UI は日本語対応。Markdown の改行・強調を保持。
- データ変換ロジックは列マッピングで管理し、列追加に柔軟に対応。
- ログなどに機密情報を出力しない。

## アーキテクチャ方針
- Rails 8 の標準構成（Propshaft, Solid Queue 等の新しいデフォルトを尊重）をベースに Turbo / Stimulus / Hotwire を活用。
- データモデル: `Story`, `StoryOwnership`, `StoryLabel`, `StoryComment`, `StoryTask`, `StoryBlocker`, `StoryPullRequest`, `StoryBranch`, `Epic` など。
- インポート処理: `Imports::StoriesXlsxImporter`（仮称）で Excel → 正規化データ → DB 保存を実施。`roo` などのライブラリを利用。
- 表示は Turbo Frame/Turbo Stream で部分更新、Stimulus でフィルタフォームやモーダル、無限スクロールを制御。
- Markdown は表示時にレンダリング（例: CommonMarker）。

## 実装ロードマップ (暫定)
1. 必要 Gem 選定、DB マイグレーションとモデル作成、インポートサービス実装＋テスト。
2. ストーリー一覧・詳細画面の作成、基本的な検索・フィルタ機能を実装。
3. エピックビューや集計表示の追加、Markdown レンダリング・タグ UI を整備。
4. 無限スクロールや通知などの UX 改善、システムテスト整備。

## セットアップメモ
- Rails 8 の標準的なセットアップ手順に従う（`bundle install`, `bin/rails db:setup` など）。
- `stories.xlsx` をプロジェクト直下（または設定ディレクトリ）に配置してインポートを実行する。
- 実装が進み次第、詳細な実行手順やコマンドを追記予定。
