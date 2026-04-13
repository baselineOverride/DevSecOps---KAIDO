# KAIDO – Cloud‑Native DevSecOps Pipeline (Terraform + Jenkins + SAST/SCA/DAST)

A fully automated DevSecOps pipeline built from scratch using **Terraform**, **AWS**, **Jenkins**, **Docker**, **Semgrep**, **Trivy**, **Gitleaks**, and **OWASP ZAP**.  
This project intentionally includes vulnerable code to demonstrate **real security scanning, real findings, and real remediation workflows** — exactly what modern security teams expect.

---

# Why This Project Matters

This repository demonstrates that I can:

- Design and provision cloud infrastructure using **Terraform**
- Build a complete **CI/CD pipeline** with security gates
- Integrate **SAST, SCA, secret scanning, container scanning, and DAST**
- Interpret scanner findings and **remediate vulnerabilities**
- Produce **audit‑ready reports**
- Build intentionally vulnerable applications for testing
- Document everything clearly and professionally

This is the same workflow used in real DevSecOps teams.

---

# Project Status — Active Remediation in Progress

This project is intentionally designed as a **realistic DevSecOps hardening workflow**.  
The pipeline is fully functional, and all security scanners (Semgrep, Trivy, Gitleaks, ZAP) are integrated and running.

I am currently in the process of:

- Fixing the remaining Semgrep SAST findings  
- Hardening the Node.js application  
- Finalizing Dockerfile user permissions  
- Completing the last DAST/SAST cleanups  

The goal is to demonstrate **how a real engineer iteratively identifies, prioritizes, and remediates vulnerabilities** in a modern CI/CD environment.

Even in its current state, the project already shows:

- Cloud infrastructure provisioning (Terraform + AWS)  
- A complete CI/CD pipeline with security gates  
- Real scanner outputs and reports  
- Evidence‑based remediation work  
- A secure‑by‑design mindset  

This README will be updated as remediation progresses.

---

# Architecture Overview

## **Infrastructure (Terraform)**

Terraform provisions:

- AWS VPC  
- Public subnet  
- Security groups  
- EC2 instance running Jenkins  
- IAM roles + instance profile  
- ECR repository  

**Diagram:**
![Terraform Diagram](screenshots/Terraform%20Diagram.png)

---

## **CI/CD Pipeline (Jenkins)**

The pipeline performs:

1. Checkout  
2. Docker build  
3. Semgrep SAST  
4. Trivy SCA  
5. Gitleaks secret scanning  
6. Run vulnerable app container  
7. OWASP ZAP DAST  
8. Archive reports  
9. Security gate (fail if any scanner reports blocking issues)

**Diagram:**
![Pipeline Diagram](screenshots/Jenkins%20Pipeline%20Diagram.png)

---

# Vulnerable Application

A deliberately insecure Node.js banking API used to demonstrate:

- XSS  
- Open redirect  
- Hardcoded JWT secret  
- Unsafe HTML rendering  
- SSRF  
- Path traversal  
- Missing security headers  
- Dockerfile running as root  

**App Front Page:**
![App](screenshots/App%20Verify.png)

---

# Security Scanning Stages

## **1. Semgrep (SAST)**

Semgrep scans the source code using the OWASP Top 10 ruleset.

### **Key Findings**

- Reflected XSS  
- Open redirect  
- Hardcoded JWT secret  
- Unsafe HTML rendering  
- Dockerfile running as root  
- Terraform misconfigurations (public subnet, IMDSv1, mutable ECR tags)

![Semgrep](screenshots/Semgrep%20Verify.png)

**Report:**  
`/reports/semgrep.json`

---

## **2. Trivy (SCA + Container Vulnerabilities)**

Trivy scans the Docker image for HIGH/CRITICAL CVEs.

### **Typical Findings**

- Vulnerable Node.js base image  
- OpenSSL CVEs  
- libc vulnerabilities  
- Outdated OS packages  
<!--
**📸 Screenshot placeholder:**  
`/screenshots/trivy-summary.png`
-->
**Report:**  
`/reports/trivy.json`

---

## **3. Gitleaks (Secret Scanning)**

Scans the repository for hardcoded secrets.

<!--
**📸 Screenshot placeholder:**  
`/screenshots/gitleaks.png`
-->
**Report:**  
`/reports/gitleaks.json`

---

## **4. OWASP ZAP (DAST)**

ZAP attacks the running application.

### **Findings include**

- Missing security headers  
- Reflected XSS  
- Open redirect  
- Path traversal indicators  

**Screenshots:**  

<p align="center">
  <img src="screenshots/ZAP%20Verify.png" width="1000" />
  <br></br>
  <img src="screenshots/ZAP%20Solution%20Example.png" width="1000" /> 
</p>

**Report:**  
`/reports/zap-report.html`

---

# Security Gate Enforcement

The pipeline fails intentionally when any scanner reports blocking issues:

```
ERROR: script returned exit code 1
Finished: FAILURE
```

This demonstrates real DevSecOps governance.

**Screenshots:**  

<p align="center">
  <img src="screenshots/Pipeline%20Fail.png" width="1000" />
  <br></br>
  <img src="screenshots/Pipeline%20Scan%20Overview.png" width="1000" /> 
</p>

---

<!--
# Remediation Workflow

After running the pipeline and reviewing findings, I implemented fixes across:

## **Application Code**

- Sanitized user input  
- Removed hardcoded secrets  
- Added allow‑list validation  
- Added security headers (Helmet)  
- Eliminated unsafe HTML rendering  

## **Dockerfile**

- Added non‑root user  
- Switched to slimmer base image  
- Updated OS packages  

## **Terraform**

- Disabled public IP assignment  
- Enforced IMDSv2  
- Set ECR tags to immutable  

## **Pipeline**

- Ensured all scanners run before failing  
- Archived all reports  
- Improved ZAP targeting and container networking  

**Screenshot placeholder:**  
`/screenshots/remediation-diff.png`

---
-->
# Reports

All reports are stored in:

```
/reports
semgrep.json
trivy.json
gitleaks.json
zap-report.html
```

These provide full transparency and auditability.

---

# Tools Used

| Category | Tool |
|---------|------|
| IaC | Terraform |
| Cloud | AWS |
| CI/CD | Jenkins |
| Containerization | Docker |
| SAST | Semgrep |
| SCA | Trivy |
| Secrets | Gitleaks |
| DAST | OWASP ZAP |
| Language | Node.js / Express |

---

# How to Run Locally

Clone the repo:

```bash
git clone https://github.com/baselineOverride/DevSecOps---KAIDO.git
```

Build and run the app:

```bash
docker build -t kaido-app .
docker run -p 3000:3000 kaido-app
```

---

**Author:** [Daniel Krakolinig]

**Version:** 1.0

**Last Updated:** April 2026
