import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'main.dart';
import 'profile_page.dart';

class PostIdeaPage extends StatefulWidget {
  @override
  _PostIdeaPageState createState() => _PostIdeaPageState();
}

class _PostIdeaPageState extends State<PostIdeaPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  List<File> attachments = [];

  int _selectedIndex = 0;

  final List<Widget> _pages = [
    MyApp(),
    PostIdeaPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create an Idea!"),
        actions: [
          TextButton(
            onPressed: _submitIdea,
            child: Text('Post Idea',
                style: TextStyle(
                    fontSize: 18, color: Color.fromARGB(255, 46, 0, 230))),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(hintText: 'Add a title...'),
            ),

            Flexible(
              child: TextField(
                controller: descriptionController,
                decoration: InputDecoration(hintText: 'Add a description...'),
                maxLines: 5, // Initially expanded to 5 lines
              ),
            ),

            TextButton.icon(
              onPressed: _attachFile,
              icon: Icon(Icons.attach_file),
              label: Text('Add Attachment'),
            ),

            // Display added attachments

            Text('Attachments: ${attachments.length} files')
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline, color: Colors.blue),
            label: 'Post Idea',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          _onItemTapped(index);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => _pages[index]),
          );
        },
      ),
    );
  }

  void _attachFile() async {
    final XFile? file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (file != null) {
      setState(() {
        attachments.add(File(file.path));
      });
    }
  }

  void _submitIdea() async {
    final title = titleController.text;
    final description = descriptionController.text;

    // Save idea to Firebase
    final ideaRef = await FirebaseFirestore.instance.collection('ideas').add({
      'title': title,
      'description': description,
    });

    // Upload attachments to Firebase Storage
    final storageRef = FirebaseStorage.instance.ref();
    for (int i = 0; i < attachments.length; i++) {
      final file = attachments[i];
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i';
      final uploadTask = storageRef.child(fileName).putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});

      if (snapshot.state == TaskState.success) {
        final downloadURL = await snapshot.ref.getDownloadURL();
        await ideaRef.update({
          'attachments': FieldValue.arrayUnion([downloadURL]),
        });
      }
    }

    // Clear text fields
    titleController.clear();
    descriptionController.clear();

    // Clear attachments
    setState(() {
      attachments.clear();
    });

    // Hide keyboard
    FocusScope.of(context).unfocus();
  }
}
