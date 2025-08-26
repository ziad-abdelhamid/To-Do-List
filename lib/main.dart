import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

/// -------- Events --------
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

/// -------- State --------
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

/// -------- Bloc --------
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

/// -------- App --------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NoteBloc(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: NoteGridPage(),
      ),
    );
  }
}

/// -------- Grid Page --------
class NoteGridPage extends StatefulWidget {
  const NoteGridPage({super.key});

  @override
  State<NoteGridPage> createState() => _NoteGridPageState();
}

class _NoteGridPageState extends State<NoteGridPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final List<String> categories = ["Other", "Work", "Study"];
  String selectedCategory = "Other";

  @override
  Widget build(BuildContext context) {
    final noteBloc = BlocProvider.of<NoteBloc>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Notes with Drag & Drop")),
      body: Column(
        children: [
          /// Add Note Form
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: "Title"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: "Description"),
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: selectedCategory,
                  items: categories
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => selectedCategory = val);
                    }
                  },
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_titleController.text.isNotEmpty &&
                        _descController.text.isNotEmpty) {
                      noteBloc.add(
                        AddNote(
                          _titleController.text,
                          _descController.text,
                          selectedCategory,
                        ),
                      );
                      _titleController.clear();
                      _descController.clear();
                    }
                  },
                  child: const Text("Add Note"),
                ),
              ],
            ),
          ),

          /// Notes Grid
          Expanded(
            child: BlocBuilder<NoteBloc, NoteState>(
              builder: (context, state) {
                if (state.notes.isEmpty) {
                  return const Center(child: Text("No notes yet"));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: state.notes.length,
                  itemBuilder: (context, index) {
                    final note = state.notes[index];
                    return Draggable<int>(
                      data: index,
                      feedback: Material(
                        color: Colors.transparent,
                        child: Container(
                          width: 150,
                          height: 150,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            note.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      childWhenDragging: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              note.description,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Text(
                              "#${note.category}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          /// Trash Bin
          DragTarget<int>(
            onAccept: (index) {
              noteBloc.add(RemoveNote(index));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Note deleted")));
            },
            builder: (context, candidateData, rejectedData) {
              return Container(
                height: 100,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: candidateData.isEmpty ? Colors.red[300] : Colors.red,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(Icons.delete, size: 40, color: Colors.white),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
