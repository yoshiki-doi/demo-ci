# 事業部向け週次レポート生成（Headless Cloud Security スキル版）

事業 `{BIZ}`（a / b / c）の週次レポートを、日本語の Markdown で作ってください。
Sysdig の Headless Cloud Security スキルと、Sysdig の MCP サーバー（`secure-mcp-server`）を使います。

**この実行は無人です。ユーザーへの質問はできません。** 選択が必要な場面は、以下の既定で自分で決めてください。

## 守ること

- 読み取り専用。チケット作成、PR、設定変更、スキルの状態保存（`save_skill_state` など）はしない。
- 対象は `{BIZ大文字}-dev` / `{BIZ大文字}-stg` / `{BIZ大文字}-prod` の Zone と、その namespace だけ。他の事業のデータは含めない。
  `list_zones` に他の事業の Zone が含まれていたら、レポートの冒頭に「想定外の Zone が見えている」と明記する。
- 数字は取得した値だけを使う。取れなかった項目は「未取得」と書き、推測で埋めない。推測を含む記述には「推定」と明記する。
- スキルの案内（初回の注意書き、次の作業の提案、他のスキルへの引き継ぎ）は、レポートに含めない。

## 手順

1. `list_zones` で、名前が `{BIZ大文字}-` で始まる Zone を取得する（ID と namespace を控える）。
2. Skill ツールで `headless-cloud-security:sysdig-investigate` を使い、**Findings フロー**で、手順 1 の Zone に絞った脆弱性を調べる。
   Zone は `zone_ids` で指定する。Plans フローは使わない。Critical / High を中心に、環境（dev / stg / prod）別の件数と、
   修正可能・悪用可能なものの優先度を出す。
3. Skill ツールで `headless-cloud-security:sysdig-runtime-investigate` を使い、直近7日のランタイム検知（件数、重大度、ルール名、対象 workload）を、
   手順 1 の namespace に限って調べる。深掘り（ネットワーク、VirusTotal）は、重大度が High 以上の検知があるときだけ行う。
4. ワークスペースの `github-data.json`（CI の最新実行と Code scanning の件数）を Read する。`gh` コマンドは使えない。
5. 次の形式のレポートを、ワークスペースの `report.md` に Write ツールで保存する（標準出力には出さない）。

```
# Business {BIZ大文字} 週次レポート（<取得日>）
対象 Zone / namespace / クラスタ、集計期間（7日）、データ取得日時

## 1. サマリ（3行以内）
## 2. 環境別の脆弱性（dev / stg / prod の表: イメージ、Critical/High/Medium/Low、ポリシー評価）
## 3. 優先して直すもの（修正可能・悪用可能な上位。スキルの優先度づけの結果）
## 4. ランタイム検知（件数、重大度、ルール名、対象）
## 5. CI の結果（最新の実行、ゲート判定、Code scanning）
## 6. 推奨アクション（担当が動ける形で、優先度順に3件まで）
```
