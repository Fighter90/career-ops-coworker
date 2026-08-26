<!-- Locale: Traditional Chinese (zh-TW). Translations live beside this file as help/<lang>.md. Keep the ## / ### headings identical across locales; translate prose only, never the code, file names, CLI flags, or YAML keys. -->
# Job-Search Coworker — 使用者指南

完整介紹如何在 **[OpenWorker](https://openworker.com)** 中安裝並執行 **career-ops** coworker。這個 coworker 讓 OpenWorker 化身為求職操盤手：它掃描各大職缺看板、依據你的 CV 為每則職缺評分、產出有依據的 CV 加求職信、追蹤投遞狀況，並草擬 follow-up——而且還能為你開啟 `career-ops-ui` 儀表板。

## 1. What this is (and isn't)

- **它是**一個 *persona*（角色）——一個 Markdown 檔案（[`career-ops.md`](../career-ops.md)），內含 YAML frontmatter（宣告它想要哪些能力）以及一段系統提示（規範它如何行動）。「coworker ⊇ skill」。
- **它不是**程式。OpenWorker **不會**把這個儲存庫的任何內容當作程式碼執行。frontmatter *宣告*經過審核的能力與建議的連接器；提示則*引導*代理程式。這正是安裝畫面會顯示「no third-party code runs, but the instructions steer the coworker」的原因。
- **它驅動的是 [`career-ops`](https://github.com/Fighter90/career-ops) 管線**，而非託管服務。一切都發生在你自己的機器上、你的專案資料夾裡，使用你自己的模型金鑰。

## 2. Requirements

1. **已安裝 OpenWorker**——請至 [openworker.com](https://openworker.com) 下載（macOS / Windows）或從原始碼執行。加入一組模型金鑰（Anthropic、OpenAI、Google，或透過 Ollama 使用的本機模型）。
2. **你機器上的 `career-ops` 專案資料夾**，並以你的資料設定完成：
   ```bash
   git clone https://github.com/Fighter90/career-ops
   cd career-ops
   # 依照該專案的 README 建立 cv.md、config/profile.yml、portals.yml
   ```
   coworker 在這個資料夾*內部*運作，並讀寫 `cv.md`、`config/profile.yml`、`config/two-pager.yml`、`portals.yml`、`data/applications.md` 以及 `reports/`。

**你需要設定的檔案**(完整結構見 [`career-ops` README](https://github.com/Fighter90/career-ops)):

| 檔案 | 填什麼 |
|---|---|
| `cv.md` | Markdown 格式的真實履歷 —— coworker 依據的唯一事實來源(它不會超出此範圍臆造)。 |
| `config/profile.yml` | 目標職缺、級別、地點、遠端偏好、薪資以及 `spend_tier`(控制模型成本)。 |
| `portals.yml` | 要掃描的職缺板 —— Greenhouse/Lever/Ashby 的公司 slug,或整板項目如 `{ name: Torre, provider: torre, search: "engineering manager", enabled: true }`。 |
| `config/two-pager.yml` *(選填)* | 偏好/必須/雷區,用於細化匹配評分。 |

在接入 OpenWorker 前,先在該資料夾執行一次 `node scan.mjs --dry-run`,確認能拉取到職缺。

**(選填)** 將 [`career-ops-ui`](https://github.com/Fighter90/career-ops-ui) 複製到 `career-ops/web-ui/`,讓*「打開儀表板」*可用(見 §6)。

## 3. Install the coworker into OpenWorker

> **新手?** 儲存庫 [README](https://github.com/Fighter90/career-ops-coworker#deploying--running--full-walkthrough) 有完整的分步部署指南(前置條件 → 模型金鑰 → 資料夾 → 連接器 → 首次執行 → 儀表板 → 更新 → 排錯)。本節是精簡版。

**最快 —— 一條命令。** 它準備好 coworker 驅動的流水線（冪等 —— 重用既有的 `career-ops` / `web-ui`），然後印出 OpenWorker 的步驟:

```bash
curl -fsSL https://raw.githubusercontent.com/Fighter90/career-ops-coworker/main/install.sh | bash
```

在 OpenWorker 的 **Install a coworker** 中，用三種方式之一新增: **GitHub URL**(`https://github.com/Fighter90/career-ops-coworker`)、**.zip**(來自 Releases)或 **Import** `career-ops.md` 檔案。三者安裝的是同一個 persona —— 在你同意前處於停用狀態。

1. 取得 `career-ops.md`——複製這個儲存庫，或直接下載這一個檔案。
2. 在 OpenWorker 中：**New coworker → Import**，然後選擇 `career-ops.md`（或讓 OpenWorker 指向這個儲存庫資料夾）。
3. 匯入時，檔案會**以快照存入 OpenWorker 的受管理區域**。之後在這個儲存庫中的修改不會變更已安裝的副本——重新匯入即可更新；`version:` 欄位會驅動「replaces vN」提示。
4. 開啟一個 **Job-Search Coworker** 工作階段，並選擇你的 `career-ops` 資料夾作為工作資料夾。

> **信任：**只安裝你能讀懂並能為其負責的 coworker——coworker 是以存取你系統的權限執行的。這一個不含任何程式碼；即便如此，還是請先開啟 [`career-ops.md`](../career-ops.md)，這樣你才能確切知道它被指示要如何行動。

## 4. First run

提出一個真實的請求，例如：
- *「掃描我的看板，給我這週最合適的前 5 則職缺。」*
- *「幫我把 CV 調整以符合這則職缺：<貼上 JD 或 URL>。」*
- *「哪些投遞需要 follow-up，幫我草擬它們。」*
- *「開啟儀表板。」*

coworker 每項任務都以一份簡短計畫（Progress 面板）開始，一次處理一個階段，並以**實際的產出成果以及它所在的位置**作結——一份候選名單、一個調整過的 CV 檔案、一筆追蹤器更新，或一封草擬好的電子郵件。

## 5. The workflow, stage by stage

- **Scan**——執行專案的掃描器（`npm run scan` → `node scan.mjs`；旗標如 `--dry-run`、`--company "<Name>"`、`--since 7`）。零 API token——對公開看板進行純 HTTP 存取。回報找到多少則職缺、來自哪些來源。
- **Score fit**——依據你的 CV + profile + two-pager 為每則職缺評分 **0–5**，附上一行理由與具體的落差。排序並呈現最頂尖的幾則。
- **Tailor**——在你請求時，撰寫針對特定職位的 CV 與求職信並存成檔案（放在 `reports/` 或 `applications/` 下）。**僅**以你 CV 中既有的事實為依據；它絕不虛構雇主、日期、指標或技能，並會標示落差而非加以掩飾。（`npm run cv:verify-facts` 是這個專案的真實性把關。）
- **Track**——在 `data/applications.md` 中新增／更新該列，採用專案既有使用的標準狀態。
- **Follow up**——檢查節奏並**草擬**電子郵件；寄送需經核准。
- **Interviews**——在你請求時，把面試時段排進你的行事曆並加入準備提醒（需經核准）。

## 6. Launch the career-ops-ui dashboard from OpenWorker

提出*「開啟儀表板」*，coworker 就會啟動本機的 web UI：
- 建議做法：`bash web-ui/bin/start.sh`——必要時安裝相依套件，並在 `http://127.0.0.1:4317` 上提供服務。設定 `PORT=` 以變更連接埠，或在 UI 位於專案外部時設定 `CAREER_OPS_ROOT=`。備援做法：`cd web-ui && npm start`。
- 這是一個**長時間執行、僅限本機**的伺服器（綁定 `127.0.0.1`），它讀取同樣的檔案，且不會把資料送往任何地方。coworker 會在背景啟動它，等待 `GET /api/health` 回應後，再把 URL 交給你。
- 在它的終端機中按 Ctrl-C 即可停止，或終止 `node server/index.mjs` 程序。

## 7. Connections (optional — you approve each)

| 連線 | 用途 | 層級 |
|---|---|---|
| **Gmail** | 讀取招募人員的回覆；草擬 follow-up／感謝電子郵件（寄送需經核准） | core |
| **Google Calendar** | 安排面試時段與準備提醒 | core |
| **GitHub** | 以你的公開專案與著作佐證 CV 條目 | optional |
| **filesystem (MCP)** | 若你偏好使用 MCP 而非內建的檔案工具，可明確掛載專案資料夾 | optional |

連線在 frontmatter 的 `connectors:` 授權中宣告，並顯示於工作階段的連線抽屜中。任何寫入或寄送動作仍會先徵詢你。

## 8. Safety model

- **真實性就是產品本身。**一項捏造的 CV 事實可能終結一次招聘流程。每一項陳述都能追溯到你的 `cv.md`；每一個調整過的條目都是你真正做過的事。當無法確定 CV 是否支持某項陳述時，coworker 會將它略去並加以標示。
- **預設為唯讀。**掃描與評分是免費的。**寄送電子郵件、變更你的行事曆、寫入專案以外的位置，或覆寫 `cv.md`，都需經核准**——coworker 會說明它將要做什麼，然後等待。
- **本機且私密。**你的 CV、薪資數字與報告都留在你的機器上，絕不會被送往你未曾要求的連接器。

## 9. Scheduling (automations)

coworker 宣告了 `scheduling: true`，因此你可以在 OpenWorker 中設定週期性執行——例如**晨間掃描簡報**（「每個工作日早上 8 點掃描，並給我最合適的新職缺」）或**每週 follow-up 巡檢**。執行結果會連同完整的逐字記錄進入應用程式；無人看管的執行會把核准請求停放在 inbox 中，而不會自行採取行動。

## 10. Troubleshooting

- **「找不到職缺。」**確認 `portals.yml` 中列出了已啟用的公司／看板，且你的網路能連到它們（某些區域性看板會被全通道 VPN 擋住——請中斷它再重新掃描）。可試試 `npm run scan -- --dry-run` 進行預覽。
- **儀表板打不開。**確認已安裝 Node ≥ 18 且連接埠 4317 未被佔用（`PORT=8080 bash web-ui/bin/start.sh`）。檢查 `http://127.0.0.1:4317/api/health`。
- **調整過的 CV 看起來很單薄。**那是真實性把關在發揮作用——它不會虛構經歷。請把真實的佐證加進 `cv.md`（或你的 GitHub）再重新調整。
- **coworker 不肯寄送電子郵件。**這是刻意設計——寄送需經核准。核准該次確認，或者若你想要更少的提示，可在 OpenWorker 中切換權限模式（請先了解其取捨）。

## 11. Update & uninstall

- **更新：**拉取這個儲存庫（或重新下載 `career-ops.md`）並重新匯入 OpenWorker；`version:` 的提升會顯示「replaces vN」提示。
- **解除安裝：**在 OpenWorker 的 coworker 清單中移除該 coworker。你的 `career-ops` 專案檔案不會被更動——coworker 從頭到尾只讀寫你所核准的檔案。

## 12. FAQ

- **它需要把我的資料放到雲端嗎？**不需要。一切都在本機；只有你所選擇的模型與連接器會看到任何內容，而且僅限你所核准的部分。
- **哪些模型效果最好？**具備強大 tool-calling 能力的模型（frontmatter 建議 `anthropic:claude-opus-4-8` 與 `openai:gpt-5.5`）；透過 Ollama 使用的高效能本機模型同樣可行。
- **它可以替我應徵工作嗎？**它會準備好一切——調整過的 CV、求職信、追蹤器列、follow-up——但任何對外的動作（寄送）都由你來核准。它是 coworker，不是自動駕駛。
- **這和 OpenWorker 有關聯嗎？**沒有。它針對的是 OpenWorker 的 coworker 格式與開源的 `career-ops` 專案；兩者皆採 MIT 授權。
