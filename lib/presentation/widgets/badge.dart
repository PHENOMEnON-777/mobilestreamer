import 'package:flutter/material.dart';

class Badge extends StatelessWidget {
  final Widget child;
  final String value;
  final Color color;

  const Badge({
    required Key key,
    required this.child,
    required this.value,
    required this.color,
  }) : super(key: key);

  
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      
      children: [
        child,
        Positioned(
          right: 8.0,
          top: 8.0,
          bottom: 0.0,
          child: Container(
            padding: EdgeInsets.all(1.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1.0),
            ),
            constraints: BoxConstraints(
              minWidth: 16,
              minHeight: 16,
            ),
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
              ),
            ),
          ),
        )
      ],
    );
  }
}
