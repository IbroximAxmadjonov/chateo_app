// В этом проэкте, наверное, не нужно:
// OutlinedButton
// outlinedButtonTheme: OutlinedButtonThemeData(
//   style:
//   OutlinedButton.styleFrom(
//     foregroundColor: colorScheme.primary,
//     minimumSize: const Size(64, 36),
//     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(8),
//     ),
//     side: BorderSide(color: colorScheme.primary, width: 1),
//     textStyle: textTheme.headlineSmall?.copyWith(
//       fontWeight: FontWeight.w600,
//     ),
//   ).copyWith(
//     overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
//       if (states.contains(WidgetState.pressed)) {
//         return BrandColor.darkOnPressed.withValues(alpha: 0.12);
//       }
//       if (states.contains(WidgetState.hovered)) {
//         return BrandColor.darkOnPressed.withValues(alpha: 0.08);
//       }
//       return null;
//     }),
//   ),
// ),

// FloatingActionButton
// floatingActionButtonTheme: FloatingActionButtonThemeData(
//   backgroundColor: colorScheme.primary,
//   foregroundColor: colorScheme.onPrimary,
//   elevation: 4,
//   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// ),

// Card
// cardTheme: CardThemeData(
//   color: colorScheme.surface,
//   elevation: 2,
//   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//   clipBehavior: Clip.antiAlias,
// ),
// Checkbox
// checkboxTheme: CheckboxThemeData(
//   fillColor: WidgetStateProperty.resolveWith((states) {
//     if (states.contains(WidgetState.selected)) {
//       return primaryLight;
//     }
//     return null;
//   }),
//   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
// ),

// Radio
// radioTheme: RadioThemeData(
//   fillColor: WidgetStateProperty.resolveWith((states) {
//     if (states.contains(WidgetState.selected)) {
//       return primaryLight;
//     }
//     return null;
//   }),
// ),

// Switch
// switchTheme: SwitchThemeData(
//   thumbColor: WidgetStateProperty.resolveWith((states) {
//     if (states.contains(WidgetState.selected)) {
//       return primaryLight;
//     }
//     return null;
//   }),
//   trackColor: WidgetStateProperty.resolveWith((states) {
//     if (states.contains(WidgetState.selected)) {
//       return primaryLight.withValues(alpha: 0.5);
//     }
//     return divider.withValues(alpha: 0.5);
//   }),
// ),