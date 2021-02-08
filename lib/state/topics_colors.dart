import 'dart:convert';
import 'dart:ui';

import 'package:disfigstyle/types/topic_color.dart';
import 'package:disfigstyle/utils/api_keys.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobx/mobx.dart';

part 'topics_colors.g.dart';

class TopicsColors = TopicsColorsBase with _$TopicsColors;

abstract class TopicsColorsBase with Store {
  @observable
  List<TopicColor> topicsColors = [];

  @action
  Future fetchTopicsColors() async {
    try {
      final response = await http.get(
        'https://api.fig.style/v1/topics',
        headers: {
          'authorization': ApiKeys.figStyle,
        },
      );

      final Map<String, dynamic> jsonObj = jsonDecode(response.body);
      final List<dynamic> rawList = jsonObj['response'];
      final List<TopicColor> list = [];

      rawList.forEach((element) {
        final topicColor = TopicColor.fromJSON(element);
        list.add(topicColor);
      });

      topicsColors = list;
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  TopicColor find(String topic) {
    final exists = topicsColors.any((element) => element.name == topic);

    if (!exists) {
      return null;
    }

    final topicColor =
        topicsColors.firstWhere((element) => element.name == topic);

    return topicColor;
  }

  Color getColorFor(String topic) {
    final topicColor = find(topic);

    if (topicColor == null) {
      return Color(0xFF58595B);
    }

    return Color(topicColor.decimal);
  }

  @action
  void setColors(List<TopicColor> topics) {
    topicsColors = topics;
  }

  List<TopicColor> shuffle({int max = 0}) {
    final copy = topicsColors.toList();
    copy.shuffle();

    if (max == 0) {
      return copy;
    }

    max = max > copy.length ? copy.length : max;

    return copy.sublist(0, max);
  }
}

final appTopicsColors = TopicsColors();
