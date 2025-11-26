// services/note_service.dart
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import '../models/note_model.dart';
import 'appwrite_config.dart';

class NoteService {
  final Databases databases;

  NoteService() : databases = Databases(AppwriteConfig.client);

  Future<List<Note>> getNotes(String userId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.collectionId,
        queries: [
          Query.equal('user_id', userId) // Filter by user_id
        ],
      );

      return response.documents.map((doc) => Note.fromJson(doc.data)).toList();
    } catch (e) {
      print('Error fetching notes: $e');
      return [];
    }
  }

  Future<Note?> addNote(String text, String userId) async {
    try {
      final response = await databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.collectionId,
        documentId: ID.unique(),
        data: {
          'text': text,
          'user_id': userId // Add user ID to the note
        },
      );

      return Note.fromJson(response.data);
    } catch (e) {
      print('Error adding note: $e');
      return null;
    }
  }

  // Update and delete methods remain similar
}