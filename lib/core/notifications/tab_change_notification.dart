import 'package:flutter/material.dart';

class TabChangeNotification extends Notification {
  final int tabIndex;
  TabChangeNotification(this.tabIndex);
}
