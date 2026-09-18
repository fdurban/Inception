
*This project has been created as part of the 42 curriculum by fdurban-*

# Inception
#Description

The goal of this project is to broaden the understanding of system administration by deploying a standardized, secure, and isolated infrastructure using Docker. It serves as an introduction to Infrastructure as Code (IaC) and microservices architecture.

**Sources Included:**
The infrastructure is built entirely from scratch using `alpine:3.23` as the base image for all containers to ensure a minimal attack surface. The orchestrated services are:
1. **NGINX:** Operating as a Reverse Proxy and the sole entry point (TLSv1.2/1.3 on port 443).
2. **WordPress (PHP-FPM):** The application layer handling dynamic content generation.
3. **MariaDB:** The persistence layer handling the relational database.

### Main Design Choices
- **Principle of Least Privilege (PoLP):** Processes and file ownership (like PHP-FPM workers) are strictly restricted to the `nobody:nobody` user to prevent privilege escalation or container escapes.
- **Custom Initialization:** We utilize custom `entrypoint.sh` scripts running as PID 1 via the `exec` command to handle process lifecycle, bootstrapping, and sequential startup enforcement (e.g., WordPress waiting for MariaDB to be fully ready).

### Architectural Comparisons

**Virtual Machines vs Docker**
Virtual Machines (VMs) rely on a Hypervisor to emulate hardware, requiring a full Guest Operating System for every instance. This makes them heavy and slow to boot. Docker, however, operates at the OS level (Containerization). Containers share the Host OS Kernel and only contain the application and its direct dependencies, resulting in lightning-fast startup times and minimal resource overhead.


**Secrets vs Environment Variables**
Environment variables are injected into the container's environment space, making them readable by any process within the container and visible via `docker inspect`, which poses a severe security risk. Docker Secrets, on the other hand, mount sensitive data as physical read-only files in RAM (`tmpfs` at `/run/secrets/`). By enforcing physical host permissions (e.g., `chmod 400`), we guarantee that only the root initialization process can read the database passwords, completely hiding them from runtime application processes.


**Docker Network vs Host Network**
Using the Host Network binds a container directly to the host machine's network interfaces, offering zero isolation and risking port collisions. This project uses a User-Defined Docker Bridge Network. This creates a deeply isolated subnet where containers communicate via an internal DNS (`127.0.0.11`). The outside world can only access explicitly published ports (443), while internal services like MariaDB (3306) remain invisible and completely shielded from external networks.


**Docker Volumes vs Bind Mounts**
Docker Volumes are fully managed by the Docker daemon and stored in a hidden, abstracted directory on the host. Bind Mounts, which are mandated for this project, map a specific, absolute path on the host system (e.g., `/home/fdurban/data/mariadb`) directly into the container. This approach grants the system administrator absolute physical control over the data's location, inode persistence, and host-level permissions, ensuring data survives even if the containers and Docker network are completely destroyed.


---


## Instructions


### Prerequisites
Before orchestrating the cluster, you must intercept the local DNS resolution to route the domain to your localhost.
1. Edit your host file: `sudo nano /etc/hosts`
2. Add the following line: `127.0.0.1 fdurban.42.fr`
3. Ensure the local physical data directories exist: `/home/fdurban/data/mariadb` and `/home/fdurban/data/wordpress`.


### Execution
The infrastructure is controlled via the `Makefile` located at the root of the repository.


- `make` or `make all`: Builds the Docker images from scratch and starts the containers in detached mode.
- `make down`: Stops the cluster and destroys the network, but **preserves** the physical Bind Mount data.
- `make clean`: Brings down the infrastructure and removes the local built images.
- `make fclean`: Complete teardown. Stops containers, deletes images, prunes the network, and **purges all physical data** in the host volumes.
- `make re`: Executes `fclean` followed by `all`.


---


## Resources


### Official Documentation
- [Docker Compose Specification](https://docs.docker.com/compose/)
- [NGINX FastCGI Proxying](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/)
- [Alpine Linux Package Management (apk)](https://wiki.alpinelinux.org/wiki/Alpine_Package_Keeper)
- [MariaDB Docker Implementation](https://hub.docker.com/_/mariadb)


### AI Usage
Artificial Intelligence (Gemini) was utilized exclusively as a Socratic architectural mentor and security auditor.
- **Tasks:** It was used to simulate a rigorous oral defense, testing knowledge on TLS handshake mechanics, FastCGI routing, Linux Namespaces, and the physics of Bind Mounts.

