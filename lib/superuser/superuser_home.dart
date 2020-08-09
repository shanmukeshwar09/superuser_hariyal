import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:superuser/get/controllers.dart';
import 'package:superuser/superuser/superuser_screens/more.dart';
import '../services/orders.dart';
import '../services/sold_items.dart';
import 'superuser_screens/reports.dart';
import 'superuser_screens/requests.dart';

class SuperuserHome extends StatelessWidget {
  final controllers = Controllers.to;

  @override
  Widget build(BuildContext context) {
    final items = [
      bottomNavigationBar('Orders', OMIcons.addShoppingCart),
      bottomNavigationBar('Requests', OMIcons.moneyOff),
      bottomNavigationBar('Sold Items', OMIcons.attachMoney),
      bottomNavigationBar('Reports', OMIcons.receipt),
      bottomNavigationBar('More', OMIcons.moreHoriz),
    ];
    final screenList = [
      Orders(),
      Requests(),
      SoldItems(
        query: controllers.products
            .orderBy('sold_timestamp', descending: true)
            .where('isSold', isEqualTo: true),
      ),
      Reports(),
      Settings(),
    ];
    return Obx(() {
      return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          onTap: (index) => controllers.changeScreen(index),
          currentIndex: controllers.currentScreen.value,
          elevation: 9,
          type: BottomNavigationBarType.fixed,
          items: items,
        ),
        body: WillPopScope(
          child: screenList[controllers.currentScreen.value],
          onWillPop: () async {
            if (controllers.currentScreen.value == 0) {
              return true;
            } else {
              controllers.changeScreen(0);
              return false;
            }
          },
        ),
      );
    });
  }

  BottomNavigationBarItem bottomNavigationBar(String title, IconData icon) =>
      BottomNavigationBarItem(
        icon: Icon(icon),
        title: Text(title),
      );
}
