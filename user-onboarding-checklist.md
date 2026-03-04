# User Onboarding Checklist (Ops)

## Before
- Confirm department group exists: SG-Engineering, SG-Sales, SG-Finance
- Confirm baseline groups exist: SG-All-Employees, SG-MFA-Required
- Confirm group-based licensing configured on SG-All-Employees

## Create user
- Run scripts/New-UserOnboarding.ps1 OR create in Entra admin center
- Set: Display name, UPN, Department, Job title, Usage location (US)
- Require password change at next sign-in

## Group membership
- Add to: department group + SG-All-Employees + SG-MFA-Required

## Verify
- Group membership correct
- License applied (after propagation)
- MFA registration prompts at first sign-in (CA-001)
