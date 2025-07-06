import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fingerprint/data/store/themedatastore.dart';
import 'package:fingerprint/presentation/theme/themedata.dart';
import 'package:flutter/material.dart';


part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
   bool _isLightMode;

  ThemeBloc({required bool isLightMode})
      : _isLightMode = isLightMode,
        super(ThemeInitial(themeData: isLightMode ? lightmode : darkmode)) {
    on<ChangeAppMode>((event, emit) async {
      emit(ThemedataLoading());
      try {
        _isLightMode = !_isLightMode; 
        await Storethemedata().setbool('islightmode', _isLightMode);
        emit(ThemedataSuccessfully(
            themeData: _isLightMode ? lightmode : darkmode));
      } catch (e) {
        emit(ThemeInitial(
            themeData: _isLightMode ? lightmode : darkmode)); 
      }
    });
  }

  bool get isLightMode => _isLightMode;
}
