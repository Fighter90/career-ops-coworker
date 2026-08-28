<!-- Locale: Korean (ko-KR). Translations live beside this file as help/<lang>.md. Keep the ## / ### headings identical across locales; translate prose only, never the code, file names, CLI flags, or YAML keys. -->
# Job-Search Coworker — 사용자 가이드

**[OpenWorker](https://openworker.com)** 안에서 **career-ops** coworker를 설치하고 실행하는 방법을 담은 완전한 가이드입니다. 이 coworker는 OpenWorker를 구직 오퍼레이터로 바꿔 줍니다. 채용 보드를 스캔하고, 모든 공고를 당신의 CV와 비교해 점수를 매기고, 근거에 기반한 CV + 커버 레터를 맞춤 작성하고, 지원 현황을 추적하고, follow-up 초안을 작성합니다 — 그리고 당신을 위해 `career-ops-ui` 대시보드를 열 수도 있습니다.

## 1. What this is (and isn't)

- **이것은** *페르소나*입니다 — YAML frontmatter(어떤 기능을 원하는지)와 시스템 프롬프트(어떻게 동작하는지)를 갖춘 하나의 Markdown 파일([`career-ops.md`](../career-ops.md))입니다. 「coworker ⊇ skill」.
- **이것은** 프로그램이 **아닙니다**. OpenWorker는 이 저장소의 내용을 코드로 **전혀** 실행하지 않습니다. frontmatter는 검증된 기능과 권장 커넥터를 *선언*하고, 프롬프트는 에이전트를 *유도*합니다. 그래서 설치 화면에 「no third-party code runs, but the instructions steer the coworker」라고 표시되는 것입니다.
- **이것은 호스팅 서비스가 아니라 [`career-ops`](https://github.com/Fighter90/career-ops) 파이프라인을 구동합니다**. 모든 것이 당신의 머신에서, 당신의 프로젝트 폴더 안에서, 당신의 모델 키로 이루어집니다.

## 2. Requirements

1. **OpenWorker** 설치 — [openworker.com](https://openworker.com)에서 다운로드(macOS / Windows)하거나 소스에서 실행하세요. 모델 키를 추가하세요(Anthropic, OpenAI, Google, 또는 Ollama를 통한 로컬 모델).
2. 당신의 데이터로 설정된, 머신 상의 **`career-ops` 프로젝트 폴더**:
   ```bash
   git clone https://github.com/Fighter90/career-ops
   cd career-ops
   # cv.md, config/profile.yml, portals.yml을 만들려면 해당 프로젝트의 README를 따르세요
   ```
   coworker는 이 폴더 *안에서* 동작하며 `cv.md`, `config/profile.yml`, `config/two-pager.yml`, `portals.yml`, `data/applications.md`, `reports/`를 읽고 씁니다.

**설정하는 파일** (전체 스키마는 [`career-ops` README](https://github.com/Fighter90/career-ops)):

| 파일 | 무엇을 넣나 |
|---|---|
| `cv.md` | 마크다운으로 된 실제 이력서 — coworker가 근거로 삼는 유일한 출처(이 이상을 지어내지 않음). |
| `config/profile.yml` | 목표 직무, 연차, 지역, 원격 선호, 급여, `spend_tier`(모델 비용 제어). |
| `portals.yml` | 스캔할 채용 보드 — Greenhouse/Lever/Ashby 회사 슬러그, 또는 `{ name: Torre, provider: torre, search: "engineering manager", enabled: true }` 같은 보드 전체 항목. |
| `config/two-pager.yml` *(선택)* | 적합도 점수를 다듬는 선호/필수/불가 요소. |

OpenWorker에 연결하기 전에 이 폴더에서 `node scan.mjs --dry-run`을 한 번 실행해 공고를 가져오는지 확인하세요.

**(선택)** *"대시보드 열기"*가 작동하도록 [`career-ops-ui`](https://github.com/Fighter90/career-ops-ui)를 `career-ops/web-ui/`에 클론하세요(§6 참고).

## 3. Install the coworker into OpenWorker

> **처음이신가요?** 저장소 [README](https://github.com/Fighter90/career-ops-coworker#deploying--running--full-walkthrough)에 전체 배포 단계별 안내가 있습니다(사전 준비 → 모델 키 → 폴더 → 커넥터 → 첫 실행 → 대시보드 → 업데이트 → 문제 해결). 이 절은 요약본입니다.

**가장 빠른 방법 — 명령 한 줄.** coworker가 구동하는 파이프라인을 준비하고(멱등 — 기존 `career-ops` / `web-ui`를 재사용), OpenWorker 설치 단계를 출력합니다:

```bash
curl -fsSL https://raw.githubusercontent.com/Fighter90/career-ops-coworker/main/install.sh | bash
```

OpenWorker의 **Install a coworker**에서 세 가지 방법으로 추가하세요: **GitHub URL**(`https://github.com/Fighter90/career-ops-coworker`), **.zip**(Releases에서), 또는 `career-ops.md` 파일 **Import**. 셋 다 동일한 페르소나를 설치하며, 동의 전까지 비활성 상태로 놓입니다.

1. `career-ops.md`를 받으세요 — 이 저장소를 클론하거나 단일 파일을 다운로드하세요.
2. OpenWorker에서: **New coworker → Import**를 선택하고 `career-ops.md`를 고르세요(또는 OpenWorker가 이 저장소 폴더를 가리키도록 하세요).
3. 가져오면 파일이 **OpenWorker의 관리 영역으로 스냅샷됩니다**. 이후 이 저장소에서 수정해도 설치된 사본은 바뀌지 않습니다 — 업데이트하려면 다시 가져오세요. `version:` 필드가 「replaces vN」 안내를 결정합니다.
4. **Job-Search Coworker**로 세션을 열고 `career-ops` 폴더를 작업 폴더로 선택하세요.

> **신뢰:** 당신이 읽고 책임을 물을 수 있는 coworker만 설치하세요 — coworker는 당신의 시스템에 접근한 채로 실행됩니다. 이것은 코드를 포함하지 않지만, 그래도 먼저 [`career-ops.md`](../career-ops.md)를 열어 그것이 어떻게 동작하도록 지시받았는지 정확히 확인하세요.

## 4. First run

예를 들어 실제로 필요한 것을 요청하세요:
- *「내 보드를 스캔해서 이번 주에 가장 잘 맞는 상위 5개를 알려줘.」*
- *「이 공고에 맞게 내 CV를 맞춤 작성해줘: <JD 또는 URL 붙여넣기>.」*
- *「어떤 지원에 follow-up이 필요한지 알려주고 초안을 작성해줘.」*
- *「대시보드를 열어줘.」*

coworker는 모든 작업을 짧은 계획(진행 상황 패널)으로 시작해 한 번에 한 단계씩 진행하고, **실제 결과물과 그것이 어디에 있는지**로 마무리합니다 — 후보 목록, 맞춤 작성된 CV 파일, 트래커 업데이트, 또는 작성된 이메일 초안.

## 5. The workflow, stage by stage

- **Scan** — 프로젝트 스캐너를 실행합니다(`npm run scan` → `node scan.mjs`; `--dry-run`, `--company "<Name>"`, `--since 7` 같은 플래그). API 토큰 0개 — 공개 보드를 상대로 한 순수 HTTP입니다. 몇 개의 공고를 어떤 소스에서 찾았는지 보고합니다.
- **Score fit** — 각 공고를 당신의 CV + profile + two-pager와 비교해 **0–5**점으로 평가하며, 한 줄 이유와 구체적인 격차를 함께 제시합니다. 순위를 매겨 상위 몇 개를 보여줍니다.
- **Tailor** — 요청 시 역할별 CV와 커버 레터를 파일로 작성합니다(`reports/` 또는 `applications/` 아래). **오직** 당신의 CV에 이미 있는 사실에만 근거합니다. 고용주, 날짜, 지표, 스킬을 절대 지어내지 않으며, 격차를 덮어 감추는 대신 표시합니다. (`npm run cv:verify-facts`가 프로젝트의 진실성 게이트입니다.)
- **Track** — 프로젝트가 이미 사용하는 표준 상태로 `data/applications.md`의 행을 추가하거나 업데이트합니다.
- **Follow up** — 주기를 확인하고 이메일 **초안을 작성**합니다. 발송은 승인이 필요합니다.
- **Interviews** — 요청 시 당신의 캘린더에 면접 일정을 넣고 준비 알림을 추가합니다(승인 필요).

## 6. Launch the career-ops-ui dashboard from OpenWorker

*「대시보드를 열어줘」*라고 요청하면 coworker가 로컬 웹 UI를 시작합니다:
- 권장: `bash web-ui/bin/start.sh` — 필요하면 의존성을 설치하고 `http://127.0.0.1:4317`에서 서비스합니다. 포트를 바꾸려면 `PORT=`를, UI가 프로젝트 밖에 있으면 `CAREER_OPS_ROOT=`를 설정하세요. 대체 방법: `cd web-ui && npm start`.
- 이것은 같은 파일을 읽고 데이터를 어디로도 보내지 않는 **장시간 실행되는, 로컬 전용** 서버입니다(`127.0.0.1`에 바인딩). coworker는 이를 백그라운드에서 시작하고 `GET /api/health`가 응답할 때까지 기다린 뒤 당신에게 URL을 건네줍니다.
- 해당 터미널에서 Ctrl-C로, 또는 `node server/index.mjs` 프로세스를 종료해 중지하세요.

## 7. Connections (optional — you approve each)

| 연결 | 이유 | 등급 |
|---|---|---|
| **Gmail** | 리크루터 답장 읽기; follow-up / 감사 이메일 초안 작성(발송은 승인 필요) | core |
| **Google Calendar** | 면접 일정과 준비 알림 배치 | core |
| **GitHub** | 공개 프로젝트와 출판물로 CV 항목 뒷받침 | optional |
| **filesystem (MCP)** | 내장 파일 도구보다 MCP를 선호한다면 프로젝트 폴더를 명시적으로 마운트 | optional |

연결은 frontmatter의 `connectors:` 권한에 선언되며 세션의 연결 서랍에 표시됩니다. 모든 쓰기나 발송은 여전히 먼저 확인을 요청합니다.

## 8. Safety model

- **진실성이 곧 제품입니다.** 지어낸 CV 사실 하나가 채용 과정을 끝장낼 수 있습니다. 모든 주장은 당신의 `cv.md`로 거슬러 올라가며, 맞춤 작성된 모든 항목은 당신이 실제로 한 일입니다. CV가 어떤 주장을 뒷받침하는지 확실하지 않으면 coworker는 그것을 빼고 표시합니다.
- **기본은 읽기 전용입니다.** 스캔과 점수 매기기는 무료입니다. **이메일 발송, 캘린더 변경, 프로젝트 밖 쓰기, 또는 `cv.md` 덮어쓰기는 승인이 필요합니다** — coworker는 무엇을 할지 밝히고 기다립니다.
- **로컬이며 비공개입니다.** 당신의 CV, 급여 수치, 보고서는 당신의 머신에 머물며, 당신이 요청하지 않은 커넥터로는 결코 전송되지 않습니다.

## 9. Scheduling (automations)

coworker는 `scheduling: true`를 선언하므로 OpenWorker에서 반복 실행을 설정할 수 있습니다 — 예를 들어 **아침 스캔 브리핑**(「매 평일 오전 8시에 스캔해서 새로 잘 맞는 상위 공고를 알려줘」) 또는 **주간 follow-up 스윕**. 실행은 전체 기록과 함께 앱에 남으며, 무인 실행은 스스로 행동하는 대신 승인 요청을 inbox에 넣어 둡니다.

## 10. Troubleshooting

- **「공고를 찾지 못함.」** `portals.yml`에 활성화된 회사/보드가 나열되어 있는지, 그리고 네트워크가 그들에 도달하는지 확인하세요(일부 지역 보드는 풀터널 VPN 뒤에서 차단됩니다 — VPN을 끊고 다시 스캔하세요). 미리 보려면 `npm run scan -- --dry-run`을 실행해 보세요.
- **대시보드가 열리지 않음.** Node ≥ 18이 설치되어 있고 포트 4317이 비어 있는지 확인하세요(`PORT=8080 bash web-ui/bin/start.sh`). `http://127.0.0.1:4317/api/health`를 확인하세요.
- **맞춤 작성된 CV가 빈약해 보임.** 이는 진실성 게이트가 작동하는 것입니다 — 경력을 지어내지 않습니다. 실제 근거를 `cv.md`(또는 당신의 GitHub)에 추가하고 다시 맞춤 작성하세요.
- **coworker가 이메일을 보내지 않음.** 의도된 동작입니다 — 발송은 승인이 필요합니다. 확인 요청을 승인하거나, 확인 창을 줄이고 싶다면 OpenWorker에서 권한 모드를 바꾸세요(먼저 트레이드오프를 이해하세요).

## 11. Update & uninstall

- **업데이트:** 이 저장소를 pull(또는 `career-ops.md`를 다시 다운로드)하고 OpenWorker로 다시 가져오세요. `version:` 상승이 「replaces vN」 안내를 표시합니다.
- **제거:** OpenWorker의 coworker 목록에서 coworker를 삭제하세요. 당신의 `career-ops` 프로젝트 파일은 그대로입니다 — coworker는 당신이 승인한 파일만 읽고 썼습니다.

## 12. FAQ

- **내 데이터가 클라우드에 있어야 하나요?** 아니요. 모든 것이 로컬입니다. 당신이 선택한 모델과 커넥터만 무언가를 보며, 그것도 당신이 승인한 것만 봅니다.
- **어떤 모델이 가장 좋나요?** 툴 호출에 강한 모델(frontmatter는 `anthropic:claude-opus-5`과 `openai:gpt-5.5`를 권장합니다). Ollama를 통한 성능 좋은 로컬 모델도 됩니다.
- **나 대신 채용에 지원할 수 있나요?** 모든 것을 준비합니다 — 맞춤 작성된 CV, 커버 레터, 트래커 행, follow-up — 그러나 모든 외부 행동(발송)은 당신이 승인해야 합니다. 이것은 자동 조종 장치가 아니라 coworker입니다.
- **이것이 OpenWorker와 제휴 관계인가요?** 아니요. OpenWorker의 coworker 형식과 오픈소스 `career-ops` 프로젝트를 대상으로 합니다. 둘 다 MIT 라이선스입니다.
