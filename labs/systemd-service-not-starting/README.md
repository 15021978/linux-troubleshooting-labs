# LAB: systemd Service Not Starting

## Objective

This lab demonstrates a real-world Linux troubleshooting scenario where a `systemd` service fails to start. The goal is to investigate the failure methodically, identify the root cause, apply the fix, and validate that the service is working correctly again.

This exercise helps develop practical sysadmin skills such as:

- Diagnosing service startup failures
- Reading `systemd` service status
- Investigating logs with `journalctl`
- Inspecting and validating unit files
- Verifying permissions, paths, users, and working directories
- Applying corrective actions based on evidence
- Building a structured troubleshooting mindset

---

## Scenario

A custom service called `myapp.service` is supposed to start automatically through `systemd`, but it fails during startup.

The administrator must determine:

- what is failing
- why it is failing
- how to fix it
- how to validate the solution

This lab simulates a realistic environment where a service definition exists, but one or more configuration mistakes prevent it from starting properly.

---

## Environment

- Linux distribution: Debian / Ubuntu / CentOS / Rocky / AlmaLinux
- Privileges: `sudo` required
- Init system: `systemd`

---

## Skills Demonstrated

- Linux service troubleshooting
- `systemctl` usage
- `journalctl` log analysis
- `systemd-analyze verify`
- File permission analysis
- User and execution context validation
- Root cause identification
- Service recovery and validation

---

## Lab Setup

### Step 1 - Create the application directory

```bash
sudo mkdir -p /opt/myapp
```

This directory stores the custom application files. In real environments, custom applications are often placed under /opt.


### Step 2 - Create the application startup script

```bash
sudo nano /opt/myapp/start.sh
```

Paste the following content:

```bash
#!/bin/bash
echo "[$(date)] myapp started successfully" >> /var/log/myapp.log
while true; do
    sleep 60
done
```

This script simulates a simple long-running service.

### Step 3 - Make the script executable

```bash
sudo chmod +x /opt/myapp/start.sh
```

This is necessary because systemd will try to execute the script defined in ExecStart.

### Step 4 - Create the systemd unit file

```bash
sudo nano /etc/systemd/system/myapp.service
```

Paste the following content:

```bash
[Unit]
Description=My Custom App
After=network.target

[Service]
Type=simple
ExecStart=/opt/myapp/start.sh
Restart=on-failure
User=root

[Install]
WantedBy=multi-user.target
```

### Step 5 - Reload systemd

```bash
sudo systemctl daemon-reload
```

Whenever a new unit file is created or modified, systemd must reload its configuration.

### Step 6 - Start the service

```bash
sudo systemctl start myapp.service
```

### Step 7 - Check service status

```bash
sudo systemctl status myapp.service
```

Expected result:

```bash
active (running)
```

### Step 8 - Enable service at boot

```bash
sudo systemctl enable myapp.service
```

This ensures the service starts automatically during boot.

---

Troubleshooting Methodology

When a systemd service does not start, the investigation should follow a consistent sequence.

### 1. Check service status

```bash
sudo systemctl status myapp.service
```

This gives a quick overview of:

* whether the service is active, inactive, or failed
* the exit code
* recent error messages
* the last execution attempt


### 2. Read detailed logs

```bash
sudo journalctl -u myapp.service -xe
```

Or:

```bash
sudo journalctl -u myapp.service --no-pager
```

This helps identify what happened during the startup attempt and reveals more precise error messages.


### 3. Inspect the actual unit file

```bash
sudo systemctl cat myapp.service
```

This confirms the exact configuration currently loaded by systemd.


### 4. Validate the unit file syntax

```bash
sudo systemd-analyze verify /etc/systemd/system/myapp.service
```

Useful for detecting syntax issues or invalid directives in the service file.


### 5. Test the command manually

```bash
sudo /opt/myapp/start.sh
```

If the command fails manually, the problem may be in the script itself rather than in systemd.


### 6. Check file existence and permissions

```bash
ls -l /opt/myapp/start.sh
ls -ld /opt/myapp
```

This confirms that the file exists and has the proper execution permissions.


### 7. Check execution user

```bash
grep -i '^User=' /etc/systemd/system/myapp.service
id root
```

Or replace root with the configured service user.

This is important because a service can fail if the configured user does not exist or lacks permissions.


### 8. Reload and restart after changes

```bash
sudo systemctl daemon-reload
sudo systemctl restart myapp.service
```

Use daemon-reload after editing the unit file.
Use restart after fixing the script or service configuration.

---

Fault Injection and Investigation

The following scenarios simulate common service startup failures.


### Scenario 1 - Incorrect ExecStart path

Break the service

Edit the unit file:

```bash
sudo nano /etc/systemd/system/myapp.service
```

Change:

```bash
ExecStart=/opt/myapp/start.sh
```

To:

```bash
ExecStart=/opt/myapp/iniciar.sh
```

Reload and restart:

```bash
sudo systemctl daemon-reload
sudo systemctl restart myapp.service
```

Investigate

```bash
sudo systemctl status myapp.service
sudo journalctl -u myapp.service --no-pager
```

Expected symptoms:

* code=exited, status=203/EXEC
* No such file or directory
* Failed at step EXEC

Why this happened

systemd tried to execute the path defined in ExecStart, but the file does not exist.

Fix Applied

Restore the correct path:

```bash
ExecStart=/opt/myapp/start.sh
```

Then run:

```bash
sudo systemctl daemon-reload
sudo systemctl restart myapp.service
sudo systemctl status myapp.service
```

---

### Scenario 2 - Script is not executable

Break the servic

```bash
sudo chmod -x /opt/myapp/start.sh
sudo systemctl restart myapp.service
```

Investigate

```bash
sudo systemctl status myapp.service
sudo journalctl -u myapp.service --no-pager
```

Expected symptoms:

* Permission denied
* Failed at step EXEC


Why this happened

The file exists, but it no longer has execution permission, so systemd cannot run it.

Fix Applied

```bash
sudo chmod +x /opt/myapp/start.sh
sudo systemctl restart myapp.service
sudo systemctl status myapp.service
```

---

### Scenario 3 - Invalid service user

Break the service

Edit the unit file:

```bash
sudo nano /etc/systemd/system/myapp.service
```

Change:

```bash
User=root
```

To:

```bash
User=appuser
```

Reload and restart:

```bash
sudo systemctl daemon-reload
sudo systemctl restart myapp.service
```

Investigate

```bash
sudo systemctl status myapp.service
sudo journalctl -u myapp.service --no-pager
id appuser
```

Expected symptoms:

* user not found
* failed to determine user credentials
* service exits before execution


Why this happened

systemd attempts to run the service under the configured user. If the user does not exist, startup fails immediately.


Fix Applied

Option 1: revert to an existing user

```bash
User=root
```

Option 2: create a dedicated system user

```bash
sudo useradd -r -s /usr/sbin/nologin appuser
```

Then reload and restart:

```bash
sudo systemctl daemon-reload
sudo systemctl restart myapp.service
sudo systemctl status myapp.service
```

---

### Scenario 4 - Missing WorkingDirectory

Break the service

Edit the unit file and add:

```bash
WorkingDirectory=/opt/myapp/app
```

Do not create that directory.

Reload and restart:

```bash
sudo systemctl daemon-reload
sudo systemctl restart myapp.service
```

Investigate

```bash
sudo systemctl status myapp.service
sudo journalctl -u myapp.service --no-pager
```

Expected symptoms:

* Failed at step CHDIR
* No such file or directory


Why this happened

Before starting the process, systemd tries to change into the configured working directory. If the directory does not exist, startup fails.


Fix Applied

Option 1: create the directory

```bash
sudo mkdir -p /opt/myapp/app
```

Option 2: remove or correct the WorkingDirectory directive

Then run:

```bash
sudo systemctl daemon-reload
sudo systemctl restart myapp.service
sudo systemctl status myapp.service
```

---

### Scenario 5 - Application fails internally

Break the script

```bash
sudo nano /opt/myapp/start.sh
```

Replace content with:

```bash
#!/bin/bash
cat /arquivo/que/nao/existe
```

Make sure it is executable:

```bash
sudo chmod +x /opt/myapp/start.sh
sudo systemctl restart myapp.service
```

Investigate

```bash
sudo systemctl status myapp.service
sudo journalctl -u myapp.service --no-pager
```

Why this happened

In this case, systemd successfully launches the script, but the script itself fails internally. This is different from an ExecStart path or permission problem.

This distinction matters:

* failure before execution usually points to systemd, path, permission, user, or directory issues
* failure after execution usually points to the application, script, configuration, or dependencies


Fix Applied

Restore the original script:

```bash
#!/bin/bash
echo "[$(date)] myapp started successfully" >> /var/log/myapp.log
while true; do
    sleep 60
done
```

Then restart:

```bash
sudo systemctl restart myapp.service
sudo systemctl status myapp.service
```

---

### Scenario 6 - Port already in use

Modify the script to run a simple HTTP server

```bash
sudo nano /opt/myapp/start.sh
```

Use:

```bash
#!/bin/bash
python3 -m http.server 8080
```

Make it executable:

```bash
sudo chmod +x /opt/myapp/start.sh
sudo systemctl restart myapp.service
```

Now, in another terminal, occupy the same port manually:

```bash
python3 -m http.server 8080
```

Restart the service again:

```bash
sudo systemctl restart myapp.service
```

Investigate

```bash
sudo systemctl status myapp.service
sudo journalctl -u myapp.service --no-pager
sudo ss -tulnp | grep 8080
```

Optional alternative:

```bash
sudo lsof -i :8080
```

Why this happened

The application cannot bind to port 8080 because another process is already using it. This is a very common production issue.


Fix Applied

Option 1: stop the conflicting process

```bash
sudo kill -9 PID
```

Option 2: change the application port


Option 3: investigate whether another legitimate service is already using the port

In real environments, it is important not to kill a process blindly without understanding what it belongs to.


Root Cause

The service startup failure can be caused by several realistic issues, including:

* incorrect ExecStart path
* missing execute permission on the script
* invalid or nonexistent service user
* nonexistent working directory
* application errors inside the script
* port conflicts with another process

The key lesson is that the exact root cause must be determined through evidence, not guesswork.


Fix Applied

The general fix workflow is:

1. confirm the failure with systemctl status
2. collect evidence from journalctl
3. inspect the loaded service definition
4. verify the unit file syntax
5. test the executable manually
6. correct the identified problem
7. reload systemd
8. restart the service
9. validate successful recovery


Validation

After applying the fix, validate the result with:

```bash
sudo systemctl status myapp.service
```

Expected output:

```bash
active (running)
```

Also confirm logs if necessary:

```bash
sudo journalctl -u myapp.service -n 20 --no-pager
```

---

Lessons Learned

* Do not guess. Investigate using evidence.
* systemctl status provides a quick summary, but journalctl usually reveals the real cause.
* A service failure can happen before the application starts or after the application starts.
* ExecStart, permissions, user context, and working directory are common failure points.
* daemon-reload is required after editing a unit file.
* Testing the command manually helps separate systemd problems from application problems.
* Port conflicts are a frequent cause of service startup failures in real environments.
* A structured troubleshooting process is more important than memorizing isolated commands.

---

Useful Commands

## Service status

```bash
sudo systemctl status myapp.service
```

## Start service

```bash
sudo systemctl start myapp.service
```

## Restart service

```bash
sudo systemctl restart myapp.service
```

## Stop service

```bash
sudo systemctl stop myapp.service
```

## Enable at boot

```bash
sudo systemctl enable myapp.service
```

## Reload systemd configuration

```bash
sudo systemctl daemon-reload
```

## Read service logs

```bash
sudo journalctl -u myapp.service
```

## Follow logs in real time

```bash
sudo journalctl -u myapp.service -f
```

## Validate unit file

```bash
sudo systemd-analyze verify /etc/systemd/system/myapp.service
```

## Check listening ports

```bash
sudo ss -tulnp
```

---

Suggested Portfolio Takeaway

This lab demonstrates practical Linux administration skills focused on diagnosing and resolving failed services with systemd. It highlights a structured troubleshooting process that mirrors real-world sysadmin work rather than simple command memorization.

---

Possible Next Improvements

Future versions of this lab could include:

* service running under a dedicated non-root user
* log directory permission issues
* environment file problems
* dependency ordering problems
* SELinux or AppArmor interference
* invalid application configuration file
* restart loops and rate limiting with StartLimitBurst
