<#
.SYNOPSIS
    Detects if Windows Firewall is disabled on any profile.
.DESCRIPTION
    Proactive Remediation detection script. Checks all three firewall
    profiles (Domain, Private, Public). Exits with code 1 if any
    profile is disabled, triggering the paired remediation script.
    Exit 0 = compliant (no action needed)
    Exit 1 = noncompliant (remediation will run)
#>

try {
    $profiles = Get-NetFirewallProfile -ErrorAction Stop
    $disabledProfiles = $profiles | Where-Object { $_.Enabled -eq $false }

    if ($disabledProfiles) {
        $names = ($disabledProfiles | ForEach-Object { $_.Name }) -join ", "
        Write-Output "DRIFT DETECTED: Firewall disabled on profiles: $names"
        exit 1
    }
    else {
        Write-Output "COMPLIANT: All firewall profiles are enabled."
        exit 0
    }
}
catch {
    Write-Output "ERROR: Could not check firewall status. $_"
    exit 1
}