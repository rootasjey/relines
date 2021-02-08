import 'package:auto_route/auto_route.dart';
import 'package:disfigstyle/components/app_icon.dart';
import 'package:disfigstyle/router/app_router.gr.dart';
import 'package:disfigstyle/state/colors.dart';
import 'package:disfigstyle/utils/app_storage.dart';
import 'package:disfigstyle/utils/brightness.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

class DesktopAppBar extends StatefulWidget {
  final bool automaticallyImplyLeading;
  final bool showUserMenu;
  final bool showCloseButton;
  final bool pinned;

  /// Show appication icon if true. Hide it if false. Default tot true.
  final bool showAppIcon;

  /// Control left padding of the first dropdown. Default to 32.0;
  final double leftPaddingFirstDropdown;

  final EdgeInsets padding;

  final Function onTapIconHeader;

  final String title;

  DesktopAppBar({
    this.automaticallyImplyLeading = true,
    this.onTapIconHeader,
    this.padding = EdgeInsets.zero,
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

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constrains) {
        final isNarrow = constrains.crossAxisExtent < 600.0;
        useIconButton = constrains.crossAxisExtent < 1000.0;
        useGroupedDropdown = constrains.crossAxisExtent < 800.0;

        bool showUserMenu = !isNarrow;

        if (widget.showUserMenu != null) {
          showUserMenu = widget.showUserMenu;
        }

        return Observer(
          builder: (_) {
            final userSectionWidgets = <Widget>[];

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
                padding: widget.padding,
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
                          onPressed: () => context.router.pop(),
                          icon: Icon(Icons.arrow_back),
                        ),
                      ),
                    if (widget.showAppIcon)
                      AppIcon(
                        size: 30.0,
                        padding: const EdgeInsets.only(left: 10.0),
                        onTap: widget.onTapIconHeader,
                      ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        right: 32.0,
                      ),
                      child: Text(
                        "Beta",
                        style: TextStyle(
                          color: Colors.pink,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        launch(
                          "https://github.com/rootasjey/dis.fig.style/"
                          "issues",
                        );
                      },
                      icon: Icon(UniconsLine.bug),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text("Signal a bug"),
                      ),
                    ),
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
        tooltip: 'Brightness',
        onSelected: (value) {
          if (value == 'auto') {
            setAutoBrightness(context);
            return;
          }

          final brightness =
              value == 'dark' ? Brightness.dark : Brightness.light;

          setBrightness(context, brightness);
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
                  'Dark',
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
                  'Light',
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

  Widget closeButton() {
    return IconButton(
      onPressed: context.router.pop,
      color: Theme.of(context).iconTheme.color,
      icon: Icon(Icons.close),
    );
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
}
