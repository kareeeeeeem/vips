import 'package:flutter/material.dart';

import '../../util/dimensions.dart';
import '../../util/styles.dart';

class ConfirmationDialogWidget extends StatelessWidget {
  final String icon;
  final String? title;
  final String description;
  final String? adminText;
  final Function onYesPressed;
  final Function? onNoPressed;
  final bool isLogOut;
  final bool isOnNoPressedShow;
  final String? onYesButtonText;
  final String? onNoButtonText;
  const ConfirmationDialogWidget({
    super.key,
    required this.icon,
    this.title,
    required this.description,
    this.adminText,
    required this.onYesPressed,
    this.onNoPressed,
    this.isLogOut = false,
    this.isOnNoPressedShow = true,
    this.onYesButtonText,
    this.onNoButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: SizedBox(
        width: 500,
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: Image.asset(icon, width: 50, height: 50),
              ),

              title != null
                  ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeLarge,
                    ),
                    child: Text(
                      title!,
                      textAlign: TextAlign.center,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeExtraLarge,
                        color: Colors.red,
                      ),
                    ),
                  )
                  : const SizedBox(),

              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: Text(
                  description,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              adminText != null && adminText!.isNotEmpty
                  ? Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    child: Text(
                      '[$adminText]',
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                  : const SizedBox(),
              const SizedBox(height: Dimensions.paddingSizeLarge),
            ],
          ),
        ),
      ),
    );
  }
}
