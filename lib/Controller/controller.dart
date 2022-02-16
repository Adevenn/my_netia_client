import 'dart:convert';
import 'dart:typed_data';

import '/Exception/database_exception.dart';
import '/Exception/database_timeout_exception.dart';
import '/Exception/server_exception.dart';
import '/Model/Elements/checkbox.dart';
import '/Model/Elements/element.dart';
import '/Model/Elements/image.dart';
import '/Model/Elements/text.dart';
import '/Model/Elements/text_type.dart';
import '/Model/cell.dart';
import '/Model/Cells/Book/sheet.dart';
import '/Network/client.dart';
import '/View/Interfaces/interaction_to_controller.dart';

class Controller implements InteractionToController {
  late Client _client;

  /// VIEW INTERACTION ///

  @override
  Future<void> testConnection(String ip, int port, String database,
      String username, String password) async {
    _client = Client(ip, port, database, username, password);
    try {
      await _client.init();
    } on ServerException catch (e) {
      throw ServerException('$e');
    } on DatabaseException catch (e) {
      throw DatabaseException('$e');
    } on DatabaseTimeoutException catch (e) {
      throw DatabaseTimeoutException('$e');
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<List<Cell>> getCells([String research = '']) async {
    var cells = <Cell>[];
    try {
      var jsonList = jsonDecode(await _client.cells(research));
      jsonList.forEach((json) {
        var cell = Cell.fromJson(jsonDecode(json));
        cells.add(cell);
      });
    } on ServerException catch (e) {
      throw ServerException('$e');
    } on DatabaseTimeoutException catch (e) {
      throw DatabaseTimeoutException('$e');
    } catch (e) {
      throw Exception(e);
    }
    return cells;
  }

  @override
  Future<List<Sheet>> getSheets(int idCell) async {
    var sheets = <Sheet>[];
    try {
      var jsonList = jsonDecode(await _client.request('sheets', [idCell]));
      jsonList.forEach((json) {
        var sheet = Sheet.fromJson(jsonDecode(json));
        sheets.add(sheet);
      });
    } on ServerException catch (e) {
      throw ServerException('$e');
    } on DatabaseTimeoutException catch (e) {
      throw DatabaseTimeoutException('$e');
    } catch (e) {
      throw Exception(e);
    }
    return sheets;
  }

  @override
  Future<Sheet> getSheet(int idCell, int sheetIndex) async {
    try {
      List<Object> list = [];
      list.add(idCell);
      list.add(sheetIndex);
      var json = await _client.request('sheet', [idCell, sheetIndex]);
      return Sheet.fromJson(jsonDecode(json));
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<List<Element>> getElements(int idSheet) async {
    var elements = <Element>[];
    try {
      var jsonList = jsonDecode(await _client.request('elements', [idSheet]));
      jsonList.forEach((json) {
        var element = Element.fromJson(jsonDecode(json));
        elements.add(element);
      });
    } on ServerException catch (e) {
      throw ServerException('$e');
    } on DatabaseTimeoutException catch (e) {
      throw DatabaseTimeoutException('$e');
    } catch (e) {
      throw Exception(e);
    }
    return elements;
  }

  @override
  Future<Uint8List> getRawImage(int idImage) async {
    try {
      var json = jsonDecode(await _client.request('rawImage', [idImage]));
      assert(json is Map<String, dynamic>);
      return Uint8List.fromList(json['img_raw'].cast<int>());
    } on ServerException catch (e) {
      throw ServerException('$e');
    } on DatabaseTimeoutException catch (e) {
      throw DatabaseTimeoutException('$e');
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> addCell(String title, String subtitle, String type) async {
    try {
      var cell =
          Cell.factory(id: -1, title: title, subtitle: subtitle, type: type);
      var result = await _client.request('addCell', [jsonEncode(cell)]);
      if (result == 'failed') {
        throw const ServerException('Result : failed');
      }
    } on ServerException catch (e) {
      throw ServerException('$e');
    } on DatabaseTimeoutException catch (e) {
      throw DatabaseTimeoutException('$e');
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> addSheet(int idCell, String title, String subtitle) async {
    try {
      var json = jsonEncode(Sheet(-1, idCell, title, subtitle, -1));
      await _client.request('addItem', ['Sheet', json]);
    } on ServerException catch (e) {
      throw ServerException('$e');
    } on DatabaseTimeoutException catch (e) {
      throw DatabaseTimeoutException('$e');
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> addCheckbox(int idParent) async {
    try {
      var json = jsonEncode(
          Checkbox(id: -1, idParent: idParent, text: '', idOrder: -1));
      await _client.request('addItem', ['Checkbox', json]);
    } on ServerException catch (e) {
      throw ServerException('$e');
    } on DatabaseTimeoutException catch (e) {
      throw DatabaseTimeoutException('$e');
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> addImage(List<Image> images) async {
    try {
      for (var image in images) {
        await _client.request('addItem', ['Image', jsonEncode(image)]);
      }
    } on ServerException catch (e) {
      throw ServerException('$e');
    } on DatabaseTimeoutException catch (e) {
      throw DatabaseTimeoutException('$e');
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> addTexts(int idParent, int txtType) async {
    try {
      var json = jsonEncode(Text(
          text: '',
          idParent: idParent,
          txtType: TextType.values[txtType],
          id: -1,
          idOrder: -1));
      await _client.request('addItem', ['Text', json]);
    } on ServerException catch (e) {
      throw ServerException('$e');
    } on DatabaseTimeoutException catch (e) {
      throw DatabaseTimeoutException('$e');
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> deleteItem(String type, int id) async {
    try {
      await _client.request('deleteItem', [type, id]);
    } on ServerException catch (e) {
      throw ServerException('$e');
    } on DatabaseTimeoutException catch (e) {
      throw DatabaseTimeoutException('$e');
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> updateItem(String type, Map<String, dynamic> jsonValues) async {
    try {
      await _client.request('updateItem', [type, jsonEncode(jsonValues)]);
    } on ServerException catch (e) {
      throw ServerException('$e');
    } on DatabaseTimeoutException catch (e) {
      throw DatabaseTimeoutException('$e');
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> updateOrder(String type, List<Object> list) async{
    try {
      var jsonList = <String>[];
      switch(type){
        case 'Sheet':
          list = list as List<Sheet>;
          break;
        case 'Element':
          list = list as List<Element>;
          break;
        default:
          throw Exception('Type not implemented\nType : $type');
      }
      for (var i = 0; i < list.length; i++) {
        jsonList.add(jsonEncode(list[i]));
      }
      await _client.request('updateOrder', [type, jsonEncode(jsonList)]);
    } catch (e) {
      throw Exception(e);
    }
  }
}
