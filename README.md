# Multi-Stack Deployment Lab

A hands-on DevOps lab deploying three application stacks (Python, Node.js, Java)
across three web/app servers (Apache, Tomcat, Nginx) on a single Ubuntu host,
with Nginx configured as an advanced reverse-proxy gateway in front of everything.

## Architecture

| Stack  | App                    | Runs as              | Internal port | Fronted by |
|--------|------------------------|-----------------------|----------------|------------|
| Python | Flask (Gunicorn)       | `pyapp.service`       | `127.0.0.1:5000` | **Apache** (reverse proxy, `:8081`) |
| Java   | Servlet/JSP (WAR)      | Tomcat (native)       | `127.0.0.1:8080` | **Tomcat** (serves directly) |
| Node   | Express                | `nodeapp.service`     | `127.0.0.1:3000` | **Nginx** (reverse proxy, `:80`/`:443`) |

Nginx is the single public entry point. Besides fronting the Node app, it also
proxies to Apache (`8081`) and Tomcat (`8080`) as upstream backends -- which is
what makes the advanced Nginx tasks (virtual hosting, domain config, SSL,
context/URL routing) able to route to all three stacks from one gateway.

```
                        +------------+
   client -- :80/:443 ->|   Nginx    |--> Node app (127.0.0.1:3000)
                        |  (gateway) |--> Apache :8081 --> Python app (127.0.0.1:5000)
                        +------------+--> Tomcat :8080 --> Java app (WAR)
```

## Repository structure

```
multi-stack-deployment-lab/
├── python-app/            Flask source, requirements.txt, systemd unit
├── node-app/               Express source, package.json, systemd unit
├── java-app/                Maven WAR project (pom.xml, servlet, JSP)
├── apache-config/          Apache vhost (reverse proxy to Python)
├── tomcat-config/          Tomcat systemd unit
├── nginx-config/            All 5 advanced Nginx configs (see below)
├── scripts/                 Ordered install/deploy/verify scripts
├── .gitignore
└── README.md
```

## Prerequisites

- Ubuntu (tested on 24.x/25.x style releases; adjust package names if your
  version differs)
- A user with `sudo` access
- Outbound internet access (apt, npm, Maven Central, Apache download mirrors)

## Deployment

Clone the repo to the server and run the scripts **in order**:

```bash
git clone <your-repo-url> /opt/multi-stack-deployment-lab
cd /opt/multi-stack-deployment-lab

sudo ./scripts/01-install-servers.sh      # Apache, Nginx, Java+Tomcat, Python, Node
sudo ./scripts/02-deploy-python.sh        # venv + gunicorn + Apache reverse proxy
sudo ./scripts/03-deploy-java.sh          # mvn package + deploy WAR to Tomcat
sudo ./scripts/04-deploy-node.sh          # npm install + systemd service
sudo ./scripts/05-deploy-nginx-configs.sh # copies all nginx-config/*.conf, adds /etc/hosts entries
sudo ./scripts/06-setup-ssl.sh            # self-signed cert for app.lab.local

./scripts/verify.sh                       # sanity-checks every piece above
```

`01-install-servers.sh` installs each server in its own isolated section -- if
one section fails, it's reported at the end without blocking the rest, so it's
safe to fix an issue and re-run.

Tomcat's exact version is **auto-detected** at install time from
`downloads.apache.org` rather than hardcoded, since Apache only keeps the
current release on the main mirror and retires older point releases within
weeks.

## Tasks performed

**Stack deployment**
- [x] Python app deployed (Flask via Gunicorn)
- [x] Node.js app deployed (Express)
- [x] Java app deployed (Servlet/JSP WAR)

**Server deployment**
- [x] One app served by Apache (Python, via `mod_proxy` reverse proxy)
- [x] One app served by Tomcat (Java, native WAR deployment)
- [x] One app served by Nginx (Node, via reverse proxy)

**Nginx advanced configuration** (all in `nginx-config/`)
- [x] Reverse proxy + forward proxy -- `reverse-and-forward-proxy.conf`
- [x] Virtual hosting -- `vhosts.conf` (`python.lab.local`, `java.lab.local`, `node.lab.local`)
- [x] Domain configuration -- `domain.conf` (`app.lab.local`)
- [x] SSL certificate -- `ssl.conf` + `scripts/06-setup-ssl.sh` (self-signed; swap in Certbot for a real domain)
- [x] Context-based and URL/subdomain-based routing -- `context-routing.conf`

## Verification

```bash
systemctl status apache2 tomcat nginx pyapp nodeapp

curl http://localhost:8081/                          # Python via Apache
curl http://localhost:8080/javaapp/                  # Java via Tomcat
curl http://localhost/                               # Node via Nginx
curl -x http://localhost:8888 http://example.com      # Nginx forward proxy
curl -H "Host: python.lab.local" http://localhost/    # virtual hosting
curl http://app.lab.local/                            # domain config
curl -k https://app.lab.local/                        # SSL
curl http://localhost:8090/python/                    # context-based routing
```

Or just run `./scripts/verify.sh`, which checks all of the above in one pass.

## Notes and gotchas

- **Local domains** (`*.lab.local`) are added to `/etc/hosts` by
  `05-deploy-nginx-configs.sh` since there's no real public DNS in this lab.
  On a real deployment, replace these with actual DNS records and use Certbot
  instead of the self-signed cert.
- **Port ownership**: Apache is moved to `8081` and Tomcat stays on its
  default `8080` so Nginx can own `80`/`443` as the single public gateway.
- **One process per app**: if you're re-running scripts after earlier manual
  testing, check `systemctl list-units --type=service --state=running` for
  duplicate/leftover services bound to the same ports (a common issue when
  iterating on a lab environment) before assuming a script failed.
- `sudo nginx -t` and `sudo apache2ctl configtest` are safe to run any time
  before a reload, to catch config errors early.
