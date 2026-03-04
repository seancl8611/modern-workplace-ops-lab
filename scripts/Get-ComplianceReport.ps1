<#
.SYNOPSIS
    Exports Intune device compliance status to CSV for daily review.
.DESCRIPTION
    Pulls all managed devices, checks compliance state, and exports
    a report. Designed to run on a schedule for daily ops monitoring.
.EXAMPLE
    .\Get-ComplianceReport.ps1
    .\Get-ComplianceReport.ps1 -OutputPath "C:\Reports\compliance.csv"
.NOTES
    Required Graph scope: DeviceManagementManagedDevices.Read.All
#>

param(
    [string]$OutputPath = ".\ComplianceReport_$(Get-Date -Format 'yyyy-MM-dd').csv"
)

if (-not (Get-MgContext)) {
    Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All"
}

Write-Host "Fetching managed devices..." -ForegroundColor Cyan

$devices = Get-MgDeviceManagementManagedDevice -All

$report = foreach ($device in $devices) {
    [PSCustomObject]@{
        DeviceName        = $device.DeviceName
        UserDisplayName   = $device.UserDisplayName
        UserPrincipalName = $device.UserPrincipalName
        OperatingSystem   = $device.OperatingSystem
        OSVersion         = $device.OsVersion
        ComplianceState   = $device.ComplianceState
        LastSyncDateTime  = $device.LastSyncDateTime
        EnrolledDateTime  = $device.EnrolledDateTime
        IsEncrypted       = $device.IsEncrypted
        Model             = $device.Model
    }
}

$report | Export-Csv -Path $OutputPath -NoTypeInformation
Write-Host "Report exported to: $OutputPath" -ForegroundColor Green

$total = $report.Count
$compliant = ($report | Where-Object { $_.ComplianceState -eq "compliant" }).Count
$nonCompliant = ($report | Where-Object { $_.ComplianceState -eq "noncompliant" }).Count

Write-Host "`n--- Compliance Summary ---" -ForegroundColor Yellow
Write-Host "Total devices:     $total"
Write-Host "Compliant:         $compliant"
Write-Host "Non-compliant:     $nonCompliant"
Write-Host "Other/Unknown:     $($total - $compliant - $nonCompliant)"

if ($nonCompliant -gt 0) {
    Write-Host "`nNon-compliant devices requiring attention:" -ForegroundColor Red
    $report | Where-Object { $_.ComplianceState -eq "noncompliant" } |
        Format-Table DeviceName, UserDisplayName, ComplianceState, LastSyncDateTime -AutoSize
}