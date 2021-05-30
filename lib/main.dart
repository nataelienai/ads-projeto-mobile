import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
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
        )
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar (
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: _buildList(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addListItem,
      ),
    );
  }
  
  Widget _buildList() {
    return ListView.separated(
      itemBuilder: (context, index) => 
        _buildTile(_listItems[index][0], _listItems[index][1]),
      separatorBuilder: (context, index) => Divider(height: 0, thickness: 0),
      itemCount: _listItems.length,
    );
  }

  Widget _buildTile(String itemTitle, String itemDescription) {
    var titleStyle = TextStyle(fontSize: 18.0);
    var descriptionStyle = TextStyle(fontSize: 14.0);
    
    if (itemDescription.isEmpty) {
      itemDescription = 'Sem descrição';
      descriptionStyle = TextStyle(fontSize: 14.0, fontStyle: FontStyle.italic);
    }
    return ListTile(
      title: Text(
        itemTitle, 
        style: titleStyle,
      ),
      subtitle: Text(
        itemDescription,
        style: descriptionStyle,
      ),
      onTap: () => null,
      trailing: Container(
        height: double.infinity,
        child: Icon(Icons.arrow_forward_ios, size: 18)
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _addListItem() {
    final _formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Adicionando item'),
              centerTitle: true,
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
                      child: Text('Finalizar'),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          setState(() {
                            _listItems.add([titleController.text, 
                              descriptionController.text]);
                          });
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
}
