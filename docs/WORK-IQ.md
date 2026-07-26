# Work IQ tenant prerequisite

Workspace in a Box uses Microsoft Work IQ/Agent Tools for the Copilot actions in the Email and Calendar widgets. Work IQ is a tenant prerequisite for those two features.

> [!CAUTION]
> If the Work IQ enterprise applications are not provisioned, Email Copilot and Calendar Copilot can fail during token acquisition or when calling the MCP server. Installing the `.sppkg` alone does not complete this tenant setup.

## Administrator setup

This is a one-time tenant operation. A Global Administrator must:

1. Download or clone this repository.
2. Review [`scripts/Enable-WorkIQTenant.ps1`](../scripts/Enable-WorkIQTenant.ps1), including every requested delegated permission.
3. Open PowerShell and run:

   ```powershell
   .\scripts\Enable-WorkIQTenant.ps1 -TenantId "00000000-0000-0000-0000-000000000000"
   ```

   Use the Directory (tenant) ID, not a tenant name. Add `-UseDeviceCode` when an interactive browser cannot be opened.

4. Confirm that the script reports successful Work IQ tenant enablement.
5. Deploy the `.sppkg`, then approve its two Agent Tools requests in **SharePoint Admin Center** > **Advanced** > **API access**:

   - `McpServers.Mail.All`
   - `McpServers.Calendar.All`

6. When available in the tenant, review Work IQ Mail and Calendar under **Microsoft 365 admin center** > **Agents** > **Tools** and apply the organization's policy.

The script is idempotent and supports PowerShell `-WhatIf`. It installs the required Microsoft Graph PowerShell modules for the current user when they are absent. It never creates a client secret.

## What the script creates

The script:

- creates missing Microsoft-owned Work IQ resource service principals;
- creates or repairs a tenant-owned public-client app registration named `WorkIQ-PublicMCPClient`;
- creates its enterprise application;
- configures the documented public-client redirect URIs;
- grants the public client the delegated Work IQ MCP scopes listed in the script.

Review this broad public-client consent carefully. It is intended to enable and test the tenant's Work IQ MCP resources. The SPFx package does not use that public client's application ID at runtime.

## SPFx permission audit

The webpart code calls these Agent Tools endpoints:

| Feature | MCP server | Token resource | Package scope |
| --- | --- | --- | --- |
| Email Copilot | `mcp_MailTools` | Agent Tools (`ea9ffc3e-8a23-4a7d-836d-234d7c7565c1`) | `McpServers.Mail.All` |
| Calendar Copilot | `mcp_CalendarTools` | Agent Tools (`ea9ffc3e-8a23-4a7d-836d-234d7c7565c1`) | `McpServers.Calendar.All` |

Both required scopes are already declared in the package manifest. No other Work IQ MCP server is called by this release, so no other Work IQ scope belongs in `package-solution.json`.

The public client created by the script and SharePoint's **SharePoint Online Client Extensibility Web Application Principal** are different OAuth clients:

- the script provisions the tenant resources and a reusable public MCP client;
- SharePoint API access approval grants the two scopes to the SPFx client used by the webpart.

Both tenant provisioning and SharePoint API approval must be completed for the features to work.

## Licensing and policy

Successful provisioning and consent do not override the signed-in user's Microsoft 365 permissions, licenses, sensitivity labels, or tenant Work IQ policy. Administrators should pilot these preview capabilities with test accounts and grant only the access accepted by their organization.

Microsoft documentation:

- [Work IQ MCP overview](https://learn.microsoft.com/microsoft-365/copilot/extensibility/work-iq/mcp/overview)
- [Enable your tenant for Work IQ](https://learn.microsoft.com/microsoft-365/copilot/extensibility/work-iq/enable-work-iq)
- [Work IQ/Agent Tools server setup](https://learn.microsoft.com/microsoft-agent-365/tooling-servers-overview)
- [Microsoft Work IQ repository](https://github.com/microsoft/work-iq)
