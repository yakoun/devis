import 'package:flutter/material.dart';

extension AccessibilityLabel on Widget {
  Widget withLabel(String label, {String? hint}) {
    return Semantics(
      label: label,
      hint: hint,
      child: this,
    );
  }

  Widget withButtonRole({required String label}) {
    return Semantics(
      label: label,
      button: true,
      child: this,
    );
  }

  Widget withHeaderRole({required String label}) {
    return Semantics(
      label: label,
      header: true,
      child: this,
    );
  }
}

class AccessibleIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;

  const AccessibleIconButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: IconButton(
        icon: Icon(icon, size: size, color: color),
        onPressed: onPressed,
        tooltip: label,
      ),
    );
  }
}
