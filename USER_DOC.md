# User Documentation (USER_DOC.md)

Guide for end users and administrators of the Inception infrastructure.

## 1. Services Provided by the Stack

- **NGINX** — the only exposed service, on port 443 (HTTPS only, TLS).
- **WordPress (PHP-FPM)** — the CMS engine, not directly reachable from outside.
- **MariaDB** — the database backend, not directly reachable from outside.

All three run on an internal Docker network; only NGINX's port 443 is published to the host.

## 2. Starting and Stopping the Project

Start:
```bash
make
```

Stop (containers removed, data preserved):
```bash
make down
```

Full reset (⚠️ deletes all stored website and database data):
```bash
make fclean
```
This will ask for your `sudo` password.

## 3. Accessing the Website and the Admin Panel

- **Website:** `https://fdurban-.42.fr`
- **Admin panel:** `https://fdurban-.42.fr/wp-admin`

The TLS certificate is self-signed, so your browser will show a warning the first time you connect — that's expected, not an error. Accept the exception to proceed.

## 4. Locating Credentials

Passwords are stored as plain-text files under `secrets/` at the project root, with restricted permissions:

- `secrets/wp_admin_password.txt` — WordPress administrator password.
- `secrets/wp_user_password.txt` — WordPress standard user password.
- `secrets/db_password.txt` — database user password.
- `secrets/db_root_password.txt` — MariaDB root password.

The admin username itself (configured in `srcs/.env` as `WORDPRESS_ADMIN_USER`) cannot contain "admin" as part of the project's rules.

To view a password locally:
```bash
cat secrets/wp_admin_password.txt
```

## 5. Checking That Services Are Running Correctly

```bash
docker compose -f srcs/docker-compose.yml ps
```
You should see `mariadb`, `wordpress`, and `nginx` all `Up`.

Test the site directly:
```bash
curl -k https://fdurban-.42.fr
```
(`-k` skips certificate verification, since it's self-signed.)

If a service isn't behaving, check its logs:
```bash
docker compose -f srcs/docker-compose.yml logs -f <service_name>
```
