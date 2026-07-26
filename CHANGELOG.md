# Changelog

## 1.0.0.6 - 2026-07-26

- Moved shared configuration to the hidden, versioned `WorkspaceInABoxConfiguration` library.
- Create the shared library only on the first authorized site-owner save; reads remain side-effect free.
- Copy legacy shared configuration from the hidden `workspace` library on the first authorized save.
- Added ETag conflict protection for shared configuration updates.
- Added the Work IQ tenant-enablement script, prerequisite warning, and Mail/Calendar Agent Tools permission audit.

## 1.0.0.5 - 2026-07-26

- Added webpart resource files for all 50 SharePoint Online UI locales.
- Localized the title, description, and group metadata for both webparts.
- Added an automated localization contract covering all 120 resource keys and interpolation placeholders.

## 1.0.0.4 - 2026-07-26

Initial public test release.

- One package containing Workspace in a Box and My Workspace in a Box.
- Shared site workspace with `ManageWeb`-restricted editing.
- Personal workspace with per-user OneDrive configuration.
- Responsive dashboard, widget menu, resizing, reordering, and widget settings.
- 39 personal-workspace and 23 shared-workspace widget choices.
- SharePoint, Teams, full-page, light theme, and dark theme support.
- English and Portuguese localization.
