import 'package:relines/utils/language.dart';

class Game {
  static String _language = Language.current;
  static int _maxQuestions = 10;

  static String get language => _language;
  static int get maxQuestions => _maxQuestions;

  static bool maxQuestionsIs(int count) {
    return _maxQuestions == count;
  }

  static void setLanguage(String lang) {
    if (Language.available().contains(lang)) {
      _language = lang;
      return;
    }
  }

  static void setMaxQuestions(int count) {
    if (count > 0 && count < 101) {
      _maxQuestions = count;
      return;
    }

    _maxQuestions = 10;
  }
}
