# Scripts — Permissions & Production Notes

## Overview
All scripts use the Microsoft Graph PowerShell SDK (`Microsoft.Graph` module). In this lab, scripts are executed manually using interactive delegated permissions (`Connect-MgGraph`) by an admin user.

## Graph Scopes Used

| Script | Required Scopes | Purpose |
|---|---|---|
| `New-UserOnboarding.ps1` | `User.ReadWrite.All`, `Group.ReadWrite.All`, `Organization.Read.All`, `Domain.Read.All` | Create users, read default domain, add users to groups |
| `Get-ComplianceReport.ps1` | `DeviceManagementManagedDevices.Read.All` | Read Intune managed device inventory + compliance state |
| `Get-LicenseAudit.ps1` | `User.Read.All`, `Organization.Read.All` | Read license SKUs and user license assignment state |
| Remediation scripts (Intune) | Runs as SYSTEM (Intune Remediations) | Detect and remediate local firewall drift |

## Lab vs Production (Least Privilege)
This lab intentionally uses interactive delegated auth for simplicity.

In production, you would:
- Register a dedicated **App Registration** per automation function (or per script)
- Grant only the **minimal application permissions** needed
- Authenticate with **certificate credentials** or **managed identity** (never store client secrets in scripts)
- Store logs centrally (Log Analytics / Sentinel / SIEM) and include run IDs and outcomes
- Separate duties: different identities for onboarding vs reporting vs device actions

## Execution Notes
- If scripts fail due to missing context, run:
  - `Connect-MgGraph -Scopes <scopes>`
  - `Get-MgContext`
- Some Graph calls can require **ConsistencyLevel eventual** when filtering large directories.
