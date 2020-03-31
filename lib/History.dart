import 'package:flutter/material.dart';
import 'dart:async';
import './database_helper.dart';
import './HistoryList.dart';
import 'package:sqflite/sqflite.dart';

class History extends StatefulWidget {
  History({Key key}) : super(key: key);

  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<HistoryList> historyList;
  int count = 0;
  @override
  Widget build(BuildContext context) {
    if (historyList == null) {
      historyList = List<HistoryList>();
      updateListView();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        centerTitle: true,
      ),
      body: count == 0
          ? Center(
              child: Text(
                'No History',
                style: TextStyle(fontSize: 20.0),
              ),
            )
          : getListView(),
    );
  }

  ListView getListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.yellow,
              child: Icon(Icons.query_builder),
            ),
            title: Text('Code : ' + this.historyList[position].code,
                style: titleStyle),
            subtitle: Text(this.historyList[position].date),
            trailing: Text(
              '₹  ' + this.historyList[position].reward,
              style: TextStyle(fontSize: 20.0),
            ),
          ),
        );
      },
    );
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<HistoryList>> historyListFuture =
          databaseHelper.getHistoryList();
      historyListFuture.then((historyList) {
        setState(() {
          this.historyList = historyList;
          this.count = historyList.length;
        });
      });
    });
  }
}
