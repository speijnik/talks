# Demo: Single-Node-Cluster mit k3s

Material zur Demo aus dem Vortrag. Alles hier lässt sich nachbauen.

* `app/`: kleine Web-App (Flask und Gunicorn), die Hostname und Version anzeigt. Die Seite fragt laufend
  `/info` ab, dadurch werden Pod-Wechsel, Updates und Ausfälle im Browser sichtbar.
* `compose.yml`: dieselbe App mit docker compose und Traefik, zum Vergleich
* `k8s/`: Deployment, Service und Ingress
* `terraform/`: VM auf [netcup eos](https://docs.eoscloud.io/products/howtos/terraform-provider-eoscloud-installation/)
  mit Netzwerk, ACL (22, 80 und Ping) und öffentlicher IP. Geschrieben für [OpenTofu](https://opentofu.org/),
  läuft unverändert auch mit Terraform

## Images

`ghcr.io/speijnik/talks/cld26-k3s-demo` in drei Versionen, gebaut vom Workflow
`.github/workflows/cld26-k3s-demo.yml`:

| Tag | Verhalten |
|---|---|
| `v1` | funktioniert |
| `v2` | funktioniert |
| `v3` | absichtlich kaputt: `/readyz` liefert 503, der Pod wird nie bereit |

Lokal bauen, für amd64 und arm64:

```shell
docker buildx build --platform linux/amd64,linux/arm64 \
  --build-arg VERSION=v3 --build-arg BROKEN=true -t demo:v3 app/
```

Ohne Container, direkt mit Python:

```shell
cd app
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
APP_VERSION=v1 .venv/bin/flask run --port 8080
```

## Ablauf

Ohne netcup eos geht es genauso: jede Debian- oder Ubuntu-Maschine mit mindestens
2 GB RAM und erreichbarem Port 80 reicht, auch ein Raspberry Pi. Dann den ersten
Block überspringen, curl installieren und bei „k3s installieren" beginnen.

```shell
# VM erzeugen (Zugangsdaten über EOS_CLIENT_ID und EOS_CLIENT_SECRET)
cd terraform
cp terraform.tfvars.example terraform.tfvars   # SSH-Schlüssel eintragen
tofu init
tofu apply

# k3s installieren
ssh deploy@<public_ip>
curl -sfL -o /tmp/install-k3s.sh https://get.k3s.io
less /tmp/install-k3s.sh
sudo sh /tmp/install-k3s.sh

# kubectl ohne sudo: Kopie der kubeconfig nur für den eigenen Benutzer
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown "$(id -u):$(id -g)" ~/.kube/config
chmod 600 ~/.kube/config
export KUBECONFIG=~/.kube/config

# App deployen, direkt aus dem Repository
BASE=https://raw.githubusercontent.com/speijnik/talks/main/cld26-k3s/demo/k8s
kubectl apply -f $BASE/deployment.yaml -f $BASE/service.yaml -f $BASE/ingress.yaml
kubectl get pods -w

# Browser: http://<public_ip>/

# Pod töten, er wird ersetzt
kubectl delete pod <name>

# Update ohne Ausfall
kubectl set image deployment/demo demo=ghcr.io/speijnik/talks/cld26-k3s-demo:v2
kubectl rollout status deployment/demo

# Kaputtes Update: Rollout bleibt stehen, v2 liefert weiter aus
kubectl set image deployment/demo demo=ghcr.io/speijnik/talks/cld26-k3s-demo:v3
kubectl get pods
kubectl describe pod <name des neuen Pods>   # unter Events: Readiness probe failed

# Rollback
kubectl rollout undo deployment/demo

# Aufräumen
tofu destroy
```
