import 'package:flutter/services.dart';

enum TgRegex {
  reference(r'^[0-9,a-zA-Z _/-]{1,20}$'),
  shoppingCardPaymentMode(r'^[0-9,a-zA-Z _/-]{0,25}$'),
  phoneNumber(r'^[0][1-9](([-. ]*)?[0-9]{2}){4}$'),
  name(r'^(([àâäéèêëïîôöùûüÿÀÁÂÄÇÉÈÊËÍÌÎÏÑÓÒÔÖÚÙÛÜA-z]{1}[ àâäéèêëïîôöùûüÿA-z]'
      r'{2,25})|([àâäéèêëïîôöùûüÿÀÁÂÄÇÉÈÊËÍÌÎÏÑÓÒÔÖÚÙÛÜA-z]{1}'
      r'[ àâäéèêëïîôöùûüÿA-z]{2,25}-[àâäéèêëïîôöùûüÿÀÁÂÄÇÉÈÊËÍÌÎÏÑÓÒÔÖÚÙÛÜA-z]'
      r'{1}[ àâäéèêëïîôöùûüÿA-z]{2,25}))$'),
  email(r'^[^@]+@[^@]+\.[^@]+$'),
  url(r'https?://(www\.)?[-a-zA-Z0-9@:%._+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z'
      r'0-9@:%_\+.~#?&//=]*)'),
  customID(r'^[A-z0-9]{5,50}$'),
  password(
    r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[?~@#_^*%/.+:;=\$!&]).{8,}$',
  ),
  hasUppercase(r'[A-Z]'),
  hasLowercase('[a-z]'),
  hasDigits(r'[0-9]'),
  hasSpecialCharacters(r'(?=.*?[?~@#_^*%/.+:;=\$!&])'),
  siret(r'^(\d{3})(\d{3})(\d{3})(\d{5})$'),
  integerWhichNoBeginWithZero(r'^[1-9]\d*'),
  finishWithTrailingZero(r'([.]*0)(?!.*\d)'),
  hasDigitsWithTwoDecimals(r'^\d+([.,]?\d{0,2})?$'),
  hasDigitsWithThreeDecimals(r'^\d+([.,]?\d{0,3})?$|^$');

  final String value;

  const TgRegex(this.value);
}

class FieldValidator {
  static bool isCorrect(TgRegex regex, String? value) {
    if (value == null) {
      return false;
    }
    return RegExp(regex.value).hasMatch(value);
  }
}

class EditTextInputFormatter extends TextInputFormatter {
  const EditTextInputFormatter({
    required this.regExp,
  });

  final RegExp regExp;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (regExp.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}
