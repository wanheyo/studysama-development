import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class UsersScreen extends StatefulWidget {
  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _apiService.getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users'),
      ),
      body: FutureBuilder<List<User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No users found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              User user = snapshot.data![index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('@${user.username}'),
                      Text(user.email),
                      // Text(user.phoneNum),
                      SizedBox(height: 8),
                      if (user.bio != null) Text('Bio: ${user.bio}'),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.people),
                          Text(' ${user.totalFollower} followers'),
                          SizedBox(width: 16),
                          Icon(Icons.star),
                          Text(' ${user.averageRating}'),
                        ],
                      ),
                      if (user.verificationStatus == 1)
                        Chip(
                          label: Text('Verified'),
                          backgroundColor: Colors.blue[100],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
