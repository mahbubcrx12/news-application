import 'dart:async';

import 'package:coders_bucket/view/bookmarked_details.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class BookmarkedArticlePage extends StatefulWidget {
  @override
  State<BookmarkedArticlePage> createState() => _BookmarkedArticlePageState();
}

class _BookmarkedArticlePageState extends State<BookmarkedArticlePage> {


  late StreamSubscription<ConnectivityResult> subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  @override
  void initState() {
    super.initState();
    checkConnectivity();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  Future<void> checkConnectivity() async {
    isDeviceConnected = await InternetConnectionChecker().hasConnection;
    setState(() {
      isDeviceConnected = isDeviceConnected;
    });

    subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
      isDeviceConnected = await InternetConnectionChecker().hasConnection;
      if (!isDeviceConnected && !isAlertSet) {
        showDialogBox();
        setState(() {
          isAlertSet = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text('Bookmarked Articles'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookmarks')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('articles')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasData) {
            final bookmarkedArticles = snapshot.data!.docs;
            if (bookmarkedArticles.isEmpty) {
              return Center(
                child: Text('No bookmarked articles.'),
              );
            }

            return ListView.builder(
              itemCount: bookmarkedArticles.length,
              itemBuilder: (context, index) {
                final bookmarkedArticle = bookmarkedArticles[index];
                final title = bookmarkedArticle['title'];
                final description = bookmarkedArticle['description'];
                final imageUrl = bookmarkedArticle['imageUrl'];
                final content = bookmarkedArticle['content'];
                final publishedAt = bookmarkedArticle['publishedAt'];
                final source = bookmarkedArticle['source'];

                return SizedBox(
                  height: 100,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 2,
                    ),
                    child: Card(
                      elevation: 5,
                      child: GestureDetector(
                        onTap: () {
                          Get.to(() => BookmarkedArticle(
                            title: title,
                            description: description,
                            imageUrl: imageUrl,
                            content: content,
                            publishedAt: publishedAt,
                            source: source,
                          ));
                        },
                        child: ListTile(
                          tileColor: Colors.white70,
                          leading: imageUrl != null
                              ? Image.network(
                            imageUrl,
                            width: 80.0,
                            height: 80.0,
                            fit: BoxFit.cover,
                          )
                              : Container(
                            width: 80.0,
                            height: 80.0,
                            color: Colors.grey,
                          ),
                          title: Text(
                            title,
                            maxLines: 1,
                          ),
                          subtitle: Text(
                            description,
                            maxLines: 3,
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              // Delete the bookmarked article
                              FirebaseFirestore.instance
                                  .collection('bookmarks')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .collection('articles')
                                  .doc(bookmarkedArticle.id)
                                  .delete();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return Center(
            child: Text('Error loading bookmarked articles.'),
          );
        },
      ),
    );
  }

  showDialogBox() => showCupertinoDialog<String>(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: const Text('No Connection'),
      content: const Text('Please check your internet connectivity'),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            Navigator.pop(context, 'Cancel');
            setState(() => isAlertSet = false);
            isDeviceConnected =
            await InternetConnectionChecker().hasConnection;
            if (!isDeviceConnected && isAlertSet == false) {
              showDialogBox();
              setState(() => isAlertSet = true);
            }
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );

}
