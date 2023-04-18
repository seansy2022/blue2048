import 'package:bluesun/help_style.dart';
import 'package:bluesun/model/blue_state.dart';
import 'package:flutter/material.dart';

class ScanItem extends StatelessWidget {
  final BlueConnectState state;
  final String name;
  final String blueId;
  final VoidCallback ontap;
  final bool disable;
  final Widget? subChild;

  const ScanItem(
      {Key? key,
      required this.state,
      required this.ontap,
      required this.name,
      required this.blueId,
      this.disable = false,
      this.subChild})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return disable
        ? ColorFiltered(
            colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.color),
            child: child())
        : child();
  }

  Widget child() {
    bool isConnect = state == BlueConnectState.connected;
    return GestureDetector(
      onTap: isConnect ? null : ontap,
      child: Container(
        margin: EdgeInsets.all(HelpStyle.cellMargin),
        padding: EdgeInsets.all(HelpStyle.cellMargin),
        decoration: HelpStyle.boxshadow,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: HelpStyle.titleStyle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    blueId,
                    style: HelpStyle.contextStyle,
                  ),
                ],
              ),
            ),
            if (subChild != null) const SizedBox(height: 4),
            if (subChild != null) subChild!,
          ],
        ),
      ),
    );
  }
}
