import 'package:auto_route/auto_route.dart';
import 'package:relines/components/desktop_app_bar.dart';
import 'package:relines/router/app_router.gr.dart';
import 'package:relines/state/colors.dart';
import 'package:relines/state/user.dart';
import 'package:relines/types/side_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _sideMenuItems = <SideMenuItem>[
    SideMenuItem(
      destination: AppsDeepRoute(children: [MyAppsRoute()]),
      iconData: UniconsLine.apps,
      label: 'My Apps',
      hoverColor: Colors.yellow.shade800,
    ),
    SideMenuItem(
      destination: DashboardSettingsDeepRoute(
        children: [DashboardSettingsRoute()],
      ),
      iconData: Icons.settings,
      label: 'Settings',
      hoverColor: Colors.blueGrey,
    ),
  ];

  @override
  void initState() {
    super.initState();
    tryAddAdminPage();
  }

  @override
  Widget build(context) {
    return AutoRouter(
      builder: (context, child) {
        return Material(
          child: Row(
            children: [
              buildSideMenu(context),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }

  Widget buildSideMenu(BuildContext context) {
    final router = context.router;

    return Container(
      foregroundDecoration: BoxDecoration(
        color: Color.fromRGBO(0, 0, 0, 0.05),
      ),
      width: 300.0,
      child: Stack(
        children: <Widget>[
          CustomScrollView(
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                  bottom: 50.0,
                ),
                sliver: DesktopAppBar(
                  showAppIcon: false,
                  automaticallyImplyLeading: false,
                  leftPaddingFirstDropdown: 0,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                ),
                sliver: SliverList(
                    delegate: SliverChildListDelegate.fixed(
                  _sideMenuItems.map((item) {
                    Color color = stateColors.foreground.withOpacity(0.6);
                    Color textColor = stateColors.foreground.withOpacity(0.6);

                    if (item.destination.fullPath ==
                        router.current?.route?.fullPath) {
                      color = item.hoverColor;
                      textColor = stateColors.foreground;
                    }

                    return ListTile(
                      leading: Icon(
                        item.iconData,
                        color: color,
                      ),
                      title: Text(
                        item.label,
                        style: TextStyle(
                          color: textColor,
                        ),
                      ),
                      onTap: () {
                        if (item.destination.routeName == 'AdminDeepRoute') {
                          item.destination.show(context);
                          return;
                        }

                        router.push(item.destination);
                      },
                    );
                  }).toList(),
                )),
              ),
            ],
          ),
          Positioned(
            left: 40.0,
            bottom: 20.0,
            child: RaisedButton(
              onPressed: () {
                context.router.root.push(
                  DashboardPageRoute(children: [CreateAppRoute()]),
                );
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(30.0),
                ),
              ),
              color: stateColors.accent,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 160.0,
                  ),
                  child: Row(
                    // mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.add, color: Colors.white),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                      ),
                      Text(
                        'Create app',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void tryAddAdminPage() async {
    if (!stateUser.canManageQuotes) {
      return;
    }
  }
}
