# CPE212 Group 2 – Portfolio Deployment with Ansible and Docker

A static web portfolio for each group member, packaged as a Docker image and
deployed to **1 CentOS VM and 2 Ubuntu VMs** using **Ansible**.

Each member's page contains:

- Prelim HOA, Midterm HOA, Finals HOA
- Prelim Exam, Midterm Exam, Final Exam
- Reflection and Learnings

## Group Members

| Member | Contribution |
|--------|--------------|
| `Charles Vence Espinas` | `<e.g. Web app>` |
| `Damien Jake Gestiada` | `<e.g. Ansible roles>` |
| `Kenzo Lim` | `<e.g. Dockerfile>` |
| `Angelo Quioyo` | `<e.g. Documentation and testing>` |

## How It Works

```
install_docker.yml  ->  build_image.yml  ->  run_container.yml
 (install Docker)       (build the image)     (run the container)
```

1. **Install Docker** on every VM (`dnf` on CentOS, `apt` on Ubuntu).
2. **Build the image** on every VM. Ansible copies the `Dockerfile` and `webapp/`
   to the VM, then builds `cpe212-group2-portfolio:latest` there.
3. **Run the container** on every VM, mapping port `8080` on the VM to port `80`
   in the container, then check that the site answers.

The site is then available at `http://<vm-ip>:8080` on each VM.

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
`-- ansible/
    |-- ansible.cfg
    |-- inventory.yaml
    |-- requirements.yml
    |-- site.yml
    |-- install_docker.yml
    |-- build_image.yml
    |-- run_container.yml
    |-- group_vars/
    |   `-- all.yml
    `-- roles/
        |-- docker_install/   (tasks: main, redhat, debian)
        |-- docker_build/
        `-- docker_run/
```

### Ansible roles

| Role | What it does |
|------|--------------|
| `docker_install` | Installs Docker Engine and the Python Docker SDK. Picks `redhat.yml` or `debian.yml` based on the VM's OS. |
| `docker_build` | Checks the project files exist, copies them to the VM, and builds the Docker image. |
| `docker_run` | Starts the container, opens the firewall port, and verifies the site returns HTTP 200. |

Shared settings (image name, tag, container name, ports) live in
`ansible/group_vars/all.yml`.

## Requirements

**Control machine** (where you run Ansible):

- Linux, macOS, or WSL
- Ansible installed
- SSH key access to all 3 VMs

**Target VMs:**

- 1 CentOS (Stream 8/9 or similar) and 2 Ubuntu VMs
- An SSH user with `sudo` rights
- Internet access (to download Docker and the `nginx:alpine` image)

## Setup

1. Edit `ansible/inventory.yaml` and replace every `<ip address>` and `<ssh_user>`.
2. In `ansible/ansible.cfg`, check that `inventory` points to `./inventory.yaml`
   and that `private_key_file` matches your SSH key.
3. Copy your SSH key to each VM:
   ```bash
   ssh-copy-id <ssh_user>@<vm-ip>
   ```
4. Install the required Ansible collections:
   ```bash
   cd ansible
   ansible-galaxy collection install -r requirements.yml
   ```

## Usage

Run all commands from the `ansible/` folder.

```bash
# Check the inventory and connectivity (expect 3 x SUCCESS)
ansible-inventory --graph
ansible docker_hosts -m ping

# Run the whole pipeline
ansible-playbook site.yml
```

Or run one step at a time:

```bash
ansible-playbook install_docker.yml
ansible-playbook build_image.yml
ansible-playbook run_container.yml
```

Run one role only, using tags:

```bash
ansible-playbook site.yml --tags build
```

Run on one VM only:

```bash
ansible-playbook build_image.yml --limit <hostname>
```

## Verification

```bash
ansible docker_hosts -a "docker --version"
ansible docker_hosts -a "docker images cpe212-group2-portfolio"
ansible docker_hosts -a "docker ps"
ansible docker_hosts -m uri -a "url=http://localhost:8080"
```

Then open `http://<vm-ip>:8080` in a browser for each VM. In the `PLAY RECAP`,
every host should show `failed=0` and `unreachable=0`.

## Updating the Web App

After changing files in `webapp/`, rebuild and restart the containers:

```bash
ansible-playbook build_image.yml
ansible-playbook run_container.yml
```

`install_docker.yml` does not need to be run again.

## Docker Image

- Base image: `nginx:alpine`
- Serves the contents of `webapp/` from `/usr/share/nginx/html/`
- Exposes port `80`
- Includes a `HEALTHCHECK` (visible as `healthy` in `docker ps`)

## Troubleshooting

| Problem | Likely cause / fix |
|---------|--------------------|
| `No inventory was parsed` | `inventory` in `ansible.cfg` doesn't match the real file name (`inventory.yaml`). |
| `UNREACHABLE` / permission denied | Wrong IP or user, or the SSH key wasn't copied. Test with `ssh <ssh_user>@<vm-ip>`. |
| `Missing sudo password` | Add `-K` to the `ansible-playbook` command. |
| `couldn't resolve module/action community.docker...` | Run `ansible-galaxy collection install -r requirements.yml`. |
| `Missing webapp/index.html` | The web app files are not in `webapp/` yet. |
| Site not reachable from the browser | Check the firewall (firewalld on CentOS, ufw on Ubuntu) and that port `8080` is open. |

## Demo Video

`<YouTube unlisted link>`
