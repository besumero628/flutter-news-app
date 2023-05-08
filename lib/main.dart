import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

const apiKey = '4727b0ddf29344c58692e487fe5b6b45';
const apiUrl = 'https://newsapi.org/v2/top-headlines?country=us&apiKey=$apiKey';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NewsList(),
    );
  }
}

class NewsList extends StatefulWidget {
  @override
  _NewsListState createState() => _NewsListState();
}


class _NewsListState extends State<NewsList> {
  List<dynamic> _news = [];

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }


  Future<void> _fetchNews() async {
    final response = await http.get(Uri.parse(apiUrl));
    final jsonData = json.decode(response.body);
    setState(() {
      _news = jsonData['articles'];
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News List'),
      ),
      body: ListView.builder(
        itemCount: _news.length,
        itemBuilder: (context, index) {
          final article = _news[index];
          return ListTile(
            leading: CachedNetworkImage(
              imageUrl: article['urlToImage'] ?? '',
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
              width: 100,
            ),
            title: Text(article['title']),
            subtitle: Text(article['description'] ?? ''),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsDetail(article: article),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class NewsDetail extends StatelessWidget {
  final dynamic article;

  NewsDetail({required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article['title']),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: article['urlToImage'] ?? '',
              placeholder: (context, url) => CircularProgressIndicator(),
              // errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                article['title'],
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                article['description'] ?? '',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                article['content'] ?? '',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
