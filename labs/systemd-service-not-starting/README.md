# 🧪 LAB: systemd Service Not Starting

## Overview

This lab simulates a common Linux administration issue: a systemd-managed service fails to start.

The goal is to investigate the failure, inspect service status and logs, identify the root cause, correct the problem, and validate that the service starts successfully.

---

## Scenario

A custom web service is configured to run through `systemd`, but it does not start as expected.

This is a common troubleshooting scenario in Linux system administration, infrastructure support, DevOps environments, and security-focused operations.

---

## Objectives

- Identify why the service is failing
- Inspect the service status with `systemctl`
- Analyze service logs with `journalctl`
- Fix the configuration issue
- Validate the service startup

---

## Tools Used

- `systemctl`
- `journalctl`
- `ss`
- `cat`
- `nano` or `vi`
- `python3`

---

## Lab Setup

This lab uses a simple Python HTTP server managed by `systemd`.

### Step 0 — Environment preparation

Ensure you have sudo privileges:

```bash
whoami
```

If needed:

```
sudo -i
```

### Step 1 — Create the systemd service file

```
sudo nano /etc/systemd/system/myweb.service
```

Add the following configuration:

```
[Unit]
Description=Simple Python Web Server
After=network.target

[Service]
ExecStart=/usr/bin/python3 -m http.server 8090
WorkingDirectory=/tmp
Restart=on-failure
User=nobody

[Install]
WantedBy=multi-user.target
```

### Step 2 — Reload systemd

```
sudo systemctl daemon-reload
```

### Step 3 — Start the service

```
sudo systemctl start myweb.service
```

### Step 4 — Check service status

```
sudo systemctl status myweb.service
```

---

## Screenshots

### Initial service status
screenshots/01-systemctl-status-initial.png

---

### Service failure after misconfiguration
screenshots/02-systemctl-status-failed.png

---

### Error details in journalctl
screenshots/03-journalctl-error.png

---

### Service running after fix
screenshots/04-systemctl-running.png

---

### Port validation with ss
screenshots/05-ss-port-8090.png
