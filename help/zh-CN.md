<!-- Locale: Simplified Chinese (zh-CN). Translations live beside this file as help/<lang>.md. Keep the ## / ### headings identical across locales; translate prose only, never the code, file names, CLI flags, or YAML keys. -->
# Job-Search Coworker — 用户指南

关于在 **[OpenWorker](https://openworker.com)** 中安装并运行 **career-ops** coworker 的完整指南。这个 coworker 把 OpenWorker 变成一名求职操作员：它扫描招聘网站，根据你的 CV 为每条职位打分，量身定制一份有据可依的 CV + 求职信，跟踪投递，并起草跟进邮件——而且它还能为你打开 `career-ops-ui` 仪表盘。

## 1. What this is (and isn't)

- **它是** 一个 *persona*——一个 Markdown 文件（[`career-ops.md`](../career-ops.md)），带有 YAML frontmatter（声明它请求哪些能力）以及一段系统提示（定义它如何行事）。「coworker ⊇ skill」。
- **它不是** 一个程序。OpenWorker **不会** 把这个仓库的任何内容作为代码运行。frontmatter *声明* 经过审核的能力和推荐的连接器；提示 *引导* 代理。这就是为什么安装界面上写着「no third-party code runs, but the instructions steer the coworker」。
- **它驱动 [`career-ops`](https://github.com/santifer/career-ops) 流水线**，而不是某个托管服务。一切都发生在你的机器上、你的项目文件夹里，用你自己的模型密钥。

## 2. Requirements

1. **已安装 OpenWorker**——从 [openworker.com](https://openworker.com)（macOS / Windows）下载，或从源码运行。添加一个模型密钥（Anthropic、OpenAI、Google，或通过 Ollama 使用本地模型）。
2. **一个 `career-ops` 项目文件夹**，位于你的机器上，并配置好你的数据：
   ```bash
   git clone https://github.com/santifer/career-ops
   cd career-ops
   # 按照该项目的 README 创建 cv.md、config/profile.yml、portals.yml
   ```
   coworker 在这个文件夹 *内部* 运作，读取/写入 `cv.md`、`config/profile.yml`、`config/two-pager.yml`、`portals.yml`、`data/applications.md` 和 `reports/`。

## 3. Install the coworker into OpenWorker

1. 获取 `career-ops.md`——克隆此仓库或下载这一个文件。
2. 在 OpenWorker 中：**New coworker → Import**，然后选择 `career-ops.md`（或将 OpenWorker 指向此仓库文件夹）。
3. 导入时，该文件会 **被快照保存到 OpenWorker 的托管区域**。之后在此仓库中的修改不会改变已安装的副本——重新导入即可更新；`version:` 字段驱动「replaces vN」提示。
4. 打开一个 **Job-Search Coworker** 会话，并选择你的 `career-ops` 文件夹作为工作文件夹。

> **信任：** 只安装那些你能够读懂并为之负责的 coworker——coworker 运行时拥有对你系统的访问权限。这一个不含任何代码；不过，还是请先打开 [`career-ops.md`](../career-ops.md)，这样你才能确切知道它被指示如何行事。

## 4. First run

提出一些真实的请求，例如：
- *「扫描我的招聘网站，给我本周最匹配的 5 个职位。」*
- *「为这条职位定制我的 CV：<粘贴 JD 或 URL>。」*
- *「哪些投递需要跟进，把它们起草出来。」*
- *「打开仪表盘。」*

coworker 在每个任务开始时都会先给出一个简短的计划（进度面板），一次只推进一个阶段，并以 **实际的交付物及其存放位置** 作为结尾——一份候选清单、一个定制好的 CV 文件、一次跟踪表更新，或一封起草好的邮件。

## 5. The workflow, stage by stage

- **Scan**——运行项目的扫描器（`npm run scan` → `node scan.mjs`；诸如 `--dry-run`、`--company "<Name>"`、`--since 7` 之类的标志）。零 API 令牌——纯 HTTP 请求访问公开招聘网站。报告找到了多少职位、来自哪些来源。
- **Score fit**——针对你的 CV + profile + two-pager 为每条职位打 **0–5** 分，附上一行理由和具体的差距。排序并呈现最靠前的少数几个。
- **Tailor**——按需将针对特定角色的 CV 和求职信写成文件（放在 `reports/` 或 `applications/` 下）。**仅** 以你 CV 中已有的事实为依据；它绝不编造雇主、日期、指标或技能，并且会标注差距而非加以掩盖。（`npm run cv:verify-facts` 是本项目的真实性关卡。）
- **Track**——在 `data/applications.md` 中追加/更新对应行，使用项目已在使用的规范状态。
- **Follow up**——检查节奏并 **起草** 邮件；发送需经过审批。
- **Interviews**——按需在你的日历上安排面试时段，并添加准备提醒（需经过审批）。

## 6. Launch the career-ops-ui dashboard from OpenWorker

提出 *「打开仪表盘」*，coworker 就会启动本地 web UI：
- 首选：`bash web-ui/bin/start.sh`——必要时安装依赖，并在 `http://127.0.0.1:4317` 上提供服务。设置 `PORT=` 可更改端口，若 UI 位于项目之外则设置 `CAREER_OPS_ROOT=`。备选方案：`cd web-ui && npm start`。
- 这是一个 **长期运行、仅限本地** 的服务器（绑定 `127.0.0.1`），它读取相同的文件，且不向任何地方发送数据。coworker 在后台启动它，等待 `GET /api/health` 作出响应，然后把 URL 交给你。
- 在它的终端中按 Ctrl-C 停止它，或结束 `node server/index.mjs` 进程。

## 7. Connections (optional — you approve each)

| 连接 | 用途 | 级别 |
|---|---|---|
| **Gmail** | 读取招聘方的回复；起草跟进 / 感谢邮件（发送需经过审批） | core |
| **Google Calendar** | 安排面试时段和准备提醒 | core |
| **GitHub** | 用你的公开项目和发表成果为 CV 条目提供佐证 | optional |
| **filesystem (MCP)** | 如果你相比内置文件工具更偏好 MCP，可显式挂载项目文件夹 | optional |

连接在 frontmatter 的 `connectors:` 授权中声明，并显示在会话的连接抽屉中。任何写入或发送仍然都会先征求同意。

## 8. Safety model

- **真实性就是产品本身。** 一条捏造的 CV 事实可能会终结整个招聘流程。每一个陈述都可追溯到你的 `cv.md`；每一个定制条目都是你真正做过的事。当无法确定 CV 是否支持某个陈述时，coworker 会略去它并加以标注。
- **默认只读。** 扫描和打分是免费的。**发送邮件、更改你的日历、在项目之外写入，或覆盖 `cv.md` 都需经过审批**——coworker 会说明它将要做什么，然后等待。
- **本地且私密。** 你的 CV、薪资数字和报告都留在你的机器上，绝不会被发送到你未曾请求的连接器。

## 9. Scheduling (automations)

coworker 声明了 `scheduling: true`，因此你可以在 OpenWorker 中设置周期性运行——例如 **早间扫描简报**（「每个工作日早上 8 点，扫描并给我最匹配的新职位」）或 **每周跟进汇总**。运行会带着完整的对话记录进入应用；无人值守的运行会把审批请求停放在 inbox 中，而不是自行采取行动。

## 10. Troubleshooting

- **「未找到职位」。** 确认 `portals.yml` 中列出了已启用的公司/招聘网站，并且你的网络能够访问它们（某些地区性招聘网站会被全隧道 VPN 屏蔽——断开它再重新扫描）。可尝试 `npm run scan -- --dry-run` 进行预览。
- **仪表盘打不开。** 确保已安装 Node ≥ 18 且端口 4317 空闲（`PORT=8080 bash web-ui/bin/start.sh`）。检查 `http://127.0.0.1:4317/api/health`。
- **定制出的 CV 看起来内容单薄。** 那是真实性关卡在起作用——它不会编造经历。把真实的证据补充进 `cv.md`（或你的 GitHub），然后重新定制。
- **coworker 不肯发送邮件。** 这是刻意为之——发送需经过审批。批准这次 check-in，或者若你希望减少提示，可在 OpenWorker 中切换权限模式（请先理解其中的权衡）。

## 11. Update & uninstall

- **更新：** 拉取此仓库（或重新下载 `career-ops.md`）并重新导入到 OpenWorker；`version:` 的提升会显示一条「replaces vN」提示。
- **卸载：** 在 OpenWorker 的 coworker 列表中移除该 coworker。你的 `career-ops` 项目文件不会被触碰——coworker 从始至终只读取和写入了你批准的文件。

## 12. FAQ

- **它需要把我的数据放到云端吗？** 不需要。一切都在本地；只有你选择的模型和连接器才会看到任何内容，而且仅限你批准的部分。
- **哪些模型效果最好？** 具备强大工具调用能力的模型（frontmatter 推荐 `anthropic:claude-opus-4-8` 和 `openai:gpt-5.5`）；通过 Ollama 使用的一款有能力的本地模型也可以。
- **它能替我投递职位吗？** 它会准备好一切——定制的 CV、求职信、跟踪表条目、跟进邮件——但任何对外的动作（一次发送）都要由你来批准。它是一名 coworker，而不是自动驾驶。
- **这与 OpenWorker 有关联吗？** 没有。它面向 OpenWorker 的 coworker 格式和开源的 `career-ops` 项目；两者都采用 MIT 许可证。
