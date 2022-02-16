import 'package:flutter/material.dart';
import '/Model/Elements/checkbox.dart' as cb;
import '../Interfaces/interaction_to_controller.dart';

class CheckboxCustom extends StatefulWidget{
  final InteractionToController interMain;
  final cb.Checkbox checkbox;

  const CheckboxCustom({required Key key, required this.interMain, required this.checkbox}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CheckBoxState();
}

class _CheckBoxState extends State<CheckboxCustom>{

  cb.Checkbox get checkbox => widget.checkbox;
  InteractionToController get interMain => widget.interMain;
  var focusCheckbox = FocusNode();
  var focusTxt = FocusNode();
  late bool backupChecked;
  late String backupText;

  @override
  void initState() {
    super.initState();
    backupChecked = checkbox.isChecked;
    backupText = checkbox.text;
    focusTxt.addListener(_updateCheckbox);
    focusCheckbox.addListener(_updateCheckbox);
  }

  @override
  void dispose() {
    super.dispose();
    focusCheckbox.removeListener(_updateCheckbox);
    focusTxt.removeListener(_updateCheckbox);
    focusCheckbox.dispose();
    focusTxt.dispose();
  }

  ///Update [checkbox] when values change and both elements
  ///([checkbox.text] and [checkbox.isChecked]) lost focus
  void _updateCheckbox() async{
    if(!focusCheckbox.hasFocus && !focusTxt.hasFocus){
      if(backupChecked != checkbox.isChecked
          || backupText != checkbox.text){
        backupChecked = checkbox.isChecked;
        backupText = checkbox.text;
        interMain.updateItem('Checkbox', checkbox.toJson());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Checkbox(
          focusNode: focusCheckbox,
          value: checkbox.isChecked,
          onChanged: (bool? value){
            focusCheckbox.requestFocus();
            setState(() => checkbox.isChecked = value!);
          },
        ),
        Expanded(
          child: TextFormField(
            focusNode: focusTxt,
            initialValue: checkbox.text,
            decoration: const InputDecoration(hintText: 'enter some text'),
            onChanged: (value) => checkbox.text = value,
          ),
        ),
      ],
    );
  }
}