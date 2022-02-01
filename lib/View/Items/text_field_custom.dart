import 'package:flutter/material.dart';
import '/View/Interfaces/interaction_to_view_controller.dart';
import '../../Model/Elements/text.dart' as text;
import '../../Model/Elements/text_type.dart';

class TextFieldCustom extends StatefulWidget{
  final InteractionToViewController interView;
  final text.Text texts;

  const TextFieldCustom({required Key? key, required this.interView, required this.texts}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TextFieldCustomState();
}

class _TextFieldCustomState extends State<TextFieldCustom>{

  InteractionToViewController get interView => widget.interView;
  text.Text get texts => widget.texts;
  final focus = FocusNode();
  late String backupText;

  @override
  void initState() {
    super.initState();
    backupText = texts.text;
    focus.addListener(_updateTexts);
  }

  @override
  void dispose() {
    super.dispose();
    focus.removeListener(_updateTexts);
    focus.dispose();
  }

  void _updateTexts() {
    if(backupText != texts.text){
      interView.updateItem('Text', texts.toJson());
    }
  }

  @override
  Widget build(BuildContext context) {
    switch(texts.txtType){
      case TextType.text:
        return TextFormField(
          focusNode: focus,
          keyboardType: TextInputType.multiline,
          minLines: 1,
          maxLines: 50,
          initialValue: texts.text,
          decoration: const InputDecoration(hintText: 'enter some text'),
          onChanged: (value) => texts.text = value,
        );
      case TextType.subtitle:
        return TextFormField(
          focusNode: focus,
          style: const TextStyle(
            fontSize: 19,
            fontStyle: FontStyle.italic
          ),
          initialValue: texts.text,
          decoration: const InputDecoration(hintText: 'enter some text'),
          onChanged: (value) => texts.text = value,
        );
      case TextType.title:
        return TextFormField(
          focusNode: focus,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold
          ),
          initialValue: texts.text,
          decoration: const InputDecoration(hintText: 'enter some text'),
          onChanged: (value) => texts.text = value,
        );
      case TextType.readonly:
        return Container(
          margin: const EdgeInsets.all(5),
          child: Text(
            texts.text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
        );
      default:
        throw Exception('Unknown text type');
    }
  }
}