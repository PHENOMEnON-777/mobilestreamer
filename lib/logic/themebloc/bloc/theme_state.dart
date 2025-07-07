part of 'theme_bloc.dart';

sealed class ThemeState extends Equatable {
  const ThemeState();
  
  @override
  List<Object> get props => [];
}

final class ThemeInitial extends ThemeState {
  final ThemeData themeData;

 const ThemeInitial({required this.themeData});
}

final class ThemedataLoading extends ThemeState {}

final class ThemedataSuccessfully extends ThemeState {
  final ThemeData themeData;
  const ThemedataSuccessfully({required this.themeData});
  
  @override
  List<Object> get props => [themeData];
}


