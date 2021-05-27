// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'second.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: RandomWords(),
    );
  }
}


class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <String>[];
  final _biggerFont = TextStyle(fontSize: 18.0);


  @override
  void initState() {
    super.initState();
    _loadList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Startup Name Generator'),
      ),
      body: _buildSuggestions(),
      floatingActionButton: FloatingActionButton(
        onPressed: () { _navigateAndDisplaySelection(context); },
        child: Icon(Icons.bookmark_add, color: Colors.white, size: 29,),
        tooltip: 'Capture Picture',
        elevation: 5,
        splashColor: Colors.grey,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
  Widget _buildSuggestions() {
  return GridView.builder(
    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20),
    itemCount: _suggestions.length,
    itemBuilder: (BuildContext ctx, index) {
      if (index >= _suggestions.length) {
          _suggestions.addAll(generateWordPairs().take(10).map((e) => e.asPascalCase));
      }
      return Container(
        alignment: Alignment.center,
        child: _buildRow(_suggestions[index]),
        decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(15)),
      );
    });
  }
  Widget _buildRow(String pair) {
    return ListTile(
      title: Text(
        pair,
        style: _biggerFont,
      ),
    );
  }

  void _addToList(String name) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _suggestions.add(name);
      prefs.setStringList('itemsKey', _suggestions);
    });
  }

  //Loading counter value on start
  void _loadList() async {
    log("loading");
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _suggestions.addAll((prefs.getStringList('itemsKey') ?? []));
    });
  }

  void _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      // Create the SelectionScreen in the next step.
      MaterialPageRoute(builder: (context) => SelectionScreen()),
    );

    if (result == null) { return; }
    _addToList('$result');

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$result')));
  }
}