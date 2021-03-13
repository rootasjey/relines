import 'package:relines/components/desktop_app_bar.dart';
import 'package:relines/components/side_menu_item.dart';
import 'package:relines/router/app_router.gr.dart';
import 'package:relines/state/colors.dart';
import 'package:relines/utils/constants.dart';
import 'package:relines/utils/fonts.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _sideMenuItems = <SideMenuItem>[
    SideMenuItem(
      destination: DashboardSettingsDeepRoute(
        children: [DashboardSettingsRoute()],
      ),
      iconData: UniconsLine.setting,
      label: 'Settings',
      hoverColor: Colors.blueGrey,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // tryAddAdminPage();
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

    if (MediaQuery.of(context).size.width < Constants.maxMobileWidth) {
      return Container();
    }

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
                    FontWeight fontWeight = FontWeight.w400;

                    if (item.destination.fullPath ==
                        router.current?.route?.fullPath) {
                      color = item.hoverColor;
                      textColor = stateColors.foreground;
                      fontWeight = FontWeight.w600;
                    }

                    return ListTile(
                      leading: Icon(
                        item.iconData,
                        color: color,
                      ),
                      title: Text(
                        item.label,
                        style: FontsUtils.mainStyle(
                          color: textColor,
                          fontWeight: fontWeight,
                        ),
                      ),
                      onTap: () {
                        if (item.destination.routeName == 'AdminDeepRoute') {
                          item.destination.show(context);
                          return;
                        }

                        router.navigate(item.destination);
                      },
                    );
                  }).toList(),
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
