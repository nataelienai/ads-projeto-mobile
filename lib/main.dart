import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rotineira',
      home: new HomePage(title: 'Rotineira'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  final _listItems = <String>[];

  Widget _buildList() {
    return ListView.separated(
      itemBuilder: (context, index) => _buildTile(_listItems[index]),
      separatorBuilder: (context, index) => Divider(height: 0),
      itemCount: _listItems.length,
    );
  }

  Widget _buildTile(String itemTitle) {
    return ListTile(
      title: Text(
        itemTitle, 
        style: TextStyle(fontSize: 18)
      ),
      subtitle: Text(
        'Descrição',
        style: TextStyle(fontSize: 14),
      ),
      onTap: () => null,
      trailing: Icon(Icons.arrow_forward_ios, size: 18),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

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
        onPressed: () {
          int index = _listItems.length;
          _listItems.add('Título $index');
          setState(() {});
        }
      ),
    );
  }
}
