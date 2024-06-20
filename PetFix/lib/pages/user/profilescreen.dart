import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:petpix/backend/datahelper.dart';
import 'package:petpix/pages/user/profilscreendetail.dart';
import 'package:petpix/pages/user/settingspage.dart';

class ProfilePage extends StatefulWidget {
  final int userId;

  ProfilePage({required this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  DatabaseHelper dbHelper = DatabaseHelper();
  Map<String, dynamic>? user;
  List<Map<String, dynamic>> photos = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await dbHelper.getUser(widget.userId);
    final userPhotos = await dbHelper.getUserPhotos(widget.userId);
    setState(() {
      user = userData;
      photos = userPhotos;
    });
  }

  Future<void> _addPhoto() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      TextEditingController captionController = TextEditingController();

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add Photo'),
            content: TextField(
              controller: captionController,
              decoration: InputDecoration(hintText: 'Enter a caption'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  String caption = captionController.text;
                  String date = DateTime.now().toIso8601String();
                  await dbHelper.insertPhoto({
                    'user_id': widget.userId,
                    'image_path': pickedFile.path,
                    'caption': caption,
                    'date': date,
                  });
                  _loadUserData();
                  Navigator.of(context).pop();
                },
                child: Text('Add'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user?['name'] ?? ''),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              _navigateToSettings();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            Divider(),
            _buildPhotoList(),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addPhoto,
              child: Text('Add Photo'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(userId: widget.userId),
      ),
    ).then((value) {
      if (value != null && value) {
        _loadUserData();
      }
    });
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: user?['profile_image'] != null
                ? FileImage(File(user!['profile_image']))
                : AssetImage('assets/default_avatar.png') as ImageProvider,
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?['name'] ?? '',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(user?['bio'] ?? ''),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        return _buildPhotoItem(photos[index]);
      },
    );
  }

  Widget _buildPhotoItem(Map<String, dynamic> photo) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhotoDetailPage(photo: photo, user: user),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: user?['profile_image'] != null
                    ? FileImage(File(user!['profile_image']))
                    : AssetImage('assets/default_avatar.png') as ImageProvider,
              ),
              title: Text(user?['name'] ?? ''),
              subtitle: Text(photo['date'] ?? 'No Date'),
            ),
            Image.file(
              File(photo['image_path']),
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(photo['caption'] ?? ''),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deletePhoto(photo['id']);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.comment),
                  onPressed: () {
                    _showCommentDialog(photo['id']);
                  },
                ),
                FutureBuilder<bool>(
  future: dbHelper.issPhotoLikedByUser(user!['id'].toString(), photo['id']),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    } else {
      bool isLiked = snapshot.data ?? false;
      return IconButton(
        icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
        onPressed: () {
          if (isLiked) {
            _unlikePhoto(photo['id']);
          } else {
            _likePhoto(photo['id']);
          }
        },
      );
    }
  },
),

              ],
            ),
          ],
        ),
      ),
    );
  }

  void _deletePhoto(String photoId) async {
    await dbHelper.deletePost(photoId as int);
    _loadUserData();
  }

  void _showCommentDialog(String photoId) {
    TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Comment'),
          content: TextField(
            controller: commentController,
            decoration: InputDecoration(hintText: 'Write your comment here'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String comment = commentController.text;
                await dbHelper.insertComment({
                  'user_id': user!['id'],
                  'photo_id': photoId,
                  'comment': comment,
                });
                _loadUserData();
                Navigator.of(context).pop();
              },
              child: Text('Add Comment'),
            ),
          ],
        );
      },
    );
  }

  void _likePhoto(String photoId) async {
    await dbHelper.insertLike(user!['id'], photoId);
    _loadUserData();
  }

  void _unlikePhoto(String photoId) async {
    await dbHelper.deleteLike(user!['id'], photoId);
    _loadUserData();
  }
}