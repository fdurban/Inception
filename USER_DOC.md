# User Documentation (USER_DOC.md)

This document provides a straightforward guide for end users and administrators to operate the Inception infrastructure.

## 1. Services Provided by the Stack
This infrastructure provides a fully functional, containerized WordPress ecosystem consisting of three isolated components:
- **Web Server (NGINX):** The secure entry point (HTTPS only) that handles incoming requests.
- **Application Logic (WordPress via PHP-FPM):** The CMS engine that renders the website.
- **Database (MariaDB):** The backend storage that securely holds all website content, user data, and configurations.


## 2. Start and Stop the Project
The entire infrastructure is automated via a `Makefile`. Open your terminal in the project root and run the following commands:


- **To start the project:**
```bash
make
