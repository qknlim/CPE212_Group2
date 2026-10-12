# CPE212_Group2

This repository contains the final project of Group 2 for **CPE212: Automating Server Management**.

It includes a static portfolio web app, a Dockerfile that packages it, and Ansible playbooks that install Docker, build the image and run the container on one CentOS VM and two Ubuntu VMs.

## Members

| # | Name | GitHub |
|---|------|--------|
| 1 | Member One | [CPE212_surname1](https://github.com/your-username/CPE212_surname1) |
| 2 | Member Two | [CPE212_surname2](https://github.com/your-username/CPE212_surname2) |
| 3 | Member Three | [CPE212_surname3](https://github.com/your-username/CPE212_surname3) |
| 4 | Member Four | [CPE212_surname4](https://github.com/your-username/CPE212_surname4) |

## What the Web App Contains

A landing page lists all four members. Each member has their own portfolio page with:

- Prelim HOA, Midterm HOA, Finals HOA
- Prelim Exam, Midterm Exam, Final Exam
- Reflection and Learnings

All HOAs and exams are PDF files linked from the member's page.

## Technologies

| Layer | Technology |
|-------|------------|
| Web app | HTML5, CSS3, JavaScript |
| Web server | Nginx (`nginx:alpine`) |
| Containerization | Docker |
| Automation | Ansible (YAML), `community.docker` collection |
| Version control | Git and GitHub |

## Project Structure

```
CPE212_Group2/
|-- README.md
|-- Dockerfile
|-- .dockerignore
|-- webapp/
|   |-- index.html
|   |-- styles.css
|   `-- members/
|       |-- surname1/   (index.html, photo.jpg, pdf/)
|       |-- surname2/
|       |-- surname3/
|       `-- surname4/
|-- ansible/
|   |-- ansible.cfg
|   |-- inventory.ini
|   |-- install_docker.yml
|   |-- build_image.yml
|   `-- run_container.yml
`-- docs/
    `-- screenshots/
```

## Infrastructure

| Machine | OS | Role |
|---------|----|------|
| Control node | Linux (Ubuntu or WSL2) | Runs Ansible |
| VM 1 | CentOS | Managed node |
| VM 2 | Ubuntu | Managed node |
| VM 3 | Ubuntu | Managed node |

## Requirements

On the control node:

- Ansible
- The `community.docker` collection
- SSH key-based access to every VM, using a user with `sudo`

On each VM:

- SSH and Python 3

Docker itself is installed by the playbooks.

## How to Run

**1. Clone the repository**

```bash
git clone https://github.com/your-username/CPE212_Group2.git
cd CPE212_Group2/ansible
```

**2. Install the Ansible collection**

```bash
ansible-galaxy collection install community.docker
```

**3. Edit `inventory.ini`** with the IP addresses and user of your VMs, then test the connection:

```bash
ansible all -i inventory.ini -m ping
```

**4. Install Docker on all VMs**

```bash
ansible-playbook -i inventory.ini install_docker.yml
```

**5. Build the Docker image on all VMs**

```bash
ansible-playbook -i inventory.ini build_image.yml
```

**6. Run the container on all VMs**

```bash
ansible-playbook -i inventory.ini run_container.yml
```

**7. Verify**

```bash
ansible all -i inventory.ini -b -a "docker ps"
```

Then open `http://<vm-ip>:8080` in a browser for each VM.

## Run the Web App Locally (Without Docker)

Open the `webapp/` folder in VS Code and run `index.html` with the Live Server extension.

## Run with Docker Only (One Machine)

```bash
docker build -t cpe212-portfolio .
docker run -d -p 8080:80 --name portfolio cpe212-portfolio
```

Then open `http://localhost:8080`.

## Playbooks

| Playbook | Purpose |
|----------|---------|
| `install_docker.yml` | Installs and starts Docker on CentOS (`dnf`) and Ubuntu (`apt`) |
| `build_image.yml` | Copies the Dockerfile and web app to each VM and builds the image |
| `run_container.yml` | Starts the container on each VM, mapping port 8080 to 80 |

All playbooks are idempotent, so running them again does not break anything.

## Notes

- The project runs on localhost and the local VM network only. It is not deployed to the internet.
- The web app is designed for desktop browsers only.
- File and folder names are case-sensitive on Linux, so keep them lowercase.
