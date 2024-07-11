import 'package:berita_app/models/news.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class CreateNewsPage extends StatefulWidget {
  @override
  _CreateNewsPageState createState() => _CreateNewsPageState();
}

class _CreateNewsPageState extends State<CreateNewsPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  File? _image;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadNews() async {
  if (_image == null) return;

  try {
    // Determine the file extension
    String fileExtension = _image!.path.split('.').last;
    
    // Ensure the file name includes the extension
    String fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
    Reference storageReference =
        FirebaseStorage.instance.ref().child('thumbnails/$fileName');
    UploadTask uploadTask = storageReference.putFile(_image!);

    // Wait for the upload to complete
    TaskSnapshot taskSnapshot = await uploadTask;
    String imageUrl = await taskSnapshot.ref.getDownloadURL();

    NewsModel newNews = NewsModel(
      author: _authorController.text,
      content: _contentController.text,
      created_at: Timestamp.now(),
      thumbnail: imageUrl,
      title: _titleController.text,
      bookmarkedBy: [""],
    );

    // Save news data to Firestore
    await FirebaseFirestore.instance.collection('news').add(newNews.toJson());

    // Clear the form
    _titleController.clear();
    _authorController.clear();
    _contentController.clear();
    setState(() {
      _image = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('News created successfully!')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to create news: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create News')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[200],
                child: _image == null
                    ? Center(child: Text('Tap to select image'))
                    : Image.file(_image!, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _authorController,
              decoration: InputDecoration(labelText: 'Author'),
            ),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Content'),
              maxLines: 10,
              keyboardType: TextInputType.multiline,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadNews,
              child: Text('Create News'),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
