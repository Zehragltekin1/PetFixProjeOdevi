import 'dart:io';

import 'package:flutter/material.dart';
import 'package:petpix/backend/datahelper.dart';

class LikedAnimalsPage extends StatelessWidget {
  final List<Map<String, dynamic>> likedAnimals;

  LikedAnimalsPage({required this.likedAnimals});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liked Animals'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: likedAnimals.length,
          itemBuilder: (context, index) {
            final animal = likedAnimals[index];
            return ListTile(
              title: Text(animal['animal_type']),
              subtitle: Text(animal['breed']),
              leading: animal['image_path'] != null
                  ? Image.file(
                      File(animal['image_path']),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/images/default_animal.png',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
            );
          },
        ),
      ),
    );
  }
}
