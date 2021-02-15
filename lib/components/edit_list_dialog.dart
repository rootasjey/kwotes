import 'package:figstyle/components/sheet_header.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/types/edit_list_payload.dart';
import 'package:figstyle/utils/constants.dart';
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
  Function(EditListPayload) onNameSubmitted,
  Function(EditListPayload) onDescriptionSubmitted,
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

  final isSmallWidth =
      MediaQuery.of(context).size.width < Constants.maxMobileWidth;

  final inputSize = Size(300.0, 80);
  final vPadding = isSmallWidth ? 4.0 : 10.0;

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
                padding: EdgeInsets.only(
                  left: 25.0,
                  right: 25.0,
                  top: 32.0,
                  bottom: vPadding,
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
                        borderSide: BorderSide(
                          color: stateColors.primary,
                          width: 2.0,
                        ),
                      ),
                    ),
                    onChanged: (newValue) {
                      listName = newValue;
                    },
                    onSubmitted: (value) => onNameSubmitted(
                      EditListPayload(
                        listName,
                        listDesc,
                        listIsPublic,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 25.0,
                  vertical: vPadding,
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
                        borderSide: BorderSide(
                          color: stateColors.primary,
                          width: 2.0,
                        ),
                      ),
                    ),
                    onChanged: (newValue) {
                      listDesc = newValue;
                    },
                    onSubmitted: (value) => onDescriptionSubmitted(
                      EditListPayload(
                        listName,
                        listDesc,
                        listIsPublic,
                      ),
                    ),
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
                  top: 28.0,
                  left: 10.0,
                ),
                child: Wrap(
                  spacing: 10.0,
                  runSpacing: 10.0,
                  children: [
                    OutlinedButton.icon(
                      onPressed: onCancel,
                      icon: Icon(Icons.clear),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 12.0,
                        ),
                        child: Opacity(
                          opacity: 1.0,
                          child: Text(
                            'Cancel',
                          ),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        primary: stateColors.foreground,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => onConfirm(
                        EditListPayload(
                          listName,
                          listDesc,
                          listIsPublic,
                        ),
                      ),
                      icon: Icon(Icons.check),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 12.0,
                        ),
                        child: Text(
                          textButtonConfirmation,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
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

  if (isSmallWidth) {
    return await showCupertinoModalBottomSheet(
      context: context,
      builder: (context) {
        return childContent;
      },
    );
  }

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
