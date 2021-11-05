import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:my_netia_client/Network/Encryption/sym_encryption.dart';
import '../Exception/database_exception.dart';
import '../Exception/database_timeout_exception.dart';
import '../Exception/server_exception.dart';
import '../Model/Elements/checkbox.dart' as cb;
import '../Model/Elements/image.dart' as img;
import '../Model/Elements/element.dart' as elem;
import '../Model/sheet.dart';
import '../Network/client.dart';
import '../Model/cell.dart';
import '../Model/CellComponents/info.dart';
import '../Model/Elements/text.dart' as text;
import '../Model/Elements/text_type.dart';
import '../View/Interfaces/interaction_view.dart';
import '../View/Screens/login_screen.dart';
import '../View/Screens/main_screen.dart';

void main() {
  Controller controller = Controller();
  controller.start();
}

class Controller implements InteractionView{
  late Client _client;
  late final Info _defaultCell;

  start() async{
    createDefaultCell();
    runApp(MyApp(this));
    //TODO: Disable some actions when _readOnly = true (inside Options)
    //TODO: Themes
  }

  void createDefaultCell() {
    _defaultCell = Info(title: 'MyNetia');
  }

  /// VIEW INTERACTION ///

  @override
  Cell getDefaultCell() => _defaultCell;


  @override
  Future<void> testConnection(String ip, int port, String database, String username, String password) async {
    print('/* testConnection */');
    _client = Client(ip, port, database, username, password);
    try{ await _client.init(); }
    on ServerException catch (e) { throw ServerException('$e'); }
    on DatabaseException catch(e) { throw DatabaseException('$e'); }
    on DatabaseTimeoutException catch(e) { throw DatabaseTimeoutException('$e'); }
    catch(e) { throw Exception(e); }
    finally{
      print('/* testConnection done */');
    }
  }

  @override
  Future<List<Cell>> getCells([String research = '']) async {
    print('/* getCells */');
    var cells = <Cell>[];
    try{
      var jsonList = jsonDecode(await _client.cells(research));
      jsonList.forEach((json) {
        var cell = Cell.fromJson(jsonDecode(json));
        cells.add(cell);
      });
      print('/* getCells done */');
    }
    on ServerException catch(e) { throw ServerException('$e'); }
    catch(e) { throw Exception(e); }
    return cells;
  }

  @override
  Future<List<Sheet>> getSheets(int idCell) async{
    print('/* getSheets */');
    var sheets = <Sheet>[];
    try{
      var jsonList = jsonDecode(await _client.sheetsFromIdCell(idCell));
      jsonList.forEach((json) {
        var sheet = Sheet.fromJson(jsonDecode(json));
        sheets.add(sheet);
      });
      print('/* getSheets done */');
    }
    on ServerException catch(e) { throw ServerException('$e'); }
    catch(e) { throw Exception(e); }
    return sheets;
  }

  @override
  Future<List<elem.Element>> getElements(int idSheet) async{
    print('/* getElements */');
    var elements = <elem.Element>[];
    try{
      var jsonList = jsonDecode(await _client.elementsFromIdSheet(idSheet));
      jsonList.forEach((json) {
        var element = elem.Element.fromJson(jsonDecode(json));
        elements.add(element);
      });
      print('/* getElements done */');
    }
    on ServerException catch(e) { throw ServerException('$e'); }
    catch(e) { throw Exception(e); }
    return elements;
  }

  @override
  Future<void> addCell(String title, String subtitle, String type) async{
    print('/* ADD CELL */');
    try{
      var cell = Cell.factory(id: -1, title: title, subtitle: subtitle, type: type);
      await _client.addCell(jsonEncode(cell));
    }
    on ServerException catch(e) { throw ServerException('$e'); }
    on DatabaseTimeoutException catch(e) { throw DatabaseTimeoutException('$e'); }
    catch(e) { throw Exception(e); }
    finally{
      print('/* ADD CELL DONE */');
    }
  }

  @override
  Future<void> addSheet(int idCell, String title, String subtitle) async{
    print('/* ADD SHEET */');
    try{
      var json = jsonEncode(Sheet(-1, idCell, title, subtitle, -1));
      await _client.addItem('Sheet', json);
    }
    on ServerException catch(e) { throw ServerException('$e'); }
    on DatabaseTimeoutException catch(e) { throw DatabaseTimeoutException('$e'); }
    catch(e) { throw Exception(e); }
    finally{
      print('/* ADD SHEET DONE */');
    }
  }

  @override
  Future<void> addCheckbox(int idParent) async{
    try{
      var json = jsonEncode(cb.Checkbox(id: -1, idParent: idParent, text: '', idOrder: -1));
      await _client.addItem('Checkbox', json);
    }
    on ServerException catch(e) { throw ServerException('$e'); }
    on DatabaseTimeoutException catch(e) { throw DatabaseTimeoutException('$e'); }
    catch(e) { throw Exception(e); }
  }

  @override
  Future<void> addImage(int idParent, Uint8List data) async{
    print('ADD IMAGE');
    try{
      var json = jsonEncode(img.Image(id: -1, data: data, idParent: idParent, idOrder: -1));
      await _client.addItem('Image', json);
    }
    on ServerException catch(e) { throw ServerException('$e'); }
    on DatabaseTimeoutException catch(e) { throw DatabaseTimeoutException('$e'); }
    catch(e) { throw Exception(e); }
    finally{
      print('ADD IMAGE END');
    }
  }

  @override
  Future<void> addTexts(int idParent, int txtType) async{
    try{
      var json = jsonEncode(text.Text(text:'', idParent: idParent, txtType: TextType.values[txtType], id: -1, idOrder: -1));
      await _client.addItem('Text', json);
    }
    on ServerException catch(e) { throw ServerException('$e'); }
    on DatabaseTimeoutException catch(e){ throw DatabaseTimeoutException('$e'); }
    catch(e) { throw Exception(e); }
  }

  @override
  Future<void> deleteItem(String type, int id) async{
    try{ await _client.deleteItem(type, id); }
    on ServerException catch(e) { throw ServerException('$e'); }
    on DatabaseTimeoutException catch(e) { throw DatabaseTimeoutException('$e'); }
    catch(e) { throw Exception(e); }
  }

  @override
  Future<void> updateItem(String type, Map<String, dynamic> jsonValues) async{
    try{ await _client.updateItem(type, jsonEncode(jsonValues)); }
    on ServerException catch(e) { throw ServerException('$e'); }
    on DatabaseTimeoutException catch(e) { throw DatabaseTimeoutException('$e'); }
    catch(e) { throw Exception(e); }
  }

  @override
  Future<void> updateSheetOrder(List<Sheet> sheets) async{
    try{
      var jsonList = <String>[];
      for(var i = 0; i < sheets.length; i++){
        jsonList.add(jsonEncode(sheets[i]));
      }
      await _client.updateOrder('Sheet', jsonEncode(jsonList));
    }
    on ServerException catch(e) { throw ServerException('$e'); }
    on DatabaseTimeoutException catch(e) { throw DatabaseTimeoutException('$e'); }
    catch(e) { throw Exception(e); }
  }

  @override
  Future<void> updateElementOrder(List<elem.Element> elements) async{
    var jsonList = <String>[];
    for(var i = 0; i < elements.length; i++){
      jsonList.add(jsonEncode(elements[i]));
    }
    await _client.updateOrder('Element', jsonEncode(jsonList));
  }

  @override
  void gotoLoginScreen(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => LoginScreen(this),
      ),
      (route) => false,
    );
  }

  @override
  void gotoMainScreen(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => MainScreen(this),
      ),
    );
  }
}

class MyApp extends StatelessWidget{
  final InteractionView interactionView;

   const MyApp(this.interactionView, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyNetia',
      /*theme: ThemeData.(
        primarySwatch: Colors.blue,
      ),*/
      theme: ThemeData.dark(),
      home: LoginScreen(interactionView),
    );
  }
}
