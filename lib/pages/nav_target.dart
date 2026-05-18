/// The five primary surfaces exposed in the bottom navigation. Defined here
/// (rather than in `main_page.dart`) so that `dashboard_page.dart` can
/// reference it without a circular import.
enum NavTarget { home, map, calendar, bulletin, profile }
