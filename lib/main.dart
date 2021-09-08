import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

// Part of Flutter excercises
// From https://flutter.dev/docs/cookbook/networking/fetch-data
// and https://flutter.dev/docs/cookbook/networking/background-parsing

Future<List<Post>> fetchPosts(http.Client client) async {
  final response = await client
      .get(Uri.parse('https://my-json-server.typicode.com/sslaia/katawaena/posts'));
      // .get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
  // Use the compute function to run parsePhotos in a separate isolate.
  return compute(parsePosts, response.body);
}

// A function that converts a response body into a List<Photo>.
List<Post> parsePosts(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Post>((json) => Post.fromJson(json)).toList();
}

class Post {
  final int userId;
  final int id;
  final String title;
  final String body;

  const Post({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: json['userId'] as int,
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Menarik konten dari Internet';

    return const MaterialApp(
      title: appTitle,
      home: MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: GoogleFonts.playfairDisplay(textStyle: TextStyle(fontSize: 24.0),),),
      ),
      body: FutureBuilder<List<Post>>(
        future: fetchPosts(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('An error has occurred!'),
            );
          } else if (snapshot.hasData) {
            return PostsList(posts: snapshot.data!);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class PostsList extends StatelessWidget {
  const PostsList({Key? key, required this.posts}) : super(key: key);

  final List<Post> posts;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          final postId = posts[index].id.toString();
          return Card(
            elevation: 8.0,
            child: ListTile(
              leading: CircleAvatar(child: Text(postId)),
              title: Text(posts[index].title, style: GoogleFonts.merriweather(textStyle: TextStyle(fontSize: 24.0),),),
              subtitle: Text(posts[index].body, style: GoogleFonts.merriweather(textStyle: TextStyle(fontSize: 14.0)),),
            ),
          );
        });
    // return GridView.builder(
    //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    //     crossAxisCount: 2,
    //   ),
    //   itemCount: posts.length,
    //   itemBuilder: (context, index) {
    //     return Text(posts[index].body);
    //   },
    // );
  }
}