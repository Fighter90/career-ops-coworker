<!-- Locale: Brazilian Portuguese (pt-BR). Translations live beside this file as help/<lang>.md. Keep the ## / ### headings identical across locales; translate prose only, never the code, file names, CLI flags, or YAML keys. -->
# Job-Search Coworker — Guia do usuário

Um guia completo para instalar e executar o coworker **career-ops** dentro do **[OpenWorker](https://openworker.com)**. O coworker transforma o OpenWorker em um operador de busca de emprego: ele varre os quadros de vagas, avalia cada vaga em relação ao seu CV, adapta um CV fundamentado + carta de apresentação, acompanha as candidaturas e prepara follow-ups — e pode abrir o painel `career-ops-ui` para você.

## 1. What this is (and isn't)

- **É** uma *persona* — um único arquivo Markdown ([`career-ops.md`](../career-ops.md)) com YAML frontmatter (quais capacidades ele deseja) mais um system prompt (como ele se comporta). "Um coworker ⊇ uma skill."
- **Não é** um programa. O OpenWorker **não** executa nada deste repositório como código. O frontmatter *declara* capacidades verificadas e conectores recomendados; o prompt *orienta* o agente. É por isso que a tela de instalação diz: "no third-party code runs, but the instructions steer the coworker".
- **Ele comanda o pipeline [`career-ops`](https://github.com/santifer/career-ops)**, não um serviço hospedado. Tudo acontece na sua máquina, na sua pasta de projeto, com a sua chave de modelo.

## 2. Requirements

1. **OpenWorker** instalado — baixe em [openworker.com](https://openworker.com) (macOS / Windows) ou execute a partir do código-fonte. Adicione uma chave de modelo (Anthropic, OpenAI, Google ou um modelo local via Ollama).
2. **Uma pasta de projeto `career-ops`** na sua máquina, configurada com os seus dados:
   ```bash
   git clone https://github.com/santifer/career-ops
   cd career-ops
   # siga o README daquele projeto para criar cv.md, config/profile.yml, portals.yml
   ```
   O coworker opera *dentro* desta pasta e lê/grava `cv.md`, `config/profile.yml`, `config/two-pager.yml`, `portals.yml`, `data/applications.md` e `reports/`.

## 3. Install the coworker into OpenWorker

1. Obtenha `career-ops.md` — clone este repositório ou baixe o arquivo único.
2. No OpenWorker: **New coworker → Import** e selecione `career-ops.md` (ou aponte o OpenWorker para a pasta deste repositório).
3. Na importação, o arquivo é **capturado como snapshot na área gerenciada do OpenWorker**. Edições posteriores neste repositório não alteram uma cópia instalada — reimporte para atualizar; o campo `version:` controla a nota "replaces vN".
4. Abra uma sessão com o **Job-Search Coworker** e escolha a sua pasta `career-ops` como pasta de trabalho.

> **Confiança:** instale apenas coworkers que você consiga ler e pelos quais possa responsabilizar-se — um coworker roda com acesso ao seu sistema. Este não traz nenhum código; ainda assim, abra [`career-ops.md`](../career-ops.md) primeiro para saber exatamente como ele é instruído a se comportar.

## 4. First run

Peça algo real, por exemplo:
- *"Varra meus quadros de vagas e me dê as 5 melhores correspondências desta semana."*
- *"Adapte meu CV para esta vaga: <cole a JD ou a URL>."*
- *"Quais candidaturas precisam de follow-up, e prepare-os."*
- *"Abra o painel."*

O coworker começa cada tarefa com um plano curto (o painel de progresso), trabalha um estágio de cada vez e termina com o **entregável real e onde ele está** — uma shortlist, um arquivo de CV adaptado, uma atualização do tracker ou um rascunho de e-mail.

## 5. The workflow, stage by stage

- **Scan** — executa o scanner do projeto (`npm run scan` → `node scan.mjs`; flags como `--dry-run`, `--company "<Name>"`, `--since 7`). Zero tokens de API — HTTP puro contra quadros públicos. Informa quantas vagas e de quais fontes.
- **Score fit** — avalia cada vaga de **0–5** em relação ao seu CV + profile + two-pager, com uma justificativa de uma linha e as lacunas concretas. Classifica e destaca as melhores.
- **Tailor** — sob solicitação, escreve um CV específico para a vaga e uma carta de apresentação como arquivos (em `reports/` ou `applications/`). Fundamentado **apenas** em fatos que já estão no seu CV; ele nunca inventa um empregador, data, métrica ou habilidade, e sinaliza uma lacuna em vez de encobri-la. (`npm run cv:verify-facts` é o gate de veracidade do projeto.)
- **Track** — acrescenta/atualiza a linha em `data/applications.md` com o status canônico que o projeto já usa.
- **Follow up** — verifica a cadência e **prepara** o e-mail; o envio passa por aprovação.
- **Interviews** — sob solicitação, coloca horários de entrevista no seu calendário e adiciona lembretes de preparação (mediante aprovação).

## 6. Launch the career-ops-ui dashboard from OpenWorker

Peça *"abra o painel"* e o coworker inicia a interface web local:
- Preferencial: `bash web-ui/bin/start.sh` — instala as dependências se necessário e serve em `http://127.0.0.1:4317`. Defina `PORT=` para mudar a porta, ou `CAREER_OPS_ROOT=` se a UI ficar fora do projeto. Alternativa: `cd web-ui && npm start`.
- É um servidor **de longa duração e apenas local** (escuta em `127.0.0.1`) que lê os mesmos arquivos e não envia dados a lugar nenhum. O coworker o inicia em segundo plano, aguarda a resposta de `GET /api/health` e então entrega a você a URL.
- Pare-o com Ctrl-C no terminal dele, ou encerrando o processo `node server/index.mjs`.

## 7. Connections (optional — you approve each)

| Conexão | Por quê | Nível |
|---|---|---|
| **Gmail** | ler respostas de recrutadores; preparar e-mails de follow-up / agradecimento (o envio passa por aprovação) | core |
| **Google Calendar** | colocar horários de entrevista e lembretes de preparação | core |
| **GitHub** | fundamentar os itens do CV com seus projetos e publicações públicos | optional |
| **filesystem (MCP)** | montar a pasta do projeto explicitamente, se você preferir MCP às ferramentas de arquivo integradas | optional |

As conexões são declaradas no grant `connectors:` do frontmatter e exibidas no painel de conexões da sessão. Toda gravação ou envio ainda pergunta antes.

## 8. Safety model

- **A veracidade é o produto.** Um fato inventado no CV pode encerrar um processo seletivo. Toda afirmação remonta ao seu `cv.md`; todo item adaptado é algo que você realmente fez. Quando há dúvida se o CV sustenta uma afirmação, o coworker a omite e a sinaliza.
- **Somente leitura por padrão.** Varredura e avaliação são gratuitas. **Enviar e-mail, alterar seu calendário, gravar fora do projeto ou sobrescrever `cv.md` passam por aprovação** — o coworker informa o que fará e aguarda.
- **Local e privado.** Seu CV, números de salário e relatórios permanecem na sua máquina e nunca são enviados a um conector que você não solicitou.

## 9. Scheduling (automations)

O coworker declara `scheduling: true`, então você pode configurar execuções recorrentes no OpenWorker — por exemplo, um **resumo matinal de varredura** ("todo dia útil às 8h, varra e me dê as melhores novas correspondências") ou uma **varredura semanal de follow-up**. As execuções chegam ao app com transcrições completas; execuções sem supervisão estacionam suas solicitações de aprovação na inbox em vez de agir por conta própria.

## 10. Troubleshooting

- **"Nenhuma vaga encontrada."** Confirme que `portals.yml` lista as empresas/quadros ativados e que sua rede os alcança (alguns quadros regionais ficam bloqueados atrás de uma VPN de túnel completo — desconecte-a e varra novamente). Experimente `npm run scan -- --dry-run` para pré-visualizar.
- **O painel não abre.** Verifique se o Node ≥ 18 está instalado e se a porta 4317 está livre (`PORT=8080 bash web-ui/bin/start.sh`). Verifique `http://127.0.0.1:4317/api/health`.
- **Um CV adaptado parece enxuto demais.** É o gate de veracidade funcionando — ele não inventa experiência. Adicione as evidências reais ao `cv.md` (ou ao seu GitHub) e adapte novamente.
- **O coworker não envia um e-mail.** É proposital — os envios passam por aprovação. Aprove o check-in ou mude o modo de permissão no OpenWorker se quiser menos avisos (entenda o trade-off primeiro).

## 11. Update & uninstall

- **Atualização:** atualize este repositório (ou baixe novamente `career-ops.md`) e reimporte no OpenWorker; o aumento de `version:` mostra uma nota "replaces vN".
- **Desinstalação:** remova o coworker na lista de coworkers do OpenWorker. Os arquivos do seu projeto `career-ops` permanecem intactos — o coworker só leu e gravou os arquivos que você aprovou.

## 12. FAQ

- **Ele precisa dos meus dados na nuvem?** Não. Tudo é local; apenas o modelo e os conectores que você escolher veem algo, e somente o que você aprova.
- **Quais modelos funcionam melhor?** Modelos fortes em tool-calling (o frontmatter recomenda `anthropic:claude-opus-4-8` e `openai:gpt-5.5`); um modelo local competente via Ollama também funciona.
- **Ele pode se candidatar a vagas por mim?** Ele prepara tudo — o CV adaptado, a carta de apresentação, a linha do tracker, o follow-up — mas qualquer ação externa (um envio) cabe a você aprovar. É um coworker, não um piloto automático.
- **Isto tem afiliação com o OpenWorker?** Não. Ele mira o formato de coworker do OpenWorker e o projeto open-source `career-ops`; ambos têm licença MIT.
