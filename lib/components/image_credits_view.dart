import 'package:fig_style/components/form_action_inputs.dart';
import 'package:fig_style/components/sheet_header.dart';
import 'package:fig_style/types/image_credits.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class ImageCreditsView extends StatefulWidget {
  final bool beforeJC;

  final DateTime selectedDate;

  final void Function(DateTime) onDateChanged;
  final void Function(bool) onBeforeJCChanged;
  final void Function(String) onNameChanged;
  final void Function(String) onUrlChanged;
  final void Function(String) onCompanyChanged;
  final void Function(String) onArtistChanged;
  final void Function(String) onLocationChanged;
  final void Function(String) onSubmit;
  final void Function() onClear;

  final ImageCredits credits;

  final ScrollController scrollController;

  const ImageCreditsView({
    Key key,
    this.scrollController,
    this.selectedDate,
    this.onDateChanged,
    this.beforeJC = false,
    this.onBeforeJCChanged,
    this.onNameChanged,
    this.onUrlChanged,
    this.onCompanyChanged,
    this.onArtistChanged,
    this.onLocationChanged,
    this.onSubmit,
    this.onClear,
    this.credits,
  }) : super(key: key);

  @override
  _ImageCreditsViewState createState() => _ImageCreditsViewState();
}

class _ImageCreditsViewState extends State<ImageCreditsView> {
  TextEditingController nameController;
  TextEditingController urlController;
  TextEditingController locationController;
  TextEditingController companyController;
  TextEditingController artistController;

  FocusNode nameFocusNode;

  DateTime _selectedDate;
  bool _beforeJC = false;

  @override
  void initState() {
    super.initState();

    _beforeJC = widget.beforeJC;
    _selectedDate = widget.selectedDate ?? DateTime.now();

    nameFocusNode = FocusNode();

    artistController = TextEditingController();
    companyController = TextEditingController();
    locationController = TextEditingController();
    nameController = TextEditingController();
    urlController = TextEditingController();

    if (widget.credits != null) {
      final credits = widget.credits;

      artistController.text = credits.artist;
      companyController.text = credits.company;
      locationController.text = credits.location;
      nameController.text = credits.name;
      urlController.text = credits.url;
    }
  }

  @override
  void dispose() {
    nameFocusNode.dispose();

    artistController.dispose();
    companyController.dispose();
    locationController.dispose();
    nameController.dispose();
    urlController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        physics: ClampingScrollPhysics(),
        controller: widget.scrollController,
        children: [
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SheetHeader(
                  title: "Credits",
                  subTitle: "Give back the image credits to its author.",
                ),
                Padding(
                  padding: EdgeInsets.only(top: 60.0),
                  child: Wrap(
                    spacing: 10.0,
                    runSpacing: 10.0,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialEntryMode: DatePickerEntryMode.input,
                            initialDate: _selectedDate ?? DateTime.now(),
                            firstDate: DateTime(0),
                            lastDate: DateTime.now(),
                          );

                          setState(() {
                            _selectedDate = picked ?? _selectedDate;
                          });

                          if (widget.onDateChanged != null) {
                            widget.onDateChanged(picked);
                          }
                        },
                        icon: Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Icon(UniconsLine.calender),
                        ),
                        label: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            _selectedDate != null
                                ? _selectedDate
                                    .toLocal()
                                    .toString()
                                    .split(' ')[0]
                                : 'Select a new date for this photo',
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 400.0,
                        child: CheckboxListTile(
                          title: Text('Before J-C (Jesus Christ)'),
                          subtitle: Text('(e.g. year -500)'),
                          // value: widget.beforeJC,
                          value: _beforeJC,
                          onChanged: (newValue) {
                            setState(() {
                              _beforeJC = newValue;
                            });

                            if (widget.onBeforeJCChanged != null) {
                              widget.onBeforeJCChanged(newValue);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30.0),
                  child: TextField(
                    autofocus: true,
                    controller: nameController,
                    focusNode: nameFocusNode,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      icon: Icon(UniconsLine.image),
                      labelText: "Name",
                    ),
                    minLines: 1,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                    onChanged: (newValue) {
                      if (widget.onNameChanged != null) {
                        widget.onNameChanged(newValue);
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: TextField(
                    controller: urlController,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      icon: Icon(UniconsLine.link),
                      labelText: "Source URL",
                    ),
                    minLines: 1,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                    onChanged: (newValue) {
                      if (widget.onUrlChanged != null) {
                        widget.onUrlChanged(newValue);
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: TextField(
                    controller: companyController,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      icon: Icon(UniconsLine.building),
                      labelText: "Company",
                    ),
                    minLines: 1,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                    onChanged: (newValue) {
                      if (widget.onCompanyChanged != null) {
                        widget.onCompanyChanged(newValue);
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: TextField(
                    controller: locationController,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      icon: Icon(UniconsLine.map),
                      labelText: "Location (e.g. Cannes festival)",
                    ),
                    minLines: 1,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                    onChanged: (newValue) {
                      if (widget.onLocationChanged != null) {
                        widget.onLocationChanged(newValue);
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 16.0,
                    bottom: 32.0,
                  ),
                  child: TextField(
                    controller: artistController,
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      icon: Icon(UniconsLine.user_md),
                      labelText: "Artist",
                    ),
                    minLines: 1,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                    onChanged: (newValue) {
                      if (widget.onArtistChanged != null) {
                        widget.onArtistChanged(newValue);
                      }
                    },
                    onSubmitted: (newValue) {
                      if (widget.onSubmit != null) {
                        widget.onSubmit(newValue);
                      }
                    },
                  ),
                ),
                FormActionInputs(
                  cancelTextString: 'Clear inputs',
                  onCancel: () {
                    artistController.clear();
                    companyController.clear();
                    locationController.clear();
                    nameController.clear();
                    urlController.clear();

                    nameFocusNode.requestFocus();

                    if (widget.onClear != null) {
                      widget.onClear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
