<#
.SYNOPSIS
Registers a Work IQ public-client enterprise application and enables its MCP resources.

.DESCRIPTION
Creates the Microsoft-owned Work IQ resource service principals in the selected
tenant, registers a tenant-owned WorkIQ-PublicMCPClient application and service
principal, and grants its documented delegated Work IQ MCP permissions.

The script is idempotent and never creates a client secret. Run it with a
Global Administrator account after reviewing the permissions in this file.

.PARAMETER TenantId
The Directory (tenant) ID as a GUID. The script refuses to continue if Graph
authenticates to a different tenant.

.PARAMETER UseDeviceCode
Uses device-code authentication instead of opening an interactive browser.

.PARAMETER ConsentOnly
Skips application and service-principal creation and only repairs permissions.
The client app and all required service principals must already exist.

.PARAMETER ClientApplicationName
Display name for the tenant-owned public-client app registration and enterprise
application. The default matches the name in Microsoft documentation.

.EXAMPLE
./scripts/Enable-WorkIQTenant.ps1 -TenantId "00000000-0000-0000-0000-000000000000"

.EXAMPLE
./scripts/Enable-WorkIQTenant.ps1 -TenantId "00000000-0000-0000-0000-000000000000" -UseDeviceCode

.NOTES
Based on Microsoft's Work IQ tenant administrator enablement guidance:
https://learn.microsoft.com/microsoft-agent-365/tooling-servers-overview
https://github.com/microsoft/work-iq/blob/main/ADMIN-INSTRUCTIONS.md
https://learn.microsoft.com/microsoft-365/copilot/extensibility/work-iq/enable-work-iq
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
param(
    [Parameter(Mandatory)]
    [ValidatePattern("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")]
    [string]$TenantId,

    [switch]$UseDeviceCode,

    [switch]$ConsentOnly,

    [ValidateNotNullOrEmpty()]
    [string]$ClientApplicationName = "WorkIQ-PublicMCPClient"
)

$ErrorActionPreference = "Stop"
$scriptCmdlet = $PSCmdlet

$workIqApiAppId = "fdcc1f02-fc51-4226-8753-f668596af7f7"
$workIqToolsAppId = "ea9ffc3e-8a23-4a7d-836d-234d7c7565c1"
$publicClientRedirectUris = @(
    "http://localhost:8080/callback"
    "http://127.0.0.1"
    "http://vscode.dev/redirect"
    "https://localhost"
)

$resourceApplications = @(
    @{ Name = "Work IQ API"; AppId = $workIqApiAppId; GrantToClient = $false }
    @{ Name = "Work IQ Tools"; AppId = $workIqToolsAppId; GrantToClient = $true }
    @{ Name = "Work IQ Mail"; AppId = "16b1878d-62c7-4009-aa25-68989d63bbad"; GrantToClient = $true }
    @{ Name = "Work IQ User"; AppId = "147dc821-b413-44c0-8009-1a3098378012"; GrantToClient = $true }
    @{ Name = "Work IQ Calendar"; AppId = "910333d2-47e9-43ca-981f-6df2f4531ef4"; GrantToClient = $true }
    @{ Name = "Work IQ Teams"; AppId = "ce5029ee-c1d3-45c0-bdcc-efb5a4245687"; GrantToClient = $true }
    @{ Name = "Work IQ OneDrive"; AppId = "b0b2a2bb-6361-4549-a00c-a018417eb8e2"; GrantToClient = $true }
    @{ Name = "Work IQ SharePoint"; AppId = "292cff14-c0e8-4116-9e3b-99934ae05766"; GrantToClient = $true }
    @{ Name = "Work IQ Admin"; AppId = "2dbeefeb-6462-48a4-abe6-1c4989699319"; GrantToClient = $true }
    @{ Name = "Work IQ Word"; AppId = "c2d0c2b6-8013-4346-9f8b-b81d3b754a29"; GrantToClient = $true }
    @{ Name = "Work IQ Microsoft 365 Copilot"; AppId = "ab7c82de-7946-4454-ac28-70249d17c95e"; GrantToClient = $true }
)

$requiredWorkIqToolsScopes = @(
    "McpServers.CopilotMCP.All"
    "McpServers.Me.All"
    "McpServers.Mail.All"
    "McpServers.Calendar.All"
    "McpServers.Teams.All"
    "McpServers.Word.All"
    "McpServers.OneDriveSharepoint.All"
    "McpServers.SharepointLists.All"
    "McpServers.SharePoint.All"
    "McpServers.OneDrive.All"
    "McpServers.Dataverse.All"
    "McpServers.M365Admin.All"
    "McpServers.Management.All"
)

function Import-RequiredGraphModule {
    param([Parameter(Mandatory)][string]$Name)

    if (-not (Get-Module -ListAvailable -Name $Name)) {
        Write-Host "Installing $Name for the current user..." -ForegroundColor Yellow
        Install-Module -Name $Name -Scope CurrentUser -Repository PSGallery -Force
    }
    Import-Module -Name $Name -ErrorAction Stop
}

function Get-SingleServicePrincipal {
    param([Parameter(Mandatory)][string]$AppId)

    @(Get-MgServicePrincipal `
        -Filter "appId eq '$AppId'" `
        -Property "id,appId,displayName,oauth2PermissionScopes" `
        -All) | Select-Object -First 1
}

function Wait-ServicePrincipal {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$AppId,
        [int]$TimeoutSeconds = 120
    )

    $pollIntervalSeconds = 5
    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    do {
        $servicePrincipal = Get-SingleServicePrincipal -AppId $AppId
        if ($servicePrincipal) {
            return $servicePrincipal
        }

        Write-Host "Waiting for $Name to propagate in Microsoft Entra..." -ForegroundColor Yellow
        Start-Sleep -Seconds $pollIntervalSeconds
    } while ((Get-Date) -lt $deadline)

    throw "$Name ($AppId) was created but did not become readable within $TimeoutSeconds seconds. Verify it with Microsoft Graph before rerunning the script."
}

function Get-SingleClientApplication {
    $escapedName = $ClientApplicationName.Replace("'", "''")
    $applications = @(Get-MgApplication -Filter "displayName eq '$escapedName'" -All)
    if ($applications.Count -gt 1) {
        throw "Multiple app registrations named '$ClientApplicationName' exist. Rename duplicates before continuing."
    }
    $applications | Select-Object -First 1
}

function Ensure-ServicePrincipal {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$AppId
    )

    $servicePrincipal = Get-SingleServicePrincipal -AppId $AppId
    if ($servicePrincipal) {
        Write-Host "[OK] $Name already exists ($($servicePrincipal.Id))" -ForegroundColor Green
        return $servicePrincipal
    }

    if ($ConsentOnly) {
        throw "$Name ($AppId) is missing. Rerun without -ConsentOnly to provision it."
    }

    if (-not $scriptCmdlet.ShouldProcess("Tenant $TenantId", "Create $Name service principal ($AppId)")) {
        return $null
    }

    $createdServicePrincipal = New-MgServicePrincipal -AppId $AppId
    Write-Host "[CREATED] $Name ($($createdServicePrincipal.Id))" -ForegroundColor Green
    $servicePrincipal = Wait-ServicePrincipal -Name $Name -AppId $AppId
    $servicePrincipal
}

function Ensure-ClientApplication {
    $application = Get-SingleClientApplication
    if (-not $application) {
        if ($ConsentOnly) {
            throw "App registration '$ClientApplicationName' is missing. Rerun without -ConsentOnly to create it."
        }

        if (-not $scriptCmdlet.ShouldProcess(
            "Tenant $TenantId",
            "Register public-client application $ClientApplicationName"
        )) {
            return $null
        }

        $application = New-MgApplication -BodyParameter @{
            DisplayName            = $ClientApplicationName
            SignInAudience         = "AzureADMyOrg"
            IsFallbackPublicClient = $true
            PublicClient           = @{
                RedirectUris = $publicClientRedirectUris
            }
        }
        Write-Host "[CREATED] App registration $ClientApplicationName ($($application.AppId))" -ForegroundColor Green
    }
    else {
        Write-Host "[OK] App registration $ClientApplicationName already exists ($($application.AppId))" -ForegroundColor Green
    }

    $servicePrincipal = Get-SingleServicePrincipal -AppId $application.AppId
    if (-not $servicePrincipal) {
        if ($ConsentOnly) {
            throw "Enterprise application for '$ClientApplicationName' is missing. Rerun without -ConsentOnly."
        }
        if ($scriptCmdlet.ShouldProcess(
            "Tenant $TenantId",
            "Create enterprise application for $ClientApplicationName"
        )) {
            $servicePrincipal = New-MgServicePrincipal -AppId $application.AppId
            Write-Host "[CREATED] Enterprise application $ClientApplicationName ($($servicePrincipal.Id))" -ForegroundColor Green
        }
    }
    else {
        Write-Host "[OK] Enterprise application $ClientApplicationName already exists ($($servicePrincipal.Id))" -ForegroundColor Green
    }

    [PSCustomObject]@{
        Application      = $application
        ServicePrincipal = $servicePrincipal
    }
}

function Get-DelegatedScopeAccess {
    param(
        [Parameter(Mandatory)][object]$ResourceServicePrincipal,
        [Parameter(Mandatory)][string[]]$ScopeNames,
        [Parameter(Mandatory)][string]$ResourceName
    )

    $access = @()
    foreach ($scopeName in $ScopeNames | Sort-Object -Unique) {
        $scope = $ResourceServicePrincipal.Oauth2PermissionScopes |
            Where-Object { $_.IsEnabled -and $_.Value -eq $scopeName } |
            Select-Object -First 1
        if (-not $scope) {
            throw "Delegated scope '$scopeName' is not published by $ResourceName ($($ResourceServicePrincipal.AppId))."
        }
        $access += @{ Id = $scope.Id; Type = "Scope" }
    }
    $access
}

function Merge-DelegatedPermissionGrant {
    param(
        [Parameter(Mandatory)][object]$ClientServicePrincipal,
        [Parameter(Mandatory)][object]$ResourceServicePrincipal,
        [Parameter(Mandatory)][string[]]$RequiredScopes,
        [Parameter(Mandatory)][string]$ResourceName
    )

    $required = @($RequiredScopes | Where-Object { $_ } | Sort-Object -Unique)
    if ($required.Count -eq 0) {
        Write-Host "[SKIP] $ResourceName publishes no delegated scopes." -ForegroundColor DarkYellow
        return
    }

    $grant = @(Get-MgOauth2PermissionGrant -Filter "clientId eq '$($ClientServicePrincipal.Id)'" -All) |
        Where-Object { $_.ResourceId -eq $ResourceServicePrincipal.Id } |
        Select-Object -First 1
    $existing = if ($grant) { @($grant.Scope -split " " | Where-Object { $_ }) } else { @() }
    $merged = @($existing + $required | Sort-Object -Unique)
    $missing = @($required | Where-Object { $_ -notin $existing })

    if ($missing.Count -eq 0) {
        Write-Host "[OK] $ResourceName consent already contains all required scopes." -ForegroundColor Green
        return
    }

    $scopeValue = $merged -join " "
    if (-not $scriptCmdlet.ShouldProcess(
        "Tenant $TenantId",
        "Grant $ResourceName delegated scopes to ${ClientApplicationName}: $($missing -join ', ')"
    )) {
        return
    }

    if ($grant) {
        Update-MgOauth2PermissionGrant -OAuth2PermissionGrantId $grant.Id -Scope $scopeValue
    }
    else {
        New-MgOauth2PermissionGrant -BodyParameter @{
            ClientId    = $ClientServicePrincipal.Id
            ConsentType = "AllPrincipals"
            ResourceId  = $ResourceServicePrincipal.Id
            Scope       = $scopeValue
        } | Out-Null
    }

    Write-Host "[GRANTED] ${ResourceName}: $($missing -join ', ')" -ForegroundColor Green
}

foreach ($moduleName in @(
    "Microsoft.Graph.Authentication",
    "Microsoft.Graph.Applications",
    "Microsoft.Graph.Identity.SignIns"
)) {
    Import-RequiredGraphModule -Name $moduleName
}

$connectParameters = @{
    TenantId  = $TenantId
    Scopes    = @("Application.ReadWrite.All", "DelegatedPermissionGrant.ReadWrite.All")
    NoWelcome = $true
}
if ($UseDeviceCode) {
    $connectParameters.UseDeviceCode = $true
}

Write-Host "Connecting to Microsoft Graph tenant $TenantId..." -ForegroundColor Cyan
Connect-MgGraph @connectParameters

try {
    $context = Get-MgContext
    if (-not $context -or $context.TenantId -ne $TenantId) {
        throw "Connected tenant '$($context.TenantId)' does not match requested tenant '$TenantId'."
    }

    Write-Host "Connected as $($context.Account) to tenant $($context.TenantId)." -ForegroundColor Green
    Write-Warning "This operation grants tenant-wide delegated access to mail, chats, meeting transcripts, people, SharePoint, OneDrive, and other Work IQ MCP resources."

    $resourceServicePrincipals = @{}
    foreach ($resourceApplication in $resourceApplications) {
        $resourceServicePrincipals[$resourceApplication.AppId] = Ensure-ServicePrincipal `
            -Name $resourceApplication.Name `
            -AppId $resourceApplication.AppId
    }

    $client = Ensure-ClientApplication
    if (-not $client -or -not $client.ServicePrincipal) {
        Write-Warning "The Work IQ public-client enterprise application is unavailable. No consent was changed."
        return
    }

    $requiredResourceAccess = @()

    $clientResources = @()
    foreach ($resourceApplication in $resourceApplications | Where-Object { $_.GrantToClient }) {
        $resourceServicePrincipal = $resourceServicePrincipals[$resourceApplication.AppId]
        if (-not $resourceServicePrincipal) {
            throw "$($resourceApplication.Name) service principal is unavailable."
        }

        $publishedScopes = if ($resourceApplication.AppId -eq $workIqToolsAppId) {
            $requiredWorkIqToolsScopes
        }
        else {
            @($resourceServicePrincipal.Oauth2PermissionScopes |
                Where-Object { $_.IsEnabled -and $_.Value } |
                Select-Object -ExpandProperty Value)
        }

        if ($publishedScopes.Count -gt 0) {
            $requiredResourceAccess += @{
                ResourceAppId  = $resourceApplication.AppId
                ResourceAccess = @(Get-DelegatedScopeAccess `
                    -ResourceServicePrincipal $resourceServicePrincipal `
                    -ScopeNames $publishedScopes `
                    -ResourceName $resourceApplication.Name)
            }
            $clientResources += @{
                Application      = $resourceApplication
                ServicePrincipal = $resourceServicePrincipal
                Scopes           = $publishedScopes
            }
        }
    }

    if ($scriptCmdlet.ShouldProcess(
        "App registration $ClientApplicationName ($($client.Application.AppId))",
        "Configure public-client redirects and Work IQ MCP API permissions"
    )) {
        Update-MgApplication -ApplicationId $client.Application.Id -BodyParameter @{
            IsFallbackPublicClient = $true
            PublicClient           = @{
                RedirectUris = $publicClientRedirectUris
            }
            RequiredResourceAccess = $requiredResourceAccess
        }
        Write-Host "[CONFIGURED] Public-client redirects and API permissions." -ForegroundColor Green
    }

    foreach ($clientResource in $clientResources) {
        Merge-DelegatedPermissionGrant `
            -ClientServicePrincipal $client.ServicePrincipal `
            -ResourceServicePrincipal $clientResource.ServicePrincipal `
            -RequiredScopes $clientResource.Scopes `
            -ResourceName $clientResource.Application.Name
    }

    $allGrants = @(Get-MgOauth2PermissionGrant -Filter "clientId eq '$($client.ServicePrincipal.Id)'" -All)
    Write-Host "`nWork IQ tenant enablement completed." -ForegroundColor Green
    Write-Host "Tenant ID:                    $TenantId"
    Write-Host "Client app name:               $ClientApplicationName"
    Write-Host "Client application (client) ID: $($client.Application.AppId)"
    Write-Host "Enterprise application object: $($client.ServicePrincipal.Id)"
    Write-Host "Work IQ Tools resource App ID:  $workIqToolsAppId"
    Write-Host "Work IQ Tools enterprise object: $($resourceServicePrincipals[$workIqToolsAppId].Id)"
    Write-Host "OAuth grants found:             $($allGrants.Count)"
    Write-Host "`nUse client ID '$($client.Application.AppId)' in your MCP client's oauth.clientId setting." -ForegroundColor Cyan
}
finally {
    Disconnect-MgGraph | Out-Null
}
