# Developer Documentation (DEV_DOC.md)

Technical guide to set up, build, and manage the Inception infrastructure.

## 1. Prerequisites

- Docker and Docker Compose installed.
- `sudo` privileges on the host (required for `make fclean`).
- Write access to `/home/<login>/` on the host.
- The project assumes your 42 login in the data path and the domain. Replace `fdurban-` with your own if different.

## 2. Initial Configuration

### 2.1 `.env` file
The compose file lives at `srcs/docker-compose.yml` and is invoked via `docker compose -f ./srcs/docker-compose.yml`, without `--project-directory`. Compose resolves relative paths (like `env_file: .env`) **relative to the directory containing the compose file**, not the repo root.

➡️ The `.env` file must be placed at `srcs/.env`, not at the repository root.


It defines *names and configuration* only — never passwords.

### 2.2 Secrets
Passwords live in `secrets/` **at the repository root** (the compose file references them as `../secrets/...`, one level up from `srcs/`):
```bash
secrets/
├── db_root_password.txt
├── db_password.txt
├── wp_admin_password.txt
└── wp_user_password.txt
```
Rules:
- Each file contains only the password, no trailing newline.
- Restrict permissions before deploying:
```bash
  chmod 400 secrets/*
```
- Never committed; listed in `.gitignore` along with `srcs/.env`.

Inside the containers, secrets are mounted at `/run/secrets/<name>` (the source name, since no `target:` is set):
- `mariadb`: `/run/secrets/db_root_password`, `/run/secrets/db_password`
- `wordpress`: `/run/secrets/db_password`, `/run/secrets/wp_admin_password`, `/run/secrets/wp_user_password`

### 2.3 Domain resolution

127.0.0.1 fdurban-.42.fr

in the host's `/etc/hosts`.

### 2.4 Data directories
The `dirs` target creates them automatically before build:
```make
dirs:
	@mkdir -p $(DATA_PATH)/mariadb
	@mkdir -p $(DATA_PATH)/wordpress
```
No manual creation needed. `DATA_PATH = /home/fdurban-/data` — adjust in the `Makefile` if your login differs.

## 3. Build and Launch

```bash
make          # same as `make all` → runs `dirs`, then builds and starts (docker compose up -d --build)
```

Stop, keep containers' data (host directories untouched, nothing removed):
```bash
make down     # docker compose down
```

Remove containers, images, anonymous/named volume references, and orphan containers — **host data is preserved**, because the volumes are bind-backed via `driver_opts` and Docker doesn't own that storage:
```bash
make clean    # docker compose down -v --rmi all --remove-orphans
```

Full teardown — **destroys the physical data on the host** and runs a **system-wide** Docker prune (affects other projects on the same machine, not just this one):
```bash
make fclean   # runs `clean`, then: sudo rm -rf /home/fdurban-/data
              # then: docker system prune -af --volumes (⚠️ global, not scoped to this project)
```

Rebuild from scratch:
```bash
make re       # fclean + all
```

## 4. Container and Volume Management

Check status:
```bash
docker compose -f srcs/docker-compose.yml ps
```

Follow logs for a service:
```bash
docker compose -f srcs/docker-compose.yml logs -f nginx
docker compose -f srcs/docker-compose.yml logs -f wordpress
docker compose -f srcs/docker-compose.yml logs -f mariadb
```

Enter a container (container names are set explicitly in the compose file):
```bash
docker exec -it mariadb /bin/sh
docker exec -it wordpress /bin/sh
docker exec -it nginx /bin/sh
```

Inspect a container's network, mounts, and config:
```bash
docker inspect <container_name>
```

List volumes and check where they actually point on the host:
```bash
docker volume ls
docker volume inspect srcs_mariadb_data   # confirm exact name with `docker volume ls` first
```

Inspect the network (its exact name depends on the Compose project name — by default the `srcs` directory name, so likely `srcs_inception`; confirm rather than assume):
```bash
docker network ls
docker network inspect <network_name>
```

## 5. Data Persistence

Data does **not** live inside the containers. It's stored via named Docker volumes (`mariadb_data`, `wordpress_data`) configured with the `local` driver and `driver_opts` pointing at a fixed host path — functionally similar to a bind mount, but registered as a Docker volume:

| Service | Docker volume | Host path (`device`) | Container path |
|---|---|---|---|
| MariaDB | `mariadb_data` | `/home/fdurban-/data/mariadb` | `/var/lib/mysql` |
| WordPress | `wordpress_data` | `/home/fdurban-/data/wordpress` | `/var/www/html` |

`wordpress_data` is mounted on **both** `wordpress` and `nginx`, which is how NGINX can serve the PHP/static files WordPress writes.

Because the volume's backing storage is an explicit host path, destroying and recreating the containers (`make down` then `make` again) leaves the data intact. Only `make fclean` (which physically `rm -rf`s the host directory) actually destroys it.


