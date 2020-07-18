import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:superuser/services/upload_product.dart';
import 'package:superuser/utils.dart';

class PushData extends StatefulWidget {
  final uid;
  final scaffoldkey;

  const PushData({Key key, this.uid, this.scaffoldkey}) : super(key: key);

  @override
  _PushDataState createState() => _PushDataState();
}

class _PushDataState extends State<PushData> {
  List<Asset> images = [];
  String selectedCategory;
  String selectedShowroom;
  String selectedState;
  String selectedArea;
  List categoryList = [];
  List areasList = [];
  List statesList = [];
  List showroomList = [];
  String addressID;
  bool loading = false;

  Utils utils = Utils();

  final price = TextEditingController();
  final title = TextEditingController();
  final description = TextEditingController();
  final showroomAddressController = TextEditingController();
  Firestore firestore = Firestore.instance;
  final textstyle = TextStyle(color: Colors.grey, fontSize: 16);

  initData() async {
    loading = true;
    handleSetState();
    await firestore.collection('extras').getDocuments().then((value) {
      value.documents.forEach((element) {
        if (element.documentID == 'category') {
          categoryList.addAll(element.data['category_array']);
        } else if (element.documentID == 'areas') {
          areasList.addAll(element.data['areas_array']);
        } else if (element.documentID == 'states') {
          statesList.addAll(element.data['states_array']);
        }
      });
    });
    await firestore.collection('showrooms').getDocuments().then((value) {
      showroomList.addAll(value.documents);
    });
    loading = false;
    handleSetState();
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  void dispose() {
    price.dispose();
    title.dispose();
    description.dispose();
    showroomAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return utils.getContainer(
      child: loading
          ? utils.getLoadingIndicator()
          : ListView(
              children: <Widget>[
                SizedBox(height: 9),
                GridView.count(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  children: List.generate(images.length + 1, (index) {
                    if (index == images.length) {
                      return Container(
                        margin: EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9),
                          color: Colors.grey.shade100,
                        ),
                        child: IconButton(
                          onPressed: () async {
                            if (await Permission.camera.request().isGranted &&
                                await Permission.storage.request().isGranted) {
                              try {
                                images = await MultiImagePicker.pickImages(
                                  maxImages: 5,
                                  enableCamera: true,
                                  selectedAssets: images,
                                  materialOptions: MaterialOptions(
                                    statusBarColor: '#FF6347',
                                    startInAllView: true,
                                    actionBarColor: "#FF6347",
                                    actionBarTitle: "Pick Images",
                                    allViewTitle: "Pick Images",
                                    useDetailsView: false,
                                    selectCircleStrokeColor: "#FF6347",
                                  ),
                                );
                                handleSetState();
                              } catch (e) {
                                utils.getSnackbar(
                                    widget.scaffoldkey, e.toString());
                              }
                            } else {
                              utils.getSnackbar(widget.scaffoldkey,
                                  'Insufficient Permissions');
                            }
                          },
                          icon: Icon(
                            MdiIcons.plusOutline,
                            color: Colors.red.shade300,
                          ),
                        ),
                      );
                    }
                    return Padding(
                      padding: EdgeInsets.all(9),
                      child: AssetThumb(
                        spinner: utils.getLoadingIndicator(),
                        asset: images[index],
                        quality: 75,
                        width: 270,
                        height: 270,
                      ),
                    );
            }),
          ),
          utils.getTextInputPadding(
            child: DropdownButtonFormField(
                decoration: utils.getDecoration(label: 'Category'),
                isExpanded: true,
                iconEnabledColor: Colors.grey,
                style: textstyle,
                iconSize: 30,
                elevation: 9,
                onChanged: (newValue) {
                  selectedCategory = newValue;
                  handleSetState();
                },
                items: categoryList.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  );
                }).toList()),
          ),
          utils.getTextInputPadding(
            child: DropdownButtonFormField(
                decoration: utils.getDecoration(label: 'State'),
                isExpanded: true,
                iconEnabledColor: Colors.grey,
                style: TextStyle(color: Colors.grey, fontSize: 16),
                iconSize: 30,
                elevation: 9,
                onChanged: (newValue) {
                  selectedState = newValue;
                  handleSetState();
                },
                items: statesList.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  );
                }).toList()),
          ),
          utils.getTextInputPadding(
            child: DropdownButtonFormField(
                decoration: utils.getDecoration(label: 'Area'),
                isExpanded: true,
                iconEnabledColor: Colors.grey,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
                iconSize: 30,
                elevation: 9,
                onChanged: (newValue) {
                  selectedArea = newValue;
                  handleSetState();
                },
                items: areasList.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  );
                }).toList()),
          ),
          utils.getTextInputPadding(
            child: DropdownButtonFormField(
              decoration: utils.getDecoration(label: 'Showroom'),
              isExpanded: true,
              iconEnabledColor: Colors.grey,
              style: TextStyle(color: Colors.grey, fontSize: 16),
              iconSize: 30,
              elevation: 9,
              onChanged: (newValue) {
                selectedShowroom = newValue;
                showroomList.forEach((element) {
                  if (element['name'] == newValue) {
                    showroomAddressController.text = element['adress'];
                    addressID = element.documentID;
                    return false;
                  } else {
                    return true;
                  }
                });
                handleSetState();
              },
              items: showroomList.map((value) {
                return DropdownMenuItem(
                  value: value['name'],
                  child: Text(
                    value['name'],
                  ),
                );
              }).toList(),
            ),
          ),
          utils.getTextInputPadding(
            child: TextField(
              style: textstyle,
              readOnly: true,
              maxLines: null,
              controller: showroomAddressController,
              keyboardType:
              TextInputType.numberWithOptions(decimal: true),
              decoration: utils.getDecoration(label: 'Showroom Adress'),
            ),
          ),
          utils.getTextInputPadding(
            child: TextField(
              style: textstyle,
              controller: price,
              maxLines: null,
              keyboardType:
              TextInputType.numberWithOptions(decimal: true),
              decoration: utils.getDecoration(label: 'Price'),
            ),
          ),
          utils.getTextInputPadding(
            child: TextField(
              style: TextStyle(color: Colors.grey, fontSize: 16),
              controller: title,
              maxLines: null,
              keyboardType: TextInputType.text,
              decoration: utils.getDecoration(label: 'Title'),
            ),
          ),
          utils.getTextInputPadding(
            child: TextField(
              style: TextStyle(color: Colors.grey, fontSize: 16),
              controller: description,
              maxLines: null,
              keyboardType: TextInputType.text,
              decoration: utils.getDecoration(label: 'Description'),
            ),
          ),
          SizedBox(
            height: 18,
          ),
          utils.getRaisedButton(
            title: 'Add Product',
            onPressed: onPressed,
          ),
          SizedBox(height: 50),
        ],
            ),
    );
  }

  onPressed() async {
    FocusScope.of(context).unfocus();
    if (images.length > 0 &&
        selectedCategory != null &&
        selectedArea != null &&
        selectedState != null &&
        title != null &&
        description != null &&
        price.text.length > 0 &&
        title.text.length > 0 &&
        description.text.length > 0) {
      loading = true;
      handleSetState();
      await PushProduct().uploadProduct(
        images,
        selectedCategory,
        selectedState,
        selectedArea,
        price.text,
        title.text,
        description.text,
        widget.uid,
        addressID,
      );
      images.clear();
      price.clear();
      title.clear();
      description.clear();
      loading = false;
      handleSetState();
      utils.getSnackbar(widget.scaffoldkey, 'Item Added Sucessfully');
    } else {
      utils.getSnackbar(widget.scaffoldkey, 'Invalid Selections');
    }
  }

  handleSetState() {
    if (mounted) {
      setState(() {});
    }
  }
}
