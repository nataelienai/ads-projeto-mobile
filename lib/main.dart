import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
          errorStyle: TextStyle(fontSize: 14.0)
        ),
        accentColor: Colors.deepPurpleAccent[200]
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
  final _selectedIndex = [];

  @override
  Widget build(BuildContext context) {
    if (_listItems.length > 0) {
      return _initList();
    } else {
      return _initNoList();
    }
  }

  Widget _initNoList() {
    return Scaffold(
      appBar: AppBar (
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Center(
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
    ));
  }

  Widget _initList() {
    return Scaffold(
      appBar: AppBar (
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: _buildList(),
      floatingActionButton: FloatingActionButton(
        child: Icon(_selectedIndex.isEmpty ? Icons.add : Icons.remove),
        onPressed: _selectedIndex.isEmpty ? _manageListItem : _removeSelectedItems,
      ),
    );
  }
  
  Widget _buildList() {
    return ListView.separated(
      itemBuilder: (context, index) => 
        _buildTile(_listItems[index][0], _listItems[index][1], index),
      separatorBuilder: (context, index) => Divider(height: 0, thickness: 0),
      itemCount: _listItems.length,
    );
  }

  Widget _buildTile(String itemTitle, String itemDescription, int index) {
    TextStyle titleStyle = TextStyle(fontSize: 18.0);
    TextStyle descriptionStyle = TextStyle(fontSize: 14.0);
    bool selected = _selectedIndex.contains(index);
    
    if (itemDescription.isEmpty) {
      itemDescription = 'Sem descrição';
      descriptionStyle = TextStyle(fontSize: 14.0, fontStyle: FontStyle.italic);
    }
    
    return ListTile(
      horizontalTitleGap: 4,
      leading: Container(
        height: double.infinity,
        child: IconButton(
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
        )
      ),
      title: Text(
        itemTitle, 
        style: titleStyle,
      ),
      subtitle: Text(
        itemDescription,
        style: descriptionStyle,
      ),
      onTap: () => _manageListItem(index: index),
      contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    );
  }

  void _manageListItem({int index}) {
    final _formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    Text title;
    Function action;

    if (index == null) {
      title = Text('Adicionando evento');
      action = () {
        _listItems.add([titleController.text, descriptionController.text]);
      };
    } else {
      title = Text('Modificando evento');
      action = () {
        _listItems[index][0] = titleController.text;
        _listItems[index][1] = descriptionController.text;
      };
      titleController.text = _listItems[index][0];
      descriptionController.text = _listItems[index][1];
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: title,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, size: 20), 
                onPressed: () { Navigator.pop(context); }
              )
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
                        if (value == null || value.isEmpty) {
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
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        textStyle: TextStyle(fontSize: 16.0),
                        padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0)
                      ),
                      child: Text('Finalizar'),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          setState(action);
                          Navigator.pop(context);
                        }
                      }
                    )
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
