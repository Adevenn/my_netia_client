import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:my_netia_client/View/Interfaces/interaction_view.dart';

class ImageCustom extends StatefulWidget{

  final Uint8List data;
  final InteractionView interView;
  const ImageCustom({required this.interView, required this.data, required Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ImageState();
}

class _ImageState extends State<ImageCustom>{
  @override
  Widget build(BuildContext context) {
    return Image.memory(widget.data);
  }

}