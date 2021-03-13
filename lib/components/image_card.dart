import 'package:flutter/material.dart';
import 'package:relines/state/colors.dart';
import 'package:relines/types/enums.dart';
import 'package:supercharged/supercharged.dart';

class ImageCard extends StatefulWidget {
  final String name;
  final String imageUrl;
  final double width;
  final double height;
  final VoidCallback onTap;
  final Color imageBackgroundColor;
  final bool selected;
  final Color selectionColor;
  final EdgeInsets padding;
  final ImageCardType type;

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
      padding: const EdgeInsets.only(right: 20.0),
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
    return Container(
      width: widget.width,
      padding: const EdgeInsets.only(right: 20.0),
      child: Column(
        children: [
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
                    elevation = isHover ? hoverElevation : initialElevation;
                    imgBgColor = isHover ? hoverImgBgColor : initialImgBgColor;
                  });
                },
                child: background(),
              ),
            ),
          ),
          InkWell(
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Opacity(
                opacity: 0.8,
                child: Text(
                  widget.name,
                  softWrap: true,
                  style: TextStyle(
                    color: stateColors.foreground,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
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
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: widget.width,
          height: widget.height,
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
