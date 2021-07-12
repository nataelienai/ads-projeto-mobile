import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'items_list.dart';
import 'item_storage.dart';

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
      home: new ItemsList(title: 'Rotineira', storage: ItemStorage()),
    );
  }
}
