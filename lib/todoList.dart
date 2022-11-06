import 'package:flutter/material.dart';

import 'package:todo_app/model/aTodo.dart';
import 'package:todo_app/model/db.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/model/aTodo.dart';

class todoList extends StatefulWidget {
  const todoList({Key? key}) : super(key: key);

  @override
  State<todoList> createState() => _todoListState();
}

class _todoListState extends State<todoList> {
  final FocusNode _screenFocus = FocusNode();

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  List<String> _requests = ['Test Description', ''];

  List<aTodo> todoList = [];

  void _getTodoList({String search = ''}) async {
    final res = await DB.getAllTodoList(search: search, status: 0);
    setState(() {
      todoList = res;
    });
  }

  @override
  void initState() {
    super.initState();
    _getTodoList(search: _searchController.text);
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          FocusScope.of(context).requestFocus(_screenFocus);
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('TODO List'),
          centerTitle: true,
          /*actions: [
            IconButton(
              onPressed: null,
              icon: Icon(Icons.notifications),
            ),
            IconButton(
              onPressed: null,
              icon: Icon(Icons.settings),
            ),
          ],*/
        ),
        body: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 10),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  controller: _searchController,
                  focusNode: _searchFocus,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 0),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Colors.blue),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    hintText: 'Search TODO',
                    suffixIcon: (_searchController.text.isNotEmpty) ?
                    IconButton(onPressed: () {setState(() {
                      _searchController.clear();
                      _getTodoList(search: _searchController.text);
                      _searchFocus.requestFocus();
                      _searchFocus.unfocus();
                    });}, icon: Icon(Icons.clear)) :
                    Icon(Icons.search_outlined),
                  ),
                  onChanged: (value) => {
                    /*
                    if (value.isEmpty || value.length == 1) {
                      setState(() {
                      })
                    },*/
                    setState(() {
                      _getTodoList(search: _searchController.text);
                    })
                  },
                  onTap: () {
                    setState(() {
                      _searchFocus.requestFocus();
                    });
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {},
                      child: TextButton(
                        onPressed: () {
                          print('Text button pressed');
                        },
                        child: Text('All', style: TextStyle(fontSize: 17),),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {},
                      child: TextButton(
                        onPressed: () {
                          print('Text button pressed');
                        },
                        child: Text('Today', style: TextStyle(fontSize: 17),),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {},
                      child: TextButton(
                        onPressed: () {
                          print('Text button pressed');
                        },
                        child: Text('Upcoming', style: TextStyle(fontSize: 17),),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  children: todoList.map((val) => val.description != ''
                      ? ExpansionTile(
                    childrenPadding: EdgeInsets.all(10),
                    leading: Checkbox(
                      value: false,
                      onChanged: (e) {
                      },
                    ),
                    title: Text(val.title),
                    subtitle: Text(val.date + ' ' + val.time ),
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
                        alignment: Alignment.centerLeft,
                        child: Text(val.description!),
                      ),
                    ],
                  )
                      : ListTile(
                    leading: Checkbox(
                      value: false,
                      onChanged: (val) {
                      },
                    ),
                    title: Text(val.title),
                    subtitle: Text(val.date + ' ' + val.time),
                  ),
                  ).toList()
                  /*todoList.map((val) => val.description != ''

                  ).toList()*/
                  /*[
                    _requests[0] != ''
                    ? ExpansionTile(
                      childrenPadding: EdgeInsets.all(10),
                        leading: Checkbox(
                          value: false,
                          onChanged: (val) {
                          },
                        ),
                        title: Text('Test Title'),
                        subtitle: Text('Test Time'),
                        children: [
                          Container(
                            padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
                            alignment: Alignment.centerLeft,
                            child: Text(_requests[0]),
                          ),
                        ],
                      )
                    : ListTile(
                      leading: Checkbox(
                        value: false,
                        onChanged: (val) {
                        },
                      ),
                      title: Text('Test Title'),
                      subtitle: Text('Test Time'),
                    ),

                    _requests[1] != ''
                    ? ExpansionTile(
                  childrenPadding: EdgeInsets.all(10),
                  leading: Checkbox(
                    value: false,
                    onChanged: (val) {
                    },
                  ),
                  title: Text('Test Title'),
                  subtitle: Text('Test Time'),
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
                      alignment: Alignment.centerLeft,
                      child: Text(_requests[1]),
                    ),
                  ],
                )
                    : ListTile(
                  leading: Checkbox(
                    value: false,
                    onChanged: (val) {
                    },
                  ),
                  title: Text('Test Title'),
                  subtitle: Text('Test Time'),
                ),
                  ],*/
                ),
              ),
            ],
          )
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/add_todo', ).then((value) => _getTodoList(search: _searchController.text));
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
