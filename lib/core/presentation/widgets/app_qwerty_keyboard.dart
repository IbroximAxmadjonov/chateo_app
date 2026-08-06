import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


/// Кастомная QWERTY-клавиатура (плоский стиль iOS, как на скриншоте).
///
/// Три цвета для кастомизации:
///   [keyboardBg]  — общий фон клавиатуры          (default: #D1D5DB light / #1C1C1E dark)
///   [spaceBg]     — фон клавиши Space              (default: белый/тёмный-card)
///   [keyIconColor]— цвет текста и иконок клавиш    (default: #1C1C1E light / белый dark)
///
/// [onKeyTap]    — нажатие буквенной/символьной клавиши.
/// [onBackspace] — нажатие ⌫.
/// [onSpace]     — нажатие пробела (опционально).
/// [onReturn]    — нажатие return (опционально).
///
/// Иконки shift и backspace подключаются через [shiftIcon] и [backspaceIcon].
/// Если не переданы — отображаются дефолтные Material-иконки.
class AppQwertyKeyboard extends StatefulWidget {
  const AppQwertyKeyboard({
    super.key,
    required this.onKeyTap,
    required this.onBackspace,
    this.onSpace,
    this.onReturn,
    // ── Цвета (оставь null для автоматического выбора по теме) ──────────────
    this.keyboardBg,
    this.spaceBg,
    this.keyIconColor,
    // ── Иконки (добавь сам) ─────────────────────────────────────────────────
    this.shiftIcon,
    this.backspaceIcon,
  });

  final void Function(String value) onKeyTap;
  final VoidCallback onBackspace;
  final VoidCallback? onSpace;
  final VoidCallback? onReturn;

  /// Фон всей клавиатуры. Оставь null — подберётся по теме.
  final Color? keyboardBg;

  /// Фон клавиши Space. Оставь null — подберётся по теме.
  final Color? spaceBg;

  /// Цвет букв и иконок. Оставь null — подберётся по теме.
  final Color? keyIconColor;

  /// Иконка Shift (подключи сам).
  /// Если null — используется дефолтная стрелка вверх.
  final Widget? shiftIcon;

  /// Иконка Backspace (подключи сам).
  /// Если null — используется дефолтная иконка ⌫.
  final Widget? backspaceIcon;

  @override
  State<AppQwertyKeyboard> createState() => _AppQwertyKeyboardState();
}

class _AppQwertyKeyboardState extends State<AppQwertyKeyboard> {
  bool _isCaps = false;

  static const List<String> _row1 = ['Q','W','E','R','T','Y','U','I','O','P'];
  static const List<String> _row2 = ['A','S','D','F','G','H','J','K','L'];
  static const List<String> _row3 = ['Z','X','C','V','B','N','M'];

  String _label(String letter) => _isCaps ? letter : letter.toLowerCase();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── Три цвета клавиатуры ─────────────────────────────────────────────────
    final Color bg = widget.keyboardBg ??
        (isDark ? const Color(0xFF1C1C1E) : const Color(0xFFD1D5DB));

    final Color spaceBg = widget.spaceBg ??
        (isDark ? const Color(0xFF3A3A3C) : const Color(0xFFFFFFFF));

    final Color iconColor = widget.keyIconColor ??
        (isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1E));
    // ─────────────────────────────────────────────────────────────────────────

    return Container(
      height: 320.h,
      width: double.infinity,
      color: bg,
      padding: EdgeInsets.only(
        top: 12.h,
        bottom: 4.h,
        left: 4.w,
        right: 4.w,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Row 1: Q W E R T Y U I O P ─────────────────────────────────
            _buildLetterRow(_row1, iconColor),
            SizedBox(height: 10.h),

            // ── Row 2: A S D F G H J K L ─────────────────────────────────
            _buildLetterRow(_row2, iconColor),
            SizedBox(height: 10.h),

            // ── Row 3: ⇧  Z X C V B N M  ⌫ ──────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Shift — место для иконки (добавь сам через shiftIcon)
                _buildActionKey(
                  width: 44.w,
                  onTap: () => setState(() => _isCaps = !_isCaps),
                  child: widget.shiftIcon ??
                      Icon(
                        Icons.arrow_upward_rounded,
                        size: 20.sp,
                        color: iconColor,
                      ),
                ),
                SizedBox(width: 6.w),

                // Буквы Z–M
                ..._row3.map((l) => Padding(
                  padding: EdgeInsets.only(right: 6.w),
                  child: _buildLetterKey(_label(l), iconColor),
                )),

                // Backspace — место для иконки (добавь сам через backspaceIcon)
                _buildActionKey(
                  width: 44.w,
                  onTap: widget.onBackspace,
                  child: widget.backspaceIcon ??
                      Icon(
                        Icons.backspace_outlined,
                        size: 20.sp,
                        color: iconColor,
                      ),
                ),
              ],
            ),
            SizedBox(height: 10.h),

            // ── Bottom row: 123 | space | return ─────────────────────────
            Row(
              children: [
                // 123
                _buildActionKey(
                  width: 48.w,
                  onTap: null, // числовой режим — подключи сам
                  child: Text(
                    '123',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: iconColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                SizedBox(width: 6.w),

                // Space — только эта клавиша имеет фоновый цвет (spaceBg)
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      widget.onKeyTap(' ');
                      widget.onSpace?.call();
                    },
                    child: Container(
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: spaceBg,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'space',
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: iconColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 6.w),

                // Return
                _buildActionKey(
                  width: 64.w,
                  onTap: widget.onReturn,
                  child: Text(
                    'return',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: iconColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 88.h),
          ],
        ),
      ),
    );
  }

  // ── Builders ─────────────────────────────────────────────────────────────────

  /// Ряд букв — без фона (прозрачные, как на скриншоте).
  Widget _buildLetterRow(List<String> letters, Color iconColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: letters.map((l) {
        final isLast = l == letters.last;
        return Padding(
          padding: EdgeInsets.only(right: isLast ? 0 : 2.w),
          child: _buildLetterKey(_label(l), iconColor),
        );
      }).toList(),
    );
  }

  /// Кнопка буквы — прозрачный фон, только текст/иконка.
  Widget _buildLetterKey(String letter, Color iconColor) {
    return GestureDetector(
      onTap: () => widget.onKeyTap(letter),
      child: SizedBox(
        width: 34.w,
        height: 44.h,
        child: Center(
          // TODO: замени Text на свою иконку буквы если нужно
          child: Text(
            letter,
            style: TextStyle(
              fontSize: 20.sp,
              color: iconColor,
              fontWeight: FontWeight.w400,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }

  /// Кнопка действия (shift, backspace, 123, return) — тоже прозрачный фон.
  Widget _buildActionKey({
    required Widget child,
    required VoidCallback? onTap,
    required double width,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: 44.h,
        child: Center(child: child),
      ),
    );
  }
}
