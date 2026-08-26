<!-- Locale: Spanish (es). Translations live beside this file as help/<lang>.md. Keep the ## / ### headings identical across locales; translate prose only, never the code, file names, CLI flags, or YAML keys. -->
# Job-Search Coworker — Guía del usuario

Una guía completa para instalar y ejecutar el coworker **career-ops** dentro de **[OpenWorker](https://openworker.com)**. El coworker convierte OpenWorker en un operador de búsqueda de empleo: escanea portales, puntúa cada vacante frente a tu CV, adapta un CV + carta de presentación fundamentados, hace seguimiento de las candidaturas y redacta los follow-ups — y puede abrir el panel de `career-ops-ui` por ti.

## 1. What this is (and isn't)

- **Es** una *persona*: un único archivo Markdown ([`career-ops.md`](../career-ops.md)) con frontmatter YAML (qué capacidades solicita) más un system prompt (cómo se comporta). «Un coworker ⊇ una skill».
- **No es** un programa. OpenWorker **no** ejecuta nada de este repositorio como código. El frontmatter *declara* capacidades verificadas y conectores recomendados; el prompt *guía* al agente. Por eso la pantalla de instalación dice «no third-party code runs, but the instructions steer the coworker».
- **Impulsa el pipeline de [`career-ops`](https://github.com/Fighter90/career-ops)**, no un servicio alojado. Todo ocurre en tu máquina, en la carpeta de tu proyecto, con tu clave de modelo.

## 2. Requirements

1. **OpenWorker** instalado — descárgalo desde [openworker.com](https://openworker.com) (macOS / Windows) o ejecútalo desde el código fuente. Añade una clave de modelo (Anthropic, OpenAI, Google o un modelo local mediante Ollama).
2. **Una carpeta de proyecto `career-ops`** en tu máquina, configurada con tus datos:
   ```bash
   git clone https://github.com/Fighter90/career-ops
   cd career-ops
   # follow that project's README to create cv.md, config/profile.yml, portals.yml
   ```
   El coworker opera *dentro* de esta carpeta y lee/escribe `cv.md`, `config/profile.yml`, `config/two-pager.yml`, `portals.yml`, `data/applications.md` y `reports/`.

**Los archivos que configuras** (esquema completo en el [README de `career-ops`](https://github.com/Fighter90/career-ops)):

| Archivo | Qué poner |
|---|---|
| `cv.md` | tu CV real en Markdown — la única fuente de verdad en la que se basa el coworker (no inventa nada más allá de esto). |
| `config/profile.yml` | roles objetivo, seniority, ubicaciones, preferencia remota, salario y `spend_tier` (controla el coste del modelo). |
| `portals.yml` | los tableros a escanear — un slug de empresa de Greenhouse/Lever/Ashby, o una entrada de tablero como `{ name: Torre, provider: torre, search: "engineering manager", enabled: true }`. |
| `config/two-pager.yml` *(opcional)* | gustos / imprescindibles / factores excluyentes que afinan la puntuación de encaje. |

Ejecuta `node scan.mjs --dry-run` desde esta carpeta una vez para confirmar que trae ofertas antes de conectar OpenWorker.

**(opcional)** clona [`career-ops-ui`](https://github.com/Fighter90/career-ops-ui) en `career-ops/web-ui/` para que *«abre el panel»* funcione (ver §6).

## 3. Install the coworker into OpenWorker

> **¿Nuevo aquí?** El [README](https://github.com/Fighter90/career-ops-coworker#deploying--running--full-walkthrough) del repo tiene un recorrido de despliegue paso a paso completo (requisitos → clave del modelo → carpeta → conectores → primera ejecución → panel → actualización → resolución de problemas). Esta sección es la versión corta.

**Lo más rápido — un comando.** Prepara el pipeline que maneja el coworker (idempotente — reutiliza un `career-ops` / `web-ui` existente) y luego muestra los pasos de OpenWorker:

```bash
curl -fsSL https://raw.githubusercontent.com/Fighter90/career-ops-coworker/main/install.sh | bash
```

En **Install a coworker** de OpenWorker, añádelo de tres formas: **GitHub URL** (`https://github.com/Fighter90/career-ops-coworker`), **.zip** (desde Releases) o **Import** del archivo `career-ops.md`. Las tres instalan la misma persona — desactivada a la espera de tu consentimiento.

1. Consigue `career-ops.md` — clona este repositorio o descarga el archivo individual.
2. En OpenWorker: **New coworker → Import** y elige `career-ops.md` (o apunta OpenWorker a la carpeta de este repositorio).
3. Al importar, el archivo se **captura como snapshot en el área gestionada de OpenWorker**. Las ediciones posteriores en este repositorio no cambian una copia ya instalada — vuelve a importar para actualizar; el campo `version:` genera la nota «replaces vN».
4. Abre una sesión con **Job-Search Coworker** y elige tu carpeta `career-ops` como carpeta de trabajo.

> **Confianza:** instala solo coworkers que puedas leer y de los que puedas responsabilizarte — un coworker se ejecuta con acceso a tu sistema. Este no incluye código; aun así, abre primero [`career-ops.md`](../career-ops.md) para saber exactamente cómo se le indica que se comporte.

## 4. First run

Pide algo real, por ejemplo:
- *«Escanea mis portales y dame las 5 vacantes que mejor encajan esta semana».*
- *«Adapta mi CV a esta vacante: <pega la JD o la URL>».*
- *«Qué candidaturas necesitan un follow-up, y redáctalos».*
- *«Abre el panel».*

El coworker inicia cada tarea con un plan breve (el panel de Progreso), trabaja una etapa a la vez y termina con el **entregable real y su ubicación** — una lista corta, un archivo de CV adaptado, una actualización del tracker o un correo redactado.

## 5. The workflow, stage by stage

- **Scan** — ejecuta el escáner del proyecto (`npm run scan` → `node scan.mjs`; flags como `--dry-run`, `--company "<Name>"`, `--since 7`). Cero tokens de API — HTTP puro contra portales públicos. Informa cuántas vacantes y de qué fuentes.
- **Score fit** — puntúa cada vacante de **0 a 5** frente a tu CV + profile + two-pager, con una razón de una línea y las carencias concretas. Ordena y muestra las mejores.
- **Tailor** — bajo petición, escribe un CV específico para el puesto y una carta de presentación como archivos (en `reports/` o `applications/`). Fundamentado **solo** en hechos que ya están en tu CV; nunca inventa un empleador, una fecha, una métrica ni una habilidad, y señala una carencia en lugar de disimularla. (`npm run cv:verify-facts` es la barrera de veracidad del proyecto.)
- **Track** — añade/actualiza la fila en `data/applications.md` con el estado canónico que el proyecto ya utiliza.
- **Follow up** — comprueba la cadencia y **redacta** el correo; el envío requiere aprobación.
- **Interviews** — bajo petición, coloca franjas de entrevista en tu calendario y añade recordatorios de preparación (con aprobación).

## 6. Launch the career-ops-ui dashboard from OpenWorker

Pide *«abre el panel»* y el coworker arranca la interfaz web local:
- Preferido: `bash web-ui/bin/start.sh` — instala las dependencias si es necesario y sirve en `http://127.0.0.1:4317`. Define `PORT=` para cambiar el puerto, o `CAREER_OPS_ROOT=` si la interfaz está fuera del proyecto. Alternativa: `cd web-ui && npm start`.
- Es un servidor **de larga duración y solo local** (escucha en `127.0.0.1`) que lee los mismos archivos y no envía datos a ninguna parte. El coworker lo arranca en segundo plano, espera a que `GET /api/health` responda y luego te entrega la URL.
- Deténlo con Ctrl-C en su terminal, o matando el proceso `node server/index.mjs`.

## 7. Connections (optional — you approve each)

| Conexión | Para qué | Nivel |
|---|---|---|
| **Gmail** | leer respuestas de reclutadores; redactar correos de follow-up / agradecimiento (el envío requiere aprobación) | core |
| **Google Calendar** | colocar franjas de entrevista y recordatorios de preparación | core |
| **GitHub** | respaldar los puntos del CV con tus proyectos y publicaciones públicos | optional |
| **filesystem (MCP)** | montar la carpeta del proyecto explícitamente, si prefieres MCP a las herramientas de archivos integradas | optional |

Las conexiones se declaran en el permiso `connectors:` del frontmatter y aparecen en el cajón de conexiones de la sesión. Toda escritura o envío sigue pidiendo confirmación primero.

## 8. Safety model

- **La veracidad es el producto.** Un hecho inventado en el CV puede arruinar un proceso de contratación. Cada afirmación se remonta a tu `cv.md`; cada punto adaptado es algo que realmente hiciste. Cuando no está claro si el CV respalda una afirmación, el coworker la omite y la señala.
- **Solo lectura por defecto.** Escanear y puntuar son gratis. **Enviar un correo, cambiar tu calendario, escribir fuera del proyecto o sobrescribir `cv.md` requieren aprobación** — el coworker indica lo que va a hacer y espera.
- **Local y privado.** Tu CV, las cifras salariales y los informes se quedan en tu máquina y nunca se publican en un conector que no hayas solicitado.

## 9. Scheduling (automations)

El coworker declara `scheduling: true`, así que puedes configurar ejecuciones periódicas en OpenWorker — por ejemplo un **resumen matutino de escaneo** («cada día laborable a las 8, escanea y dame las nuevas mejores coincidencias») o un **barrido semanal de follow-up**. Las ejecuciones llegan a la app con transcripciones completas; las ejecuciones sin supervisión aparcan sus solicitudes de aprobación en la bandeja de entrada en lugar de actuar por su cuenta.

## 10. Troubleshooting

- **«No postings found».** Confirma que `portals.yml` lista empresas/portales habilitados y que tu red llega a ellos (algunos portales regionales quedan bloqueados tras una VPN de túnel completo — desconéctala y vuelve a escanear). Prueba `npm run scan -- --dry-run` para ver una vista previa.
- **El panel no se abre.** Asegúrate de que Node ≥ 18 está instalado y de que el puerto 4317 está libre (`PORT=8080 bash web-ui/bin/start.sh`). Comprueba `http://127.0.0.1:4317/api/health`.
- **Un CV adaptado parece escaso.** Es la barrera de veracidad funcionando — no inventará experiencia. Añade la evidencia real a `cv.md` (o a tu GitHub) y vuelve a adaptar.
- **El coworker no envía un correo.** Es a propósito — los envíos requieren aprobación. Aprueba la confirmación, o cambia el modo de permisos en OpenWorker si quieres menos avisos (entiende primero el compromiso que implica).

## 11. Update & uninstall

- **Actualizar:** haz pull de este repositorio (o vuelve a descargar `career-ops.md`) y reimpórtalo en OpenWorker; el aumento de `version:` muestra una nota «replaces vN».
- **Desinstalar:** elimina el coworker en la lista de coworkers de OpenWorker. Los archivos de tu proyecto `career-ops` quedan intactos — el coworker solo leyó y escribió los archivos que aprobaste.

## 12. FAQ

- **¿Necesita mis datos en la nube?** No. Todo es local; solo el modelo y los conectores que elijas ven algo, y únicamente lo que apruebas.
- **¿Qué modelos funcionan mejor?** Modelos potentes en tool-calling (el frontmatter recomienda `anthropic:claude-opus-4-8` y `openai:gpt-5.5`); un modelo local capaz mediante Ollama también sirve.
- **¿Puede postularse a empleos por mí?** Prepara todo — el CV adaptado, la carta de presentación, la fila del tracker, el follow-up — pero cualquier acción hacia fuera (un envío) la apruebas tú. Es un coworker, no un piloto automático.
- **¿Está afiliado a OpenWorker?** No. Apunta al formato de coworker de OpenWorker y al proyecto de código abierto `career-ops`; ambos tienen licencia MIT.
