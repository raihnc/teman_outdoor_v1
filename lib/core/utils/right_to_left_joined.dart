import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RightToLeftJoinedTransition extends CustomTransition {
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final enterTween = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).chain(CurveTween(curve: curve ?? Curves.easeInOut));
    final exitTween = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.0, 0.0),
    ).chain(CurveTween(curve: curve ?? Curves.easeInOut));

    return SlideTransition(
      position: animation.drive(enterTween),
      child: SlideTransition(
        position: secondaryAnimation.drive(exitTween),
        child: child,
      ),
    );
  }
}
