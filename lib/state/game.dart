class Game {
  static int _maxQuestions = 10;

  static int get maxQuestions => _maxQuestions;

  bool maxQuestionsIs(int count) {
    return _maxQuestions == count;
  }

  void setMaxQuestions(int count) {
    if (count > 0 && count < 101) {
      _maxQuestions = count;
      return;
    }

    _maxQuestions = 10;
  }
}

var stateGame = Game();
