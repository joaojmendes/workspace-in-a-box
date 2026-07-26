# Workspace in a Box for SharePoint Online

Workspace in a Box is a SharePoint Framework package containing two modern dashboard webparts for SharePoint Online:

- **Workspace in a Box** — a site-shared workspace managed by users who have permission to manage the site.
- **My Workspace in a Box** — a personal workspace whose layout and widget configuration follow the signed-in user.

Both webparts provide a responsive dashboard, configurable navigation, light and dark theme support, and a catalog of Microsoft 365, SharePoint, productivity, information, and business widgets.

> This is a binary distribution and support repository. The source code is not published here. Use GitHub Issues to report test results, installation problems, and product defects.
>
> External contributions are issues only. Pull requests and direct repository changes are not accepted.

[Download the latest `workspace-in-a-box.sppkg`](https://github.com/joaojmendes/workspace-in-a-box/raw/main/workspace-in-a-box.sppkg) · [Installation guide](docs/INSTALLATION.md) · [Configuration guide](docs/CONFIGURATION.md) · [Testing guide](docs/TESTING.md) · [Report a problem](https://github.com/joaojmendes/workspace-in-a-box/issues/new/choose)

## What the package provides

### Workspace in a Box

- A shared dashboard for a SharePoint site.
- Widget configuration stored in a hidden, versioned `WorkspaceInABoxConfiguration` document library in that site.
- Add, remove, resize, reorder, and configure operations restricted to site owners.
- Optional welcome area and background.
- A shared workspace menu.

### My Workspace in a Box

- A dashboard personalized for each signed-in user.
- Personal configuration stored in the user's OneDrive application folder.
- Personal add, remove, resize, reorder, title, and widget settings.
- A personal welcome and day-overview experience.
- A personal workspace menu.

### Shared capabilities

- 39 personal-workspace widget choices and 23 shared-workspace widget choices in this release.
- SharePoint, Microsoft Graph, Teams, Planner, Power BI, Viva Engage, Power Apps, Copilot, service health, maps, charts, and general information widgets.
- Responsive layouts for desktop and mobile.
- SharePoint, Microsoft Teams personal app/tab, Teams tab, and SharePoint full-page hosts.
- Webpart and widget labels for all 50 SharePoint Online UI locales.
- Automatic adaptation to the active SharePoint theme.
- Local browser cache and retry handling for interrupted saves.

Widget availability depends on the user's Microsoft 365 licenses, approved API permissions, accessible data, and the selected host.

> [!IMPORTANT]
> **Work IQ tenant setup is required for the Email Copilot and Calendar Copilot features.** A Global Administrator must run [`scripts/Enable-WorkIQTenant.ps1`](scripts/Enable-WorkIQTenant.ps1) before approving the package's Agent Tools permissions. If the Work IQ enterprise applications are missing, those features can fail while requesting a token or calling the Mail or Calendar MCP server. See [Work IQ tenant prerequisite](docs/WORK-IQ.md).

## Supported environment

- SharePoint Online modern pages.
- A tenant App Catalog.
- Work IQ tenant resources provisioned for Email Copilot and Calendar Copilot tests.
- OneDrive for each user testing **My Workspace in a Box**.
- Current Microsoft Edge, Google Chrome, or another current Chromium-based browser.
- Microsoft Teams when testing a supported Teams host.

This package is not intended for SharePoint Server or classic SharePoint pages.

## Quick start

1. Download [`workspace-in-a-box.sppkg`](https://github.com/joaojmendes/workspace-in-a-box/raw/main/workspace-in-a-box.sppkg).
2. Upload it to **Apps for SharePoint** in the tenant App Catalog.
3. Select **Enable this app and add it to all sites**, then deploy it.
4. Ask a Global Administrator to complete the [Work IQ tenant prerequisite](docs/WORK-IQ.md).
5. Review and approve the API permissions required by your test plan.
6. Create or edit a modern SharePoint page.
7. Add **Workspace In Abox**, **My WorkSpace**, or both webparts.
8. Publish the page and test with a site owner and an ordinary user.

Read the complete [installation guide](docs/INSTALLATION.md) before deploying to a production tenant.

## Package identity

| Property | Value |
| --- | --- |
| Product | Workspace in a Box |
| Current test release | `1.0.0.6` |
| Solution ID | `f875e592-8038-4338-86c4-4e76b2a08e64` |
| Workspace in a Box webpart ID | `d0f9e3a6-5c56-41f9-ba17-df942503ec2f` |
| My Workspace in a Box webpart ID | `5e4a8764-ce0a-49cc-9d05-88d9af373d76` |
| Component type | `WebPart` |
| Deployment | Tenant deployable |

## Required API permissions

The package requests delegated access for the widgets it contains. The permission set includes Microsoft Graph access to calendars, profile and directory data, files, mail, people, Teams, meetings, chats, tasks, communities, presence, and service data, together with delegated Power BI, Yammer, and Agent Tools scopes.

The Work IQ implementation calls only the Mail and Calendar MCP servers. The package therefore requests only `McpServers.Mail.All` and `McpServers.Calendar.All` from Agent Tools. The tenant-enablement script can provision a broader Work IQ public client for administrators and MCP testing; those additional permissions are not requested by the SPFx package.

Approve only the permissions required by the widgets in your test plan and according to your organization's security and consent policies. See the [complete permission table](docs/INSTALLATION.md#4-review-and-approve-api-access).

## Testing and feedback

Test both webparts because their configuration ownership and authorization models are different. Include a site manager, an ordinary member, and a second user when possible.

Before reporting an issue:

- remove tenant names, user identities, tokens, license data, and confidential URLs;
- record the package version, webpart, widget, browser, and host;
- include reproducible steps and the expected versus actual result;
- include sanitized console errors or screenshots when useful.

Use the [issue forms](https://github.com/joaojmendes/workspace-in-a-box/issues/new/choose) so reports contain the information needed for investigation.

## Documentation

- [Install and activate](docs/INSTALLATION.md)
- [Enable Work IQ](docs/WORK-IQ.md)
- [Configure both webparts](docs/CONFIGURATION.md)
- [Test both webparts](docs/TESTING.md)
- [Troubleshoot](docs/TROUBLESHOOTING.md)
- [Update or remove](docs/UPDATING-AND-REMOVAL.md)
- [Support policy](SUPPORT.md)
- [Security reporting](SECURITY.md)
- [Release history](CHANGELOG.md)
- [Binary distribution notice](BINARY-LICENSE.md)

## Source code and licensing

This repository intentionally does not contain the application source code. The downloadable `.sppkg` contains compiled assets required by SharePoint Online. Availability of the package on GitHub does not make the product open source.

See [BINARY-LICENSE.md](BINARY-LICENSE.md) before downloading or installing the package.
