import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBar appBar;
  final void Function() onTap;

  const CustomAppBar({Key key, this.appBar, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: appBar,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
