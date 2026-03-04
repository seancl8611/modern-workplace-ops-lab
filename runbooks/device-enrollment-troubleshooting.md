# Device Enrollment Troubleshooting (Intune) — ContosoOpsLab

## Scope
This project enrolls **Windows 11 VMs** into Intune using **Entra Join + automatic enrollment**.
Host OS in this build: **Windows 11 Home**, using **Oracle VirtualBox** for VMs.

## Symptoms
- Device not appearing in **Intune → Devices → All devices**
- Device shows **pending**/no check-in
- Enrollment succeeds but policies/apps don’t apply
- OOBE sign-in succeeds but device is not managed by Intune

## Quick Facts (Expected Lab Behavior)
- Intune reporting can lag (often 5–20+ minutes).
- If a VM is **powered off**, it generally won’t check in or receive new assignments until it’s back on.
- A device can appear in Intune but still be catching up on compliance/config/app reporting.

## Diagnostic Steps
### 1) Verify join + management state on the device
On the Windows device/VM:
1. **Settings → Accounts → Access work or school**
2. Click the work account (tenant) → **Info**
3. Confirm:
   - Connected to your tenant
   - MDM/Intune management information exists
4. Optional checks:
   - Run **`dsregcmd /status`** and confirm **AzureAdJoined = YES** (Entra joined)

**Important:** “Workplace join” (adding a work account) is not the same as full Entra Join. Full Entra Join is required for automatic MDM enrollment.

### 2) Verify automatic enrollment configuration in Intune
In Intune admin center: https://intune.microsoft.com
- **Devices → Enrollment → Automatic enrollment**
- Confirm **MDM user scope** includes the intended users (in this build, SG-All-Employees was used)

### 3) Verify user license
- Ensure the user has an Intune-eligible license (in this lab, licensing is driven by group assignment to **SG-All-Employees**)

### 4) Check enrollment restrictions (if enrollment blocks)
- **Devices → Enrollment → Enrollment device platform restrictions**
- Confirm Windows is allowed and any device limits aren’t exceeded.

### 5) Force a sync from the device (good for demos)
On the device:
- **Settings → Accounts → Access work or school → (tenant connection) → Info → Sync**

### 6) Wait for service-side propagation
- Wait 10–20 minutes and refresh **Intune → Devices → All devices**.

## Common Fixes
- **Wrong join type:** Disconnect and re-join properly (Entra Join).
- **User not in scope / not licensed:** Add user to SG-All-Employees (and ensure license assignment is healthy).
- **VM offline:** Power on the VM and allow it to check in.
- **Network / DNS:** Ensure the VM can reach Microsoft endpoints over HTTPS (login, enrollment, Intune management endpoints).

## Data to collect (for escalation / documentation)
- Device name + OS version
- **Entra sign-in logs** around the enrollment time
- Intune device record screenshot (Properties + last check-in)
- Optional MDM logs:
  - `mdmdiagnosticstool.exe -area DeviceEnrollment -cab c:\temp\mdm.cab`

## Notes specific to this lab
- VirtualBox VMs may have TPM/BitLocker limitations depending on VM settings; document expected noncompliance if BitLocker requirements cannot be satisfied in the VM environment.
