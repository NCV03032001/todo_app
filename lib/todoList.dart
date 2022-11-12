import 'package:flutter/material.dart';
import 'package:todo_app/editTodo.dart';

import 'package:todo_app/model/aTodo.dart';
import 'package:todo_app/model/db.dart';
import 'package:todo_app/notification/notification.dart';
import 'package:timezone/data/latest.dart' as tzData;

class todoList extends StatefulWidget {
  const todoList({Key? key}) : super(key: key);

  @override
  State<todoList> createState() => _todoListState();
}

class _todoListState extends State<todoList> {
  final FocusNode _screenFocus = FocusNode();

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  final TextEditingController _typeController = TextEditingController();
  List<aTodo> todoList = [];
  List<bool> checkList = [];

  int _selectedIndex = 0;
  int _selectedTag = 0;

  void _getTodoList({String search = '', int status = 0, String type = ''}) async {
    final res = await DB.getTodoList(search: search, type: type, status: status);
    setState(() {
      todoList = res;
      checkList = List.generate(todoList.length, (index) => false);
    });
  }

  void _markDoneTodo(aTodo val) async {
    aTodo newTodo = new aTodo(id: val.id, title: val.title, description: val.description, date: val.date, time: val.time, status: 1);
    await DB.updateTodo(newTodo);
  }

  void _deleteTodo(aTodo val) async {
    await DB.deleteTodo(val);
  }

  @override
  void initState() {
    super.initState();
    tzData.initializeTimeZones();
    _searchController.text = '';
    _typeController.text = 'All';
    _selectedTag = 0;
    _getTodoList(search: _searchController.text, type: _typeController.text, status: _selectedTag);
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
        body: Container( constraints: BoxConstraints.expand(),
          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
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
                      _getTodoList(search: _searchController.text, type: _typeController.text, status: _selectedTag);
                      _searchFocus.requestFocus();
                      _searchFocus.unfocus();
                    });}, icon: Icon(Icons.clear)) :
                    Icon(Icons.search_outlined),
                  ),
                  onChanged: (value) => {
                    setState(() {
                      _getTodoList(search: _searchController.text, type: _typeController.text, status: _selectedTag);
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
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(
                              bottom: _typeController.text == 'All' ? BorderSide(width: 2, color: Colors.blue) : BorderSide.none,
                            )
                        ),
                        child: InkWell(
                          onTap: () {
                          },
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _typeController.text = 'All';
                                _getTodoList(search: _searchController.text, type: _typeController.text, status: _selectedTag);
                              });
                            },
                            child: Text('All', style: TextStyle(
                              fontSize: 17, color:_typeController.text == 'All' ? Colors.blue : Colors.black,
                            ),),
                          ),
                        ),
                      )
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                            bottom: _typeController.text == 'Today' ? BorderSide(width: 2, color: Colors.blue) : BorderSide.none,
                          )
                      ),
                      child: InkWell(
                        onTap: () {},
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _typeController.text = 'Today';
                              _getTodoList(search: _searchController.text, type: _typeController.text, status: _selectedTag);
                            });
                          },
                          child: Text('Today', style: TextStyle(
                            fontSize: 17, color:_typeController.text == 'Today' ? Colors.blue : Colors.black,
                          ),),
                        ),
                      ),
                    ),
                  ),
                  _selectedTag == 0
                  ? Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(
                                bottom: _typeController.text == 'Upcoming' ? BorderSide(width: 2, color: Colors.blue) : BorderSide.none,
                              )
                          ),
                          child: InkWell(
                            onTap: () {},
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _typeController.text = 'Upcoming';
                                  _getTodoList(search: _searchController.text, type: _typeController.text, status: _selectedTag);
                                });
                              },
                              child: Text('Upcoming', style: TextStyle(
                                fontSize: 17, color:_typeController.text == 'Upcoming' ? Colors.blue : Colors.black,
                              ),),
                            ),
                          ),
                        ),
                      )
                  : Container(),
                ],
              ),
              SizedBox(height: 10,),
              Expanded(
                child: ListView(
                  children: List.generate(todoList.length, (i) {
                    return Column(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            color: _selectedTag == 0 ? Color(0xFFF8FF42)
                            : _selectedTag == 1 ? Color(0xFF42FF5C)
                            : Color(0xFFFF5542),//Color(0xFFC7C7D4),
                          ),
                          child: todoList[i].description != ''
                          ? ExpansionTile(
                            childrenPadding: EdgeInsets.all(10),
                            leading: _selectedTag == 0
                            ? Checkbox(
                              value: checkList[i],
                              onChanged: (e) {
                                setState(() {
                                  checkList[i] = !checkList[i];
                                  showModalBottomSheet(context: context, builder: ((builder) => bottomSheet(todoList[i])),).then((value) => _getTodoList(search: _searchController.text, type: _typeController.text, status: _selectedTag));
                                });
                              },
                            )
                            : IconButton(
                              onPressed: () => showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: const Text('Confirm Delete'),
                                  content: const Text('Are you sure to delete this TODO? It will remove the TODO from database.'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, 'Cancel'),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => {
                                        _deleteTodo(todoList[i]),
                                        NotificationService.cancelNotification(todoList[i]),
                                        Navigator.pop(context, 'OK')
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              ).then((value) => _getTodoList(search: _searchController.text, type: _typeController.text, status: _selectedTag)),
                              icon: Icon(Icons.delete),
                            ),
                            title: Text(todoList[i].title, maxLines: 1, overflow: TextOverflow.ellipsis,),
                            subtitle: Text(todoList[i].date + ' ' + todoList[i].time, maxLines: 1, overflow: TextOverflow.ellipsis,),
                            children: [
                              Container(
                                child: Text('Description:'),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
                                alignment: Alignment.centerLeft,
                                child: Text(todoList[i].description!),
                              ),
                            ],
                          )
                          : ListTile(
                            leading: _selectedTag == 0
                            ? Checkbox(
                              value: checkList[i],
                              onChanged: (e) {
                                setState(() {
                                  checkList[i] = !checkList[i];
                                  showModalBottomSheet(context: context, builder: ((builder) => bottomSheet(todoList[i])),).then((value) => _getTodoList(search: _searchController.text, type: _typeController.text, status: _selectedTag));
                                });
                              },
                            )
                            : IconButton(
                              onPressed: () => showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: const Text('Confirm Delete'),
                                  content: const Text('Are you sure to delete this TODO? It will remove the TODO from database.'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, 'Cancel'),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => {
                                        _deleteTodo(todoList[i]),
                                        NotificationService.cancelNotification(todoList[i]),
                                        Navigator.pop(context, 'OK')
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              ).then((value) => _getTodoList(search: _searchController.text, type: _typeController.text, status: _selectedTag)),
                              icon: Icon(Icons.delete),
                            ),
                            title: Text(todoList[i].title, maxLines: 1, overflow: TextOverflow.ellipsis,),
                            subtitle: Text(todoList[i].date + ' ' + todoList[i].time, maxLines: 1, overflow: TextOverflow.ellipsis,),
                          ),
                        ),
                        SizedBox(height: 10,),
                      ],
                    );
                  }),
                ),
              ),
            ],
          )
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/add_todo', ).then((value) => _getTodoList(search: _searchController.text, type: _typeController.text, status: _selectedTag));
            //.then((value) =>_getLastRow()).then((value) => NotificationService.addNotification(lastRow[0]));
          },
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.check_box_outline_blank_outlined),
              label: 'TODO',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_box_outlined),
              label: 'Done',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.cancel_outlined),
              label: 'Missed',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: (int index) {
            if (_typeController.text == 'Upcoming' && index != 0) setState(() {
              _typeController.text = 'All';
            });
            if (index == 2) _selectedTag = -1;
            else _selectedTag = index;
            _getTodoList(search: _searchController.text, type: _typeController.text, status: _selectedTag);
            _selectedIndex = index;
          },
        ),
      ),
    );
  }

  Widget bottomSheet(aTodo val) {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        children: <Widget>[
          Text(
            "What to do with TODO :V",
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
            ElevatedButton.icon(
              icon: Icon(Icons.check_box_outlined, color: Colors.black,),
              onPressed: () => showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Confirm Done'),
                  content: const Text('Are you sure to mark this TODO done? It will move this TODO to \'Done\' tab.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => {
                        _markDoneTodo(val),
                        NotificationService.cancelNotification(val),
                        Navigator.pop(context, 'OK')
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ).then((value) => value == 'OK'? Navigator.pop(context, true) : null),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              label: Text("Done", style: TextStyle(color: Colors.black),),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.edit, color: Colors.black,),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => editTodo(valTodo: val),
                ),).then((value) => value == true ? _getTodoList(search: _searchController.text, type: _typeController.text, status: _selectedTag) : null);
              },
              label: Text("Edit", style: TextStyle(color: Colors.black),),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.delete, color: Colors.black,),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Confirm Delete'),
                  content: const Text('Are you sure to delete this TODO? It will remove the TODO from database.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => {
                        _deleteTodo(val),
                        NotificationService.cancelNotification(val),
                        Navigator.pop(context, 'OK')
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ).then((value) => value == 'OK'? Navigator.pop(context, true) : null),
              label: Text("Delete", style: TextStyle(color: Colors.black),),
            ),
          ])
        ],
      ),
    );
  }
}
