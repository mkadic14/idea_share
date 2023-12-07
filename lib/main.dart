import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'profile_page.dart';
import 'postidea_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
        title: SizedBox(
          height: AppBar().preferredSize.height,
          child: Padding(
            padding: const EdgeInsets.only(left: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'lib/images/IdeaShare.png',
                  width: 140,
                ),
              ],
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2.0),
          child: Container(
            height: 2.0,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
// Navigate to settings page
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('ideas').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Text('No data available');
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;

              String attachmentUrl = data['attachment'] ?? '';

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                height: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      data['title'],
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      data['description'],
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    attachmentUrl.isNotEmpty
                        ? Image.network(
                            attachmentUrl,
                            height: 100,
                            width: 100,
                          )
                        : Text('No attachment available'),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: Colors.blue,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
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
}
