# Service Failure with systemd

## Objective

Investigate and recover a Linux service that fails to start using `systemctl`, `journalctl`, and related troubleshooting tools.

## Scenario

A custom web service called `myapp.service` should start automatically at boot, but the service fails to start.

The goal is to identify the root cause, apply the fix, and verify that the service is running correctly.

## Lab Setup

### Create the service script

```bash
sudo mkdir -p /opt/myapp
```

```bash
cat << 'EOF' | sudo tee /opt/myapp/start.sh
```

```bash
#!/bin/bash
echo "Starting MyApp..."
python3 -m http.server 8080
EOF
```

```bash
sudo chmod +x /opt/myapp/start.sh
```

### Create the systemd unit file

```bash
cat << 'EOF' | sudo tee /etc/systemd/system/myapp.service
```

```bash
[Unit]
Description=Simple Python Web Service
After=network.target

[Service]
ExecStart=/opt/myapp/start.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
```

### Reload systemd and enable the service

```bash
sudo systemctl daemon-reload
sudo systemctl enable myapp.service
```

## Simulated Problem

A process is already using TCP port 8080, causing the service to fail.

### Start a conflicting process

```bash
python3 -m http.server 8080
```

## Symptoms

### Attempting to start the service results in failure:

```bash
sudo systemctl start myapp.service
```

Expected error:

* Service enters failed state
* Port 8080 already in use

## Investigation Steps

### Check service status

```bash
sudo systemctl status myapp.service
```

## Review logs

```bash
sudo journalctl -u myapp.service -n 30 --no-pager
```

## Identify the process using port 8080

```bash
sudo ss -tulpn | grep :8080
```

### Alternative:

```bash
sudo fuser 8080/tcp
```

## Root Cause

Another process was already listening on TCP port 8080, preventing the service from binding to the port.

## Fix Applied

### Stop the conflicting process:

```bash
sudo kill <PID>
```

### Start the service again:

```bash
sudo systemctl start myapp.service
```

## Verification

### Check service status:

```bash
sudo systemctl status myapp.service
```

## Expected output:

* Active: active (running)

## Test locally:

```bash
curl http://localhost:8080
```

## Optional Checks

### Enable service at boot:

```bash
sudo systemctl is-enabled myapp.service
```

### View listening ports:#

```bash
sudo ss -tulpn | grep :8080
```

## Command Reference

| Command | Purpose |
|--------|---------|
| `systemctl status myapp.service` | Display the current status of the service |
| `systemctl start myapp.service` | Start the service |
| `systemctl stop myapp.service` | Stop the service |
| `systemctl restart myapp.service` | Restart the service |
| `systemctl daemon-reload` | Reload systemd unit files after changes |
| `systemctl enable myapp.service` | Enable the service to start automatically at boot |
| `systemctl is-enabled myapp.service` | Verify whether the service is enabled |
| `journalctl -u myapp.service -n 30 --no-pager` | Show the last 30 log entries for the service |
| `ss -tulpn \| grep :8080` | Identify which process is listening on TCP port 8080 |
| `fuser 8080/tcp` | Display the PID using port 8080 |
| `kill <PID>` | Terminate the conflicting process |
| `curl http://localhost:8080` | Verify that the web service is responding |

## Files Involved

| File | Description |
|------|-------------|
| `/etc/systemd/system/myapp.service` | systemd unit file that defines how the service is started and managed |
| `/opt/myapp/start.sh` | Bash script executed by systemd to launch the Python web server |
| `/var/log/journal/` | Location where systemd journal logs are stored (if persistent logging is enabled) |


## Skills Demonstrated

* Linux service troubleshooting
* systemd administration
* Log analysis with journalctl
* Port conflict diagnosis
* Basic network verification
* Incident documentation

## Lessons Learned

A service may fail even when the unit file is correct. Checking logs and listening ports is essential to identify conflicts and restore service availability.

## Related CV Project

This lab supports the following project listed in my CV:

## Linux Service Troubleshooting & Incident Recovery


## Helper Script

This lab includes a helper script named `service_status.sh` that displays:

- Service status using `systemctl`
- Recent logs using `journalctl`

Example usage:

```bash
./service_status.sh
./service_status.sh ssh
```

