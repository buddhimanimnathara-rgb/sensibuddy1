class GameAnalytics {
  int correctAnswers = 0;
  int wrongAnswers = 0;
  int attempts = 0;

  void recordCorrect() {
    correctAnswers++;
    attempts++;
  }

  void recordWrong() {
    wrongAnswers++;
    attempts++;
  }

  double get accuracy {
    if (attempts == 0) return 0;

    return (correctAnswers / attempts) * 100;
  }

  void reset() {
    correctAnswers = 0;
    wrongAnswers = 0;
    attempts = 0;
  }
}