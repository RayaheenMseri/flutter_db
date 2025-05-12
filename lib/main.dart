import 'package:flutter/material.dart';
import 'notes_database.dart';

void main() {
  runApp(MaterialApp(
    title: 'Notes App',
    home: NotesHome(),
    supportedLocales: [
      Locale('en'),
    ],
  ));
}

class NotesHome extends StatefulWidget {
  @override
  _NotesHomeState createState() => _NotesHomeState();
}

class _NotesHomeState extends State<NotesHome> {
  final db = NotesDatabase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notes')),
      body: NoteList(db: db),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final content = await _showAddNoteDialog(context);
          if (content != null && content.isNotEmpty) {
            await db.addNote(content);
            setState(() {});  // This will refresh the UI
          }
        },
      ),
    );
  }

  Future<String?> _showAddNoteDialog(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Add Note'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel')),
          TextButton(
              onPressed: () => {
                Navigator.pop(context, controller.text),
              },
              child: Text('Save')),
        ],
      ),
    );
  }
}

class NoteList extends StatefulWidget {
  final NotesDatabase db;
  NoteList({required this.db});

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.db.getAllNotes(),
      builder: (context, AsyncSnapshot<List<Note>> snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        final notes = snapshot.data!;
        return ListView.builder(
          itemCount: notes.length,
          itemBuilder: (_, index) {
            final note = notes[index];
            return ListTile(
              title: Text(note.content),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  await widget.db.deleteNote(note.id);
                  setState(() {});
                },
              ),
            );
          },
        );
      },
    );
  }
}
