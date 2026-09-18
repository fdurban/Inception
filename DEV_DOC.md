#### Documento 2: `DEV_DOC.md`
```markdown
# Developer Documentation (DEV_DOC.md)


This document provides technical instructions for developers to set up, build, and manage the Inception infrastructure at a lower level.
## 1. Environment Setup (Prerequisites, Configs, Secrets)
Before orchestration, the local environment must be prepared:
- **Prerequisites:** Docker and Docker Compose must be installed on the Debian Virtual Machine.
- **Volumes Configuration:** The physical host directories for persistent data must exist. Ensure you create `/home/fdurban/data/mariadb` and `/home/fdurban/data/wordpress` (or allow the Makefile to create them).
- **Domain Resolution:** If applicable, map the domain `fdurban.42.fr` to `127.0.0.1` in the `/etc/hosts` file.
- **Secrets Architecture:** The `docker-compose.yml` uses Docker Secrets via Bind Mounts to inject passwords securely into the containers' `tmpfs` RAM at `/run/secrets/`. You must create a `secrets/` directory at the project root containing the four `.txt` password files.
- **Security:** Ensure host-level protection by running `chmod 400` on the secret files before deployment.


## 2. Build and Launch (Makefile & Docker Compose)
The project utilizes a `Makefile` to wrap `docker compose` commands, preventing execution errors. The orchestration is defined in `srcs/docker-compose.yml`.


- **Build and Launch:**
```bash
make
