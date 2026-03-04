<#
.SYNOPSIS
    Re-enables Windows Firewall on all profiles.
.DESCRIPTION
    Proactive Remediation remediation script. Paired with
    Detect-FirewallDrift.ps1. Runs automatically when the detection
    script finds a disabled firewall profile.
#>

try {
    Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled True -ErrorAction Stop

    $profiles = Get-NetFirewallProfile
    $stillDisabled = $profiles | Where-Object { $_.Enabled -eq $false }

    if ($stillDisabled) {
        $names = ($stillDisabled | ForEach-Object { $_.Name }) -join ", "
        Write-Output "PARTIAL FIX: Still disabled on: $names"
        exit 1
    }
    else {
        Write-Output "REMEDIATED: All firewall profiles re-enabled successfully."
        exit 0
    }
}
catch {
    Write-Output "ERROR: Failed to re-enable firewall. $_"
    exit 1
}