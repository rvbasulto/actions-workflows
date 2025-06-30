# DevOps Portfolio Deployment

This repository demonstrates a complete DevOps pipeline for deploying a containerized Next.js application using modern tools and practices. The application is built and maintained separately, and the deployment process is fully automated using GitHub Actions, Docker, and Ansible on a VPS hosted at Hetzner.

---

## 📊 Architecture Overview

```
+---------------------------+       GitHub Actions       +----------------------+
|  Application Repository  | -------------------------> |  Central Deploy Repo |
| (Next.js + Dockerfile)   |  trigger via dispatch API  |  (CI/CD workflow)    |
+---------------------------+                            +----------------------+
                                                            |
                                                            | SSH
                                                            v
                                                     +------------+
                                                     |   VPS @    |
                                                     |  Hetzner   |
                                                     +------------+
                                                          |
                                                          | Docker + NGINX
                                                          v
                                              [ Containerized Next.js App ]
```

---

## 🚀 What This Project Covers

* Containerization of a Next.js application using Docker
* CI/CD automation using GitHub Actions and `repository_dispatch`
* Secure centralized deployment flow
* VPS provisioning with Ansible (Docker + NGINX)
* Domain name configuration and HTTPS via Certbot

---

## 🔨 Tools Used

* **Next.js**: Frontend framework
* **Docker**: Containerize the app for consistent deployments
* **GitHub Actions**: CI/CD workflow for building and deploying
* **Ansible**: Provision Docker and NGINX on the VPS
* **NGINX**: Reverse proxy to expose the Next.js container
* **Hetzner VPS**: Production environment
* **Certbot**: Free SSL certificates

---

## 🛠️ How It Works

1. Code changes are pushed to the `main` branch of the app repo.
2. A GitHub Actions workflow sends a `repository_dispatch` event to the central `actions-workflows` repository.
3. The central repo listens for `deploy-app` events.
4. It clones the app code, builds a Docker image, pushes it to Docker Hub.
5. It connects to the VPS over SSH and runs the container.
6. NGINX proxies requests from the domain to the app.

---

## 🔑 Secrets and Security

Secrets are **not stored in the app repo**. Only the central deployment repository manages:

* `GH_PAT`: GitHub token to clone private repos
* `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`
* `SSH_KEY`, `SSH_USER`, `HOST`

The app repo only stores a token `PAT_ACTIONS_WORKFLOWS` to call the deployment API.

---

## 🚫 Why This Matters

This structure:

* Keeps the deployment logic centralized
* Is secure and scalable for multiple apps
* Mirrors real-world DevOps pipelines used in industry