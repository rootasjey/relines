import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:relines/state/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:unicons/unicons.dart';

class BasePageAppBar extends StatefulWidget {
  /// Appbar's expanded height.
  final double expandedHeight;

  /// Appbar's collapsed height.
  final double collapsedHeight;

  /// Appbar's  height.
  final double toolbarHeight;

  /// Typically open a drawer. Menu icon will be hidden if null.
  final Function onPressedMenu;

  /// If true, AppBar will stayed visible while scrolling.
  final bool pinned;

  /// If true, the back icon will be visible.
  final bool showNavBackIcon;

  /// If set, will be shown at the bottom of the title.
  final Widget bottom;

  /// App bar title.
  final String textTitle;

  /// Will override [textTitle] if set.
  final Widget title;

  BasePageAppBar({
    this.toolbarHeight = kToolbarHeight,
    this.collapsedHeight,
    this.expandedHeight = 210.0,
    this.onPressedMenu,
    this.pinned = false,
    this.showNavBackIcon = true,
    this.bottom,
    this.textTitle,
    this.title,
  });

  @override
  _BasePageAppBarState createState() => _BasePageAppBarState();
}

class _BasePageAppBarState extends State<BasePageAppBar> {
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return SliverAppBar(
          floating: true,
          snap: true,
          pinned: widget.pinned,
          toolbarHeight: widget.toolbarHeight,
          collapsedHeight: widget.collapsedHeight,
          backgroundColor: stateColors.appBackground.withOpacity(1.0),
          expandedHeight: widget.expandedHeight,
          automaticallyImplyLeading: false,
          title: titleContainer(),
          centerTitle: false,
          bottom: bottomContainer(),
        );
      },
    );
  }

  Widget titleContainer() {
    return LayoutBuilder(
      builder: (context, constrains) {
        double titleFontSize = 40.0;

        if (constrains.maxWidth < 700.0) {
          titleFontSize = 25.0;
        }

        return headerSection(titleFontSize);
      },
    );
  }

  Widget headerSection(double titleFontSize) {
    return widget.title != null
        ? widget.title
        : Row(
            children: <Widget>[
              if (widget.showNavBackIcon) ...[
                IconButton(
                  onPressed: context.router.pop,
                  tooltip: 'back'.tr(),
                  icon: Icon(UniconsLine.arrow_left),
                ),
                Padding(padding: const EdgeInsets.only(right: 45.0)),
              ],
              Text(
                widget.textTitle,
                style: TextStyle(
                  fontSize: titleFontSize,
                ),
              ),
            ],
          );
  }

  Widget bottomContainer() {
    if (widget.bottom == null) {
      return null;
    }

    return PreferredSize(
      child: widget.bottom,
      preferredSize: Size.fromHeight(20.0),
    );
  }
}
