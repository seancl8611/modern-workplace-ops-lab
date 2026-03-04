<#
.SYNOPSIS
    Automates new user creation in Entra ID with group assignments.
.DESCRIPTION
    Creates a new user, sets standard attributes, assigns to department
    security group, and adds to the MFA-required group for Conditional
    Access policy targeting. Group membership also drives license
    assignment (via group-based licensing on SG-All-Employees) and
    Intune policy targeting.
.PARAMETER DisplayName
    Full name of the new user (e.g., "Alex Kim")
.PARAMETER Department
    Department name — must match an existing SG-{Department} group
.PARAMETER JobTitle
    The user's job title
.EXAMPLE
    .\New-UserOnboarding.ps1 -DisplayName "Sam Wilson" -Department "Engineering" -JobTitle "Junior Developer"
.NOTES
    Required Graph scopes: User.ReadWrite.All, Group.ReadWrite.All, Organization.Read.All, Domain.Read.All
#>

param(
    [Parameter(Mandatory)]
    [string]$DisplayName,

    [Parameter(Mandatory)]
    [ValidateSet("Engineering", "Sales", "Finance")]
    [string]$Department,

    [Parameter(Mandatory)]
    [string]$JobTitle
)

# --- Ensure Graph connection (only prompts if not already connected) ---
if (-not (Get-MgContext)) {
    Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All","Organization.Read.All","Domain.Read.All"
}

# Build the UPN from display name
$mailNickname = ($DisplayName.Trim() -replace '\s+', '.').ToLower()

# Get default tenant domain (ex: contosoopslab.onmicrosoft.com)
$tenantDomain = (Get-MgDomain | Where-Object { $_.IsDefault -eq $true } | Select-Object -First 1 -ExpandProperty Id)

if (-not $tenantDomain) {
    throw "Could not determine default tenant domain. Ensure you have Domain.Read.All scope and try again."
}

$upn = "$mailNickname@$tenantDomain"

# Generate a temporary password (simple for lab; don’t store in repo)
$tempPassword = "TempPass!" + (Get-Random -Minimum 1000 -Maximum 9999)

# Create the user
$userParams = @{
    DisplayName       = $DisplayName
    UserPrincipalName = $upn
    MailNickname      = $mailNickname
    Department        = $Department
    JobTitle          = $JobTitle
    UsageLocation     = "US"
    AccountEnabled    = $true
    PasswordProfile   = @{
        Password                      = $tempPassword
        ForceChangePasswordNextSignIn = $true
    }
}

Write-Host "Creating user: $upn" -ForegroundColor Cyan
$newUser = New-MgUser @userParams
Write-Host "User created successfully. Object ID: $($newUser.Id)" -ForegroundColor Green

# Helper to add a user to a group by display name
function Add-UserToGroupByName {
    param(
        [Parameter(Mandatory)][string]$GroupDisplayName,
        [Parameter(Mandatory)][string]$UserId
    )

    $grp = Get-MgGroup -Filter "displayName eq '$GroupDisplayName'" -ConsistencyLevel eventual -CountVariable c
    if ($grp -and $grp.Id) {
        New-MgGroupMember -GroupId $grp.Id -DirectoryObjectId $UserId
        Write-Host "Added to group: $GroupDisplayName" -ForegroundColor Green
        return $true
    } else {
        Write-Warning "Group '$GroupDisplayName' not found. Skipping."
        return $false
    }
}

# Add to department group
$deptGroupName = "SG-$Department"
Add-UserToGroupByName -GroupDisplayName $deptGroupName -UserId $newUser.Id | Out-Null

# Add to All-Employees group (drives license assignment via group-based licensing)
Add-UserToGroupByName -GroupDisplayName "SG-All-Employees" -UserId $newUser.Id | Out-Null

# Add to MFA-Required group (drives Conditional Access targeting)
Add-UserToGroupByName -GroupDisplayName "SG-MFA-Required" -UserId $newUser.Id | Out-Null

# Output summary
Write-Host "`n--- Onboarding Summary ---" -ForegroundColor Yellow
Write-Host "User:           $upn"
Write-Host "Department:     $Department"
Write-Host "Job Title:      $JobTitle"
Write-Host "Groups:         $deptGroupName, SG-All-Employees, SG-MFA-Required"
Write-Host "Temp Password:  $tempPassword"
Write-Host "Note: User must change password on first sign-in."
Write-Host "Note: License should assign automatically via SG-All-Employees group licensing."
Write-Host "Note: Intune + CA policies apply via group membership."