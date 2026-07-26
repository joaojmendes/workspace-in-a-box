# Testing both webparts

Use a non-production tenant or controlled pilot site. Test both webparts: a successful personal-workspace test does not validate shared-site storage or shared editing.

## Recommended accounts

- A SharePoint site owner or user with `ManageWeb`.
- An ordinary site member.
- A second ordinary user with OneDrive provisioned.
- A user with any optional licenses required by widgets in the test plan.

## Workspace in a Box

1. Add the webpart as the site manager and publish the page.
2. Enter edit mode, add several widgets, resize and reorder them, and configure the menu.
3. Reload the page and verify that the configuration persists.
4. Open the page as an ordinary member.
5. Confirm the same dashboard is visible.
6. Confirm shared editing, removal, and reordering controls are not exposed outside the intended edit and permission context.
7. Edit again as the manager and confirm that changes become visible to the ordinary member.
8. Verify that the hidden `workspace` library and its configuration file are not exposed as ordinary navigation.

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

## Hosts and layouts

Test:

- modern SharePoint page;
- full-width section when supported by the page;
- desktop and mobile-width browser layouts;
- light and dark SharePoint themes;
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

