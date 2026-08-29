<!-- Locale: French (fr). Translations live beside this file as help/<lang>.md. Keep the ## / ### headings identical across locales; translate prose only, never the code, file names, CLI flags, or YAML keys. -->
# Job-Search Coworker — Guide de l'utilisateur

Un guide complet pour installer et lancer le coworker **career-ops** dans **[OpenWorker](https://openworker.com)**. Le coworker transforme OpenWorker en opérateur de recherche d'emploi : il scanne les sites d'offres, évalue chaque annonce par rapport à votre CV, adapte un CV + une lettre de motivation fondés sur les faits, suit vos candidatures et rédige des relances — et il peut ouvrir le dashboard `career-ops-ui` pour vous.

## 1. What this is (and isn't)

- **C'est** une *persona* — un unique fichier Markdown ([`career-ops.md`](../career-ops.md)) avec un frontmatter YAML (les capacités qu'il demande) plus un prompt système (la façon dont il se comporte). « Un coworker ⊇ une skill ».
- **Ce n'est pas** un programme. OpenWorker n'exécute **aucune** partie de ce dépôt en tant que code. Le frontmatter *déclare* des capacités vérifiées et des connecteurs recommandés ; le prompt *oriente* l'agent. C'est pourquoi l'écran d'installation indique : « no third-party code runs, but the instructions steer the coworker ».
- **Il pilote le pipeline [`career-ops`](https://github.com/Fighter90/career-ops)**, et non un service hébergé. Tout se passe sur votre machine, dans votre dossier de projet, avec votre clé de modèle.

## 2. Requirements

1. **OpenWorker** installé — téléchargez-le depuis [openworker.com](https://openworker.com) (macOS / Windows) ou lancez-le depuis les sources. Ajoutez une clé de modèle (Anthropic, OpenAI, Google ou un modèle local via Ollama).
2. **Un dossier de projet `career-ops`** sur votre machine, configuré avec vos données :
   ```bash
   git clone https://github.com/Fighter90/career-ops
   cd career-ops
   # suivez le README de ce projet pour créer cv.md, config/profile.yml, portals.yml
   ```
   Le coworker opère *à l'intérieur* de ce dossier et lit/écrit `cv.md`, `config/profile.yml`, `config/two-pager.yml`, `portals.yml`, `data/applications.md` et `reports/`.

**Les fichiers à configurer** (schéma complet dans le [README de `career-ops`](https://github.com/Fighter90/career-ops)) :

| Fichier | Quoi y mettre |
|---|---|
| `cv.md` | votre vrai CV en Markdown — la seule source de vérité sur laquelle le coworker s’appuie (il n’invente rien au-delà). |
| `config/profile.yml` | rôles visés, séniorité, localisations, préférence télétravail, salaire et `spend_tier` (contrôle le coût du modèle). |
| `portals.yml` | les tableaux à scanner — un slug d’entreprise Greenhouse/Lever/Ashby, ou une entrée globale comme `{ name: Torre, provider: torre, search: "engineering manager", enabled: true }`. |
| `config/two-pager.yml` *(optionnel)* | goûts / indispensables / rédhibitoires qui affinent le score d’adéquation. |

Lancez `node scan.mjs --dry-run` depuis ce dossier une fois pour confirmer qu’il ramène des offres avant de brancher OpenWorker.

**(optionnel)** clonez [`career-ops-ui`](https://github.com/Fighter90/career-ops-ui) dans `career-ops/web-ui/` pour que *« ouvre le tableau de bord »* fonctionne (voir §6).

## 3. Install the coworker into OpenWorker

> **Nouveau ici ?** Le [README](https://github.com/Fighter90/career-ops-coworker#deploying--running--full-walkthrough) du dépôt propose un parcours de déploiement pas à pas complet (prérequis → clé du modèle → dossier → connecteurs → première exécution → tableau de bord → mise à jour → dépannage). Cette section est la version courte.

**Le plus rapide — une commande.** Elle prépare le pipeline que le coworker pilote (idempotente — elle réutilise un `career-ops` / `web-ui` existant), puis affiche les étapes OpenWorker :

```bash
curl -fsSL https://raw.githubusercontent.com/Fighter90/career-ops-coworker/main/install.sh | bash
```

Dans **Install a coworker** d'OpenWorker, ajoutez-le de trois façons : **GitHub URL** (`https://github.com/Fighter90/career-ops-coworker`), **.zip** (depuis les Releases) ou **Import** du fichier `career-ops.md`. Les trois installent la même persona — désactivée en attendant votre consentement.

1. Récupérez `career-ops.md` — clonez ce dépôt ou téléchargez le fichier unique.
2. Dans OpenWorker : **New coworker → Import**, puis sélectionnez `career-ops.md` (ou indiquez à OpenWorker le dossier de ce dépôt).
3. À l'import, le fichier est **capturé dans l'espace géré d'OpenWorker**. Les modifications ultérieures dans ce dépôt ne changent pas une copie installée — réimportez pour mettre à jour ; le champ `version:` pilote la mention « replaces vN ».
4. Ouvrez une session avec **Job-Search Coworker** et choisissez votre dossier `career-ops` comme dossier de travail.

> **Confiance :** n'installez que des coworkers que vous pouvez lire et dont vous pouvez répondre — un coworker s'exécute avec accès à votre système. Celui-ci ne contient aucun code ; néanmoins, ouvrez d'abord [`career-ops.md`](../career-ops.md) pour savoir exactement comment il lui est demandé de se comporter.

## 4. First run

Demandez quelque chose de concret, par exemple :
- *« Scanne mes sites d'offres et donne-moi les 5 meilleures correspondances pour cette semaine. »*
- *« Adapte mon CV à cette annonce : <collez la JD ou l'URL>. »*
- *« Quelles candidatures nécessitent une relance, et rédige-les. »*
- *« Ouvre le dashboard. »*

Le coworker commence chaque tâche par un bref plan (le panneau de progression), traite une étape à la fois, et termine par **le livrable concret et l'endroit où il se trouve** — une liste restreinte, un fichier CV adapté, une mise à jour du suivi ou un brouillon d'e-mail.

## 5. The workflow, stage by stage

- **Scan** — lance le scanner du projet (`npm run scan` → `node scan.mjs` ; options comme `--dry-run`, `--company "<Name>"`, `--since 7`). Zéro token d'API — du HTTP pur vers les sites d'offres publics. Indique combien d'annonces, et de quelles sources.
- **Score fit** — attribue à chaque annonce une note de **0–5** par rapport à votre CV + profile + two-pager, avec une justification en une ligne et les lacunes concrètes. Classe et fait remonter les quelques meilleures.
- **Tailor** — sur demande, écrit un CV spécifique au poste et une lettre de motivation sous forme de fichiers (dans `reports/` ou `applications/`). Fondé **uniquement** sur des faits déjà présents dans votre CV ; il n'invente jamais un employeur, une date, une métrique ou une compétence, et signale une lacune au lieu de la masquer. (`npm run cv:verify-facts` est le garde-fou de véracité du projet ; `npm run cv:verify-ats` en est le pendant pour la lisibilité machine : facts vérifie si une affirmation est VRAIE, ATS si un analyseur de CV peut la LIRE.)
- **Track** — ajoute/met à jour la ligne dans `data/applications.md` avec le statut canonique que le projet utilise déjà.
- **Follow up** — vérifie la cadence et **rédige** l'e-mail ; l'envoi est soumis à approbation. L'échéance vient du `node followup-cadence.mjs` du projet, qui classe chaque candidature en urgent / overdue / waiting / cold, et non du statut du suivi, qui répond à une autre question.
- **Interviews** — sur demande, place des créneaux d'entretien dans votre calendrier et ajoute des rappels de préparation (soumis à approbation).

## 6. Launch the career-ops-ui dashboard from OpenWorker

Demandez *« ouvre le dashboard »* et le coworker démarre l'interface web locale :
- Préféré : `bash web-ui/bin/start.sh` — installe les dépendances si nécessaire et sert sur `http://127.0.0.1:4317`. Définissez `PORT=` pour changer de port, ou `CAREER_OPS_ROOT=` si l'UI se trouve en dehors du projet. Solution de repli : `cd web-ui && npm start`.
- C'est un serveur **de longue durée, uniquement local** (lié à `127.0.0.1`) qui lit les mêmes fichiers et n'envoie de données nulle part. Le coworker le démarre en arrière-plan, attend que `GET /api/health` réponde, puis vous remet l'URL.
- Arrêtez-le avec Ctrl-C dans son terminal, ou en tuant le processus `node server/index.mjs`.

## 7. Connections (optional — you approve each)

| Connexion | Pourquoi | Niveau |
|---|---|---|
| **Gmail** | lire les réponses des recruteurs ; rédiger des e-mails de relance / de remerciement (l'envoi est soumis à approbation) | core |
| **Google Calendar** | placer des créneaux d'entretien et des rappels de préparation | core |
| **GitHub** | étayer les points du CV avec vos projets et publications publics | optional |
| **filesystem (MCP)** | monter explicitement le dossier de projet, si vous préférez MCP aux outils de fichiers intégrés | optional |

Les connexions sont déclarées dans l'autorisation `connectors:` du frontmatter et présentées dans le panneau des connexions de la session. Chaque écriture ou envoi demande toujours votre accord au préalable.

## 8. Safety model

- **La véracité est le produit.** Un fait inventé dans un CV peut mettre fin à un processus de recrutement. Chaque affirmation remonte à votre `cv.md` ; chaque point adapté correspond à une chose que vous avez réellement faite. En cas de doute sur le fait que le CV étaye une affirmation, le coworker l'omet et le signale.
- **Lecture seule par défaut.** Le scan et l'évaluation sont gratuits. **L'envoi d'e-mails, la modification de votre calendrier, l'écriture en dehors du projet ou l'écrasement de `cv.md` sont soumis à approbation** — le coworker énonce ce qu'il va faire et attend.
- **Local et privé.** Votre CV, vos chiffres de salaire et vos rapports restent sur votre machine et ne sont jamais publiés vers un connecteur que vous n'avez pas demandé.

## 9. Scheduling (automations)

Le coworker déclare `scheduling: true`, vous pouvez donc programmer des exécutions récurrentes dans OpenWorker — par exemple un **brief de scan matinal** (« chaque jour de semaine à 8 h, scanne et donne-moi les meilleures nouvelles correspondances ») ou un **balayage hebdomadaire des relances**. Les exécutions arrivent dans l'application avec des transcriptions complètes ; les exécutions sans surveillance déposent leurs demandes d'approbation dans l'inbox au lieu d'agir d'elles-mêmes.

## 10. Troubleshooting

- **« Aucune annonce trouvée. »** Vérifiez que `portals.yml` liste les entreprises/sites activés et que votre réseau les atteint (certains sites régionaux sont bloqués derrière un VPN à tunnel complet — déconnectez-le et relancez le scan). Essayez `npm run scan -- --dry-run` pour un aperçu.
- **Le dashboard ne s'ouvre pas.** Assurez-vous que Node ≥ 18 est installé et que le port 4317 est libre (`PORT=8080 bash web-ui/bin/start.sh`). Vérifiez `http://127.0.0.1:4317/api/health`.
- **Un CV adapté paraît maigre.** C'est le garde-fou de véracité qui fonctionne — il n'invente pas d'expérience. Ajoutez les preuves réelles à `cv.md` (ou à votre GitHub) et relancez l'adaptation.
- **Le coworker n'envoie pas d'e-mail.** C'est voulu — les envois sont soumis à approbation. Approuvez le point de contrôle, ou changez de mode d'autorisation dans OpenWorker si vous voulez moins de sollicitations (comprenez d'abord le compromis).

## 11. Update & uninstall

- **Mise à jour :** mettez à jour ce dépôt (ou retéléchargez `career-ops.md`) et réimportez-le dans OpenWorker ; l'incrémentation de `version:` affiche une mention « replaces vN ».
- **Désinstallation :** retirez le coworker dans la liste des coworkers d'OpenWorker. Les fichiers de votre projet `career-ops` sont intacts — le coworker n'a jamais fait que lire et écrire les fichiers que vous avez approuvés.

## 12. FAQ

- **A-t-il besoin de mes données dans le cloud ?** Non. Tout est local ; seuls le modèle et les connecteurs que vous avez choisis voient quoi que ce soit, et uniquement ce que vous approuvez.
- **Quels modèles fonctionnent le mieux ?** Des modèles performants en tool-calling (le frontmatter recommande `anthropic:claude-opus-5` et `openai:gpt-5.5`) ; un modèle local capable via Ollama fonctionne aussi.
- **Peut-il postuler à des emplois à ma place ?** Il prépare tout — le CV adapté, la lettre de motivation, la ligne de suivi, la relance — mais toute action vers l'extérieur (un envoi) vous revient à approuver. C'est un coworker, pas un pilote automatique.
- **Est-ce affilié à OpenWorker ?** Non. Il vise le format coworker d'OpenWorker et le projet open-source `career-ops` ; les deux sont sous licence MIT.
