# Testing both webparts

Use a non-production tenant or controlled pilot site. Test both webparts: a successful personal-workspace test does not validate shared-site storage or shared editing.

## Recommended accounts

- A SharePoint site owner.
- An ordinary site member.
- A second ordinary user with OneDrive provisioned.
- A user with any optional licenses required by widgets in the test plan.
- A Work IQ-enabled user for Email Copilot and Calendar Copilot tests.

## Workspace in a Box

1. Add the webpart as the site owner and publish the page.
2. As the site owner, add several widgets, resize and reorder them, and configure the menu.
3. Reload the page and verify that the configuration persists.
4. Open the page as an ordinary member.
5. Confirm the same dashboard is visible.
6. Confirm shared editing, removal, and reordering controls are not exposed to the ordinary member.
7. Edit again as the site owner and confirm that changes become visible to the ordinary member.
8. Verify that the hidden, versioned `WorkspaceInABoxConfiguration` library and its configuration file are not exposed as ordinary navigation.
9. Attempt concurrent owner edits and confirm an older save cannot silently overwrite a newer configuration.

## My Workspace in a Box

1. Add the webpart to a published page.
2. Open it as the first ordinary user, add widgets, resize and reorder them, and configure personal settings.
3. Reload and verify persistence.
4. Open the same page as the second ordinary user.
5. Confirm that the second user starts with a separate personal configuration.
6. Add a different layout for the second user.
7. Return to the first account and confirm its layout is unchanged.

## Widget coverage

Test a representative group before attempting the complete catalog:

- user and organization: profile, team, company directory, organization chart;
- productivity: mail, calendar, events, tasks, Planner, Teams;
- content: OneDrive, SharePoint document library, SharePoint collection, news;
- business apps: Power BI, Power Apps, Forms, Viva Engage;
- information: weather, world clock, world map, service health;
- layout and content: hero, image and text, KPI, chart, Gantt;
- licensed experiences: Copilot and any entitlement-controlled widgets.

For each tested widget, verify add, initial load, empty state, configuration, refresh, resize, reorder, removal, theme, and narrow-width behavior.

For Email Copilot and Calendar Copilot, first complete the [Work IQ tenant prerequisite](WORK-IQ.md), then verify both read and confirmed write actions. In a separate test tenant or before provisioning, verify that missing Work IQ setup produces an understandable authorization/service error and does not affect non-Work-IQ widgets.

## Hosts and layouts

Test:

- modern SharePoint page;
- full-width section when supported by the page;
- desktop and mobile-width browser layouts;
- light and dark SharePoint themes;
- several SharePoint UI languages, including one right-to-left language;
- Microsoft Teams personal app or tab if included in the pilot.

## Safe issue report

Record:

- package version;
- affected webpart and widget;
- host, browser, operating system, and approximate viewport;
- account role and relevant license, without identifying the user;
- exact reproduction steps;
- expected and actual behavior;
- sanitized console or network error.

Never attach tokens, cookies, tenant names, personal data, private URLs, OneDrive contents, mail, chat messages, or customer content.
