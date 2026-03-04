<#
.SYNOPSIS
    Audits M365 license assignment across the tenant.
.DESCRIPTION
    Reports on total/available/consumed licenses, identifies users
    without licenses, and flags onboarding gaps.
.EXAMPLE
    .\Get-LicenseAudit.ps1
.NOTES
    Required Graph scopes: User.Read.All, Organization.Read.All
#>

param(
    [string]$OutputPath = ".\LicenseAudit_$(Get-Date -Format 'yyyy-MM-dd').csv"
)

if (-not (Get-MgContext)) {
    Connect-MgGraph -Scopes "User.Read.All","Organization.Read.All"
}

Write-Host "=== License Pool Summary ===" -ForegroundColor Cyan
$skus = Get-MgSubscribedSku
foreach ($sku in $skus) {
    $total = $sku.PrepaidUnits.Enabled
    $consumed = $sku.ConsumedUnits
    $available = $total - $consumed
    $pct = if ($total -gt 0) { [math]::Round(($consumed / $total) * 100, 1) } else { 0 }
    Write-Host "  $($sku.SkuPartNumber): $consumed / $total used ($pct%) — $available available"
}

Write-Host "`n=== Unlicensed Users ===" -ForegroundColor Cyan
$allUsers = Get-MgUser -All -Property DisplayName,UserPrincipalName,AssignedLicenses,AccountEnabled |
    Where-Object { $_.AccountEnabled -eq $true }

$unlicensed = $allUsers | Where-Object { $_.AssignedLicenses.Count -eq 0 }

if ($unlicensed) {
    Write-Host "  Found $($unlicensed.Count) active users with no license:" -ForegroundColor Yellow
    $unlicensed | ForEach-Object { Write-Host "    - $($_.DisplayName) ($($_.UserPrincipalName))" -ForegroundColor Yellow }
} else {
    Write-Host "  All active users are licensed." -ForegroundColor Green
}

$report = foreach ($user in $allUsers) {
    [PSCustomObject]@{
        DisplayName       = $user.DisplayName
        UserPrincipalName = $user.UserPrincipalName
        AccountEnabled    = $user.AccountEnabled
        LicenseCount      = $user.AssignedLicenses.Count
        Licensed          = ($user.AssignedLicenses.Count -gt 0)
    }
}

$report | Export-Csv -Path $OutputPath -NoTypeInformation
Write-Host "`nFull report exported to: $OutputPath" -ForegroundColor Green