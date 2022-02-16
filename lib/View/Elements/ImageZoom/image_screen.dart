import 'dart:typed_data';

import 'package:flutter/material.dart';
import '/View/Interfaces/interaction_main.dart';
import '../image_raw.dart';

class ImageScreen extends StatelessWidget{

  final InteractionMain interMain;
  final int idImage;

  const ImageScreen({Key? key, required this.idImage, required this.interMain}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: FutureBuilder<Uint8List>(
        future: interMain.getRawImage(idImage),
        builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
          if(snapshot.hasData){
            var data = snapshot.data!;
            return Center(
              child: SingleChildScrollView(
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ImageRaw(data: data),
                  ),
                ),
              ),
            );
          }
          else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const <Widget>[
                  SizedBox(
                    child: CircularProgressIndicator(),
                    width: 60,
                    height: 60,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text('Awaiting ...'),
                  )
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        child: const Icon(Icons.close),
        tooltip: 'Close image screen',
      ),
    );
  }
}