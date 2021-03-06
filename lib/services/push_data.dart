import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/route_manager.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:pattern_formatter/numeric_formatter.dart';
import 'package:superuser/full_screen.dart';
import 'package:superuser/get/controllers.dart';
import 'package:superuser/services/upload_product.dart';

class PushData extends StatefulWidget {
  @override
  _PushDataState createState() => _PushDataState();
}

class _PushDataState extends State<PushData> {
  final controllers = Controllers.to;
  List<File> images = [];
  String selectedCategory;
  String selectedSubCategory;
  String selectedState;
  String selectedArea;
  String selectedShowroom;
  List subCategory = [];
  List areasList = [];
  List showroomList = [];
  List specificationsList = [];
  String addressID;
  bool loading = false;

  Map inputSpecifications = {};

  GlobalKey<FormState> globalKey = GlobalKey<FormState>();

  final price = TextEditingController();
  final title = TextEditingController();
  final description = TextEditingController();
  final showroomAddressController = TextEditingController();

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
    return controllers.utils.root(
      label: 'Add Product',
      child: loading
          ? controllers.utils.loading()
          : ListView(
              padding: EdgeInsets.symmetric(vertical: 9, horizontal: 18),
              children: <Widget>[
                GridView.count(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  children: List.generate(images.length + 1, (index) {
                    if (index == images.length) {
                      return images.length >= 5
                          ? Container()
                          : IconButton(
                              onPressed: () async {
                                dynamic source;

                                await Get.bottomSheet(
                                  Container(
                                      height: 90,
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          IconButton(
                                              icon: Icon(
                                                OMIcons.camera,
                                                size: 36,
                                                color: Colors.redAccent,
                                              ),
                                              onPressed: () {
                                                Get.back();
                                                return source =
                                                    ImageSource.camera;
                                              }),
                                          IconButton(
                                            icon: Icon(
                                              OMIcons.image,
                                              size: 36,
                                              color: Colors.redAccent,
                                            ),
                                            onPressed: () {
                                              Get.back();
                                              return source =
                                                  ImageSource.gallery;
                                            },
                                          )
                                        ],
                                      )),
                                  backgroundColor: Colors.white,
                                );

                                try {
                                  final pickedFile = await ImagePicker()
                                      .getImage(
                                          source: source, imageQuality: 75);
                                  if (pickedFile != null) {
                                    File croppedFile =
                                        await ImageCropper.cropImage(
                                      sourcePath: pickedFile.path,
                                      aspectRatioPresets: [
                                        CropAspectRatioPreset.square,
                                        CropAspectRatioPreset.ratio3x2,
                                        CropAspectRatioPreset.original,
                                        CropAspectRatioPreset.ratio4x3,
                                        CropAspectRatioPreset.ratio16x9
                                      ],
                                      androidUiSettings: AndroidUiSettings(
                                        toolbarTitle: 'Crop Image',
                                        toolbarColor:
                                            Theme.of(context).accentColor,
                                        toolbarWidgetColor: Colors.white,
                                        initAspectRatio:
                                            CropAspectRatioPreset.original,
                                        lockAspectRatio: false,
                                      ),
                                    );
                                    if (croppedFile == null) {
                                      return;
                                    }

                                    images.add(croppedFile);
                                  }
                                } catch (e) {
                                  print(e.toString());
                                }

                                handleSetState();
                              },
                              icon: Icon(
                                OMIcons.plusOne,
                                color: Colors.red.shade300,
                              ),
                            );
                    }
                    return Padding(
                      padding: EdgeInsets.all(9),
                      child: GestureDetector(
                        onTap: () async {
                          Map<String, dynamic> map = await Navigator.of(context)
                              .push(PageRouteBuilder(
                                  opaque: false,
                                  pageBuilder: (BuildContext context, _, __) =>
                                      FullScreen(
                                        index: index,
                                        image: images[index],
                                        imageLink: null,
                                      )));
                          if (map == null) return;
                          if (map['isDeleted'] == null ||
                              map['index'] == null ||
                              map['image'] == null) return;

                          if (map['isDeleted']) {
                            images.remove(map['image']);
                          } else {
                            images[map['index']] = map['image'];
                          }
                          handleSetState();
                        },
                        child: Hero(
                          tag: images[index].path.toString(),
                          child: Image.file(
                            images[index],
                            width: 270,
                            height: 270,
                            errorBuilder: (context, url, error) =>
                                Icon(Icons.error_outline),
                            filterQuality: FilterQuality.medium,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                Form(
                  key: globalKey,
                  child: Wrap(
                    spacing: 18,
                    runSpacing: 18,
                    children: <Widget>[
                      controllers.utils.streamBuilder<DocumentSnapshot>(
                          stream: controllers.categoryStream,
                          builder: (context, snapshot) {
                            return controllers.utils.productInputDropDown(
                                label: 'Category',
                                value: selectedCategory,
                                items: snapshot?.data?.keys?.toList(),
                                onChanged: (value) {
                                  selectedCategory = value;
                                  selectedSubCategory = null;
                                  specificationsList.clear();
                                  subCategory = snapshot.data[selectedCategory];

                                  handleSetState();
                                });
                          }),
                      controllers.utils.productInputDropDown(
                          label: 'Sub-Category',
                          value: selectedSubCategory,
                          items: subCategory,
                          onChanged: (value) {
                            selectedSubCategory = value;
                            handleSetState();
                          },
                          onTap: () {
                            if (selectedCategory == null) {
                              controllers.utils
                                  .snackbar('Please select category first');
                            } else if (subCategory.length == 0) {
                              controllers.utils.snackbar(
                                  'No subcategories in $selectedCategory');
                            }
                          }),
                      controllers.utils.streamBuilder<DocumentSnapshot>(
                        stream: controllers.locationsStream,
                        builder: (context, snapshot) =>
                            controllers.utils.productInputDropDown(
                                label: 'State',
                                value: selectedState,
                                items: snapshot?.data?.keys?.toList(),
                                onChanged: (value) {
                                  selectedState = value;
                                  selectedArea = null;
                                  selectedShowroom = null;
                                  areasList = snapshot.data[selectedState];
                                  showroomAddressController.clear();
                                  showroomList.clear();
                                  handleSetState();
                                }),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (selectedState == null) {
                            controllers.utils
                                .snackbar('Please select state first');
                          } else if (subCategory.length == 0) {
                            controllers.utils
                                .snackbar('No areas in $selectedState');
                          }
                        },
                        child: controllers.utils.productInputDropDown(
                            label: 'Area',
                            value: selectedArea,
                            items: areasList,
                            onChanged: (newValue) async {
                              selectedArea = newValue;
                              selectedShowroom = null;
                              showroomAddressController.clear();
                              showroomList.clear();
                              controllers.utils.snackbar(
                                  'Loading showrooms in $selectedArea...');

                              await controllers.showrooms
                                  .where('active', isEqualTo: true)
                                  .where('area', isEqualTo: newValue)
                                  .getDocuments()
                                  .then((value) {
                                showroomList.addAll(value.documents);
                                handleSetState();
                              });
                            }),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (selectedArea == null) {
                            controllers.utils
                                .snackbar('Please select area first');
                          } else if (showroomList.length == 0) {
                            controllers.utils
                                .snackbar('No showrooms in $selectedArea');
                          }
                        },
                        child: controllers.utils.productInputDropDown(
                            label: 'Showroom',
                            items: showroomList,
                            value: selectedShowroom,
                            isShowroom: true,
                            onChanged: (newValue) {
                              selectedShowroom = newValue;
                              showroomList.forEach((element) {
                                if (element['name'] == newValue) {
                                  showroomAddressController.text =
                                      element['address'];
                                  addressID = element.documentID;
                                  return false;
                                } else {
                                  return true;
                                }
                              });
                              handleSetState();
                            }),
                      ),
                      controllers.utils.inputTextField(
                        label: 'Showroom Address',
                        controller: showroomAddressController,
                        readOnly: true,
                      ),
                      controllers.utils.inputTextField(
                        label: 'Price',
                        controller: price,
                        inputFormatters: <TextInputFormatter>[
                          WhitelistingTextInputFormatter.digitsOnly,
                          ThousandsFormatter(),
                        ],
                        textInputType: TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                      ),
                      controllers.utils.inputTextField(
                        label: 'Title',
                        controller: title,
                      ),
                      controllers.utils.inputTextField(
                        label: 'Description',
                        controller: description,
                      ),
                      controllers.utils.streamBuilder<DocumentSnapshot>(
                        stream: controllers.specificationsStream,
                        builder: (context, snapsot) {
                          if (snapsot.data[selectedCategory] != null) {
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Add Specifications',
                                      style: Get.textTheme.headline4),
                                ),
                                ListView.separated(
                                  separatorBuilder: (context, index) =>
                                      SizedBox(height: 12),
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount:
                                      snapsot.data[selectedCategory].length,
                                  itemBuilder: (context, index) {
                                    return controllers.utils.inputTextField(
                                      label: snapsot.data[selectedCategory]
                                          [index],
                                      onChanged: (value) => inputSpecifications[
                                          snapsot.data[selectedCategory]
                                              [index]] = value,
                                    );
                                  },
                                ),
                              ],
                            );
                          }
                          return Container();
                        },
                      ),
                      controllers.utils.raisedButton('Add Product', onPressed),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  onPressed() async {
    FocusScope.of(context).unfocus();
    if (globalKey.currentState.validate() && images.length > 0) {
      loading = true;
      handleSetState();
      await PushProduct().uploadProduct(
          images: images,
          category: selectedCategory,
          subCategory: selectedSubCategory,
          state: selectedState,
          area: selectedArea,
          adressID: addressID,
          price:
              double.parse(price.text.trim().toLowerCase().replaceAll(',', '')),
          title: title.text.trim().toLowerCase(),
          description: description.text.trim().toLowerCase(),
          specifications: inputSpecifications,
          authored: controllers.isSuperuser.value,
          uid: controllers.firebaseUser.value.uid,
          searchList: controllers.utils
              .getProductSearchList(title.text.trim().toLowerCase()));
      clearAllData();
      loading = false;
      handleSetState();
      controllers.utils.snackbar('Item Added Sucessfully');
    } else {
      if (images.length == 0) {
        controllers.utils.snackbar('Please select atleast 1 image');
      }
    }
  }

  clearAllData() {
    selectedCategory = null;
    selectedSubCategory = null;
    selectedState = null;
    selectedArea = null;
    selectedShowroom = null;
    showroomAddressController.clear();
    images.clear();
    price.clear();
    title.clear();
    description.clear();
    specificationsList.clear();
    inputSpecifications.clear();
  }

  handleSetState() => (mounted) ? setState(() => null) : null;
}
