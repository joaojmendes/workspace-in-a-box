# Troubleshooting

Before opening an issue, confirm the package version, App Catalog deployment, API approvals, current user's site permissions, OneDrive availability, affected webpart, and affected widget.

## The webparts do not appear in the toolbox

1. Confirm `workspace-in-a-box.sppkg` is deployed and enabled in **Apps for SharePoint**.
2. Confirm the deployment has propagated to the test site.
3. Search for **Workspace In Abox** and **My WorkSpace**.
4. Confirm the page is a modern SharePoint page.
5. Remove and re-add the app to the site if tenant-wide deployment was not selected.

## A widget is missing from the catalog

- Confirm that the widget belongs to the selected shared or personal catalog.
- Some personal widgets are intentionally unavailable in Workspace in a Box.
- Confirm the signed-in user has any required license.
- Confirm required API permissions have been approved.
- Try a fresh browser session after a license or consent change.

## A widget shows an authorization or empty-data error

- Identify the widget's backing service.
- Confirm its API permission is approved.
- Confirm the user has a service license and permission to the source data.
- Test the source directly, such as the SharePoint library or Power BI report.
- Inspect sanitized browser console and network status codes.

## Workspace in a Box does not save

- Enter SharePoint page edit mode.
- Confirm the user has `ManageWeb` or equivalent site-management rights.
- Confirm the site allows creation and update of the hidden `workspace` library.
- Check for `403`, `404`, `409`, `429`, or `5xx` SharePoint requests.
- Avoid simultaneous edits in multiple tabs.

## My Workspace in a Box does not save

- Confirm OneDrive is provisioned for the signed-in user.
- Approve Microsoft Graph `Files.ReadWrite.AppFolder`.
- Confirm the user's OneDrive is not blocked, read-only, or over quota.
- Sign out and in after consent changes.
- Check Graph requests to the OneDrive application folder for sanitized status codes.

## Users unexpectedly see the same personal layout

Confirm that the page contains My Workspace in a Box, not Workspace in a Box. My Workspace configuration is stored per user; Workspace in a Box is intentionally shared at site level.

## Users unexpectedly see different shared layouts

- Confirm they opened the same site, page, and webpart instance.
- Confirm the page was republished after webpart changes.
- Reload without stale browser cache.
- Confirm a manager did not remove and re-add the webpart, which changes its instance identity.

## A saved change disappears

- Wait for the save to complete before navigating away.
- Check the browser console for a failed remote save.
- Confirm another tab or manager did not save an older complete configuration later.
- Retry after restoring network connectivity.

## Collect safe diagnostic information

Include package version, webpart, widget, host, browser, operating system, user role, exact steps, expected and actual behavior, and sanitized errors.

Never include access tokens, cookies, passwords, tenant secrets, license tokens, personal data, mail, chats, files, or confidential URLs.

