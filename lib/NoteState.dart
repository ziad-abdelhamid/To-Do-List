class Note {
  final String title;
  final String description;
  final String category;

  Note({
    required this.title,
    required this.description,
    required this.category,
  });
}

class NoteState {
  final List<Note> notes;

  NoteState({required this.notes});
}
