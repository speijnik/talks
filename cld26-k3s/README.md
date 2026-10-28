# Einfacher als gedacht: Kubernetes mit k3s auch für kleine Umgebungen

Vortrag am Kärntner Linuxtag 2026.

* Demo-App, Manifeste und VM-Konfiguration zum Nachbauen: [demo](./demo)
* Folien lokal ansehen: `pnpm install`, dann `pnpm dev` und <http://localhost:3030>

## Weiterführend

### Grundlagen

* [Kubernetes: Konzepte](https://kubernetes.io/docs/concepts/)
* [Controller](https://kubernetes.io/docs/concepts/architecture/controller/)
* [Operator Pattern](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/)
* [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
* [Pod-Lebenszyklus und Neustarts](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/)
* [Liveness, Readiness und Startup Probes](https://kubernetes.io/docs/concepts/configuration/liveness-readiness-startup-probes/)
* [CronJobs](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)
* [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)

### k3s

* [Dokumentation](https://docs.k3s.io/)
* [Anforderungen an die Maschine](https://docs.k3s.io/installation/requirements)
* [Mitgelieferte Komponenten und Auto-Deploy-Manifeste](https://docs.k3s.io/installation/packaged-components)
* [Netzwerk: ServiceLB, Traefik, CoreDNS](https://docs.k3s.io/networking/networking-services)
* [Storage: local-path und Longhorn](https://docs.k3s.io/add-ons/storage)
* [Zugriff mit kubectl und kubeconfig](https://docs.k3s.io/cluster-access)
* [Härtung](https://docs.k3s.io/security/hardening-guide)
* [k3s als CNCF-Projekt](https://www.cncf.io/projects/k3s/)

### Betrieb

* [k3s manuell aktualisieren](https://docs.k3s.io/upgrades/manual)
* [k3s automatisch aktualisieren](https://docs.k3s.io/upgrades/automated) mit dem
  [system-upgrade-controller](https://github.com/rancher/system-upgrade-controller)
* [k3s stoppen: was mit laufenden Containern passiert](https://docs.k3s.io/upgrades/killall)
* [Backup und Restore der Cluster-Datenbank](https://docs.k3s.io/datastore/backup-restore)
* [Velero: Backup von Ressourcen und Volumes](https://velero.io/docs/)
* [Fehlersuche bei Pods](https://kubernetes.io/docs/tasks/debug/debug-application/debug-pods/)
* [Kubernetes-Releases und Support-Zeiträume](https://kubernetes.io/releases/)

### Mehr als ein Node

* [Weitere Nodes hinzufügen](https://docs.k3s.io/quick-start)
* [Hochverfügbarkeit mit embedded etcd](https://docs.k3s.io/datastore/ha-embedded)
* [Longhorn: replizierter Storage](https://longhorn.io/docs/)

### Von compose kommend

* [Docker: Restart-Policies](https://docs.docker.com/engine/containers/start-containers-automatically/)
* [docker rollout](https://github.com/wowu/docker-rollout)
* [Kompose: compose-Dateien in Manifeste übersetzen](https://kompose.io/)

### Anwendungen und Konfiguration

* [Helm](https://helm.sh/docs/)
* [Helm installieren](https://helm.sh/docs/intro/install/)
* [Nextcloud Helm Chart](https://github.com/nextcloud/helm)
* [Kustomize](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/)

### Zugriff von außen und TLS

* [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
* [Gateway API](https://gateway-api.sigs.k8s.io/)
* [Ende von ingress-nginx](https://kubernetes.io/blog/2025/11/11/ingress-nginx-retirement/)
* [Traefik](https://doc.traefik.io/traefik/)
* [cert-manager](https://cert-manager.io/docs/)

### GitOps und automatische Updates

* [Flux](https://fluxcd.io/flux/)
* [Argo CD](https://argo-cd.readthedocs.io/)
* [Renovate](https://docs.renovatebot.com/)

### Werkzeuge

* [k9s](https://k9scli.io/)
* [OpenTofu](https://opentofu.org/)
* [Migration von Terraform zu OpenTofu](https://opentofu.org/docs/intro/migration/)

### Alternativen zu k3s

* [k0s](https://docs.k0sproject.io/)
* [MicroK8s](https://microk8s.io/docs)
* [Talos Linux](https://www.talos.dev/)
* [kind](https://kind.sigs.k8s.io/)
