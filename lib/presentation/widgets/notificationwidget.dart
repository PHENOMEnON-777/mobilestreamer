import 'package:fingerprint/logic/userbloc/bloc/user_bloc.dart';
import 'package:fingerprint/router/routers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



class NotificationWidget extends StatelessWidget {
  const NotificationWidget({super.key});

  @override
  Widget build(BuildContext context) {
 BlocProvider.of<UserBloc>(context).add(GetAllNotifications());
    return  BlocBuilder<UserBloc, UserState>(
      buildWhen: (previous, current) => current is GetingAllNotificationsSuccessfully,
            builder: (context, state) {
              if(state is GetingAllNotificationsSuccessfully){
                final notificationlength = (state.data);
                 return Badge(
                backgroundColor: Colors.red,
                label: Text(notificationlength.length.toString(),style: TextStyle(color: Theme.of(context).colorScheme.onSurface),),
                child:
                   GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(notificationsscreen);
                    },
                    child:const Icon(Icons.notifications_none_rounded,)),);
              }
              return const Badge(
                backgroundColor: Colors.red,
                label:  Text('0'),
                child: Icon(Icons.notifications_none_rounded,),);
            },
          );
  }
}