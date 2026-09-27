<!-- Locale: Japanese (ja). Translations live beside this file as help/<lang>.md. Keep the ## / ### headings identical across locales; translate prose only, never the code, file names, CLI flags, or YAML keys. -->
# Job-Search Coworker — ユーザーガイド

**career-ops** coworker を **[OpenWorker](https://openworker.com)** の中でインストールして実行するための完全ガイドです。この coworker は OpenWorker を求職オペレーターに変えます。求人ボードをスキャンし、各求人をあなたの CV に照らして採点し、根拠に基づいた CV ＋ カバーレターを仕立て、応募を管理し、フォローアップを下書きします — そして `career-ops-ui` ダッシュボードをあなたのために開くこともできます。

## 1. What this is (and isn't)

- **これは** *ペルソナ* です — YAML frontmatter（どの機能を必要とするか）とシステムプロンプト（どのように振る舞うか）を備えた単一の Markdown ファイル（[`career-ops.md`](../career-ops.md)）です。「coworker ⊇ skill」。
- **これはプログラムではありません**。OpenWorker はこのリポジトリの内容を **一切** コードとして実行しません。frontmatter は検証済みの機能と推奨コネクターを *宣言* し、プロンプトはエージェントを *方向づけ* ます。だからこそインストール画面には「no third-party code runs, but the instructions steer the coworker」と表示されます。
- **これは [`career-ops`](https://github.com/Fighter90/career-ops) パイプラインを動かします**。ホスティングされたサービスではありません。すべてはあなたのマシン上で、あなたのプロジェクトフォルダーの中で、あなたのモデルキーで行われます。

## 2. Requirements

1. **OpenWorker** をインストール済みであること — [openworker.com](https://openworker.com)（macOS / Windows）からダウンロードするか、ソースから実行します。モデルキー（Anthropic、OpenAI、Google、または Ollama 経由のローカルモデル）を追加してください。
2. あなたのデータで設定した、マシン上の **`career-ops` プロジェクトフォルダー**：
   ```bash
   git clone https://github.com/Fighter90/career-ops
   cd career-ops
   # そのプロジェクトの README に従って cv.md、config/profile.yml、portals.yml を作成してください
   ```
   coworker はこのフォルダーの *内部* で動作し、`cv.md`、`config/profile.yml`、`config/two-pager.yml`、`portals.yml`、`data/applications.md`、`reports/` を読み書きします。

**設定するファイル**（完全なスキーマは [`career-ops` README](https://github.com/Fighter90/career-ops)）:

| ファイル | 入れる内容 |
|---|---|
| `cv.md` | Markdown 形式のあなたの実際の CV — coworker が根拠とする唯一の情報源（これを超えて作り話をしません）。 |
| `config/profile.yml` | 対象ロール、シニアリティ、勤務地、リモート希望、給与、`spend_tier`（モデルコストを制御）。 |
| `portals.yml` | スキャンする求人ボード — Greenhouse/Lever/Ashby の会社スラッグ、または `{ name: Torre, provider: torre, search: "engineering manager", enabled: true }` のようなボード全体エントリー。 |
| `config/two-pager.yml` *(任意)* | 適合度スコアを研ぎ澄ます 好み/必須/NG 要素。 |

OpenWorker に接続する前に、このフォルダーで `node scan.mjs --dry-run` を一度実行し、求人を取得できるか確認してください。

**(任意)** *「ダッシュボードを開いて」*が動くよう、[`career-ops-ui`](https://github.com/Fighter90/career-ops-ui) を `career-ops/web-ui/` にクローンしてください（§6 参照）。

## 3. Install the coworker into OpenWorker

> **はじめての方へ:** リポジトリの [README](https://github.com/Fighter90/career-ops-coworker#deploying--running--full-walkthrough) に、デプロイの完全なステップバイステップ（前提 → モデルキー → フォルダー → コネクター → 初回実行 → ダッシュボード → 更新 → トラブルシューティング）があります。この節は短縮版です。

**最速 — コマンド1つ。** coworker が動かすパイプラインを用意し（冪等 — 既存の `career-ops` / `web-ui` を再利用）、OpenWorker の手順を表示します:

```bash
curl -fsSL https://raw.githubusercontent.com/Fighter90/career-ops-coworker/main/install.sh | bash
```

OpenWorker の **Install a coworker** で、3つの方法のいずれかで追加します: **GitHub URL**(`https://github.com/Fighter90/career-ops-coworker`)、**.zip**(Releases から)、または `career-ops.md` ファイルの **Import**。いずれも同じペルソナをインストールし、同意まで無効の状態で置かれます。

1. `career-ops.md` を入手します — このリポジトリをクローンするか、単一ファイルをダウンロードします。
2. OpenWorker で **New coworker → Import** を開き、`career-ops.md` を選びます（または OpenWorker にこのリポジトリのフォルダーを指定します）。
3. インポート時に、ファイルは **OpenWorker の管理領域にスナップショットとして取り込まれます**。このリポジトリでの後からの編集はインストール済みのコピーを変更しません — 更新するには再インポートします。`version:` フィールドが「replaces vN」の注記を制御します。
4. **Job-Search Coworker** でセッションを開き、作業フォルダーとして `career-ops` フォルダーを選びます。

> **信頼：** 読んで責任を問える coworker だけをインストールしてください — coworker はあなたのシステムへのアクセス権を持って動作します。これはコードを含みませんが、それでもまず [`career-ops.md`](../career-ops.md) を開き、どのように振る舞うよう指示されているかを正確に把握してください。

## 4. First run

実際のことを頼んでみてください。例えば：
- *「私の求人ボードをスキャンして、今週の上位5件のマッチを教えて」*
- *「この求人に合わせて私の CV を仕立てて：<JD または URL を貼り付け>」*
- *「どの応募にフォローアップが必要か、そしてその下書きを作って」*
- *「ダッシュボードを開いて」*

coworker はすべてのタスクを短い計画（進捗パネル）から始め、一度に1つの段階を進め、**実際の成果物とその保存場所** で締めくくります — ショートリスト、仕立てた CV ファイル、トラッカーの更新、または下書きされたメールなどです。

## 5. The workflow, stage by stage

- **Scan** — プロジェクトのスキャナー（`npm run scan` → `node scan.mjs`；`--dry-run`、`--company "<Name>"`、`--since 7` などのフラグ）を実行します。API トークンはゼロ — 公開ボードに対する純粋な HTTP です。いくつの求人が、どのソースから見つかったかを報告します。
- **Score fit** — 各求人を、あなたの CV ＋ profile ＋ two-pager に照らして **0〜5** で評価し、一行の理由と具体的なギャップを添えます。ランク付けして上位のいくつかを提示します。
- **Tailor** — 要求に応じて、役割に特化した CV とカバーレターをファイルとして（`reports/` または `applications/` の下に）書き出します。あなたの CV に既にある事実 **のみ** に基づき、雇用主・日付・指標・スキルを決して捏造せず、ごまかす代わりにギャップを明示します。（`npm run cv:verify-facts` がプロジェクトの真実性ゲートで、`npm run cv:verify-ats` が対となる可読性ゲートです —— facts は主張が事実かを、ATS は履歴書パーサーが読み取れるかを確認します。）
- **Track** — プロジェクトが既に使用している正規のステータスで、`data/applications.md` の行を追加／更新します。 ステータスの変更はプロジェクトの正規の書き込み経路 `node set-status.mjs <report#|company> <State>` を通します（実際の日付は `--on YYYY-MM-DD` を付ける）。ステータスを検証し、トラッカーをロックし、遷移を記録するため、コワーカーがステータス欄を手で編集することはありません。
- **Follow up** — 頻度を確認し、メールを **下書き** します。送信は承認が必要です。対応要否はプロジェクト自身の `node followup-cadence.mjs` が urgent / overdue / waiting / cold に分類した結果から判断します。別の問いに答えるトラッカーのステータスからは判断しません。
- **Interviews** — 要求に応じて、面接の枠をカレンダーに入れ、準備のリマインダーを追加します（承認が必要）。

## 6. Launch the career-ops-ui dashboard from OpenWorker

*「ダッシュボードを開いて」* と頼むと、coworker はローカルの web UI を起動します：
- 推奨：`bash web-ui/bin/start.sh` — 必要に応じて依存関係をインストールし、`http://127.0.0.1:4317` で配信します。ポートを変えるには `PORT=` を、UI がプロジェクトの外にある場合は `CAREER_OPS_ROOT=` を設定します。代替手段：`cd web-ui && npm start`。
- これは **常駐する、ローカル専用の** サーバー（`127.0.0.1` にバインド）で、同じファイルを読み、データをどこにも送信しません。coworker はそれをバックグラウンドで起動し、`GET /api/health` が応答するのを待ってから、URL をあなたに渡します。
- そのターミナルで Ctrl-C を押すか、`node server/index.mjs` プロセスを終了させて停止します。

## 7. Connections (optional — you approve each)

| 接続 | 理由 | ティア |
|---|---|---|
| **Gmail** | 採用担当者の返信を読み、フォローアップ／お礼のメールを下書きする（送信は承認が必要） | core |
| **Google Calendar** | 面接の枠と準備のリマインダーを入れる | core |
| **GitHub** | CV の項目をあなたの公開プロジェクトや出版物で裏づける | optional |
| **filesystem (MCP)** | 組み込みのファイルツールより MCP を好む場合に、プロジェクトフォルダーを明示的にマウントする | optional |

接続は frontmatter の `connectors:` グラントで宣言され、セッションの接続ドロワーに表示されます。あらゆる書き込みや送信は、やはり最初に確認を求めます。

## 8. Safety model

- **真実性こそが製品です。** 捏造された CV の事実は、採用プロセスを台無しにしかねません。あらゆる主張はあなたの `cv.md` にさかのぼり、仕立てられたすべての項目はあなたが実際に行ったことです。CV がある主張を裏づけるか不確かなとき、coworker はそれを省き、その旨を明示します。
- **デフォルトでは読み取り専用。** スキャンと採点は無償です。**メールの送信、カレンダーの変更、プロジェクト外への書き込み、`cv.md` の上書きは承認が必要です** — coworker は何を行うかを述べて待機します。
- **ローカルかつプライベート。** あなたの CV、給与額、レポートはあなたのマシン上にとどまり、あなたが求めていないコネクターに送信されることは決してありません。

## 9. Scheduling (automations)

coworker は `scheduling: true` を宣言するため、OpenWorker で定期的な実行を設定できます — 例えば **朝のスキャンブリーフ**（「平日の毎朝8時にスキャンして、新着の上位マッチを教えて」）や **週次のフォローアップ一巡** などです。実行結果は完全なトランスクリプトとともにアプリに届きます。無人の実行は、勝手に動作するのではなく、承認リクエストを inbox に留め置きます。

## 10. Troubleshooting

- **「求人が見つかりません」。** `portals.yml` に有効な企業／ボードが列挙されていること、そしてあなたのネットワークがそれらに到達できることを確認してください（一部の地域ボードはフルトンネル VPN の背後でブロックされます — 切断して再スキャンしてください）。プレビューには `npm run scan -- --dry-run` を試してください。
- **`config/profile.yml` の設定が無視されているようだ**（出力言語が違う、spend tier が既定のまま）。たいていはキーの綴り間違いです — `node validate-profile.mjs` がそのキーを示し、`npm run doctor` がセットアップ全体のチェックリストを表示します。
- **ダッシュボードが開きません。** Node ≥ 18 がインストールされ、ポート 4317 が空いていることを確認してください（`PORT=8080 bash web-ui/bin/start.sh`）。`http://127.0.0.1:4317/api/health` を確認してください。
- **仕立てた CV が薄く見えます。** それは真実性ゲートが働いている証拠です — 経験を捏造しません。実際の証拠を `cv.md`（またはあなたの GitHub）に追加して、もう一度仕立ててください。
- **coworker がメールを送信しません。** 仕様です — 送信は承認が必要です。確認を承認するか、プロンプトを減らしたい場合は OpenWorker で権限モードを切り替えてください（まずトレードオフを理解してください）。

## 11. Update & uninstall

- **更新：** このリポジトリを pull し（または `career-ops.md` を再ダウンロードし）、OpenWorker に再インポートします。`version:` の引き上げにより「replaces vN」の注記が表示されます。
- **アンインストール：** OpenWorker の coworker 一覧から coworker を削除します。あなたの `career-ops` プロジェクトのファイルはそのまま残ります — coworker はあなたが承認したファイルを読み書きしただけです。

## 12. FAQ

- **私のデータをクラウドに置く必要はありますか？** いいえ。すべてはローカルです。何かを目にするのはあなたが選んだモデルとコネクターだけで、しかもあなたが承認したものだけです。
- **どのモデルが最も適していますか？** tool-calling に強いモデル（frontmatter は `anthropic:claude-opus-5` と `openai:gpt-5.5` を推奨します）。Ollama 経由の高性能なローカルモデルも使えます。
- **私の代わりに求人へ応募できますか？** すべてを準備します — 仕立てた CV、カバーレター、トラッカーの行、フォローアップ — が、外向きの動作（送信）はあなたが承認するものです。これは coworker であり、オートパイロットではありません。
- **これは OpenWorker と提携していますか？** いいえ。OpenWorker の coworker 形式とオープンソースの `career-ops` プロジェクトを対象にしています。どちらも MIT ライセンスです。
