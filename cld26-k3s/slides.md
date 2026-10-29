---
theme: seriph
layout: cover
addons:
    - excalidraw
title: 'Einfacher als gedacht: Kubernetes mit k3s auch für kleine Umgebungen'
info: |
  ## Einfacher als gedacht

  Wie viel muss man wirklich verstehen, um Kubernetes zu benutzen? Weniger, als sein Ruf vermuten lässt, im Kern nämlich ein einziges Prinzip. Der Vortrag erklärt dieses Prinzip, geht echte Manifeste durch und zeigt einen Single-Node-Cluster auf k3s bei der Arbeit.

  <a href="https://github.com/speijnik/talks/tree/main/cld26-k3s" target="_blank" class="slidev-icon-btn">
    <carbon:logo-github />
  </a>
class: text-center
drawings:
  persist: false
transition: slide-up
mdc: true
duration: 30min
presenter: dev
colorSchema: light
fonts:
  sans: Geist
  serif: Geist
  mono: Geist Mono
themeConfig:
  primary: '#37AEC0'
---

# Einfacher als gedacht

Kubernetes mit k3s auch für kleine Umgebungen

## Kärntner Linuxtag 2026


<!--
- Zeit: 0:15, Ziel: bei 0:15 fertig
-->

---
transition: slide-up
layout: intro
---

# Stephan Peijnik-Steinwender

Chief Solution Architect bei netcup eos

<div class="logo-list">

- <span class="logo-tile"><logos-linux-tux /></span> GNU/Linux und FOSS seit 1999
- <span class="logo-tile full"><img src="/logos/anexia.svg" alt="Anexia" /></span> Anexia seit 2010
- <span class="logo-tile"><img src="/logos/eos.svg" alt="eos" /></span> netcup eos seit 2025

</div>

<!--
- Zeit: 1:00, Ziel: bei 1:15 fertig
- Die Demo läuft heute live in der Cloud, weil mein Arbeitgeber netcup eos die Ressourcen dafür zur Verfügung stellt. Danke dafür
- Nichts davon hängt an der Plattform: jede VM mit 2 GB RAM oder ein Raspberry Pi reicht, die Anleitung liegt im Repository
-->

---
transition: slide-up
layout: two-cols-header
---

# Ausgangspunkt

::left::

<Excalidraw
  drawFilePath="./standort_seed.excalidraw"
  class="w-[400px] mt-4"
  :darkMode="false"
  :background="false"
/>

::right::

<div v-click class="eos-card xs">
<div class="eos-card-label">Anforderung</div>
<div class="eos-card-head">Ein Infrastrukturdienst an jedem Standort</div>
<p>Ein Kubernetes-Cluster pro Standort? Zu viel, so der Gedanke</p>
</div>

<div v-click class="eos-card xs mt-3">
<div class="eos-card-label">Lösung</div>
<div class="eos-card-head">Eine VM, Ansible, systemd-Unit</div>
<p>Rolling Restarts über eigene Logik, in mehreren Anläufen</p>
</div>

<div v-click class="eos-card xs mt-3">
<div class="eos-card-label">Nächster Schritt</div>
<div class="eos-card-head">procroll, ein eigener Prozessmanager</div>
<p>In Go geschrieben, <a href="https://github.com/speijnik/procroll">nie fertig geworden</a></p>
</div>

<div v-click class="eos-band mt-4">Kubernetes konnte das bereits.</div>

<!--
- Zeit: 2:30, Ziel: bei 3:45 fertig
- Beispiel: ein Low-Level-Infrastrukturdienst mit eigener API-Komponente, der an jedem Standort laufen muss
- Kubernetes galt lange als etwas, das erst ab mehreren Maschinen sinnvoll ist
- Gelöst wurde es mit einer einzelnen VM: Ansible rollt eine systemd-Unit aus, eigene Logik beim Start der Unit sorgt für Rolling Restarts
- Das funktioniert, ähnlich wie die vielen compose-Setups in Home-Labs und kleinen Firmen
- procroll: Problem beschrieben, Lösung kam von Kubernetes
- Die Skripte stammen von mehreren Autoren, keine Variante hat die Sonderfälle vollständig abgedeckt
- Entwicklung von procroll eingestellt, weil Kubernetes das Problem schon gelöst mitbringt
- Was trivial aussieht, ist es bei näherem Hinsehen selten
-->

---
transition: slide-up
layout: two-cols-header
---

# Soll und Ist

::left::

<Excalidraw
  drawFilePath="./reconcile_loop.excalidraw"
  class="w-[400px] mt-4"
  :darkMode="false"
  :background="false"
/>

::right::

<div v-click class="eos-card sm">
<div class="eos-card-label">Imperativ</div>
<div class="eos-card-head">„Starte drei Container"</div>
<p>etwa mit <code>docker run</code></p>
</div>

<div v-click class="eos-card sm mt-3 mb-2">
<div class="eos-card-label">Deklarativ</div>
<div class="eos-card-head">„Drei Container in Version v1"</div>
<p>Der Soll-Zustand steht in einer Datei, dem Manifest. Kubernetes vergleicht laufend Soll mit Ist</p>
</div>

<div v-click="3" class="eos-card sm eos-events">
<div class="eos-card-label">So reagiert Kubernetes</div>
<div v-click="3" class="eos-event"><span>Container stirbt</span><span class="eos-cmp-arrow">→</span><strong>neuer startet</strong></div>
<div v-click="4" class="eos-event"><span>Neue Version</span><span class="eos-cmp-arrow">→</span><strong>schrittweise ersetzt</strong></div>
<div v-click="5" class="eos-event"><span>Neue Anzahl</span><span class="eos-cmp-arrow">→</span><strong>hoch- oder runterskaliert</strong></div>
</div>

<!--
- Zeit: 2:30, Ziel: bei 6:15 fertig
- Vergleich Thermostat: man sagt der Heizung nicht "jetzt fünf Minuten heizen", man stellt 21 Grad ein
- Jedes Mal dieselbe Reaktion: Differenz erkennen, Differenz beheben
- compose ist auch deklarativ, gleicht aber nur einmal beim "up" ab
- restart: always startet abgestürzte Container neu. Anzahl, Version und gelöschte Container gleicht compose aber nur beim "up" ab
- Kubernetes gleicht immer ab, das ist der eigentliche Unterschied
- Neue Version, schrittweise ersetzt: das nennt sich Rolling Update
- Fast alles Weitere lässt sich aus diesem Gedanken herleiten
-->

---
transition: slide-up
---

# Wer den Loop ausführt

<div class="grid grid-cols-2 gap-6 mt-4">
<div v-click class="eos-card sm">
<div class="eos-card-label">Eingebaut</div>
<div class="eos-card-head">Controller</div>
<p>Führt den Loop für eine Art von Objekt aus, etwa für Deployments und Updates</p>
</div>
<div v-click class="eos-card sm">
<div class="eos-card-label">Nachgerüstet</div>
<div class="eos-card-head">Operator</div>
<p>Eigener Controller für eigene Objekte, bringt Betriebswissen als Software mit</p>
</div>
</div>

<div v-click class="mt-4" style="--slidev-code-font-size: 11px; --slidev-code-line-height: 16px">

```yaml
# Beispiel cert-manager: der Wunsch nach einem Zertifikat
apiVersion: cert-manager.io/v1
kind: Certificate          # was gewünscht ist
metadata:
  name: demo
spec:                      # wie es aussehen soll
  secretName: demo-tls
  dnsNames:
    - demo.example.com
  issuerRef:
    kind: ClusterIssuer
    name: letsencrypt
```

</div>

<!--
- Zeit: 1:30, Ziel: bei 7:45 fertig
- Soll: es gibt ein gültiges Zertifikat für demo.example.com im Secret demo-tls
- Ist: Zertifikat fehlt oder läuft bald ab
- Der Operator holt das Zertifikat bei Let's Encrypt und erneuert es rechtzeitig
- Früher ein Cronjob mit Skript, jetzt ein Objekt und ein Loop
-->

---
transition: slide-up
---

# k3s

Batteries included: alles, was ein Kubernetes-Cluster braucht, auf einer Maschine

```shell
curl -sfL -o /tmp/install-k3s.sh https://get.k3s.io
less /tmp/install-k3s.sh
sudo sh /tmp/install-k3s.sh
```

<div class="grid grid-cols-2 gap-6 mt-6">
<div v-click class="eos-card sm">
<div class="eos-card-label">Installation</div>
<div class="eos-card-head">Ein Binary, ein Skript</div>
<p><code>kubectl</code> gleich dabei</p>
</div>
<div v-click class="eos-card sm">
<div class="eos-card-label">Mitgeliefert</div>
<div class="eos-card-head">Traefik, local-path, CoreDNS</div>
<p>Zugriff von außen, Volumes und interne Namen</p>
</div>
</div>

<!--
- Zeit: 1:30, Ziel: bei 9:15 fertig
- Zertifizierte Kubernetes-Distribution, nur kompakt verpackt
- Die Verwaltung des Clusters und die eigenen Anwendungen laufen auf derselben Maschine
- Läuft auch auf einem Raspberry Pi
- Kein curl | sh: erst ansehen, dann ausführen
- Ohne Angabe installiert das Skript die aktuelle stable-Version. Mit INSTALL_K3S_VERSION lässt sich eine Version festlegen
- Das Skript lädt das Binary von GitHub Releases, prüft die SHA256-Prüfsumme und richtet eine systemd-Unit ein
- Die Installation sehen wir gleich live
-->

---
transition: slide-up
---

# Damals und heute

<div class="grid grid-cols-2 gap-6 mt-4">
<div class="eos-card">
<div class="eos-card-label">Damals</div>
<div class="eos-card-head">Selbst gestrickt</div>

- Eine VM
- Ansible rollt eine systemd-Unit aus
- Eigene Logik für Rolling Restarts
- Danach ein eigener Prozessmanager

</div>
<div v-click class="eos-card">
<div class="eos-card-label">Heute</div>
<div class="eos-card-head">Mit k3s</div>

- Eine VM
- k3s
- Soll-Zustand als Manifest
- Rolling Update als Standardverhalten

</div>
</div>

<div v-click class="eos-band mt-6">Dieselbe Form, nur nicht mehr selbst gebaut.</div>

<!--
- Zeit: 1:00, Ziel: bei 10:15 fertig
- Dieselbe Form, nur nicht mehr selbst gebaut
- Single Node widerlegt den Gedanken, ein Cluster sei als Seed pro Standort zu viel
- Der Unterschied liegt im Loop: der läuft dauerhaft und muss nicht gepflegt werden
-->

---
transition: slide-up
layout: two-cols-header
---

# Die Begriffe, die man braucht

::left::

<Excalidraw
  drawFilePath="./objekte.excalidraw"
  class="w-[440px] mt-4"
  :darkMode="false"
  :background="false"
/>

::right::

<div class="grid gap-2 pl-2">
<div v-click class="eos-card xs">
<div class="eos-card-label">Pod</div>
<p>Kleinste Einheit, meist ein Container. Geht er verloren, wird er ersetzt</p>
</div>
<div v-click class="eos-card xs">
<div class="eos-card-label">Deployment</div>
<p>„Davon n Stück in dieser Version", der Loop sorgt dafür</p>
</div>
<div v-click class="eos-card xs">
<div class="eos-card-label">Service</div>
<p>Stabiler Name und Adresse über wechselnden Pods</p>
</div>
<div v-click class="eos-card xs">
<div class="eos-card-label">Ingress</div>
<p>Die Tür von außen: Hostname und Pfad zum Service</p>
</div>
</div>

<!--
- Zeit: 2:00, Ziel: bei 12:15 fertig
- Cluster und Node: bei uns dieselbe Kiste
- Pod: kleinste Einheit, meist ein Container. Geht ein Pod verloren, legt das Deployment einen neuen an
- Stürzt nur der Container ab, startet ihn der Node im selben Pod neu, das ist die Liveness Probe von gleich
- Deployment: "davon hätte ich gern n Stück in dieser Version"
- Service: stabiler Name über wechselnden Pods
- Ingress: die Tür von außen
- Ingress ist eingefroren, aber nicht abgekündigt. Nachfolger ist die Gateway API. In k3s ist Ingress ohne Zusatzschritt dabei, die Gateway API muss erst eingeschaltet werden. Wer neu anfängt, sollte sie sich ansehen
- Secret und ConfigMap ersetzen die .env-Datei, Secrets sind per Default nur base64-kodiert
-->

---
transition: slide-up
layout: two-cols-header
---

# compose und Manifeste

::left::

<div class="pr-3" style="--slidev-code-font-size: 10px; --slidev-code-line-height: 15px">

```yaml
services:
  demo:
    image: ghcr.io/speijnik/talks/cld26-k3s-demo:v1
    restart: always
    healthcheck:
      test: ["CMD", "python", "healthcheck.py"]
      interval: 10s
    labels:
      - traefik.enable=true
      - traefik.http.routers.demo.rule=PathPrefix(`/`)
      - traefik.http.services.demo.loadbalancer.server.port=8080
```

<div v-click="[1, 2]" class="eos-note sm">

**Liveness:** lebt der Container? Sonst Neustart.<br>
**Readiness:** kann er Anfragen bedienen? Sonst kein Traffic.

</div>

</div>

::right::

<div class="pl-3" style="--slidev-code-font-size: 10px; --slidev-code-line-height: 15px">

````md magic-move
```yaml
# Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo
spec:
  replicas: 3
  selector:
    matchLabels:
      app: demo
  template:
    metadata:
      labels:
        app: demo
    spec:
      containers:
        - name: demo
          image: ghcr.io/speijnik/talks/cld26-k3s-demo:v1
          ports:
            - containerPort: 8080
```
```yaml
# Deployment (Ausschnitt)
    spec:
      containers:
        - name: demo
          image: ghcr.io/speijnik/talks/cld26-k3s-demo:v1
          ports:
            - containerPort: 8080
          livenessProbe:
            httpGet:
              path: /healthz
              port: 8080
          readinessProbe:
            httpGet:
              path: /readyz
              port: 8080
```
```yaml
# Service
apiVersion: v1
kind: Service
metadata:
  name: demo
spec:
  selector:
    app: demo
  ports:
    - port: 80
      targetPort: 8080
```
```yaml
# Ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: demo
spec:
  ingressClassName: traefik
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: demo
                port:
                  number: 80
```
````

<div v-click class="eos-note sm">

**Hinweis:** Ingress ist eingefroren, der Nachfolger heißt Gateway API

</div>

</div>

<!--
- Zeit: 2:45, Ziel: bei 15:00 fertig
- Links die compose.yml, rechts dasselbe als Manifeste, vollständig im Repository
- Image und Port kennt man aus compose
- Liveness entscheidet über Neustart, Readiness über Traffic. Genau diese Trennung macht das Rolling Update gefahrlos
- Service: der Selector verbindet mit den Pods des Deployments
- Ingress ersetzt die Traefik-Labels
- Hinweis auf die Gateway API, falls jemand nach dem Ende von ingress-nginx fragt: das betrifft den Controller, nicht die Ingress-API, und k3s nutzt Traefik
- Mehr YAML, dafür strukturiert
- Für fertige Anwendungen gibt es Helm, dort ist die values.yaml wieder nur ein Soll-Zustand. Links im Repository
-->

---
transition: slide-up
---

# compose und Kubernetes im Vergleich

<div class="eos-cmp eos-cmp-header">
<div></div>
<div>compose</div>
<div></div>
<div>Kubernetes</div>
</div>

<div class="grid gap-2">
<div v-click class="eos-card eos-cmp">
<div class="eos-card-label">Unterbrechungsfreies Update</div>
<div class="eos-cmp-old">App doppelt definieren, nacheinander aktualisieren</div>
<div class="eos-cmp-arrow">→</div>
<div class="eos-cmp-new">Standardverhalten</div>
</div>
<div v-click class="eos-card eos-cmp">
<div class="eos-card-label">Hängender Dienst</div>
<div class="eos-cmp-old"><code>unhealthy</code>, läuft weiter</div>
<div class="eos-cmp-arrow">→</div>
<div class="eos-cmp-new">Liveness Probe startet neu</div>
</div>
<div v-click class="eos-card eos-cmp">
<div class="eos-card-label">Rollback</div>
<div class="eos-cmp-old">Wie das Update: alte Version eintragen, nacheinander aktualisieren</div>
<div class="eos-cmp-arrow">→</div>
<div class="eos-cmp-new"><code>rollout undo</code>, Revisionen gespeichert</div>
</div>
<div v-click class="eos-card eos-cmp">
<div class="eos-card-label">Cron</div>
<div class="eos-cmp-old">Host-Cron ohne Retry und Historie</div>
<div class="eos-cmp-arrow">→</div>
<div class="eos-cmp-new">CronJob mit Wiederholung und Historie</div>
</div>
<div v-click class="eos-card eos-cmp">
<div class="eos-card-label">Soll-Zustand herstellen</div>
<div class="eos-cmp-old">Absturz: <code>restart</code>, Anzahl und Version nur beim <code>up</code></div>
<div class="eos-cmp-arrow">→</div>
<div class="eos-cmp-new">laufend, für alles</div>
</div>
</div>

<!--
- Zeit: 2:00, Ziel: bei 17:00 fertig
- Verglichen wird gegen ein gut konfiguriertes compose-Setup
- Soll-Zustand: Docker startet abgestürzte Container per restart-Policy neu. Gelöschte Container, falsche Anzahl oder Version korrigiert erst das nächste up
- Alles davon lässt sich mit compose nachbauen, aber man muss es wissen und dazubauen
- Kubernetes-Update unterbrechungsfrei dank Readiness Probe. Ohne Probe bekommt ein Pod schon Traffic, bevor er bereit ist
- Für das Abbauen der alten Pods steht im Repo zusätzlich eine kurze Pause vor dem Beenden (preStop). Ohne sie gibt es beim Update vereinzelt 502
- Update mit compose und Traefik: zwei Dienste mit denselben Labels, Traefik verteilt nur auf gesunde Container. Nacheinander aktualisieren und auf healthy warten bleibt Handarbeit oder ein Skript
- Rollback: mit compose derselbe Weg wie beim Update, nur mit der alten Version. Kubernetes merkt sich die Revisionen, ein Befehl genügt
- Es gibt Zusatzwerkzeuge wie das Plugin docker rollout, die so ein Update automatisieren. Nicht Teil von compose, muss man dazubauen
- Einiges davon sehen wir gleich live
-->

---
transition: slide-up
layout: section
---

# Demo

1. Konsole öffnen
2. k3s installieren
3. Demo-App deployen
4. Pod töten
5. Update auf v2
6. Kaputtes Update auf v3
7. Rollback

<!--
- Zeit: 6:45, Ziel: bei 23:45 fertig
- VM etwa 10 Minuten vor dem Vortrag frisch per tofu apply erzeugen, IP notieren und Browser-Tab vorbereiten. curl und less sind per cloud-init schon installiert
- Beim Wechsel in die Oberfläche: wie gesagt, das ginge auf jeder VM
- In der Konsole k3s installieren
- Nach dem Deploy den vorbereiteten Browser-Tab neu laden, vorher lauscht auf Port 80 noch nichts
- Offen sind laut ACL nur die Ports 22 und 80, die Kubernetes-API (6443) ist von außen nicht erreichbar
- Falls die Konsole hakt: per SSH als deploy anmelden
- Alle Befehle liegen per cloud-init im Verlauf von root, bei Bedarf mit Strg+R suchen statt abtippen. BASE ist schon gesetzt
- Während der Installation: was k3s mitbringt
- k3s-Installation live: Skript laden, Prüfsumme prüfen, ausführen. Dazu sagen: ein Skript aus dem Internet als root immer erst lesen. Dieses habe ich vorab gelesen und mir die Prüfsumme notiert, stimmt sie, ist es genau dieses Skript
- Meldet sha256sum FAILED, hat get.k3s.io eine neuere Version. Dann mit Strg+R nach 2977 suchen, das lädt die gelesene Version über den gepinnten k3s-Commit
- Die Seite zeigt pro Pod eine Kachel mit Version, ein verschwundener Pod wird grau. Pod-Wechsel und Update sind so am Projektor sichtbar
- v3: Readiness Probe schlägt fehl, Rollout bleibt stehen, alte Pods liefern weiter aus
- Vor dem Rollback kubectl describe pod auf den neuen Pod: unter Events steht "Readiness probe failed" mit Statuscode 503. So sucht man Fehler im Alltag
- Danach rollout undo
- Ablauf: Konsole 0:15, k3s 1:30, Browser 0:15, Deploy 1:00, Pod töten 0:45, v2 1:00, v3 mit describe 1:15, Rollback 0:30, Puffer 0:15
- Bei Zeitnot entfällt der Schritt mit v3, spart etwa 1:45
- Fallback: Screencast, zweite fertige VM
-->

---
transition: slide-up
---

# Was ein einzelner Node nicht kann

Weniger Komplexität, dafür weniger Möglichkeiten

<div class="grid grid-cols-2 gap-4 mt-4">
<div v-click class="eos-card xs">
<div class="eos-card-label">Ausfall</div>
<div class="eos-card-head">Fällt die Maschine aus, steht alles</div>
<p>Replicas helfen gegen abstürzende Prozesse, nicht gegen Hardware</p>
</div>
<div v-click class="eos-card xs">
<div class="eos-card-label">Wartung</div>
<div class="eos-card-head">Neustart des Hosts heißt Ausfall</div>
<p>Kein zweiter Node, auf den die Pods ausweichen können</p>
</div>
<div v-click class="eos-card xs">
<div class="eos-card-label">Daten</div>
<div class="eos-card-head">Alles liegt auf dieser einen Maschine</div>
<p>local-path ohne Replikation, Backup bleibt eigene Aufgabe</p>
</div>
<div v-click class="eos-card xs">
<div class="eos-card-label">Ressourcen</div>
<div class="eos-card-head">Cluster und Anwendungen teilen sich alles</div>
<p>Die k3s-Doku nennt 2 GB RAM, Skalieren geht nur mit mehr CPU und RAM</p>
</div>
</div>

<div v-click class="eos-note">

**compose bleibt der kürzere Weg** für einen einzelnen Dienst, der selten angefasst wird.<br>
**Mehr Nodes:** k3s nimmt weitere auch nachträglich auf. Alternative: **k0s**, weniger mitgeliefert, Multi-Node deklarativ mit k0sctl.

</div>

<!--
- Zeit: 2:00, Ziel: bei 25:45 fertig
- Single Node ist eine bewusste Entscheidung: kein etcd-Quorum, keine verteilte Speicherung, dafür weniger Teile, die kaputtgehen können
- Wichtigster Punkt ist der erste, weil vorher Self-Healing gezeigt wurde: drei Replicas auf einer Maschine fallen gemeinsam aus
- Wartung: ein Kernel-Update bedeutet Neustart der einzigen Maschine, kein Drain auf einen anderen Node
- k3s-Upgrade dagegen ohne Ausfall: stoppt der k3s-Dienst, laufen die Container weiter, nur die API ist kurz weg. Upgrade per Skript mit neuer INSTALL_K3S_VERSION oder per system-upgrade-controller
- Daten: local-path heißt ein Verzeichnis auf dieser Maschine, ohne Replikation und Snapshots. Zu sichern sind die Volumes und die Cluster-Datenbank (SQLite unter /var/lib/rancher/k3s/server/db)
- Kubernetes macht das Deployment reproduzierbar. Die Daten muss man selbst sichern
- Ressourcen: k3s selbst braucht einige hundert MB RAM, die den Anwendungen fehlen. Die Doku nennt 2 GB RAM und 2 CPU-Kerne für einen Server
- Unabhängig vom einzelnen Node: etwa drei Minor-Releases pro Jahr mit rund einem Jahr Support, und mehr Lernstoff (Pending, CrashLoopBackOff). Das ist der laufende Preis von Kubernetes überhaupt
- compose gewinnt bei: eine Datei, kein Control Plane, in Sekunden gestartet, kein Upgrade-Zyklus
- Interessant wird Kubernetes ab mehreren Diensten, die regelmäßig aktualisiert werden, oder wenn man lernen will, was einem beruflich begegnet
- Wachsen mit k3s: weitere Nodes treten mit Token und Server-Adresse bei. Ein Single Server mit SQLite lässt sich durch Neustart mit --cluster-init auf embedded etcd umstellen, danach sind weitere Server möglich
- k0s: ebenfalls ein Binary, bringt aber weniger mit (kein Ingress Controller, kein Storage Provisioner), näher an Upstream. Control Plane per Default von den Workloads getrennt. k0sctl installiert und aktualisiert Multi-Node-Cluster aus einer Konfigurationsdatei
-->

---
transition: slide-up
---

# Fazit

<div class="grid grid-cols-2 gap-6 mt-6">
<div v-click class="eos-card">
<div class="eos-card-label">Statt selbst gebaut</div>
<div class="eos-card-head">Ein paar Zeilen YAML</div>
<p>Rolling Restarts und Rollback bringt Kubernetes mit</p>
</div>
<div v-click class="eos-card">
<div class="eos-card-label">Für den Anfang</div>
<div class="eos-card-head">Eine Maschine reicht</div>
<p>Die Hürde ist kleiner als ihr Ruf, k3s steht in Minuten</p>
</div>
</div>

<div v-click class="eos-cta">
<div>
<div class="eos-cta-head">Selbst ausprobieren</div>
<p>Demo zum Nachbauen und weiterführende Links<br>
<a href="https://github.com/speijnik/talks/tree/main/cld26-k3s">github.com/speijnik/talks</a></p>
</div>
<img src="/qr-repo.svg" alt="QR-Code zum Repository" class="eos-qr" />
</div>

<div v-click class="eos-questions">Fragen?</div>

<!-- Leere Klicks als Puffer, damit ein Klick zu viel nicht zum Spickzettel springt -->
<div v-click="9" />

<!--
- Zeit: 1:00, Ziel: bei 26:45 fertig. Danach bleiben gut 3 Minuten für Fragen
- Zurück zum Ausgangspunkt: was damals selbst gestrickt wurde, ist in Kubernetes Standardverhalten
- Das eine Prinzip vom Anfang trägt alles Weitere
- Ziel war ein Überblick. Wer tiefer einsteigen will, findet alles im Repository
- Dort liegen die Folien, die Demo-App mit Manifesten und OpenTofu-Konfiguration zum Nachbauen
- Dazu Links zu allem, was hier keinen Platz hatte: Upgrades, Backup, mehr Nodes, GitOps, Alternativen
-->

---
transition: slide-up
routeAlias: spick
---

# Was eben passiert ist

```shell
curl -sfL -o /tmp/install-k3s.sh https://get.k3s.io
echo "e5cc3b3d9dfc1662c2d9be6da5abc9a4cd317d6abc3a5ffc02e3dd3248207fee  /tmp/install-k3s.sh" | sha256sum -c
sudo sh /tmp/install-k3s.sh

BASE=https://raw.githubusercontent.com/speijnik/talks/main/cld26-k3s/demo/k8s
kubectl apply -f $BASE/deployment.yaml -f $BASE/service.yaml -f $BASE/ingress.yaml
kubectl get pods -w
kubectl delete pod <name>

kubectl set image deployment/demo demo=ghcr.io/speijnik/talks/cld26-k3s-demo:v2
kubectl set image deployment/demo demo=ghcr.io/speijnik/talks/cld26-k3s-demo:v3
kubectl rollout status deployment/demo
kubectl describe pod <name>
kubectl rollout undo deployment/demo
```

<!--
- Spickzettel hinter dem Fazit, wird im Vortrag nicht angeklickt
- Erreichbar mit g und Foliennummer 14 oder über /spick, falls die Demo hakt. Die Befehle stehen auch in demo/README.md
-->
