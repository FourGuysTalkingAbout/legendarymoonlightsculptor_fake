import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

//final dummySnapshot = [
//  {"name": "Filip", "votes": 15},
//  {"name": "Abraham", "votes": 14},
//  {"name": "Richard", "votes": 11},
//  {"name": "Ike", "votes": 10},
//  {"name": "Justin", "votes": 1},
//];

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby Names',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Baby Name Votes', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.pink,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
//    // TODO: get actual snapshot from Cloud Firestore
//    return _buildList(context, dummySnapshot);
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('baby').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    return Padding(
      key: ValueKey(record.name),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _textFormField(),
          Text(record.name),
          FlatButton(
            onPressed: () =>
                Firestore.instance.runTransaction((transaction) async {
                  final freshSnapshot = await transaction.get(record.reference);
                  final fresh = Record.fromSnapshot(freshSnapshot);
                  await transaction
                      .update(record.reference, {'votes': fresh.votes + 1});
                }),
            child: Text(record.votes.toString()),
          ),
          FlatButton(
            onPressed: () =>
                Firestore.instance.runTransaction((transaction) async {
                  final freshSnapshot = await transaction.get(record.reference);
                  final fresh = Record.fromSnapshot(freshSnapshot);
                  await transaction
                      .update(record.reference, {'test': fresh.test - 1});
                }),
            child: Text(record.test.toString()),
          )
        ]),
      ),
    );
  }

  Widget _textFormField() {
    return TextFormField();
  }
}

class Record {
  final String inputtedName;
  final String name;
  final int votes;
  final int test;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['inputtedName'] != null),
        assert(map['name'] != null),
        assert(map['votes'] != null),
        assert(map['test'] != null),
        inputtedName = map['name'],
        name = map['name'],
        votes = map['votes'],
        test = map['test'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$inputtedName:$name:$votes:$test>";
}
