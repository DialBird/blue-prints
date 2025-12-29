# 自動化設定ガイド

このリポジトリに設定されている自動化の仕組みと必要な設定を説明する。

## 概要

| 機能 | 目的 | 実行タイミング |
|------|------|----------------|
| Dependabot | パッケージ更新PRの自動作成 | 毎週月曜9時(JST) |
| CI | ビルド・リント・型チェック | PR時 / master push時 |
| OSV-Scanner | 脆弱性スキャン | master push時 / 毎週月曜9時 |
| Auto-merge | Dependabot PRの自動マージ | PR作成時 |

## Dependabot PRの自動マージフロー

```
Dependabot PR作成
    │
    ├─→ CI実行 (check-nextjs, check-vite)
    │
    └─→ Auto-merge ワークフロー実行
        │
        ├─ patch/minor更新
        │   └─→ CIが通るのを待機 → 自動マージ
        │
        └─ major更新
            └─→ 手動レビュー促すコメント追加
```

## 必要なGitHub設定

### 1. Auto-mergeの有効化（必須）

**Settings → General → Pull Requests**

- [x] `Allow auto-merge` を有効化

これがないと `gh pr merge --auto` が機能しない。

### 2. Branch Protection Rules（推奨）

**Settings → Branches → Add rule**

- **Branch name pattern**: `master`
- [x] `Require status checks to pass before merging`
- [x] `Require branches to be up to date before merging`
- **Required status checks**:
  - `check-nextjs`
  - `check-vite`

## ワークフロー詳細

### CI（`.github/workflows/ci.yml`）

両テンプレートに対して以下を実行：

- `pnpm install --frozen-lockfile`
- `pnpm biome check .`
- `pnpm tsc --noEmit`
- `pnpm build`

### OSV-Scanner（`.github/workflows/security-scan.yml`）

- Google製の脆弱性スキャナー
- OSV.devデータベースを参照
- 結果はGitHub Security tabに表示

### Dependabot（`.github/dependabot.yml`）

- 週次でパッケージ更新PRを作成
- patch/minor更新はグループ化してPR数を削減
- `chore(deps)` プレフィックスでコミット

### Auto-merge（`.github/workflows/dependabot-auto-merge.yml`）

- Dependabot PRのみ対象（`github.actor == 'dependabot[bot]'`）
- patch/minor: 自動マージ予約
- major: 手動レビュー促すコメント追加

## トラブルシューティング

### Auto-mergeが動かない

1. リポジトリ設定で `Allow auto-merge` が有効か確認
2. Branch protection rulesで必要なステータスチェックが設定されているか確認
3. `GITHUB_TOKEN` の権限（`contents: write`, `pull-requests: write`）を確認

### CIが失敗する

1. `pnpm-lock.yaml` が最新か確認
2. ローカルで `pnpm biome check .` を実行して確認
3. Node.js / pnpm のバージョンを確認（Node 24+, pnpm 10+）

### OSV-Scannerで脆弱性が検出された

1. GitHub Security tabで詳細を確認
2. Dependabotがセキュリティ更新PRを自動作成するのを待つ
3. 緊急の場合は手動で `pnpm update <package>` を実行
