# Developer Documentation (DEV_DOC.md)

This document provides technical instructions for developers to set up, build, and manage the Inception infrastructure at a lower level.

## 1. Environment Setup
Before orchestration, the local environment must be prepared:
- **Prerequisites:** Docker and Docker Compose must be installed.
- **Volumes Configuration:** Ensure the physical host directories exist at `/home/fdurban-/data/mariadb` and `/home/fdurban-/data/wordpress`.
- **Domain Resolution:** Map the domain `fdurban-.42.fr` to `127.0.0.1` in your host's `/etc/hosts` file.
- **Secrets Architecture:** Create a `secrets/` directory at the project root with the 4 required password `.txt` files. Apply strict host-level protection before deployment:
  ```bash
  chmod 400 secrets/*
  ```
## 2. Build and Launch
The orchestration is controlled via the Makefile wrapping docker compose commands.
Build images and start the cluster:
  ```bash
  make
  ```
Complete Teardown (WARNING: Destroys physical data):
  ```bash
  make fclean
  ```

## 3. Container management and debugging
  ```bash
  docker exec -it <container_name> /bin/sh
  ```
Inspect network, mounts, and low-level container properties:
  ```bash
  docker inspect <container_name>
  ```
## 4 Data Persistence
 Data is strictly decoupled from the container lifecycle using Bind Mounts.
By explicitly mapping a physical host path (device: /home/fdurban-/data/...), the container writes inodes directly to the host's disk. If the containers are destroyed, the data remains fully intact on the host OS and will be automatically reattached upon the next deployment.
