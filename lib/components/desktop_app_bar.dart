import 'package:auto_route/auto_route.dart';
import 'package:relines/components/app_icon.dart';
import 'package:relines/router/app_router.gr.dart';
import 'package:relines/state/colors.dart';
import 'package:relines/state/user.dart';
import 'package:relines/types/enums.dart';
import 'package:relines/utils/app_storage.dart';
import 'package:relines/utils/brightness.dart';
import 'package:relines/utils/constants.dart';
import 'package:relines/utils/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

class DesktopAppBar extends StatefulWidget {
  final bool automaticallyImplyLeading;
  final bool showUserMenu;
  final bool showCloseButton;
  final bool pinned;

  /// Show appication icon if true. Hide it if false. Default tot true.
  final bool showAppIcon;

  /// Control left padding of the first dropdown. Default to 32.0;
  final double leftPaddingFirstDropdown;

  final Function onTapIconHeader;
  final Function onNavBack;

  final String title;

  DesktopAppBar({
    this.automaticallyImplyLeading = true,
    this.onTapIconHeader,
    this.onNavBack,
    this.pinned = true,
    this.showAppIcon = true,
    this.showCloseButton = false,
    this.showUserMenu = true,
    this.title = '',
    this.leftPaddingFirstDropdown = 32.0,
  });

  @override
  _DesktopAppBarState createState() => _DesktopAppBarState();
}

class _DesktopAppBarState extends State<DesktopAppBar> {
  /// If true, use icon instead of text for PopupMenuButton.
  bool useIconButton = false;
  bool useGroupedDropdown = false;
  bool isNarrow = false;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constrains) {
        isNarrow = constrains.crossAxisExtent < Constants.maxMobileWidth;
        useIconButton = constrains.crossAxisExtent < 1000.0;
        useGroupedDropdown = constrains.crossAxisExtent < 800.0;

        final left =
            constrains.crossAxisExtent < Constants.maxMobileWidth ? 0.0 : 65.0;

        bool showUserMenu = !isNarrow;

        if (widget.showUserMenu != null) {
          showUserMenu = widget.showUserMenu;
        }

        return Observer(
          builder: (_) {
            final userSectionWidgets = <Widget>[];
            userSectionWidgets.addAll(getGuestButtons(isNarrow));

            final mustShowNavBack = widget.automaticallyImplyLeading &&
                context.router.root.stack.length > 1;

            return SliverAppBar(
              floating: true,
              snap: true,
              pinned: widget.pinned,
              toolbarHeight: 80.0,
              backgroundColor: stateColors.appBackground.withOpacity(1.0),
              automaticallyImplyLeading: false,
              actions: showUserMenu ? userSectionWidgets : [],
              title: Padding(
                padding: EdgeInsets.only(
                  left: left,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    if (mustShowNavBack)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 10.0,
                          right: 16.0,
                        ),
                        child: IconButton(
                          color: stateColors.foreground,
                          onPressed: widget.onNavBack,
                          icon: Icon(UniconsLine.arrow_left),
                        ),
                      ),
                    if (widget.showAppIcon)
                      AppIcon(
                        size: 30.0,
                        padding: const EdgeInsets.only(left: 0.0),
                        onTap: widget.onTapIconHeader,
                      ),
                    bugButton(),
                    if (useGroupedDropdown) groupedDropdown(),
                    if (widget.showCloseButton) closeButton(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Switch from dark to light and vice-versa.
  Widget brightnessButton() {
    IconData iconBrightness = Icons.brightness_auto;
    final autoBrightness = appStorage.getAutoBrightness();

    if (!autoBrightness) {
      final currentBrightness = appStorage.getBrightness();

      iconBrightness = currentBrightness == Brightness.dark
          ? Icons.brightness_2
          : Icons.brightness_low;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: PopupMenuButton<String>(
        icon: Icon(
          iconBrightness,
          color: stateColors.foreground.withOpacity(0.6),
        ),
        tooltip: 'brightness'.tr(),
        onSelected: (value) {
          if (value == 'auto') {
            BrightnessUtils.setAutoBrightness(context);
            return;
          }

          final brightness =
              value == 'dark' ? Brightness.dark : Brightness.light;

          BrightnessUtils.setBrightness(context, brightness);
        },
        itemBuilder: (context) {
          final autoBrightness = appStorage.getAutoBrightness();
          final brightness = autoBrightness ? null : appStorage.getBrightness();

          final primary = stateColors.primary;
          final basic = stateColors.foreground;

          return [
            PopupMenuItem(
              value: 'auto',
              child: ListTile(
                leading: Icon(Icons.brightness_auto),
                title: Text(
                  'Auto',
                  style: TextStyle(
                    color: autoBrightness ? primary : basic,
                  ),
                ),
                trailing: autoBrightness
                    ? Icon(
                        UniconsLine.check,
                        color: primary,
                      )
                    : null,
              ),
            ),
            PopupMenuItem(
              value: 'dark',
              child: ListTile(
                leading: Icon(Icons.brightness_2),
                title: Text(
                  'dark'.tr(),
                  style: TextStyle(
                    color: brightness == Brightness.dark ? primary : basic,
                  ),
                ),
                trailing: brightness == Brightness.dark
                    ? Icon(
                        UniconsLine.check,
                        color: primary,
                      )
                    : null,
              ),
            ),
            PopupMenuItem(
              value: 'light',
              child: ListTile(
                leading: Icon(Icons.brightness_5),
                title: Text(
                  'light'.tr(),
                  style: TextStyle(
                    color: brightness == Brightness.light ? primary : basic,
                  ),
                ),
                trailing: brightness == Brightness.light
                    ? Icon(
                        UniconsLine.check,
                        color: primary,
                      )
                    : null,
              ),
            ),
          ];
        },
      ),
    );
  }

  Widget bugButton() {
    if (isNarrow) {
      return IconButton(
        color: stateColors.accent,
        onPressed: () {
          launch(
            "https://github.com/rootasjey/relines/"
            "issues",
          );
        },
        icon: Icon(UniconsLine.bug),
      );
    }
    return TextButton.icon(
      style: TextButton.styleFrom(
        primary: stateColors.accent,
      ),
      onPressed: () {
        launch(
          "https://github.com/rootasjey/relines/"
          "issues",
        );
      },
      icon: Icon(UniconsLine.bug),
      label: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
        ),
        child: Text("report_bug".tr()),
      ),
    );
  }

  Widget closeButton() {
    return IconButton(
      onPressed: context.router.pop,
      color: Theme.of(context).iconTheme.color,
      icon: Icon(Icons.close),
    );
  }

  Widget developerEntry({
    @required Widget icon,
    @required PageRouteInfo value,
    @required String textData,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          icon,
          Padding(padding: const EdgeInsets.only(left: 12.0)),
          Text(textData),
        ],
      ),
    );
  }

  Iterable<Widget> getGuestButtons(bool isNarrow) {
    if (isNarrow) {
      return [userNarrowMenu()];
    }

    return [
      brightnessButton(),
      settingsButton(),
    ];
  }

  Widget groupedSectionEntry({
    @required Widget icon,
    @required PageRouteInfo value,
    @required String textData,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          icon,
          Padding(padding: const EdgeInsets.only(left: 12.0)),
          Text(textData),
        ],
      ),
    );
  }

  Widget groupedDropdown() {
    return PopupMenuButton(
      tooltip: 'More',
      child: Opacity(
        opacity: 0.6,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.more_horiz, color: stateColors.foreground),
              Icon(Icons.keyboard_arrow_down, color: stateColors.foreground),
            ],
          ),
        ),
      ),
      itemBuilder: (_) => <PopupMenuEntry<PageRouteInfo>>[
        groupedSectionEntry(
          value: HomeRoute(),
          icon: Icon(
            UniconsLine.home,
            color: stateColors.foreground.withOpacity(0.6),
          ),
          textData: 'home',
        ),
        PopupMenuDivider(),
        groupedSectionEntry(
          value: GitHubRoute(),
          icon: Icon(
            UniconsLine.github,
            color: stateColors.foreground.withOpacity(0.6),
          ),
          textData: 'GitHub',
        ),
        PopupMenuDivider(),
        groupedSectionEntry(
          value: AboutRoute(),
          icon: Icon(
            Icons.help_outline,
            color: stateColors.foreground.withOpacity(0.6),
          ),
          textData: 'about',
        ),
        groupedSectionEntry(
          value: ContactRoute(),
          icon: Icon(
            Icons.sms_outlined,
            color: stateColors.foreground.withOpacity(0.6),
          ),
          textData: 'contact',
        ),
        groupedSectionEntry(
          value: TosRoute(),
          icon: Icon(
            Icons.privacy_tip_outlined,
            color: stateColors.foreground.withOpacity(0.6),
          ),
          textData: 'Privacy Terms',
        ),
      ],
      onSelected: (PageRouteInfo pageRouteInfo) {
        if (pageRouteInfo.routeName == 'GitHubRoute') {
          launch('https://github.com/rootasjey/dev.fig.style');
          return;
        }

        context.router.root.push(pageRouteInfo);
      },
    );
  }

  Widget quotesByEntry({
    @required Widget icon,
    @required PageRouteInfo value,
    @required String textData,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          icon,
          Padding(padding: const EdgeInsets.only(left: 12.0)),
          Text(textData),
        ],
      ),
    );
  }

  Widget resourcesEntry({
    @required Widget icon,
    @required PageRouteInfo value,
    @required String textData,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          icon,
          Padding(padding: const EdgeInsets.only(left: 12.0)),
          Text(textData),
        ],
      ),
    );
  }

  Widget searchButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: IconButton(
        tooltip: 'Search',
        onPressed: null,
        // onPressed: () => context.router.root.push(SearchRoute()),
        color: stateColors.foreground,
        icon: Icon(
          Icons.search,
          color: stateColors.foreground.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget settingsButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 60.0),
      child: PopupMenuButton(
        tooltip: 'settings'.tr(),
        icon: Icon(
          Icons.settings,
          color: stateColors.foreground,
        ),
        itemBuilder: (_) => <PopupMenuEntry<AppBarSettings>>[
          PopupMenuItem(
            value: AppBarSettings.allSettings,
            child: Text('all_settings'.tr()),
          ),
        ],
        onSelected: (value) {
          switch (value) {
            case AppBarSettings.allSettings:
              context.router.root.push(SettingsRoute(showAppBar: true));
              break;
            default:
          }
        },
      ),
    );
  }

  Widget userAvatar({bool isNarrow = true}) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20.0,
        right: 60.0,
      ),
      child: PopupMenuButton<PageRouteInfo>(
        icon: Icon(
          UniconsLine.user_circle,
          color: stateColors.primary,
        ),
        tooltip: 'Show user menu',
        onSelected: (pageRouteInfo) {
          if (pageRouteInfo.routeName == SignOutRoute.name) {
            stateUser.signOut(
              context: context,
              redirectOnComplete: true,
            );
            return;
          }

          context.router.root.push(pageRouteInfo);
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<PageRouteInfo>>[
          PopupMenuItem(
            value: NavigationHelper.getSettingsRoute(),
            child: ListTile(
              leading: Icon(Icons.settings),
              title: Text(
                'Settings',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget userNarrowMenu() {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert),
      itemBuilder: (context) => <PopupMenuEntry<PageRouteInfo>>[
        PopupMenuItem(
          value: SettingsRoute(showAppBar: true),
          child: ListTile(
            leading: Icon(UniconsLine.setting),
            title: Text('settings'.tr()),
          ),
        ),
      ],
      onSelected: (pageRouteInfo) {
        context.router.root.navigate(pageRouteInfo);
      },
    );
  }
}
