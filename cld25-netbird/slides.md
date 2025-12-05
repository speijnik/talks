---
theme: seriph
layout: cover
addons:
    - excalidraw
title: NetBird - moderne FOSS VPN Lösung für Zuhause und im Unternehmen
info: |
  ## NetBird

  NetBird ist eine FOSS Zero-Trust VPN Lösung die auf WireGuard basiert und bei der alle Komponenten frei verfügbar sind. Der Vortrag zeigt den Unterschied zu klassischen VPN Lösungen und beleuchtet die Vorteile gegenüber verschiedener Alternativen.

  <a href="https://github.com/speijnik/talks/tree/main/cld25-netbird" target="_blank" class="slidev-icon-btn">
    <carbon:logo-github />
  </a>
class: text-center
drawings:
  persist: false
transition: slide-up
mdc: true
duration: 30min
---

# NetBird

Moderne FOSS VPN Lösung für Zuhause und im Unternehmen

## Carinthian Linux Day 2025

---
transition: slide-up
layout: intro
---

# Stephan Peijnik-Steinwender

Chief Solution Architect bei <a href="https://eoscloud.io">eos</a> einem <a href="https://anexia.com">Anexia</a> Unternehmen

- <uil-linux /> GNU/Linux und FOSS seit 2000
- <uil-server-connection /> Anexia seit 2010
- <uil-cloud-computing /> eos seit 2025

---
transition: slide-up
---

# Was ist ein VPN?

<Excalidraw
  drawFilePath="./vpn_concept.excalidraw"
  class="w-[400px]"
  :darkMode="false"
  :background="false"
/>

<!--
- VPN: Virtual Private Network
- Virtuelles Netzwerk zwischen zwei Punkten dass durch ein öffentliches Netzwerk (das Internet) transportiert wird.
- Verschlüsselt, damit der Netzwerkverkehr auch wirklich privat bleibt
-->

---
transition: slide-up
---

# Wozu ein VPN nutzen?

- 🔐 Sicherer Fernzugriff auf Ressourcen in privaten Netzwerken
- 🔐 Absichern von Netzwerkverkehr in nicht vertrauenswürdigen Netzwerken

<!--
- Fernzugriff: NAS daheim, Server im Unternehmen
- Absichern: zB. öffentliches (Hotel) WLAN
-->

---
transition: slide-up
---

# VPN klassisch - Architektur

<Excalidraw
  drawFilePath="./vpn_server.excalidraw"
  class="w-[400px]"
  :darkMode="false"
  :background="false"
/>

<!--
- VPN klassich mit einem zentralen Server als Vermittlungsstelle
- Gesamter Datenverkehr wird durch das Internet über Server geleitet
-->

---
transition: slide-up
---

# VPN klassisch - Vor- und Nachteile

## Vorteile

- Zentrale Verwaltung

## Nachteile

- Zentraler Server als Single-Point-Of-Failure
- Performance - der gesamte Datenverkehr muss durch den Server
- Je nach Protokoll hohe Komplexität (IPSec) oder unzeitgemäße Verschlüsselung (PPTP)

---
transition: slide-up
---

# WireGuard - Architektur

<Excalidraw
  drawFilePath="./vpn_wireguard.excalidraw"
  class="w-[400px]"
  :darkMode="false"
  :background="false"
/>

<!--
- VPN WireGuard als Mesh umgesetzt - jeder redet mit jedem
-->

---
transition: slide-up
---

# WireGuard - Vor- und Nachteile

## Vorteile

- Hohe Performance durch direkte Kommunikation
- Keine Abhängigkeit auf zentrale Stelle

## Nachteile

- Nodes müssen öffentlich erreichbar sein (NAT/Firewall)
- Konfiguration aufwändig - jede Node muss Konfiguration für jede anderen Node beinhalten

---
transition: slide-up
---

# NetBird - Architektur

<Excalidraw
  drawFilePath="./vpn_netbird.excalidraw"
  class="w-[400px]"
  :darkMode="false"
  :background="false"
/>

<!--
- VPN NetBird wie bei WireGuard als Mesh umgesetzt - jeder redet mit jedem
- zentraler Management-Server steuert Zugriffe und macht Nodes miteinander bekannt
-->

---
transition: slide-up
---

# NetBird - Vor- und Nachteile

## Vorteile

- Zentrale Verwaltung
- Hohe Performance durch direkte Kommunikation
- Keine Abhängigkeit auf zentrale Stelle für Netzwerkverkehr
- Nodes können NAT mittels STUN/TURN überwinden

## Nachteile

- Komplexerer Aufbau

---
transition: slide-up
---

# NetBird - Funktionen

- Zentrale Verwaltung in Web-Interface und per API
  - Benutzern
  - Nodes
  - Policies
- Zero-Trust Ansatz
- DNS Namen für jeden Client (`netbird.cloud` oder eigene Domain) 
- Nodes können direkt verbundene Netzwerke anderen Nodes verfügbar machen
- SSO mit OIDC, Google, GitHub, Microsoft Account und Okta
- Feingranulare Zugriffssteuerung über Gruppenmitgliedschaft

---
transition: slide-up
layout: image
image: screenshot_netbird_peers.png
backgroundSize: 50em 70%
---

# NetBird - Web Interface

---
transition: slide-up
---

# NetBird - Im Unternehmen (Beispiel)

## Ausgangslage

- Zentrale Infrastruktur: ArgoCD in Kubernetes
- Steuerung mehrere Kubernetes Cluster in entfernen Netzen
- Wie erreicht die ArgoCD die entfernten Kubernetes Cluster?

---
transition: slide-up
---

# NetBird - Im Unternehmen (Beispiel)

## Klassischer Ansatz

- a.) Site-To-Site VPN auf Netzwerk-Ebene der zentralen Kubernetes Hosts
  - Alle anderen Komponenten im selben Netzwerk erreichen die entfernten Cluster ebenfalls
- b.) VPN Clients auf Kubernetes Hosts 
  - Alle anderen Komponenten auf den selben Hosts erreichen die entfernten Cluster ebenfalls

---
transition: slide-up
---

# NetBird - Im Unternehmen (Beispiel)

## NetBird Ansatz

- Sidecar Container auf den ArgoCD Server Pods
- Setup Key der Sidecars in Gruppe "k8s-access" hebt
- NetBird Instanzen in entferntem Netz in der Gruppe
- Network mit einer Ressource für die entfernten Hosts in "k8s-hosts" Gruppe
- Policy "k8s-control-plane-access" die Zugriff steuert
  - Quelle: k8s-access
  - Ziel: k8s-hosts
  - Ziel-Port: 6443 (TCP)

---
transition: slide-up
---

# NetBird - Im Unternehmen (Beispiel)

## NetBird Ansatz - Vorteile

- Zugriff wird nur dort gewährt wo unbedingt notwendig
- Policy schränkt Zugriff auf Ziel, Protokoll und Port ein
- Policy "k8s-control-plane-access" kann für Administratoren wiederverwendet werden 

---
transition: slide-up
---

# NetBird - Varianten

## Cloud Service - netbird.io
  - Gratis bis zu 5 User und 100 Clients

## Self-Hosted - eigene Infrastruktur
  - Selber Funktionsumfang wie Cloud Service
  - Alle Komponenten FOSS
  - Einfache Einrichtung mit Setup-Script & Docker
  - Kubernetes Deployment mittels Helm Chart im Unternehmen

```shell
curl -sSLO https://github.com/netbirdio/netbird/releases/latest/download/getting-started-with-zitadel.sh
# check the script
cat getting-started-with-zitadel.sh
# run the script
export NETBIRD_DOMAIN=netbird.example.com
bash getting-started-with-zitadel.sh
```

---
transition: slide-up
layout: end
---

# Fragen?