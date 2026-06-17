import 'package:get/get.dart';

import '../views/widgets/electric_bill.dart';

class PayBillsController extends GetxController {
  final List<Map<String, dynamic>> billCategories = [
    {
      'id': 'electric',
      'title': 'Electric',
      'image':
          'https://nabeul.info/wp-content/uploads/2019/09/nabeul-info-steg.jpg',
      'route': 'electric-bill',
    },
    {
      'id': 'internet',
      'title': 'Internet',
      'image':
          'https://www.jawharafm.net/fr/imageResize/resize/francais_image2_35665_1458124719.png',
      'route': '/internet-bill',
    },
    {
      'id': 'water',
      'title': 'Water',
      'image':
          'https://www.sonede.com.tn/wp-content/uploads/2024/03/cropped-logo-sonede-2_Plan-de-travail-1.png',
      'route': '/water-bill',
    },
    {
      'id': 'phone',
      'title': 'Phone',
      'image':
          'https://play-lh.googleusercontent.com/1jOeJtlv6NtcrfhAj06GrhhbBnn9uo951q41eoJf8dpfPutOls3fjKUzWID7CHsWmkZZ=w526-h296-rw',
      'route': '/phone-bill',
    },

    {
      'id': 'education',
      'title': 'Education',
      'image':
          'https://lechotunisien.com/wp-content/uploads/2022/09/ministere-de-leducation.png',
      'route': '/education-bill',
    },
    {
      'id': 'donation',
      'title': 'Donation',
      'image': 'https://cdn-icons-png.flaticon.com/512/2917/2917242.png',
      'route': '/donation',
    },
  ];

  void navigateToCategory(String route) {
    if (route == 'electric-bill') {
      Get.to(() => ElectricBillView());
    } else {}
  }
}
