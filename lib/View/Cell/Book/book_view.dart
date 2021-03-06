import 'package:flutter/material.dart';

import '/Model/Cells/sheet.dart';
import '/View/Cell/Book/book_element_view.dart';
import '/Model/Cells/cell.dart';
import '/View/Interfaces/interaction_view.dart';
import '../Sheet/sheet_screen.dart';

typedef SheetIndexCallBack = void Function(int sheetIndex);

class BookView extends StatelessWidget {
  final InteractionView interView;
  final Cell cell;
  final Sheet sheet;
  final int sheetIndex;
  final SheetIndexCallBack onSheetIndexChange;

  const BookView(
      {Key? key,
      required this.interView,
      required this.cell,
      required this.sheet,
      required this.sheetIndex,
      required this.onSheetIndexChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BookElemView(interView: interView, sheet: sheet),
      bottomSheet: Container(
        margin: const EdgeInsets.all(15),
        child: Tooltip(
          message: 'Sheets',
          child: FloatingActionButton(
            heroTag: 'sheetsBtn',
            onPressed: () async {
              var result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SheetScreen(
                            cell: cell,
                            interView: interView,
                            index: sheetIndex,
                            selectedSheetId: sheet.id,
                          )));
              if (sheetIndex != result) {
                //Call the function defined by the parent (parent setState)
                onSheetIndexChange(result);
              }
            },
            child: const Icon(Icons.text_snippet),
          ),
        ),
      ),
    );
  }
}
