part of 'theme_bloc.dart';

class ThemeState extends Equatable {
  final ThemeMode themeMode;
  final bool isExplicit;

  const ThemeState({this.themeMode = ThemeMode.light, this.isExplicit = false});

  ThemeState copyWith({
    ThemeMode? themeMode,
    bool? isExplicit,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isExplicit: isExplicit ?? this.isExplicit,
    );
  }

  @override
  List<Object> get props => [themeMode, isExplicit];

  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.index,
      'isExplicit': isExplicit,
    };
  }

  factory ThemeState.fromMap(Map<String, dynamic> map) {
    final isExplicit = map['isExplicit'] as bool? ?? false;
    return ThemeState(
      themeMode: isExplicit
          ? ThemeMode.values[map['themeMode'] ?? ThemeMode.light.index]
          : ThemeMode.light,
      isExplicit: isExplicit,
    );
  }
}
