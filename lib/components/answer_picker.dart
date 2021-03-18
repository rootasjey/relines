import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:relines/components/fade_in_x.dart';
import 'package:relines/components/gallery_photo_view_wrapper.dart';
import 'package:relines/components/image_card.dart';
import 'package:relines/types/enums.dart';
import 'package:relines/types/gallery_item.dart';
import 'package:relines/types/game_question_response.dart';
import 'package:relines/utils/constants.dart';

class AnswerPicker extends StatefulWidget {
  final String questionType;
  final String selectedId;
  final GameQuestionResponse questionResponse;
  final void Function(String) onPickAnswer;

  const AnswerPicker({
    Key key,
    @required this.questionType,
    @required this.questionResponse,
    @required this.selectedId,
    @required this.onPickAnswer,
  }) : super(key: key);

  @override
  _AnswerPickerState createState() => _AnswerPickerState();
}

class _AnswerPickerState extends State<AnswerPicker> {
  List<GalleryItem> galleryItems = [];

  @override
  void initState() {
    super.initState();
    populateGalleryItems();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questionType == 'author') {
      return authorsRow(context);
    }

    return referencesRow(context);
  }

  Widget authorsRow(BuildContext context) {
    if (widget.questionResponse.authorProposals == null) {
      return Container();
    }

    final size = MediaQuery.of(context).size;
    double height = 320.0;
    double width = 240.0;

    if (size.width < Constants.maxMobileWidth) {
      height = 150.0;
      width = 360.0;
    }

    final children = widget.questionResponse.authorProposals.values.mapIndexed(
      (index, proposal) {
        return FadeInX(
          beginX: 20.0,
          delay: Duration(milliseconds: 200 * index),
          child: ImageCard(
            name: proposal.name,
            height: height,
            width: width,
            index: index,
            showZoomIcon: true,
            type: ImageCardType.extended,
            imageUrl: proposal.urls.image,
            selected: widget.selectedId == proposal.id,
            padding: const EdgeInsets.only(bottom: 24.0),
            onTap: () {
              if (widget.onPickAnswer != null) {
                widget.onPickAnswer(proposal.id);
              }
            },
            openImage: openImage,
          ),
        );
      },
    ).toList();

    if (size.width < Constants.maxMobileWidth) {
      return Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: Column(
          children: children,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  Widget referencesRow(BuildContext context) {
    if (widget.questionResponse.referenceProposals == null) {
      return Container();
    }

    final size = MediaQuery.of(context).size;
    double height = 320.0;
    double width = 240.0;

    if (size.width < Constants.maxMobileWidth) {
      height = 150.0;
      width = 360.0;
    }

    final children =
        widget.questionResponse.referenceProposals.values.mapIndexed(
      (index, proposal) {
        return FadeInX(
          beginX: 20.0,
          delay: Duration(milliseconds: 200 * index),
          child: ImageCard(
            name: proposal.name,
            height: height,
            width: width,
            index: index,
            showZoomIcon: true,
            type: ImageCardType.extended,
            imageUrl: proposal.urls.image,
            selected: widget.selectedId == proposal.id,
            padding: const EdgeInsets.only(bottom: 24.0),
            onTap: () {
              if (widget.onPickAnswer != null) {
                widget.onPickAnswer(proposal.id);
              }
            },
            openImage: openImage,
          ),
        );
      },
    ).toList();

    if (size.width < Constants.maxMobileWidth) {
      return Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: Column(
          children: children,
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  void openImage(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryPhotoViewWrapper(
          galleryItems: galleryItems,
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
          initialIndex: index,
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }

  void populateGalleryItems() {
    if (widget.questionType == 'author') {
      final values = widget.questionResponse.authorProposals.values;

      values.forEach((author) {
        galleryItems.add(
          GalleryItem(
            name: author.name,
            url: author.urls.image,
          ),
        );
      });

      return;
    }

    final values = widget.questionResponse.referenceProposals.values;

    values.forEach((reference) {
      galleryItems.add(
        GalleryItem(
          name: reference.name,
          url: reference.urls.image,
        ),
      );
    });
  }
}
