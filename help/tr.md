<!-- Locale: Turkish (tr). Translations live beside this file as help/<lang>.md. Keep the ## / ### headings identical across locales; translate prose only, never the code, file names, CLI flags, or YAML keys. -->
# Job-Search Coworker — Kullanıcı Kılavuzu

**career-ops** coworker'ını **[OpenWorker](https://openworker.com)** içinde kurmak ve çalıştırmak için eksiksiz bir kılavuz. Coworker, OpenWorker'ı bir iş arama operatörüne dönüştürür: iş ilanı panolarını tarar, her ilanı CV'nize göre puanlar, gerçeklere dayalı bir CV + ön yazı hazırlar, başvuruları izler ve follow-up taslakları oluşturur — ayrıca sizin için `career-ops-ui` dashboard'unu açabilir.

## 1. What this is (and isn't)

- **Bu bir** *persona*'dır — YAML frontmatter (hangi yetenekleri istediği) artı bir sistem promptu (nasıl davrandığı) içeren tek bir Markdown dosyasıdır ([`career-ops.md`](../career-ops.md)). "Coworker ⊇ skill."
- **Bu bir** program **değildir**. OpenWorker bu deponun **hiçbir** kısmını kod olarak çalıştırmaz. Frontmatter, incelenmiş yetenekleri ve önerilen konnektörleri *bildirir*; prompt ise agent'ı *yönlendirir*. İşte bu yüzden kurulum ekranında "no third-party code runs, but the instructions steer the coworker" yazar.
- **[`career-ops`](https://github.com/Fighter90/career-ops) pipeline'ını yönetir**, barındırılan bir hizmeti değil. Her şey sizin makinenizde, proje klasörünüzde, sizin model anahtarınızla gerçekleşir.

## 2. Requirements

1. **OpenWorker** kurulu olmalı — [openworker.com](https://openworker.com) adresinden indirin (macOS / Windows) veya kaynaktan çalıştırın. Bir model anahtarı ekleyin (Anthropic, OpenAI, Google veya Ollama üzerinden yerel bir model).
2. Verilerinizle kurulmuş, makinenizde bir **`career-ops` proje klasörü**:
   ```bash
   git clone https://github.com/Fighter90/career-ops
   cd career-ops
   # cv.md, config/profile.yml, portals.yml oluşturmak için o projenin README dosyasını izleyin
   ```
   Coworker bu klasörün *içinde* çalışır ve `cv.md`, `config/profile.yml`, `config/two-pager.yml`, `portals.yml`, `data/applications.md` ve `reports/` dosyalarını okur/yazar.

**Kuracağın dosyalar** (tam şema [`career-ops` README](https://github.com/Fighter90/career-ops)):

| Dosya | İçine ne konur |
|---|---|
| `cv.md` | Markdown biçiminde gerçek özgeçmişin — coworker’ın dayandığı tek doğruluk kaynağı (bunun ötesinde uydurmaz). |
| `config/profile.yml` | hedef roller, kıdem, lokasyonlar, uzaktan tercihi, maaş ve `spend_tier` (model maliyetini denetler). |
| `portals.yml` | taranacak ilan panoları — bir Greenhouse/Lever/Ashby şirket slug’ı ya da `{ name: Torre, provider: torre, search: "engineering manager", enabled: true }` gibi pano geneli bir giriş. |
| `config/two-pager.yml` *(isteğe bağlı)* | sevdiklerin / olmazsa olmazlar / anlaşma bozanlar — uygunluk puanını keskinleştirir. |

OpenWorker’a bağlamadan önce bu klasörden bir kez `node scan.mjs --dry-run` çalıştırıp ilan çektiğini doğrula.

**(isteğe bağlı)** *"panoyu aç"* çalışsın diye [`career-ops-ui`](https://github.com/Fighter90/career-ops-ui)’i `career-ops/web-ui/` içine klonla (bkz. §6).

## 3. Install the coworker into OpenWorker

> **Yeni misin?** Deponun [README](https://github.com/Fighter90/career-ops-coworker#deploying--running--full-walkthrough) dosyasında tam adım adım dağıtım rehberi var (ön koşullar → model anahtarı → klasör → bağlayıcılar → ilk çalıştırma → pano → güncelleme → sorun giderme). Bu bölüm kısa sürümdür.

1. `career-ops.md` dosyasını edinin — bu depoyu klonlayın veya tek dosyayı indirin.
2. OpenWorker'da: **New coworker → Import** ve `career-ops.md` dosyasını seçin (veya OpenWorker'ı bu depo klasörüne yönlendirin).
3. İçe aktarma sırasında dosya **OpenWorker'ın yönetilen alanına anlık görüntü olarak alınır**. Bu depodaki sonraki düzenlemeler kurulu bir kopyayı değiştirmez — güncellemek için yeniden içe aktarın; `version:` alanı "replaces vN" notunu belirler.
4. **Job-Search Coworker** ile bir oturum açın ve çalışma klasörü olarak `career-ops` klasörünüzü seçin.

> **Güven:** yalnızca okuyabildiğiniz ve sorumlu tutabildiğiniz coworker'ları kurun — bir coworker sisteminize erişimle çalışır. Bu, hiç kod içermez; yine de, tam olarak nasıl davranmasının söylendiğini bilmeniz için önce [`career-ops.md`](../career-ops.md) dosyasını açın.

## 4. First run

Gerçek bir şey isteyin, örneğin:
- *"Panolarımı tara ve bu hafta için en uygun 5 ilanı ver."*
- *"CV'mi bu ilana göre uyarla: <JD veya URL yapıştırın>."*
- *"Hangi başvurular için follow-up gerekiyor, ve onların taslaklarını hazırla."*
- *"Dashboard'u aç."*

Coworker her göreve kısa bir planla başlar (ilerleme paneli), her seferinde tek bir aşamada çalışır ve **asıl çıktı ve onun nerede bulunduğu** ile tamamlar — bir kısa liste, uyarlanmış bir CV dosyası, bir tracker güncellemesi veya bir e-posta taslağı.

## 5. The workflow, stage by stage

- **Scan** — proje tarayıcısını çalıştırır (`npm run scan` → `node scan.mjs`; `--dry-run`, `--company "<Name>"`, `--since 7` gibi bayraklar). Sıfır API tokenı — genel panolara karşı saf HTTP. Kaç ilan olduğunu ve hangi kaynaklardan geldiğini bildirir.
- **Score fit** — her ilanı CV + profile + two-pager'ınıza göre **0–5** arasında puanlar; tek satırlık bir gerekçe ve somut eksikliklerle birlikte. Sıralar ve en iyi birkaçını öne çıkarır.
- **Tailor** — istek üzerine, role özgü bir CV ve bir ön yazıyı dosya olarak yazar (`reports/` veya `applications/` altında). **Yalnızca** CV'nizde zaten var olan gerçeklere dayanır; asla bir işveren, tarih, metrik veya beceri uydurmaz ve bir eksikliği örtbas etmek yerine işaretler. (`npm run cv:verify-facts` projenin doğruluk kapısıdır.)
- **Track** — `data/applications.md` içindeki satırı, projenin zaten kullandığı kanonik durumla ekler/günceller.
- **Follow up** — kadansı kontrol eder ve e-postanın **taslağını** hazırlar; gönderim onaya tabidir.
- **Interviews** — istek üzerine, takviminize mülakat zaman aralıkları yerleştirir ve hazırlık hatırlatıcıları ekler (onaya tabidir).

## 6. Launch the career-ops-ui dashboard from OpenWorker

*"dashboard'u aç"* deyin, coworker yerel web arayüzünü başlatır:
- Tercih edilen: `bash web-ui/bin/start.sh` — gerekirse bağımlılıkları kurar ve `http://127.0.0.1:4317` üzerinde sunar. Portu değiştirmek için `PORT=`, arayüz proje dışında bulunuyorsa `CAREER_OPS_ROOT=` ayarlayın. Yedek: `cd web-ui && npm start`.
- Bu, aynı dosyaları okuyan ve verileri hiçbir yere göndermeyen **uzun süre çalışan, yalnızca yerel** bir sunucudur (`127.0.0.1` üzerinde dinler). Coworker onu arka planda başlatır, `GET /api/health` yanıt verene kadar bekler, ardından size URL'yi verir.
- Onu terminalinde Ctrl-C ile veya `node server/index.mjs` işlemini sonlandırarak durdurun.

## 7. Connections (optional — you approve each)

| Bağlantı | Neden | Seviye |
|---|---|---|
| **Gmail** | işe alım uzmanı yanıtlarını okuma; follow-up / teşekkür e-postaları taslağı hazırlama (gönderim onaya tabidir) | core |
| **Google Calendar** | mülakat zaman aralıkları ve hazırlık hatırlatıcıları yerleştirme | core |
| **GitHub** | CV maddelerini genel projeleriniz ve yayınlarınızla destekleme | optional |
| **filesystem (MCP)** | yerleşik dosya araçları yerine MCP'yi tercih ediyorsanız, proje klasörünü açıkça bağlama | optional |

Bağlantılar, frontmatter'ın `connectors:` izninde bildirilir ve oturumun bağlantılar çekmecesinde gösterilir. Her yazma veya gönderme işlemi yine de önce sorar.

## 8. Safety model

- **Doğruluk, ürünün kendisidir.** Uydurulmuş bir CV gerçeği, bir işe alım sürecini bitirebilir. Her iddia sizin `cv.md` dosyanıza dayanır; uyarlanmış her madde gerçekten yaptığınız bir şeydir. CV'nin bir iddiayı destekleyip desteklemediği belirsiz olduğunda, coworker onu dışarıda bırakır ve işaretler.
- **Varsayılan olarak salt okunur.** Tarama ve puanlama ücretsizdir. **E-posta gönderme, takviminizi değiştirme, proje dışına yazma veya `cv.md` dosyasının üzerine yazma onaya tabidir** — coworker ne yapacağını belirtir ve bekler.
- **Yerel ve özel.** CV'niz, maaş rakamlarınız ve raporlarınız makinenizde kalır ve istemediğiniz bir konnektöre asla gönderilmez.

## 9. Scheduling (automations)

Coworker `scheduling: true` bildirir, böylece OpenWorker'da yinelenen çalıştırmalar ayarlayabilirsiniz — örneğin bir **sabah tarama brifingi** ("her iş günü sabah 8'de tara ve bana en iyi yeni uygun ilanları ver") veya bir **haftalık follow-up taraması**. Çalıştırmalar, tam transkriptlerle uygulamaya düşer; gözetimsiz çalıştırmalar kendi başlarına eylemde bulunmak yerine onay isteklerini inbox'a park eder.

## 10. Troubleshooting

- **"İlan bulunamadı."** `portals.yml` dosyasının etkin şirketleri/panoları listelediğini ve ağınızın onlara ulaştığını doğrulayın (bazı bölgesel panolar tam tünel VPN arkasında engellenir — bağlantıyı kesip yeniden tarayın). Önizleme için `npm run scan -- --dry-run` deneyin.
- **Dashboard açılmıyor.** Node ≥ 18'in kurulu olduğundan ve 4317 portunun boş olduğundan emin olun (`PORT=8080 bash web-ui/bin/start.sh`). `http://127.0.0.1:4317/api/health` adresini kontrol edin.
- **Uyarlanmış bir CV zayıf görünüyor.** Bu, doğruluk kapısının çalışmasıdır — deneyim uydurmaz. Gerçek kanıtları `cv.md` dosyasına (veya GitHub'ınıza) ekleyin ve yeniden uyarlayın.
- **Coworker bir e-posta göndermiyor.** Tasarım gereği — gönderimler onaya tabidir. Check-in'i onaylayın veya daha az istem istiyorsanız OpenWorker'da izin modunu değiştirin (önce ödünleşimi anlayın).

## 11. Update & uninstall

- **Güncelleme:** bu depoyu çekin (veya `career-ops.md` dosyasını yeniden indirin) ve OpenWorker'a yeniden içe aktarın; `version:` artışı bir "replaces vN" notu gösterir.
- **Kaldırma:** coworker'ı OpenWorker'ın coworker listesinden kaldırın. `career-ops` proje dosyalarınıza dokunulmaz — coworker yalnızca onayladığınız dosyaları okudu ve yazdı.

## 12. FAQ

- **Verilerimin bulutta olması gerekiyor mu?** Hayır. Her şey yereldir; herhangi bir şeyi yalnızca seçtiğiniz model ve konnektörler görür, ve yalnızca onayladığınız kadarını.
- **Hangi modeller en iyi çalışır?** Güçlü tool-calling modelleri (frontmatter `anthropic:claude-opus-4-8` ve `openai:gpt-5.5` önerir); Ollama üzerinden yetenekli bir yerel model de işe yarar.
- **Benim için işlere başvurabilir mi?** Her şeyi hazırlar — uyarlanmış CV, ön yazı, tracker satırı, follow-up — ancak dışarıya yönelik herhangi bir eylem (bir gönderim) sizin onayınıza bağlıdır. O bir coworker'dır, bir otopilot değil.
- **Bu, OpenWorker ile bağlantılı mı?** Hayır. OpenWorker coworker formatını ve open-source `career-ops` projesini hedefler; her ikisi de MIT lisanslıdır.
