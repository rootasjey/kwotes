import 'package:figstyle/components/sheet_header.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/types/edit_list_payload.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

Future showEditListDialog({
  @required BuildContext context,
  @required String listName,
  @required String listDesc,
  @required bool listIsPublic,
  @required VoidCallback onCancel,
  @required Function(EditListPayload) onConfirm,
  String textButtonConfirmation = 'Update',
  String title = 'Update name',
  String subtitle = '',
}) async {
  final initialListName = listName;
  final initialListDesc = listDesc;

  final nameController = TextEditingController();
  final descController = TextEditingController();

  nameController.text = initialListName;
  descController.text = initialListDesc;

  final inputSize = Size(300.0, 80);

  final childContent = Material(
    child: ListView(
      physics: ClampingScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SheetHeader(
                title: title,
                subTitle: subtitle,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25.0,
                  vertical: 10.0,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints.tight(inputSize),
                  child: TextField(
                    autofocus: true,
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(color: stateColors.primary),
                      hintText: initialListName,
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: stateColors.primary, width: 2.0),
                      ),
                    ),
                    onChanged: (newValue) {
                      listName = newValue;
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25.0,
                  vertical: 10.0,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints.tight(inputSize),
                  child: TextField(
                    controller: descController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: stateColors.primary),
                      hintText: initialListDesc,
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: stateColors.primary, width: 2.0),
                      ),
                    ),
                    onChanged: (newValue) {
                      listDesc = newValue;
                    },
                  ),
                ),
              ),
              StatefulBuilder(builder: (context, childSetState) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      Checkbox(
                        value: listIsPublic,
                        onChanged: (newValue) {
                          childSetState(() {
                            listIsPublic = newValue;
                          });
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Opacity(
                          opacity: .6,
                          child: Text('Is public?'),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              Padding(
                padding: EdgeInsets.only(
                  top: 20.0,
                  left: 10.0,
                ),
                child: Wrap(
                  spacing: 10.0,
                  runSpacing: 10.0,
                  children: [
                    OutlinedButton.icon(
                      onPressed: onCancel,
                      icon: Opacity(
                        opacity: 0.6,
                        child: Icon(Icons.clear),
                      ),
                      label: Opacity(
                        opacity: 0.6,
                        child: Text(
                          'Cancel',
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        primary: stateColors.foreground,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => onConfirm(
                        EditListPayload(
                          listName,
                          listDesc,
                          listIsPublic,
                        ),
                      ),
                      icon: Opacity(
                        opacity: 0.6,
                        child: Icon(Icons.check),
                      ),
                      label: Opacity(
                        opacity: 0.6,
                        child: Text(
                          textButtonConfirmation,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        primary: stateColors.validation,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  if (MediaQuery.of(context).size.width < 700.0) {
    return await showCupertinoModalBottomSheet(
      context: context,
      builder: (context) {
        return childContent;
      },
    );
  } else {
    return await showFlash(
      context: context,
      persistent: false,
      builder: (context, controller) {
        return Flash.dialog(
          controller: controller,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          enableDrag: true,
          margin: const EdgeInsets.only(
            left: 120.0,
            right: 120.0,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(8.0),
          ),
          child: FlashBar(
            message: Container(
              height: MediaQuery.of(context).size.height - 100.0,
              padding: const EdgeInsets.all(60.0),
              child: childContent,
            ),
          ),
        );
      },
    );
  }
}
