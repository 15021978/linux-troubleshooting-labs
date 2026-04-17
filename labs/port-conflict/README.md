# 🧪 LAB: Port Conflict Troubleshooting

## Overview

This lab simulates a common Linux administration issue: a service fails to start because the required port is already in use.

The goal is to diagnose the issue, identify the conflicting process, terminate it safely, and validate that the service can start correctly.

---

## Scenario

A web service is expected to run on port `8080`, but it fails to start with an error indicating that the address is already in use.

This is a common troubleshooting case in Linux system administration, DevOps environments, and infrastructure support roles.

---

## Objectives

- Identify why the service cannot start  
- Check which process is listening on the target port  
- Use Linux troubleshooting tools to resolve the conflict  
- Validate the fix  

---

## Tools Used

- `ss`  
- `fuser`  
- `kill`  
- `ps`  
- `python3`  

---

## Step 1 — Simulate the problem

Start a simple HTTP service on port 8080:

```bash
python3 -m http.server 8080
```

Open a second terminal and try to start the same service again:

```bash
python3 -m http.server 8080
```

Expected result:

```bash
OSError: [Errno 98] Address already in use
```

---

## Step 2 — Diagnose the issue

Check which process is using port 8080:

```bash
ss -tulnp | grep 8080
```

Example output:

```bash
LISTEN 0 5 0.0.0.0:8080 0.0.0.0:* users:(("python3",pid=1234,fd=3))
```

Identify the process with fuser:

```bash
fuser 8080/tcp
```

Example output:

```bash
8080/tcp: 1234
```

Inspect the process in more detail:

```bash
ps -fp 1234
```

---

## Step 3 — Resolve the conflict

Terminate the process by PID:

```bash
kill 1234
```

Or kill it directly with fuser:

```bash
fuser -k 8080/tcp
```

---

## Step 4 — Validate the fix

Verify that nothing is listening on port 8080:

```bash
ss -tulnp | grep 8080
```

If no output is returned, the port is now free.

Start the service again:

```bash
python3 -m http.server 8080
```

The service should now start successfully.

⸻

Key Takeaways
	•	Only one process can bind to the same IP:port combination at a time
	•	ss is useful for inspecting listening sockets
	•	fuser helps identify which process is using a port
	•	kill can be used to terminate the blocking process
	•	A structured troubleshooting approach improves efficiency

⸻

Troubleshooting Mindset

A sysadmin approach usually follows this sequence:
	1.	Reproduce the issue
	2.	Inspect the system state
	3.	Identify the root cause
	4.	Apply the fix
	5.	Validate the result

