import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_data_stream_builder/flutter_data_stream_builder.dart';
import 'package:get/get.dart';
import 'package:superuser/admin_extras/customer_details.dart';
import 'package:superuser/superuser/product_details.dart';
import 'package:superuser/utils.dart';

class Interests extends StatelessWidget {
  final firestore = Firestore.instance;
  final Utils utils = Utils();

  @override
  Widget build(BuildContext context) {
    final products = firestore.collection('products');
    final interests = firestore.collection('interests');
    final customers = firestore.collection('customers');

    return Scaffold(
      appBar: utils.appbar('Interests'),
      body: utils.container(
        child: DataStreamBuilder<QuerySnapshot>(
          errorBuilder: (context, error) => utils.nullWidget(error),
          loadingBuilder: (context) => utils.progressIndicator(),
          stream: interests.orderBy('timestamp', descending: true).snapshots(),
          builder: (context, interest) {
            if (interest.documents.length == 0) {
              return utils.nullWidget('No Interests found !');
            }
            return ListView.builder(
              itemCount: interest.documents.length,
              itemBuilder: (context, index) {
                return DataStreamBuilder<DocumentSnapshot>(
                  stream: customers
                      .document(interest.documents[index]['author'])
                      .snapshots(),
                  builder: (context, author) {
                    return DataStreamBuilder<DocumentSnapshot>(
                      stream: products
                          .document(interest.documents[index]['productId'])
                          .snapshots(),
                      builder: (context, product) {
                        return utils.listTile(
                            textscalefactor: 1,
                            leading: GestureDetector(
                              onTap: () =>
                                  Get.to(Customerdetails(docsnap: author)),
                              child: CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider(
                                  author.data['image'],
                                ),
                                backgroundColor: Colors.white,
                              ),
                            ),
                            onTap: () => Get.to(
                                  ProductDetails(),
                                  arguments: product.documentID,
                                ),
                            title:
                                '${author.data['name']} is interested in ${product['title']}');
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
