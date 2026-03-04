# Conditional Access Troubleshooting — ContosoOpsLab

## Scope
This lab uses Conditional Access (CA) policies in Microsoft Entra to enforce security baselines, including MFA requirements and blocking legacy authentication.

Primary policies used in this build:
- **CA-001: Require MFA for All Users**
- **CA-002: Block Legacy Authentication**
- **CA-003: Require Compliant Device for Finance Apps** (kept in Report-only initially during setup)
- **CA-TEST-001** (temporary test policy used to generate clear sign-in log evidence)

## Symptoms
- User gets: “You cannot access this right now” / error code (example: **53003**)
- Unexpected MFA prompts or continuous MFA loops
- Access blocked to a specific app (OfficeHome, Exchange, SharePoint, etc.)
- Device-based policy fails because device is not compliant/enrolled

## Diagnostic Steps (Most Reliable)
### 1) Use Entra Sign-in logs
Entra admin center: https://entra.microsoft.com  
Path: **Monitoring & health → Sign-in logs**

Recommended filters:
- **Date range:** Last 24 hours
- **User:** specific UPN (e.g., `taylor.brooks@contosoopslab.onmicrosoft.com`)
- **Status:** Failure / Interrupted (as needed)
- Optional: **Application** (OfficeHome, Azure Portal, Microsoft Authentication Broker, etc.)

Open the event → check:
- **Conditional access** tab: which policies were evaluated and each result (Success/Failure/Not applied).
- **Authentication details**: MFA requirement, method, etc.
- **Basic info**: error code and failure reason.

### 2) Confirm group targeting
Verify the user’s memberships:
- Included group(s) (e.g., **SG-MFA-Required**, **SG-Finance**)
- Excluded accounts (break-glass accounts must be excluded from all CA policies)

### 3) (Optional) “What If” tool
If available in your tenant: **Conditional Access → What If**  
Use it to simulate user/app/conditions and confirm which policies apply.

## Common Fixes
- **MFA registration missing:** direct user to https://aka.ms/mfasetup
- **Blocked due to CA targeting:** adjust policy include/exclude groups, or move policy to Report-only while fixing.
- **Compliant device required:** enroll device in Intune, ensure compliance policy applies, then re-test access.
- **Legacy auth blocked:** use modern clients (Outlook/OWA). Legacy protocols cannot satisfy MFA.

## Break-glass safety
If admins are locked out:
- Use the break-glass runbook: **break-glass-procedure.md**
- Immediately move misconfigured CA policies to **Report-only** or correct exclusions.
- Validate normal admin access before ending break-glass session.

## Evidence capture (for this project)
For screenshots/write-ups, capture:
- Sign-in log list with the failed entry highlighted
- The opened event’s **Conditional access** tab showing the applied policy and result (example: CA-TEST-001 failure)
- The user-facing error page (e.g., error 53003) if available
