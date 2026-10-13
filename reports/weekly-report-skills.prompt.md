# 事業部向け脆弱性レポート生成（Headless Cloud Security の sysdig-investigate）

事業 `{BIZ}`（a / b / c）の**脆弱性レポート**を、日本語の Markdown で作ってください。
Sysdig の Headless Cloud Security スキル `headless-cloud-security:sysdig-investigate` と、Sysdig の MCP サーバー（`secure-mcp-server`）を使います。

**この実行は無人です。ユーザーへの質問はできません。** 選択が必要な場面は、以下の既定で自分で決めてください。

## 守ること

- 読み取り専用。チケット作成、PR、設定変更、スキルの状態保存（`save_skill_state` など）、レポート成果物の保存（`save_plan_report` など）はしない。
  他のスキル（`sysdig-remediate` など）への引き継ぎもしない。
- 対象は `{BIZ大文字}-dev` / `{BIZ大文字}-stg` / `{BIZ大文字}-prod` の Zone が指す namespace（`{BIZ}-dev` / `{BIZ}-stg` / `{BIZ}-prod`）だけ。他の事業のデータは含めない。
  このテナントでは、他の事業のデータもツールから見えてしまうため、**必ず namespace で絞り、結果にも対象外の namespace が混ざっていないか確認する**。
- **`zone_ids` や `zoneId` のフィルタは使わない**（このテナントでは効かないことを確認済み。どの Zone ID を指定しても全件が返る）。
  Zone は、対象 namespace を知るためにだけ使う（`list_zones` の `scopes[].rules` の `namespace`）。
- 数字は取得した値だけを使う。取れなかった項目は「未取得」と書き、推測で埋めない。推測を含む記述には「推定」と明記する。
- スキルの案内（初回の注意書き、次の作業の提案）は、レポートに含めない。

## 手順

1. `list_zones` で、名前が `{BIZ大文字}-` で始まる Zone を取得し、各 Zone の `namespace` を控える。
2. Skill ツールで `headless-cloud-security:sysdig-investigate` を使い、**Findings フロー**で脆弱性を調べる（Plans フローは使わない）。
   絞り込みは `namespace` のフィルタ（`in`）で行い、次を調べる。
   - 環境（dev / stg / prod）別の、重大度別の件数（Critical / High / Medium / Low）。
   - Critical / High の、修正可能（`hasFix`）なもの、悪用可能（`hasExploit`）なもの、実行中のパッケージ（`inUse`）のもの。
   - 影響の大きい順の上位（イメージ、CVE、パッケージ）。同じ原因（共有のベースイメージ、同じパッケージ）に集中していれば、そう書く。
3. ワークスペースの `github-data.json`（CI の最新実行と Code scanning の件数）を Read する。`gh` コマンドは使えない。
4. 次の形式のレポートを、ワークスペースの `report.md` に Write ツールで保存する（標準出力には出さない）。

```
# Business {BIZ大文字} 脆弱性レポート（<取得日>）
対象 Zone / namespace / クラスタ、データ取得日時、対象外の namespace が混ざっていないことの確認結果

## 1. サマリ（3行以内）
## 2. 環境別の脆弱性（dev / stg / prod の表: イメージ、Critical/High/Medium/Low）
## 3. 優先して直すもの（修正可能・悪用可能・実行中のものの上位。原因の集中があれば明記）
## 4. CI の結果（最新の実行、ゲート判定、Code scanning）
## 5. 推奨アクション（担当が動ける形で、優先度順に3件まで）
```
