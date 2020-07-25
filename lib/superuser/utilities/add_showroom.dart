import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:superuser/utils.dart';

class AddShowroom extends StatefulWidget {
  @override
  _AddShowroomState createState() => _AddShowroomState();
}

class _AddShowroomState extends State<AddShowroom> {
  final titleController = TextEditingController();
  final addressController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  List states = [];
  List areas = [];
  Map locationsMap = {};
  String selectedState;
  String selectedArea;
  CollectionReference firestore = Firestore.instance.collection('showrooms');
  DocumentSnapshot docSnap;

  @override
  void initState() {
    docSnap = Get.arguments;
    if (docSnap != null) {
      titleController.text = docSnap['name'];
      addressController.text = docSnap['adress'];
      latitudeController.text = docSnap['latitude'];
      longitudeController.text = docSnap['longitude'];
      selectedArea = docSnap['area'];
      selectedState = docSnap['state'];
    }
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    addressController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final utils = context.watch<Utils>();
    final extras = context.watch<QuerySnapshot>();
    if (extras != null) {
      for (var map in extras.documents) {
        if (map.documentID == 'locations') {
          locationsMap.addAll(map.data);
        }
      }
      if (selectedState != null) {
        areas = locationsMap[selectedState];
      }
    }

    return Scaffold(
      appBar: utils.appbar(docSnap == null ? 'Add Showroom' : 'Edit Showroom'),
      body: utils.container(
        child: ListView(
          children: <Widget>[
            SizedBox(height: 36),
            utils.productInputDropDown(
                label: 'State',
                value: selectedState,
                items: locationsMap.keys.toList(),
                onChanged: (value) {
                  selectedState = value;
                  selectedArea = null;
                  handleSetState();
                }),
            utils.productInputDropDown(
                label: 'Area',
                value: selectedArea,
                items: areas,
                onChanged: (newValue) {
                  selectedArea = newValue;
                  handleSetState();
                }),
            utils.productInputText(
              label: 'Name',
              controller: titleController,
            ),
            utils.productInputText(
              label: 'Address',
              controller: addressController,
            ),
            utils.productInputText(
              label: 'latitude',
              controller: latitudeController,
              textInputType:
                  TextInputType.numberWithOptions(signed: true, decimal: true),
            ),
            utils.productInputText(
              label: 'longitude',
              controller: longitudeController,
              textInputType:
                  TextInputType.numberWithOptions(signed: true, decimal: true),
            ),
            SizedBox(height: 36),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                utils.getRaisedButton(
                  title: 'Cancel',
                  onPressed: () => Get.back(),
                ),
                utils.getRaisedButton(
                  title: docSnap == null ? 'Confirm' : 'Update',
                  onPressed: () async {
                    if (titleController.text.length > 0 &&
                        addressController.text.length > 0 &&
                        latitudeController.text.length > 0 &&
                        longitudeController.text.length > 0 &&
                        selectedArea != null &&
                        selectedState != null) {
                      if (docSnap == null) {
                        firestore.document().setData({
                          'name': titleController.text,
                          'adress': addressController.text,
                          'state': selectedState,
                          'area': selectedArea,
                          'latitude': latitudeController.text,
                          'longitude': longitudeController.text,
                        });
                      } else {
                        firestore.document(docSnap.documentID).updateData({
                          'name': titleController.text,
                          'adress': addressController.text,
                          'state': selectedState,
                          'area': selectedArea,
                          'latitude': latitudeController.text,
                          'longitude': longitudeController.text,
                        });
                      }
                      Get.back(result: true);
                    } else {
                      utils.showSnackbar('Invalid Entries');
                    }
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  handleSetState() => (mounted) ? setState(() {}) : null;
}
