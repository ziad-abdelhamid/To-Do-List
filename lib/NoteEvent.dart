abstract class NoteEvent {}

class AddNote extends NoteEvent {
  final String title;
  final String description;
  final String category;

  AddNote(this.title, this.description, this.category);
}

class RemoveNote extends NoteEvent {
  final int index;

  RemoveNote(this.index);
}
