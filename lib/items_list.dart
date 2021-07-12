import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'item_storage.dart';

class ItemsList extends StatefulWidget {
  final String title;
  final ItemStorage storage;

  ItemsList({Key key, this.title, this.storage}) : super(key: key);

  @override
  _ItemsListState createState() => _ItemsListState();
}

class _ItemsListState extends State<ItemsList> {
  List _items = [];
  List _itemsNotDisplayed = [];
  List<int> _selectedIndex = [];
  int _listIndex = 0;

  void _shiftLists() {
    var _auxList = _items.toList();
    _items.clear();
    _items.addAll(_itemsNotDisplayed.toList());
    _itemsNotDisplayed.clear();
    _itemsNotDisplayed.addAll(_auxList);
  }

  void _removeSelectedItems() {
    setState(() {
      _selectedIndex.sort();
      for (int index = _selectedIndex.length - 1; index >= 0; index--) {
        _items.removeAt(_selectedIndex[index]);
      }
      _selectedIndex.clear();
    });
    _saveState();
  }

  void _manageListItem({int index}) {
    final _formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final datetimeController = TextEditingController();
    Text title;
    DateTime datetime;
    Function action;
    Function compare = (time1, time2) {
      if (time1.isBefore(time2)) return -1;
      if (time2.isBefore(time1)) return 1;
      return 0;
    };
    
    if (index == null) {
      title = Text('Adicionando evento');
      action = () {
        _items.add([titleController.text,
          descriptionController.text, datetime]);
        if (_listIndex == 0) {
          _items.sort((a, b) => compare(a[2], b[2]));
        }
      };
    } else {
      title = Text('Modificando evento');
      action = () {
        _items[index][0] = titleController.text;
        _items[index][1] = descriptionController.text;
        _items[index][2] = datetime;
        if (_listIndex == 0) {
          _items.sort((a, b) => compare(a[2], b[2]));
        }
      };
      titleController.text = _items[index][0];
      descriptionController.text = _items[index][1];
      datetime = _items[index][2];
      if (datetime != null) {
        datetimeController.text = 
          '${DateFormat.yMMMMEEEEd('pt_BR').add_Hm().format(datetime)}';
      }
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: title,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.close_outlined, size: 28),
                tooltip: 'Voltar',
                onPressed: () => Navigator.pop(context)
              ),
              actions: [IconButton(
                icon: Icon(Icons.check, size: 28),
                tooltip: 'Finalizar',
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    setState(action);
                    _saveState();
                    Navigator.pop(context);
                  }
                }
              )],
            ),
            body: Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Digite o título do evento',
                      ),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Por favor, digite um título';
                        }
                        return null;
                      },
                      controller: titleController,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Digite a descrição do evento (opcional)',
                      ),
                      controller: descriptionController,
                    ),
                  ),
                  _listIndex == 1 ? Container() : Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                    child: TextFormField(
                      controller: datetimeController,
                      decoration: InputDecoration(
                        hintText: 'Data e hora (00:00 01/01/0001)',
                        suffixIcon: Icon(Icons.access_time, size: 28, color: Colors.deepPurple),
                        suffixIconConstraints: BoxConstraints(maxHeight: 28.0, maxWidth: 28.0)
                      ),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Por favor, insira um horário';
                        }
                        return null;
                      },
                      readOnly: true,
                      onTap: () {
                        DatePicker.showDateTimePicker(context,
                          theme: DatePickerTheme(
                            cancelStyle: TextStyle(color: Colors.black54, fontSize: 20),
                            doneStyle: TextStyle(color: Colors.deepPurple, fontSize: 20),
                            itemStyle: TextStyle(color: Color(0xFF270157), fontSize: 24),
                            containerHeight: 300.0
                          ),
                          showTitleActions: true,
                          minTime: DateTime(DateTime.now().year, 1, 1),
                          maxTime: DateTime(DateTime.now().year + 5, 12, 31),
                          onConfirm: (dt) {
                            datetime = dt;
                            datetimeController.text = 
                              '${DateFormat.yMMMMEEEEd('pt_BR').add_Hm().format(dt)}';
                          },
                          currentTime: DateTime.now(),
                          locale: LocaleType.pt
                        );
                      }
                    ),
                  ),
                ]
              ),
            ),
          );
        }
      )
    );
  }

  Widget _noList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RawMaterialButton(
            onPressed: _manageListItem,
            elevation: 5.0,
            fillColor: Colors.deepPurple,
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 34.0,
            ),
            padding: EdgeInsets.all(18.0),
            shape: CircleBorder(),
          ),
          const SizedBox(height: 15.0),
          Text(
            'Pressione o botão para adicionar eventos',
            style: TextStyle(
              color: Color(0xFFAAAAAA),
              fontSize: 17,
            )
          )
        ],
      )
    );
  }
  
  Widget _buildList() {
    return ListView.separated(
      itemBuilder: (context, index) => 
        _buildTile(_items[index][0], _items[index][1], _items[index][2], index),
      separatorBuilder: (context, index) => Divider(height: 0, thickness: 0),
      itemCount: _items.length,
    );
  }

  Widget _buildTile(String title, String description, DateTime datetime, int index) {
    TextStyle titleStyle = TextStyle(fontSize: 18.0);
    TextStyle descriptionStyle = TextStyle(fontSize: 14.0);
    TextStyle datetimeStyle = TextStyle(color: Colors.black54);
    String datetimeString = '';
    bool selected = _selectedIndex.contains(index);
    
    if (description.isEmpty) {
      description = 'Sem descrição';
      descriptionStyle = TextStyle(fontSize: 14.0, fontStyle: FontStyle.italic);
    }
    if (datetime != null) {
      datetimeString = 
        '${DateFormat('kk:mm\nEEEE\ndd/MM/yyyy', 'pt_BR').format(datetime)}';
      DateTime now = DateTime.now();
      if (datetime.isBefore(now) && (datetime.day != now.day ||
        datetime.month != now.month || datetime.year != now.year)) {
          datetimeStyle = TextStyle(color: Colors.redAccent);
        }
    }
    return ListTile(
      horizontalTitleGap: 0,
      leading: IconButton(
        padding: EdgeInsets.all(0),
        splashRadius: 25,
        icon: Icon(selected ? Icons.check_circle : Icons.circle_outlined),
        color: selected ? Colors.deepPurple : null,
        onPressed: () {
          setState(() {
            if (selected) {
              _selectedIndex.remove(index);
            } else {
              _selectedIndex.add(index);
            }
          });
        }
      ),
      title: Text(
        title, 
        style: titleStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis
      ),
      subtitle: Text(
        description,
        style: descriptionStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis
      ),
      trailing: Container(
        child: Text(
          datetimeString,
          style: datetimeStyle,
        ),
        width: datetime == null ? 0 : 85,
      ),
      onTap: () => _manageListItem(index: index),
      contentPadding: EdgeInsets.only(top: 4, bottom: 4, left: 0, right: 8),
    );
  }
  
  Future<File> _saveState() {
    if (_listIndex == 0) {
      List convertedList = 
        _items.map((item) => [item[0], item[1], item[2].toString()]).toList();
      return widget.storage.writeLists(
        {'agendamentos': convertedList, 'a fazeres': _itemsNotDisplayed}
      );
    } else {
      List convertedList = 
        _itemsNotDisplayed.map((item) => [item[0], item[1], item[2].toString()]).toList();
      return widget.storage.writeLists(
        {'agendamentos': convertedList, 'a fazeres': _items}
      );
    }
  }

  @override
  void initState() {
    super.initState();
    widget.storage.readLists().then((Map<String, dynamic> list) {
      setState(() {
        if (list.isNotEmpty) {
          _items = list['agendamentos'].map((item) => [item[0], item[1], DateTime.parse(item[2])]).toList();
          _itemsNotDisplayed = list['a fazeres'];
        }
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    bool itemsExist = _items.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: itemsExist ? _buildList() : _noList(),
      floatingActionButton: itemsExist ? FloatingActionButton(
        child: Icon(_selectedIndex.isEmpty ? Icons.add : Icons.delete_forever),
        onPressed: _selectedIndex.isEmpty ? _manageListItem : _removeSelectedItems,
      ) : Container(),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Agendamentos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'A fazeres',
          )
        ],
        iconSize: 32,
        selectedFontSize: 16,
        unselectedFontSize: 14,
        currentIndex: _listIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: (index) => setState(() {
          if (_listIndex != index) {
            _shiftLists();
            _selectedIndex.clear();
            _listIndex = index;
          }
        }),
      )
    );
  }
}
