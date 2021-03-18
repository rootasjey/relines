import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:relines/types/enums.dart';
import 'package:relines/utils/fonts.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

class ImageCard extends StatefulWidget {
  final bool showZoomIcon;
  final bool selected;

  final Color imageBackgroundColor;
  final Color selectionColor;

  final double width;
  final double height;

  final Function(int) openImage;

  final EdgeInsets padding;

  final ImageCardType type;
  final int index;

  final String name;
  final String imageUrl;

  final VoidCallback onTap;

  const ImageCard({
    Key key,
    @required this.name,
    this.imageUrl,
    this.width = 240.0,
    this.height = 320.0,
    this.onTap,
    this.padding = const EdgeInsets.only(right: 20.0),
    this.imageBackgroundColor = Colors.black,
    this.selected = false,
    this.selectionColor = Colors.blue,
    this.type = ImageCardType.compact,
    this.openImage,
    this.index,
    this.showZoomIcon = false,
  }) : super(key: key);

  @override
  _ImageCardState createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> with TickerProviderStateMixin {
  Animation<double> scaleAnimation;
  AnimationController scaleAnimationController;

  Color imgBgColor = Colors.blue;
  Color initialImgBgColor = Colors.blue;
  Color hoverImgBgColor = Colors.blue;

  double elevation = 4.0;
  double initialElevation = 4.0;
  double hoverElevation = 8.0;

  @override
  void initState() {
    super.initState();

    initialImgBgColor = widget.imageBackgroundColor != null
        ? widget.imageBackgroundColor.withOpacity(0.7)
        : Colors.black26;

    imgBgColor = initialImgBgColor;
    hoverImgBgColor = imgBgColor.withOpacity(imgBgColor.opacity / 2);

    scaleAnimationController = AnimationController(
      lowerBound: 0.8,
      upperBound: 1.0,
      duration: 500.milliseconds,
      vsync: this,
    );

    scaleAnimation = CurvedAnimation(
      parent: scaleAnimationController,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    scaleAnimationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == ImageCardType.compact) {
      return compactLayout();
    }

    return extendedLayout();
  }

  Widget compactLayout() {
    return Container(
      width: widget.width,
      height: widget.height,
      padding: widget.padding,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Card(
          elevation: elevation,
          shape: widget.selected
              ? RoundedRectangleBorder(
                  side: BorderSide(
                    color: widget.selectionColor,
                    width: 3.0,
                  ),
                )
              : null,
          child: InkWell(
            onTap: widget.onTap,
            onHover: (isHover) {
              if (isHover) {
                scaleAnimationController.forward();
              } else {
                scaleAnimationController.reverse();
              }

              setState(() {
                elevation = isHover ? hoverElevation : initialElevation;
                imgBgColor = isHover ? hoverImgBgColor : initialImgBgColor;
              });
            },
            child: Stack(
              children: [
                background(),
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  child: Container(
                    width: widget.width,
                    padding: const EdgeInsets.all(8.0),
                    child: Opacity(
                      opacity: 0.8,
                      child: Text(
                        widget.name,
                        maxLines: 6,
                        softWrap: true,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget extendedLayout() {
    return Padding(
      padding: widget.padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: widget.width,
            padding: const EdgeInsets.only(right: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: widget.onTap,
                  child: Container(
                    padding: const EdgeInsets.only(
                      left: 8.0,
                    ),
                    child: Opacity(
                      opacity: 0.6,
                      child: Text(
                        widget.name,
                        softWrap: true,
                        style: FontsUtils.mainStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                ScaleTransition(
                  scale: scaleAnimation,
                  child: Card(
                    elevation: elevation,
                    shape: widget.selected
                        ? RoundedRectangleBorder(
                            side: BorderSide(
                              color: widget.selectionColor,
                              width: 3.0,
                            ),
                          )
                        : null,
                    child: InkWell(
                      onTap: widget.onTap,
                      onHover: (isHover) {
                        if (isHover) {
                          scaleAnimationController.forward();
                        } else {
                          scaleAnimationController.reverse();
                        }

                        setState(() {
                          elevation =
                              isHover ? hoverElevation : initialElevation;
                          imgBgColor =
                              isHover ? hoverImgBgColor : initialImgBgColor;
                        });
                      },
                      child: background(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.showZoomIcon)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: IconButton(
                tooltip: "zoom".tr(),
                onPressed: () => widget.openImage(widget.index),
                icon: Opacity(
                  opacity: 0.6,
                  child: Icon(UniconsLine.search_plus),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget background() {
    Widget imgWidget = Container(
      width: widget.width,
      height: widget.height,
    );

    final imageUrl = widget.imageUrl;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      imgWidget = Opacity(
        opacity: 0.8,
        child: Hero(
          tag: widget.name,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: widget.width,
            height: widget.height,
          ),
        ),
      );
    }

    return Stack(
      children: [
        imgWidget,
        Positioned.fill(
          child: Opacity(
            opacity: 0.5,
            child: Container(
              color: imgBgColor,
            ),
          ),
        ),
      ],
    );
  }
}
