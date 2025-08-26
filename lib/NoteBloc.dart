import 'package:flutter_bloc/flutter_bloc.dart';
import 'NoteEvent.dart';
import 'NoteState.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  NoteBloc() : super(NoteState(notes: [])) {
    on<AddNote>((event, emit) {
      final updatedNotes = List<Note>.from(state.notes)
        ..add(
          Note(
            title: event.title,
            description: event.description,
            category: event.category,
          ),
        );
      emit(NoteState(notes: updatedNotes));
    });

    on<RemoveNote>((event, emit) {
      final updatedNotes = List<Note>.from(state.notes)..removeAt(event.index);
      emit(NoteState(notes: updatedNotes));
    });
  }
}
