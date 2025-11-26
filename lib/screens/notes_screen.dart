// screens/notes_screen.dart
import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/note_service.dart';
import '../widgets/note_item.dart';
import '../widgets/add_note_modal.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Note> notes = [];
  bool isLoading = true;
  final NoteService _noteService = NoteService();

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final fetchedNotes = await _noteService.getNotes(authProvider.user!.id);
      setState(() {
        notes = fetchedNotes;
        isLoading = false;
      });
    } catch (e) {
      print('Failed to fetch notes: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _addNote(String text) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) return;

    try {
      final newNote = await _noteService.addNote(text, authProvider.user!.id);
      if (newNote != null) {
        setState(() {
          notes.insert(0, newNote);
        });
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Failed to add note: $e');
    }
  }

  // ---------------------------
  // AJOUT : delete + update handlers
  // ---------------------------

  Future<void> _deleteNote(String noteId) async {
    try {
      await _noteService.deleteNote(noteId);
      setState(() {
        notes.removeWhere((note) => note.id == noteId);
      });
    } catch (e) {
      print('Failed to delete note: $e');
    }
  }

  Future<void> _updateNote(String noteId, String newText) async {
    try {
      final updatedNote = await _noteService.updateNote(noteId, newText);
      if (updatedNote != null) {
        setState(() {
          int index = notes.indexWhere((note) => note.id == noteId);
          if (index != -1) notes[index] = updatedNote;
        });
      }
    } catch (e) {
      print('Failed to update note: $e');
    }
  }

  // ---------------------------
  // AJOUT : Empty Notes Widget
  // ---------------------------

  Widget _buildEmptyNotesView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "You don't have any notes yet.",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Tap the + button to create your first note!",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ---------------------------
  // AJOUT : Nouveau Build complet
  // ---------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Notes'),
        actions: [
          // Logout or actions
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : notes.isEmpty
              ? _buildEmptyNotesView()
              : ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    return NoteItem(
                      note: notes[index],
                      onDelete: _deleteNote,
                      onUpdate: _updateNote,
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => AddNoteModal(onSave: _addNote),
          );
        },
      ),
    );
  }
}
