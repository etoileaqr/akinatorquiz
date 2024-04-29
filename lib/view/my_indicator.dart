// ignore_for_file: no_leading_underscores_for_local_identifiers, non_constant_identifier_names

import 'package:flutter/cupertino.dart';

mixin MyIndicator {
  void showIndicator(BuildContext ctxt) {
    showCupertinoDialog(
      context: ctxt,
      builder: (_) => const Center(
        child: CupertinoActivityIndicator(
          color: CupertinoColors.activeBlue,
        ),
      ),
    );
  }
}
