# Break-Glass Emergency Access Procedure (ContosoOpsLab)

## Purpose
Break-glass accounts provide **emergency access** to the tenant when normal admin access fails (for example, a Conditional Access misconfiguration, MFA outage, or admin account compromise).

This runbook is written for the **ContosoOpsLab** Microsoft 365 Developer tenant used in this project.

## Accounts (Lab)
Two break-glass accounts are maintained for resilience:
- **BreakGlass-01@contosoopslab.onmicrosoft.com**
- **BreakGlass-02@contosoopslab.onmicrosoft.com**

**Configuration requirements (both accounts):**
- Role: **Global Administrator**
- **Excluded from ALL Conditional Access policies**
- **No MFA methods configured**
- Not members of normal operational groups (no SG-* group memberships)

## When to Use (Strict)
Use break-glass accounts ONLY when:
- All other admin accounts are blocked by Conditional Access (lockout)
- MFA is unavailable / MFA registration is broken for admins
- An admin account is compromised and immediate containment is required
- A critical tenant-wide setting must be changed and normal admin access cannot be restored quickly

## How to Use (Procedure)
1. **Authorization / decision**
   - Confirm the event is an emergency and document who authorized use.
2. **Retrieve password**
   - Retrieve the password for **BreakGlass-01** (use BreakGlass-02 if BreakGlass-01 is unavailable).
3. **Sign in**
   - Sign in to the Entra admin center: https://entra.microsoft.com
4. **Fix the outage / lockout**
   - Common fixes:
     - Disable or set Conditional Access policies to **Report-only**
     - Add proper **exclusions** (break-glass and/or admin group)
     - Correct targeting for CA policies (users/groups/apps/conditions)
5. **Validate normal access is restored**
   - Confirm a standard admin account can sign in and manage Entra/Intune.
6. **Sign out immediately**
   - Sign out of break-glass session as soon as remediation is complete.
7. **Post-incident actions**
   - Rotate the password for the break-glass account that was used.
   - Record the incident (see template below).

## Compensating Controls (No MFA)
Since break-glass accounts bypass MFA, risk is reduced by compensating controls:

### Password Storage (Documented Process — do not store secrets in repo)
- BreakGlass-01 password stored in **password manager vault**
- BreakGlass-02 password stored in **separate storage** (example: sealed envelope / separate vault)

### Monitoring / Alerting (Lab + Production guidance)
**Lab evidence approach:**
- Verify break-glass sign-ins appear in **Entra → Monitoring & health → Sign-in logs**.
- Keep screenshots of CA policy exclusions for the break-glass accounts.

**Production approach (documented for maturity):**
- Send sign-in logs to Log Analytics / SIEM and create alerts for:
  - Any sign-in by BreakGlass-01 or BreakGlass-02
  - Any role changes affecting Global Administrator memberships
  - Conditional Access policy edits

### Usage Policy
- Accounts are for emergency use only.
- Use requires documented authorization and post-incident password rotation.

## Quarterly Verification Checklist
Record each quarterly check in the table below.

| Check | Frequency | Last Verified | Notes |
|---|---:|---|---|
| Accounts exist and are enabled | Quarterly | 2026-03-04 | |
| Global Admin role assigned | Quarterly | 2026-03-04 | |
| Excluded from **all** CA policies | Quarterly | 2026-03-04 | Confirmed in each CA policy exclusions |
| MFA methods are **not** configured | Quarterly | 2026-03-04 | |
| Zero unexpected sign-in activity | Quarterly | 2026-03-04 | Review Sign-in logs |
| Passwords accessible to authorized contacts | Quarterly | 2026-03-04 | Verify process only (no secrets) |
| Password rotation | Annually / after use | 2026-03-04 | |

## Incident Record Template
Use this format for any break-glass usage.

- **Incident ID:** INC-BG-____
- **Date/Time (UTC):**
- **Account used:** BreakGlass-01 / BreakGlass-02
- **Authorized by:**
- **Reason for use:** (CA lockout / MFA outage / compromise / other)
- **Actions performed:**
- **Normal admin access restored (Y/N):**
- **Password rotated (Y/N + date):**
- **Screenshots / logs captured:** (sign-in log entry, CA policy exclusions, policy changes)
