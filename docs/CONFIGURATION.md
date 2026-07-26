# Configuration and administration

The package contains two webparts that share the same dashboard experience but use different configuration ownership.

## Configuration model

| Behavior | Workspace in a Box | My Workspace in a Box |
| --- | --- | --- |
| Intended use | Shared site dashboard | Personal dashboard |
| Configuration owner | Current SharePoint site | Signed-in user |
| Remote storage | Hidden `workspace` document library | OneDrive application folder |
| Add widgets | SharePoint edit mode | Available to the signed-in user |
| Reorder, resize, remove | Users with site-management rights in edit mode | Signed-in user |
| Configuration shared with another user | Yes, on the same page and site | No |

Each webpart instance has its own configuration filename. Removing one instance and adding a new one can create a different configuration identity.

## Webpart properties

1. Edit the SharePoint page.
2. Select the webpart, then open its property pane.
3. Configure the title and background.
4. For Workspace in a Box, configure the optional welcome area when available.
5. Republish the page.

## Add and arrange widgets

1. Select **Add widget** from the workspace menu or empty dashboard.
2. Choose an available widget.
3. Configure the widget through its action or properties control.
4. Resize or drag the card when the current webpart and user context permits it.
5. Wait for the save operation to finish before closing or reloading the page.

Some widget types permit multiple instances. Personal widgets such as profile, mail, or calendar generally permit one instance.

## Workspace menu

The menu can contain a brand, sections, links, and actions. Configure links with URLs that all intended users can access. Menu configuration follows the same ownership model as the surrounding dashboard:

- shared in Workspace in a Box;
- personal in My Workspace in a Box.

## Widget availability

The catalog is filtered by webpart type and may also be filtered by licensing. A visible widget can still require:

- an approved Microsoft Graph or service-specific permission;
- a Microsoft 365, Power BI, Viva, or Copilot license;
- access to the selected SharePoint list, library, site, app, report, or external service;
- additional widget-specific setup.

## Storage behavior

Changes are cached locally and queued for remote saving. Retryable network or service errors are retried. Avoid editing the same shared workspace simultaneously in several tabs because the latest complete saved configuration can replace an earlier one.

For personal workspaces, verify that OneDrive is provisioned and that `Files.ReadWrite.AppFolder` has been approved.

