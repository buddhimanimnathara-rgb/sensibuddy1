class StoryModel {
  final String id;

  final String emotion;

  // si / en / ta
  final String language;

  final String title;

  final String content;

  final String lesson;

  const StoryModel({
    required this.id,
    required this.emotion,
    required this.language,
    required this.title,
    required this.content,
    required this.lesson,
  });
}