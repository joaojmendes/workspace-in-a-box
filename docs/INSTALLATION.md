# Installation and activation

This guide is for SharePoint and Microsoft 365 administrators evaluating Workspace in a Box and My Workspace in a Box.

## Prerequisites

- SharePoint Online tenant with a tenant App Catalog.
- Permission to upload and deploy SharePoint Framework packages.
- Permission to review and approve SharePoint API access requests.
- A modern SharePoint test site and page.
- A site owner or user with `ManageWeb` for shared-workspace tests.
- At least two ordinary test users for personal and permission-boundary tests.
- OneDrive provisioned for users testing My Workspace in a Box.

Start in a test tenant or controlled pilot group whenever possible.

## 1. Download and verify the package

Download these files from the [latest GitHub release](https://github.com/joaojmendes/workspace-in-a-box/releases/latest):

- `workspace-in-a-box.sppkg`
- `workspace-in-a-box.sppkg.sha256`

Optional checksum verification:

### PowerShell

```powershell
Get-FileHash .\workspace-in-a-box.sppkg -Algorithm SHA256
```

### macOS or Linux

```bash
shasum -a 256 workspace-in-a-box.sppkg
```

Compare the result with the value in the `.sha256` file.

## 2. Upload to the tenant App Catalog

1. Open the tenant App Catalog site.
2. Open **Apps for SharePoint**.
3. Upload `workspace-in-a-box.sppkg`.
4. Confirm solution ID `f875e592-8038-4338-86c4-4e76b2a08e64` and version `1.0.0.5`.
5. Review the package name, version, requested permissions, and deployment scope.
6. Select **Enable this app and add it to all sites**.
7. Select **Enable app** or **Deploy**, depending on the current SharePoint interface.

The package includes its client-side assets. Initial deployment can require several minutes to propagate.

## 3. Review and approve API access

Open **SharePoint Admin Center** > **Advanced** > **API access**. The package requests the following delegated permissions:

| Resource | Permission | Used by |
| --- | --- | --- |
| Microsoft Graph | `Calendars.Read` | Calendar and event widgets |
| Microsoft Graph | `User.Read` | Signed-in user profile |
| Microsoft Graph | `User.ReadWrite` | User profile features that update permitted user data |
| Microsoft Graph | `User.Read.All` | Directory user lookup |
| Microsoft Graph | `User-Phone.ReadWrite.All` | Profile phone features |
| Microsoft Graph | `GroupMember.Read.All` | Groups, teams, membership, and targeted experiences |
| Microsoft Graph | `Group.Read.All` | Group and team discovery |
| Microsoft Graph | `Sites.Read.All` | SharePoint site and content widgets |
| Microsoft Graph | `Files.Read` | User file widgets |
| Microsoft Graph | `Mail.Read` | Mail widget |
| Microsoft Graph | `People.Read.All` | People and organization widgets |
| Microsoft Graph | `Team.ReadBasic.All` | Teams widget |
| Microsoft Graph | `OnlineMeetingTranscript.Read.All` | Meeting transcript features |
| Microsoft Graph | `Chat.Read` | Chat features |
| Microsoft Graph | `ChannelMessage.Read.All` | Teams channel-message features |
| Microsoft Graph | `ExternalItem.Read.All` | Microsoft 365 external content features |
| Microsoft Graph | `LicenseAssignment.Read.All` | License-aware widget availability |
| Microsoft Graph | `Tasks.Read` | Task widgets |
| Microsoft Graph | `Tasks.ReadWrite` | Task interactions |
| Microsoft Graph | `Community.Read.All` | Community features |
| Microsoft Graph | `Files.Read.All` | SharePoint and OneDrive file widgets |
| Microsoft Graph | `Files.ReadWrite.AppFolder` | Personal workspace configuration in the user's OneDrive application folder |
| Microsoft Graph | `Presence.Read.All` | Presence indicators |
| Yammer | `user_impersonation` | Viva Engage widgets |
| Power BI Service | `Report.Read.All` | Power BI report widget |
| Agent Tools | `McpServers.Mail.All` | Agent mail tools |
| Agent Tools | `McpServers.Calendar.All` | Agent calendar tools |

Approve only the requests permitted by your organization's security policy and required by your test plan. A widget can remain unavailable or show an authorization error when its required permission, license, service, or source data is unavailable.

## 4. Add both webparts to a test page

1. Open a modern SharePoint page and select **Edit**.
2. Add **Workspace In Abox**.
3. Add **My WorkSpace** to the same page or a separate test page.
4. Configure each webpart's title and background option.
5. For Workspace in a Box, optionally enable the welcome area.
6. Publish the page.

The package also declares SharePoint full-page and Microsoft Teams hosts. Validate the SharePoint page experience first before expanding the test scope.

## 5. Validate storage and authorization

### Workspace in a Box

The webpart creates a hidden SharePoint document library named `workspace` in the current site and stores one configuration file per webpart instance. A user needs appropriate site rights to create or update this configuration. Dashboard editing is intended for users with `ManageWeb`.

### My Workspace in a Box

The webpart stores one configuration file per webpart instance under the signed-in user's OneDrive application folder. Each user should see and maintain a separate layout.

Continue with the [testing guide](TESTING.md).
