import 'package:figstyle/components/sheet_header.dart';
import 'package:figstyle/state/colors.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

Future showDeleteListDialog({
  @required BuildContext context,
  @required VoidCallback onConfirm,
  @required VoidCallback onCancel,
  @required String listName,
}) async {
  FocusNode focusNode = FocusNode();

  if (MediaQuery.of(context).size.width < 700.0) {
    return await showCustomModalBottomSheet(
      context: context,
      builder: (context) {
        return RawKeyboardListener(
          focusNode: focusNode,
          autofocus: true,
          onKey: (keyEvent) {
            if (keyEvent.isKeyPressed(LogicalKeyboardKey.enter) ||
                keyEvent.isKeyPressed(LogicalKeyboardKey.space)) {
              onConfirm();
              return;
            }
          },
          child: Material(
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                      'Confirm',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    trailing: Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                    tileColor: stateColors.deletion,
                    onTap: onConfirm,
                  ),
                  ListTile(
                    title: Text('Cancel'),
                    trailing: Icon(Icons.close),
                    onTap: onCancel,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      containerWidget: (context, animation, child) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Material(
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(12.0),
              child: child,
            ),
          ),
        );
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
              child: RawKeyboardListener(
                focusNode: focusNode,
                autofocus: true,
                onKey: (keyEvent) {
                  if (keyEvent.isKeyPressed(LogicalKeyboardKey.enter) ||
                      keyEvent.isKeyPressed(LogicalKeyboardKey.space)) {
                    onConfirm();
                    return;
                  }
                },
                child: Material(
                  child: ListView(
                    physics: ClampingScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SheetHeader(
                              title: "Delete list $listName",
                              subTitle: "Are you sure?",
                            ),
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
                                    onPressed: onConfirm,
                                    icon: Opacity(
                                      opacity: 0.6,
                                      child: Icon(Icons.check),
                                    ),
                                    label: Opacity(
                                      opacity: 0.6,
                                      child: Text(
                                        'Delete',
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
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
