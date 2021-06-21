import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: [const Locale('pt', 'BR')],
      theme: ThemeData(
        primaryColor: Colors.deepPurple,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.deepPurple)
          )
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.deepPurple
        ), 
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.deepPurple,
          selectionColor: Colors.deepPurpleAccent[100],
          selectionHandleColor: Colors.deepPurple,
        ),
        focusColor: Colors.deepPurple,
        inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple, width: 2.0),
          ),
          suffixStyle: TextStyle(decorationColor: Colors.deepPurple),
          errorStyle: TextStyle(fontSize: 14.0)
        ),
        accentColor: Colors.deepPurpleAccent[200],
      ),
      title: 'Rotineira',
      home: new ItemsList(title: 'Rotineira'),
    );
  }
}

class ItemsList extends StatefulWidget {
  ItemsList({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ItemsList createState() => _ItemsList();
}

class _ItemsList extends State<ItemsList> {
  final _listItems = [];
  final _listItemsNotDisplayed = [];
  final _selectedIndex = [];
  int _listIndex = 0;

  @override
  Widget build(BuildContext context) {
    bool hasItems = _listItems.length > 0;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: hasItems ? _buildList() : _noList(),
      floatingActionButton: hasItems ? FloatingActionButton(
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

  void _shiftLists() {
    var _auxList = _listItems.toList();
    _listItems.clear();
    _listItems.addAll(_listItemsNotDisplayed.toList());
    _listItemsNotDisplayed.clear();
    _listItemsNotDisplayed.addAll(_auxList);
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
        _buildTile(_listItems[index][0], _listItems[index][1], _listItems[index][2], index),
      separatorBuilder: (context, index) => Divider(height: 0, thickness: 0),
      itemCount: _listItems.length,
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
        _listItems.add([titleController.text,
          descriptionController.text, datetime]);
        if (_listIndex == 0) {
          _listItems.sort((a, b) => compare(a[2], b[2]));
        }
      };
    } else {
      title = Text('Modificando evento');
      action = () {
        _listItems[index][0] = titleController.text;
        _listItems[index][1] = descriptionController.text;
        _listItems[index][2] = datetime;
        if (_listIndex == 0) {
          _listItems.sort((a, b) => compare(a[2], b[2]));
        }
      };
      titleController.text = _listItems[index][0];
      descriptionController.text = _listItems[index][1];
      datetime = _listItems[index][2];
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

  void _removeSelectedItems() {
    setState(() {
      _selectedIndex.sort();
      for (int index = _selectedIndex.length - 1; index >= 0; index--) {
        _listItems.removeAt(_selectedIndex[index]);
      }
      _selectedIndex.clear();
    });
  }
}
