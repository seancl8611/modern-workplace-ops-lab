# Investigation Write-Ups (Ticket Style)

## INC-001: Sign-In Blocked by Conditional Access (Browser Block Test)

**Reported:** User `taylor.brooks` unable to access OfficeHome from an untrusted browser session  
**Time:** 2026-03-04 (see sign-in logs)  
**Sign-in status:** Failure / blocked (error code 53003)  
**Conditional Access policy applied:** `CA-TEST-001` (temporary test policy)  
**Client app:** Browser  
**Resource/App:** OfficeHome / Microsoft 365

### Investigation
1. Reproduced issue using an InPrivate/Incognito browser session.
2. Opened **Entra admin center → Monitoring & health → Sign-in logs** and filtered by:
   - User = `taylor.brooks@contosoopslab.onmicrosoft.com`
   - Status = Failure/Interrupted
3. Opened the event details and checked **Conditional access** tab to confirm which policy was evaluated and which one caused the block.

### Resolution
- Confirmed Conditional Access policy enforcement worked as intended (block condition met).
- Documented the event and removed/disabled test policy after capturing evidence.

### Follow-up
- Keep baseline policies (CA-001/CA-002/CA-003) as the permanent configuration.
- Use **Report-only** first when introducing new restrictions, then enforce once validated.


## INC-002: Win32 App (7-Zip) Reporting Delay / “No items found” in Device Install Status

**Reported:** 7-Zip installed on endpoints, but Intune **Device install status** initially showed no devices  
**Devices:** Windows 11 VMs enrolled via Intune

### Investigation
1. Verified the 7-Zip Win32 app assignment was set to **Required** for the correct group.
2. Confirmed 7-Zip began installing on the VM (toast notification).
3. Observed the Intune app status blade initially returning “No items found,” indicating reporting lag rather than install failure.

### Resolution
- Waited for reporting to populate; confirmed successful installs under **User install status**.

### Follow-up
- For demos, capture both:
  - User install status page showing installs
  - VM confirmation showing 7-Zip present


## INC-003: VirtualBox VM Boot Failure / Disk Full / ISO Missing

**Reported:** VM fails to start (disk full / ISO inaccessible / NVRAM errors)  
**Impact:** Lab endpoint unavailable; Intune policies can’t process while device is offline

### Investigation
- VirtualBox displayed errors such as:
  - `VERR_DISK_FULL` (host storage exhausted)
  - ISO file inaccessible (ISO moved/deleted)
  - NVRAM storage errors after a failed start

### Resolution
1. Freed host disk space.
2. Re-attached the Windows 11 ISO to the VM optical drive if needed.
3. Confirmed VM boots successfully and device can check in to Intune again.

### Follow-up
- Keep Windows ISO in a stable folder (do not delete/move).
- Maintain free disk space to avoid VDI/NVRAM corruption risk.
