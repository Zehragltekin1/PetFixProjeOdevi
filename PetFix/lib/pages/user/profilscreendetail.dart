import 'dart:io';

import 'package:flutter/material.dart';

class PhotoDetailPage extends StatelessWidget {
  final Map<String, dynamic> photo;
  final Map<String, dynamic>? user;

  PhotoDetailPage({required this.photo, this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fotoğraf Detayı'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.file(
              File(photo['image_path']),
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              photo['caption'] ?? '',
              style: TextStyle(fontSize: 18),
            ),
          ),
          SizedBox(height: 16),
          _buildUserInfo(),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    if (user == null) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: user!['profile_image'] != null
                ? FileImage(File(user!['profile_image']))
                : AssetImage('assets/default_avatar.png') as ImageProvider,
          ),
          SizedBox(height: 16),
          Text(
            user!['name'] ?? '',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            user!['bio'] ?? '',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
