import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:superuser/get/controllers.dart';
import 'package:superuser/services/change_password.dart';
import 'package:superuser/utils.dart';
import 'package:superuser/widgets/image_view.dart';

class Profile extends StatelessWidget {
  final controllers = Controllers.to;
  final utils = Utils();
  final _storage = FirebaseStorage.instance.ref().child('profile_pictures');

  @override
  Widget build(BuildContext context) {
    String text = '';

    void changeName() {
      Get.back();
      if (utils.validateInputText(text)) {
        controllers.userData.value.reference
            .updateData({'name': text.toLowerCase()});
        utils.showSnackbar('Changes updated');
        text = '';
      } else {
        utils.showSnackbar('Given name is not valid');
      }
    }

    uploadImage(final PickedFile asset) async {
      try {
        _storage
            .child(controllers.userData.value.documentID)
            .putData(await asset
                .readAsBytes()
                .then((value) => value.buffer.asUint8List()))
            .onComplete
            .then((value) {
          value.ref.getDownloadURL().then((value) async {
            await controllers.userData.value.reference
                .updateData({'imageUrl': value});
          });
        });
      } catch (e) {
        utils.showSnackbar('Something went wrong');
      }
    }

    return Scaffold(
      appBar: utils.appbar('Profile'),
      body: utils.container(
        child: ListView(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Get.to(HariyalImageView(
                    imageUrls: [controllers.userData.value['imageUrl']]));
              },
              child: Container(
                padding: EdgeInsets.all(18),
                margin: EdgeInsets.all(18),
                child: Center(
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    maxRadius: 90,
                    minRadius: 90,
                    backgroundImage:
                        controllers.userData.value['imageUrl'] == null
                            ? AssetImage('assets/avatar-default-circle.png')
                            : CachedNetworkImageProvider(
                                controllers.userData.value['imageUrl'],
                              ),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(9),
              ),
              child: ListTile(
                leading: Icon(
                  MdiIcons.accountOutline,
                  color: Colors.red,
                ),
                title: Text(
                  GetUtils.capitalize(controllers.userData.value['name']),
                  style: TextStyle(
                    color: Colors.red,
                    letterSpacing: 1,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.edit, color: Colors.red),
                  onPressed: () => utils.getSimpleDialouge(
                    title: 'Change name',
                    content: utils.dialogInput(
                      initialValue: controllers.userData.value.data['name'],
                      onChnaged: (value) {
                        text = value;
                      },
                      hintText: 'Type here',
                    ),
                    noPressed: () => Get.back(),
                    yesPressed: () => changeName(),
                  ),
                ),
              ),
            ),
            utils.listTile(
              title: 'Change Profile Picture',
              onTap: () => Get.bottomSheet(
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(9),
                      child: Column(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              MdiIcons.cameraOutline,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              final asset = await ImagePicker().getImage(
                                source: ImageSource.camera,
                                imageQuality: 75,
                              );
                              Get.back();
                              if (asset != null) {
                                utils.showSnackbar(
                                  'Changes will be displayed in a while',
                                );
                                uploadImage(asset);
                              }
                            },
                          ),
                          Text(
                            'Camera',
                            style: TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(9),
                      child: Column(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              MdiIcons.imageOutline,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              final asset = await ImagePicker().getImage(
                                source: ImageSource.gallery,
                                imageQuality: 75,
                              );
                              Get.back();
                              if (asset != null) {
                                utils.showSnackbar(
                                  'Changes will be displayed in a while',
                                );
                                uploadImage(asset);
                              }
                            },
                          ),
                          Text(
                            'Gallery',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(9),
                    topRight: Radius.circular(9),
                  ),
                ),
                enableDrag: true,
                backgroundColor: Colors.white,
                isScrollControlled: true,
              ),
            ),
            utils.listTile(
              title: 'Change Password',
              onTap: () => Get.to(ChangePassword()),
            ),
          ],
        ),
      ),
    );
  }
}
