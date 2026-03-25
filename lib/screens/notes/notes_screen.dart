import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notes_provider.dart';
import '../../models/note.dart';
import 'note_detail_screen.dart';

const _noteColors = [
  0xFFFFF9C4, // yellow
  0xFFE1F5FE, // light blue
  0xFFF3E5F5, // purple
  0xFFE8F5E9, // green
  0xFFFFEBEE, // red
  0xFFFFF3E0, // orange
];

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const NoteDetailScreen(),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New Note'),
      ),
      body: Consumer<NotesProvider>(
        builder: (context, provider, _) {
          final notes = provider.notes;
          if (notes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sticky_note_2_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No notes yet. Tap + to add one!',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: notes.length,
            itemBuilder: (context, i) => _NoteCard(
              note: notes[i],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NoteDetailScreen(note: notes[i]),
                ),
              ),
              onDelete: () => context.read<NotesProvider>().delete(notes[i].id),
            ),
          );
        },
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NoteCard({
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Color(note.color),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: onDelete,
                    child: const Icon(Icons.close, size: 16, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  note.body,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                  overflow: TextOverflow.fade,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
