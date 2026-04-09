import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Helpers {
  static Timer? _searchOnStoppedTyping;

  static double getResponsiveWidth(BuildContext context) => MediaQuery.of(context).size.width;

  static double getResponsiveHeight(BuildContext context) => MediaQuery.of(context).size.height;

  static double getDevicePixelRatio(BuildContext context) => MediaQuery.of(context).devicePixelRatio;

  static bool isNullEmptyOrFalse(dynamic o) {
    if (o is Map<String, dynamic> || o is List<dynamic>) {
      return o == null || o.length == 0;
    }
    return o == null || false == o || '' == o;
  }

  static bool isNotNullAndEmpty(String? value) => value != null && value.isNotEmpty;

  static void onSearchHandler(void Function() callback) {
    if (_searchOnStoppedTyping != null) _searchOnStoppedTyping!.cancel();
    _searchOnStoppedTyping = Timer(const Duration(milliseconds: 800), callback);
  }

  static String getEnumValue(e) => e.toString().split('.').last;

  static String formatDouble(number) {
    final formatter = NumberFormat.currency(customPattern: '###,###,###,###.###', symbol: '', decimalDigits: 2);
    return formatter.format(number).replaceAll(',', ' ');
  }

  static String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}

OutlineInputBorder myInputBorder = OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: BorderSide.none);