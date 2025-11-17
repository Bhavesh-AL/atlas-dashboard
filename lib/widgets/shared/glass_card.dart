// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:atlas_dashboard/app_theme.dart';
//
// class GlassCard extends StatelessWidget {
//   final Widget child;
//   final EdgeInsets padding;
//   final Color borderColor;
//   final Color shadowColor;
//   final double blur;
//
//   const GlassCard({
//     super.key,
//     required this.child,
//     this.padding = const EdgeInsets.all(16.0),
//     this.borderColor = AppTheme.neonBlue,
//     this.shadowColor = AppTheme.neonBlue,
//     this.blur = 5.0,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(16),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
//         child: Container(
//           padding: padding,
//           decoration: BoxDecoration(
//             color: AppTheme.glassColor,
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(
//               color: borderColor.withOpacity(0.2),
//               width: 1.5,
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: shadowColor.withOpacity(0.05),
//                 blurRadius: 10,
//                 spreadRadius: 2,
//               ),
//             ],
//           ),
//           child: child,
//         ),
//       ),
//     );
//   }
// }

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../app_theme.dart'; // FIX: Made import relative

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets? margin; // FIX: Added margin parameter
  final Color borderColor;
  final Color shadowColor;
  final double blur;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin, // FIX: Added margin parameter
    this.borderColor = AppTheme.neonBlue,
    this.shadowColor = AppTheme.neonBlue,
    this.blur = 5.0,
  });

  @override
  Widget build(BuildContext context) {
    // FIX: Wrap the card in a Padding widget if margin is provided
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: AppTheme.glassColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: shadowColor.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}