# Update or remove

## Update the package

1. Download the new `.sppkg` and checksum from GitHub Releases.
2. Verify the checksum.
3. Upload the package to **Apps for SharePoint** and replace the existing version.
4. Review new or changed API permission requests.
5. Confirm tenant-wide deployment.
6. Test both webparts with a site manager and at least two ordinary users.

Keep a copy of the previously deployed package until validation is complete.

## Roll back

1. Upload the retained previous `.sppkg` to **Apps for SharePoint** and replace the current package.
2. Review API access and confirm deployment.
3. Test shared and personal configuration loading.

Configuration created by a newer version may not be compatible with an older package.

## Remove a webpart from a page

Edit the page, remove the selected webpart, and republish. This does not automatically remove its remote configuration.

## Remove the package

1. Remove both webparts from active pages.
2. Remove or disable the app in **Apps for SharePoint**.
3. Review and revoke API permissions that are no longer required by another solution.
4. If approved by your data-retention policy, remove obsolete shared configuration files or the hidden `WorkspaceInABoxConfiguration` library from test sites. The legacy hidden `workspace` library can also be removed after confirming that every required configuration was copied successfully.
5. Let users manage personal application-folder data through the approved OneDrive administration process.

Do not delete configuration storage until retention, recovery, and ownership requirements have been reviewed.
