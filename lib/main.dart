import 'package:fingerprint/data/provider/repository/userrepository.dart';
import 'package:fingerprint/data/provider/server/userservercervice.dart';
import 'package:fingerprint/data/store/themedatastore.dart';
import 'package:fingerprint/logic/blocobserver/blocobserver.dart';
import 'package:fingerprint/logic/themebloc/bloc/theme_bloc.dart';
import 'package:fingerprint/logic/userbloc/bloc/user_bloc.dart';
import 'package:fingerprint/presentation/theme/themedata.dart';
import 'package:fingerprint/router/routers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  Bloc.observer = MyBlocObserver();
  WidgetsFlutterBinding.ensureInitialized();

  // Fetch the stored theme mode
  final bool islightmode =
      await Storethemedata().getbool('islightmode') ?? true;
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((
    _,
  ) {
    runApp(MyApp(islightmode: islightmode));
  });
}

class MyApp extends StatelessWidget {
  final bool islightmode;
  const MyApp({super.key, required this.islightmode});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create:
              (context) =>
                  Userrepository(userserverservices: Userserverservices()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create:
                (context) => UserBloc(
                  userrepository: Userrepository(
                    userserverservices: Userserverservices(),
                  ),
                ),
          ),
          BlocProvider(
            create: (context) => ThemeBloc(isLightMode: islightmode),
          ),
        ],
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
             ThemeData currentTheme = islightmode ? lightmode : darkmode; 
            if (state is ThemedataSuccessfully) {
              currentTheme = state.themeData;
            }
            return MaterialApp(
              title: 'Flutter Demo',
              debugShowCheckedModeBanner: false,
              theme:currentTheme,
              initialRoute: authScreenRoute,
              onGenerateRoute: AppRoute.generateRoute,
            );
          },
        ),
      ),
    );
  }
}
