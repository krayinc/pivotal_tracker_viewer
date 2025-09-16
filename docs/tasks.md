# 実装タスクリスト

Rails 8 ベースの Pivotal Tracker Viewer を完成させるためのタスクを、実装順の目安に沿って整理しています。完了状況に応じてチェックボックスを更新してください。

## フェーズ 0: 開発環境整備
- [x] Rails 8 プロジェクトのセットアップ確認 (`bin/setup`, `bin/dev` が動作する状態か)
- [ ] 依存 Gem の選定と追加（`roo`, `caxlsx`, `commonmarker` or `redcarpet`, `annotate` 等必要に応じて）
- [ ] Rubocop / standardrb 等のコード整形ツール導入の要否判断

## フェーズ 1: データモデル & インポート基盤
- [ ] DB マイグレーション作成 (`Story`, `StoryOwnership`, `StoryLabel`, `StoryComment`, `StoryTask`, `StoryBlocker`, `StoryPullRequest`, `StoryBranch`, `Epic` など)
- [ ] モデル実装と関連付け、バリデーション整備
- [ ] `Imports::StoriesXlsxImporter` サービス実装（Excel 解析 → 正規化 → トランザクション保存）
- [ ] インポート用テストデータ整備（小規模サンプル Excel の作成 or fixture 生成）
- [ ] インポート処理のユニットテスト/統合テスト追加

## フェーズ 2: ストーリー閲覧機能（一覧＆詳細）
- [ ] `StoriesController` 実装（index/show）
- [ ] 一覧画面: Turbo Frame 化、ページング or 無限スクロール用 Stimulus（`InfiniteScrollController` 仮）
- [ ] 詳細表示: Turbo Stream モーダル or サイドペイン、Markdown レンダリング対応
- [ ] フィルタフォーム: フリーテキスト、ラベル/タイプ/状態/優先度/担当者/日付レンジ
- [ ] フィルタ適用ロジック（`StoriesQuery` PORO 等）とテスト
- [ ] レイアウト / タグ UI / 状態バッジ等のスタイル整備

## フェーズ 3: エピック・集計ビュー
- [ ] `EpicsController` / ビュー実装
- [ ] エピック進捗集計（accepted 比率、ポイント合計）ロジック
- [ ] エピック選択でストーリー一覧へフィルタ連携
- [ ] 必要に応じた追加 UI（グラフ表示など）の検討

## フェーズ 4: 設定・インポート UI
- [ ] `ImportsController` 実装（新規/作成/削除）
- [ ] ファイル選択フォームと進捗表示
- [ ] インポート完了/失敗時の Turbo Stream トースト通知
- [ ] インポート履歴 or 最終実行日時の表示

## フェーズ 5: 仕上げ
- [ ] システムテスト（一覧フィルタ、詳細表示、インポートワークフロー）
- [ ] エラーハンドリングとユーザーフィードバック（例: 必須列欠損時の処理）
- [ ] 国際化 (i18n) メッセージ整備、日本語 UI の文言確認
- [ ] README/ドキュメント更新（セットアップ手順、利用方法）
- [ ] パフォーマンス検証（インポート時間、検索応答）

必要に応じてタスクの分割・統合・順序変更を行い、進行状況を管理してください。
