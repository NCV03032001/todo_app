import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/model/db.dart';
import 'package:todo_app/model/aTodo.dart';
import 'package:todo_app/notification/notification.dart';
import 'package:timezone/data/latest.dart' as tzData;

class editTodo extends StatefulWidget {
  final aTodo valTodo;
  const editTodo({Key? key, required this.valTodo}) : super(key: key);

  @override
  State<editTodo> createState() => _editTodoState();
}

class _editTodoState extends State<editTodo> {
  final FocusNode _screenFocus = FocusNode();

  final _addFormKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final FocusNode _titleFocus = FocusNode();

  final TextEditingController _desController = TextEditingController();
  final FocusNode _desFocus = FocusNode();
  final ScrollController _desScrollController = ScrollController();

  DateTime selectedDate = DateTime.now();
  final TextEditingController _dateController = TextEditingController();
  final FocusNode _dateFocus = FocusNode();

  _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
    );
    if (picked != null) {
      selectedDate = picked;
      setState(() {
        _dateController.text = "${selectedDate.toLocal()}".split(' ')[0];
        print('Changed Date');
        if (!checkDateTimeConflict(_dateController.text, _timeController.text)) {
          setState(() {
            datetimeConflictError.text = 'You can\'t make a TODO for the past';
          });
        }
        else {
          setState(() {
            datetimeConflictError.clear();
          });
        }
        _dateFocus.requestFocus();
      });
    }
  }

  TimeOfDay selectedTime = TimeOfDay.now();
  final TextEditingController _timeController = TextEditingController();
  final FocusNode _timeFocus = FocusNode();
  _selectTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) {
      selectedTime = picked;
      setState(() {
        _timeController.text = selectedTime.hour.toString().padLeft(2, '0') + ':' + selectedTime.minute.toString().padLeft(2, '0');
        print('Changed Time');
        if (!checkDateTimeConflict(_dateController.text, _timeController.text)) {
          setState(() {
            datetimeConflictError.text = 'You can\'t make a TODO for the past';
          });
        }
        else {
          setState(() {
            datetimeConflictError.clear();
          });
        }
        _timeFocus.requestFocus();
      });
    }
  }

  final FocusNode _rsFocus = FocusNode();

  final TextEditingController datetimeConflictError = TextEditingController();

  void _editTodo(aTodo todo) async {
    await DB.updateTodo(todo);
  }

  @override
  void initState() {
    super.initState();
    tzData.initializeTimeZones();
    _titleController.text = widget.valTodo.title;
    _desController.text = widget.valTodo.description!;
    _dateController.text = widget.valTodo.date;
    _timeController.text = widget.valTodo.time;
  }

  @override
  Widget build(BuildContext context) {
    aTodo newTodo;

    return GestureDetector(
      onTap: () {
        setState(() {
          FocusScope.of(context).requestFocus(_screenFocus);
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit TODO'),
          centerTitle: true,
          automaticallyImplyLeading: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 30, 20, 20),
          child: Form(
            key: _addFormKey,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: _titleController,
                    focusNode: _titleFocus,
                    autovalidateMode: AutovalidateMode.always,
                    maxLength: 50,
                    decoration: InputDecoration(
                      label: Row(
                        children: [
                          Text('*', style: TextStyle(color: Colors.red),),
                          Text(' Title'),
                        ],
                      ),
                      contentPadding: EdgeInsets.fromLTRB(10, 15, 10, 0),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.grey),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.blue),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.red),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.orange),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      hintText: 'Name your task (max 50 letters)',
                      suffixIcon: (_titleController.text.isNotEmpty) ?
                      IconButton(onPressed: () {setState(() {
                        _titleController.clear();
                        _titleFocus.requestFocus();
                        _titleFocus.unfocus();
                      });}, icon: Icon(Icons.clear)) :
                      null,
                    ),
                    onChanged: (value) => {
                      if (value.isEmpty || value.length == 1) {
                        setState(() {})
                      }
                    },
                    onTap: () => setState(() {
                      _titleFocus.requestFocus();
                    }),
                    validator: (val) {
                      if(val == null || val.isEmpty){
                        return "Please input task's Title";
                      }
                      return null;
                    },
                  ),
                ),
                Scrollbar(
                  thumbVisibility: true,
                  controller: _desScrollController,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 30),
                    child: TextFormField(
                      keyboardType: TextInputType.multiline,
                      controller: _desController,
                      focusNode: _desFocus,
                      scrollController: _desScrollController,
                      minLines: 3,
                      maxLines: 8,
                      decoration: InputDecoration(
                        labelText: 'Description:',
                        contentPadding: EdgeInsets.fromLTRB(10, 15, 10, 0),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Colors.blue),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        hintText: 'List the task\'s details here...',
                        isCollapsed: true,
                        suffixIcon: (_desController.text.isNotEmpty) ?
                        IconButton(onPressed: () {setState(() {
                          _desController.clear();
                          _desFocus.requestFocus();
                          _desFocus.unfocus();
                        });}, icon: Icon(Icons.clear)) :
                        null,
                      ),
                      onTap: () {
                        setState(() {
                          _desFocus.requestFocus();
                        });
                      },
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(bottom: 20),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          focusNode: _dateFocus,
                          controller: _dateController,
                          autovalidateMode: AutovalidateMode.always,
                          decoration: InputDecoration(
                            label: Row(
                              children: [
                                Text('*', style: TextStyle(color: Colors.red),),
                                Text(' Date'),
                              ],
                            ),
                            contentPadding: EdgeInsets.fromLTRB(20, 15, 0, 0),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 1, color: Colors.grey),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 1, color: Colors.blue),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 1, color: Colors.red),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 1, color: Colors.orange),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            suffixIcon: (_dateController.text.isNotEmpty && _dateFocus.hasFocus) ?
                            IconButton(onPressed: () {setState(() {
                              _dateController.clear();
                              selectedDate = DateTime.now();
                              datetimeConflictError.clear();
                              _dateFocus.unfocus();
                            });}, icon: Icon(Icons.clear)) :
                            Icon(Icons.calendar_month_outlined),
                          ),
                          readOnly: true,
                          onTap: () => _selectDate(context),
                          validator: (val) {
                            if(val == null || val.isEmpty){
                              return "Please select task's Date";
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(bottom: 20),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          focusNode: _timeFocus,
                          controller: _timeController,
                          autovalidateMode: AutovalidateMode.always,
                          decoration: InputDecoration(
                            label: Row(
                              children: [
                                Text('*', style: TextStyle(color: Colors.red),),
                                Text(' Time'),
                              ],
                            ),
                            contentPadding: EdgeInsets.fromLTRB(20, 15, 0, 0),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 1, color: Colors.grey),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 1, color: Colors.blue),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 1, color: Colors.red),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 1, color: Colors.orange),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            suffixIcon: (_timeController.text.isNotEmpty && _timeFocus.hasFocus) ?
                            IconButton(onPressed: () {setState(() {
                              _timeController.clear();
                              selectedTime = TimeOfDay.now();
                              datetimeConflictError.clear();
                              _timeFocus.unfocus();
                            });}, icon: Icon(Icons.clear)) :
                            Icon(Icons.access_time_outlined),
                          ),
                          readOnly: true,
                          onTap: () => _selectTime(context),
                          validator: (val) {
                            if(val == null || val.isEmpty){
                              return "Please select task's Time";
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: Text(datetimeConflictError.text, style: TextStyle(color: Colors.red),),
                ),
                Row(
                  children: [
                    Expanded(child: Container(
                      alignment: Alignment.center,
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _rsFocus.requestFocus();
                            _titleController.clear();
                            _desController.clear();
                            selectedDate = DateTime.now();
                            _dateController.clear();
                            selectedTime = TimeOfDay.now();
                            _timeController.clear();
                            datetimeConflictError.clear();
                          });
                        },
                        focusNode: _rsFocus,
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(115, 20),
                          padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.blue, width: 2),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                        ),
                        child: Text(
                          'Clear all',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),),
                    Expanded(child: Container(
                      alignment: Alignment.center,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(115, 20),
                          padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.blue, width: 2),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                        ),
                        child: Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.blue,
                          ),
                        ),
                        onPressed: () => {
                          if (_addFormKey.currentState!.validate() && checkDateTimeConflict(_dateController.text, _timeController.text)) {
                            newTodo = new aTodo(id: widget.valTodo.id, title: _titleController.text, description: _desController.text, date: _dateController.text, time: _timeController.text, status: widget.valTodo.status),
                            _editTodo(newTodo),
                            NotificationService.cancelNotification(newTodo),
                            NotificationService.addNotification(newTodo),
                            Navigator.pop(context, true),
                          }
                        },
                      ),
                    ),),
                  ],
                ),
              ],
            ),
          )
        ),
      ),
    );
  }

  bool checkDateTimeConflict(String date, String time) {
    var formatterDate = new DateFormat('yyyy-MM-dd');
    var formatterTime = new DateFormat('HH:mm');

    DateTime checkDate = DateTime.now();

    String checkDateString = formatterDate.format(checkDate);
    String checkTimeString = formatterTime.format(checkDate);

    if (date.isNotEmpty && time.isNotEmpty
        && (
        (date.compareTo(checkDateString) == 0 && time.compareTo(checkTimeString) <= 0)) ||
        (date.compareTo(checkDateString) == -1)
    ) {
      return false;
    }

    return true;
  }
}
