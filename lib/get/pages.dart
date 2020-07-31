import 'package:get/get.dart';
import 'package:superuser/admin/admin_home.dart';
import 'package:superuser/admin_extras/customer_details.dart';
import 'package:superuser/authenticate.dart';
import 'package:superuser/initial_page.dart';
import 'package:superuser/services/add_admin.dart';
import 'package:superuser/services/all_products.dart';
import 'package:superuser/services/product_details.dart';
import 'package:superuser/services/profile.dart';
import 'package:superuser/superuser/interests.dart';
import 'package:superuser/superuser/superuser_home.dart';
import 'package:superuser/superuser/superuser_screens/admins.dart';
import 'package:superuser/superuser/superuser_screens/customers.dart';
import 'package:superuser/superuser/superuser_screens/more.dart';
import 'package:superuser/superuser/utilities/add_showroom.dart';
import 'package:superuser/superuser/utilities/areas.dart';
import 'package:superuser/superuser/utilities/categories.dart';
import 'package:superuser/superuser/utilities/shorooms.dart';
import 'package:superuser/superuser/utilities/specifications.dart';
import 'package:superuser/superuser/utilities/states.dart';
import 'package:superuser/superuser/utilities/sub_categories.dart';

class Pages {
  static final routes = [
    GetPage(
      name: '/initialPage',
      page: () => InitialRoute(),
    ),
    GetPage(
      name: '/authenticate',
      page: () => Authenticate(),
    ),
    GetPage(
      name: '/superuser_home',
      page: () => SuperuserHome(),
    ),
    GetPage(
      name: '/admin_home',
      page: () => AdminHome(),
    ),
    GetPage(
      name: '/settings',
      page: () => Settings(),
    ),
    GetPage(
      name: '/profile',
      page: () => Profile(),
    ),
    GetPage(
      name: '/add_admin',
      page: () => AddAdmin(),
    ),
    GetPage(
      name: '/interests',
      page: () => Interests(),
    ),
    GetPage(
      name: '/customer_deatils',
      page: () => Customerdetails(),
    ),
    GetPage(
      name: '/categories',
      page: () => CategoriesScreen(),
    ),
    GetPage(
      name: '/specifications',
      page: () => Specifications(),
    ),
    GetPage(
      name: '/states',
      page: () => States(),
    ),
    GetPage(
      name: '/showrooms',
      page: () => Showrooms(),
    ),
    GetPage(
      name: '/all_products',
      page: () => AllProducts(),
    ),
    GetPage(
      name: '/all_customers',
      page: () => AllCustomers(),
    ),
    GetPage(
      name: '/admins',
      page: () => Admins(),
    ),
    GetPage(
      name: '/sub_categories',
      page: () => SubCategories(),
    ),
    GetPage(
      name: '/areas',
      page: () => Areas(),
    ),
    GetPage(
      name: '/add_showroom',
      page: () => AddShowroom(),
    ),
    GetPage(
      name: '/product_details',
      page: () => ProductDetails(),
    ),
  ];
}