import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:superuser/get/controllers.dart';
import 'package:superuser/utils.dart';

class SpecificationData extends StatelessWidget {
  final String category;

  const SpecificationData({Key key, this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Utils utils = Utils();
    final Controllers controllers = Get.find();
    final Firestore firestore = Firestore.instance;

    List items = controllers.specifications.value.data[category];

    DocumentSnapshot snapshot;
    String text = '';

    addSpecification() {
      if (utils.validateInputText(text) &&
          !items.contains(text.toLowerCase())) {
        if (snapshot == null) {
          firestore.collection('extras').document('specifications').setData({
            category: FieldValue.arrayUnion([text.toLowerCase()])
          });
        } else {
          snapshot.reference.updateData({
            category: FieldValue.arrayUnion([text.toLowerCase()])
          });
        }

        Get.back();
        utils.showSnackbar('Specification Added');
      } else {
        Get.back();
        utils.showSnackbar('Invalid entries');
      }
      text = '';
    }

    return Scaffold(
      appBar: utils.appbar(category, actions: [
        IconButton(
            icon: Icon(MdiIcons.plusOutline),
            onPressed: () {
              utils.getSimpleDialouge(
                title: 'Add Specifications in $category',
                content: utils.dialogInput(
                    hintText: 'Type here',
                    onChnaged: (value) {
                      text = value;
                    }),
                noPressed: () => Get.back(),
                yesPressed: () => addSpecification(),
              );
            }),
      ]),
      body: utils.container(
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) => utils.dismissible(
            key: UniqueKey(),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                return await utils.getSimpleDialouge(
                  title: 'Confirm',
                  content: Text('Delete this Specification ?'),
                  yesPressed: () {
                    deleteSpecification(items[index]);

                    snapshot.reference.updateData({
                      category: FieldValue.arrayRemove([items[index]])
                    });
                    Get.back();
                  },
                  noPressed: () => Get.back(),
                );
              } else {
                return await utils.getSimpleDialouge(
                  title: 'Edit Specification',
                  content: utils.dialogInput(
                      hintText: 'Type here',
                      initialValue: items[index],
                      onChnaged: (value) {
                        text = value;
                      }),
                  noPressed: () => Get.back(),
                  yesPressed: () {
                    Get.back();
                    if (utils.validateInputText(text) &&
                        text != items[index] &&
                        !items.contains(text.toLowerCase())) {
                      editSpecification(items[index], text);
                      snapshot.reference.updateData({
                        category: FieldValue.arrayRemove([items[index]]),
                      });
                      snapshot.reference.updateData({
                        category: FieldValue.arrayUnion([text]),
                      });
                    } else {
                      utils.showSnackbar('Invalid entries');
                    }
                    text = '';
                  },
                );
              }
            },
            child: utils.listTile(
              title: items[index],
              isTrailingNull: true,
            ),
          ),
        ),
      ),
    );
  }

  deleteSpecification(String data) {
    /*  firestore
        .collection('products')
        .where('category.subCategory', isEqualTo: data)
        .getDocuments()
        .then((value) {
      value.documents.forEach((element) {
        element.reference.updateData({
          'category.subCategory': null,
          'isDeleted': true,
        });
      });
    }); */
  }

  editSpecification(String oldData, String newData) {
    /* firestore
        .collection('products')
        .where('category.subCategory', isEqualTo: oldData)
        .getDocuments()
        .then((value) {
      value.documents.forEach((element) {
        element.reference.updateData({'category.subCategory': newData});
      });
    }); */
  }
}
