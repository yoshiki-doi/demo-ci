# 事業部向け週次レポート生成（Headless）

事業 `{BIZ}`（a / b / c）の週次レポートを、日本語の Markdown で出力してください。
Sysdig Secure の MCP サーバー（`secure-mcp-server`）と `gh` コマンドだけを使い、書き込み系の操作はしないでください。

## 1. 対象範囲を Zone から決める

1. `list_zones` で、名前が `{BIZ大文字}-` で始まる Zone（例: `A-dev` / `A-stg` / `A-prod`）を取得する。
2. 各 Zone の `scopes[].rules` から `namespace` を取り出し、以降の絞り込み条件にする。
   - 例: `namespace in ("a-dev")` → `a-dev`

**権限の確認**: このトークンは、事業の Team に紐づく Zone だけが見える想定。`list_zones` に他の事業の Zone が含まれていたら、
レポートの冒頭に「想定外の Zone が見えている」と明記し、他の事業のデータは使わないこと。

**注意（検証済み）**: `list_vulnerability_findings*` の `zoneId_in` は効かない（存在しない Zone ID でも同じ結果が返る）。
Zone ID ではなく、手順 1〜2 で得た namespace で絞ること。

## 2. データを集める

| 項目 | ツールと条件 |
|---|---|
| ランタイム脆弱性 | `list_runtime_scan_results` の `filter`: `kubernetes.namespace.name="<ns1>" or kubernetes.namespace.name="<ns2>" or ...` |
| ランタイム検知の件数 | `count_runtime_events` の `filter_expr`: `kubernetes.namespace.name in ("<ns1>","<ns2>","<ns3>")`、`scope_hours`: 168 |
| 発火したルール | `discover_runtime_event_field_values`（`field`: `ruleName`、同じ `filter_expr`、`scope_hours`: 168）の `suggested` |
| CI の結果 | `gh run list -R yoshiki-doi/demo-biz-{BIZ} --limit 1 --json conclusion,createdAt,headSha` |
| Code scanning | `gh api "repos/yoshiki-doi/demo-biz-{BIZ}/code-scanning/alerts?state=open&per_page=100" --paginate`（権限や設定が無い場合は「対象外」と書く） |

## 3. 出力形式

```
# Business {BIZ大文字} 週次レポート（<取得日>）
対象 Zone / namespace / クラスタ、集計期間（7日）、データ取得日時

## 1. サマリ（3行以内）
## 2. 環境別の脆弱性（dev / stg / prod の表: イメージ、Critical/High/Medium/Low、ポリシー評価）
## 3. ランタイム検知（件数、重大度、ルール名）
## 4. CI の結果（最新の実行、ゲート判定、Code scanning）
## 5. 推奨アクション（担当が動ける形で、優先度順に3件まで）
```

## 4. 守ること

- 数字は取得した値だけを使う。取れなかった項目は「未取得」と書き、推測で埋めない。
- 推測を含む記述には「推定」と明記する。
- 他の事業のデータを混ぜない（対象 namespace 以外は含めない）。
