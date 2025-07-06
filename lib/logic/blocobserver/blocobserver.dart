import 'package:flutter_bloc/flutter_bloc.dart';

class MyBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('Bloc: ${bloc.runtimeType}, Change: ${change.currentState.runtimeType} -> ${change.nextState.runtimeType}');
    print('Details: $change');
  }
  
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    print('Bloc: ${bloc.runtimeType}, Error: $error');
  }
  
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print('Bloc: ${bloc.runtimeType}, Transition: ${transition.currentState.runtimeType} -> ${transition.nextState.runtimeType}');
  }
}
