import 'package:flutter/material.dart';
import 'package:petpix/pages/searchlist.dart';

class SearchView extends StatefulWidget {
  SearchView({super.key});

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  List<Map<String, dynamic>> filteredUsers = [];

  @override
  void initState() {
    filteredUsers = searchUsers;
    super.initState();
  }

  void filterUsers(String query) {
    List<Map<String, dynamic>> _searchUsers = [];
    _searchUsers.addAll(searchUsers);
    if (query.isNotEmpty) {
      List<Map<String, dynamic>> _filteredUsers = [];
      _searchUsers.forEach((user) {
        if (user['username'].toLowerCase().contains(query.toLowerCase())) {
          _filteredUsers.add(user);
        }
      });
      setState(() {
        filteredUsers = _filteredUsers;
      });
    } else {
      setState(() {
        filteredUsers = searchUsers;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: SizedBox(
          height: 40,
          child: TextField(
            onChanged: (value) {
              filterUsers(value);
            },
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                filled: true,
                fillColor: Colors.orange.shade200,
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey,
                )),
          ),
        ),
      ),
      body: ListView.builder(
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            var data = filteredUsers[index];
            return ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(data['profileImageUrl']),
              ),
              title: Text(data['username']),
              subtitle: Text(data['fullName']),
            );
          }),
    );
  }
}
