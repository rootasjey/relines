import 'package:auto_route/auto_route.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:disfigstyle/components/animated_app_icon.dart';
import 'package:disfigstyle/components/fade_in_y.dart';
import 'package:disfigstyle/components/page_app_bar.dart';
import 'package:disfigstyle/components/sliver_edge_padding.dart';
import 'package:disfigstyle/router/app_router.gr.dart';
import 'package:disfigstyle/state/colors.dart';
import 'package:disfigstyle/utils/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

class CreateApp extends StatefulWidget {
  @override
  _CreateAppState createState() => _CreateAppState();
}

class _CreateAppState extends State<CreateApp> {
  final scrollController = ScrollController();

  TextEditingController nameController;
  TextEditingController descriptionController;
  FocusNode descriptionFocusNode;

  String name = '';
  String description = '';

  bool isCreating = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    descriptionController = TextEditingController();
    descriptionFocusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    nameController?.dispose();
    descriptionController?.dispose();
    descriptionFocusNode?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverEdgePadding(),
          appBar(),
          body(),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 200.0),
          ),
        ],
      ),
    );
  }

  Widget appBar() {
    final width = MediaQuery.of(context).size.width;
    double titleLeftPadding = 70.0;
    double bottomContentLeftPadding = 94.0;

    if (width < Constants.maxMobileWidth) {
      titleLeftPadding = 0.0;
      bottomContentLeftPadding = 24.0;
    }

    return PageAppBar(
      textTitle: 'Create app',
      textSubTitle: 'Fill out the necessaries fields',
      titlePadding: EdgeInsets.only(
        left: titleLeftPadding,
      ),
      bottomPadding: EdgeInsets.only(
        left: bottomContentLeftPadding,
        bottom: 10.0,
      ),
      showNavBackIcon: true,
      onTitlePressed: () {
        scrollController.animateTo(
          0,
          duration: 250.milliseconds,
          curve: Curves.easeIn,
        );
      },
    );
  }

  Widget body() {
    if (isCreating) {
      return SliverPadding(
        padding: const EdgeInsets.only(top: 24.0),
        sliver: SliverList(
          delegate: SliverChildListDelegate.fixed([
            AnimatedAppIcon(),
            Center(
              child: Text(
                "Creating new app...",
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          ]),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(top: 24.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Column(
            children: [
              nameInput(),
              descriptionInput(),
              validationButton(),
            ],
          ),
        ]),
      ),
    );
  }

  Widget nameInput() {
    return FadeInY(
      delay: 100.milliseconds,
      beginY: 50.0,
      child: Container(
        width: 300.0,
        child: TextFormField(
          autofocus: true,
          controller: nameController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            icon: Icon(Icons.location_history_outlined),
            labelText: 'Name',
          ),
          onChanged: (value) {
            name = value;
          },
          onFieldSubmitted: (value) => descriptionFocusNode.requestFocus(),
          validator: (value) {
            if (value.isEmpty) {
              return "App's name cannot be empty.";
            }

            return null;
          },
        ),
      ),
    );
  }

  Widget descriptionInput() {
    return FadeInY(
      delay: 200.milliseconds,
      beginY: 50.0,
      child: Container(
        width: 300.0,
        padding: EdgeInsets.only(
          top: 24.0,
        ),
        child: TextFormField(
          controller: descriptionController,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            icon: Icon(Icons.list),
            labelText: 'Description',
          ),
          onChanged: (value) {
            description = value;
          },
          onFieldSubmitted: (value) => createApp(),
        ),
      ),
    );
  }

  Widget validationButton() {
    return FadeInY(
      delay: 300.milliseconds,
      beginY: 50.0,
      child: Padding(
        padding: const EdgeInsets.only(top: 48.0),
        child: ElevatedButton(
          onPressed: createApp,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 12,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Validate",
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(UniconsLine.check),
                ),
              ],
            ),
          ),
          style: ElevatedButton.styleFrom(
            primary: stateColors.secondary,
          ),
        ),
      ),
    );
  }

  void createApp() async {
    setState(() => isCreating = true);

    try {
      final callable = CloudFunctions(
        app: Firebase.app(),
        region: 'europe-west3',
      ).getHttpsCallable(
        functionName: 'developers-createApp',
      );

      await callable.call({
        'name': name,
        'description': description,
      });

      setState(() => isCreating = false);

      context.router.root.push(
        DashboardPageRoute(
          children: [AppsDeepRoute()],
        ),
      );
    } on CloudFunctionsException catch (exception) {
      setState(() => isCreating = false);
      debugPrint("[code: ${exception.code}] - ${exception.message}");
    } catch (error) {
      setState(() => isCreating = false);
      debugPrint(error.toString());
    }
  }
}
