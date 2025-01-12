import "package:flashbacks/models/event.dart";
import "package:flashbacks/models/user.dart";
import "package:flashbacks/providers/api.dart";
import "package:flashbacks/services/api/event.dart";
import "package:flashbacks/utils/widget.dart";
import "package:flashbacks/widgets/user.dart";
import "package:flutter/material.dart";

class UserAsMember {
  final User user;
  final bool isMember;

  const UserAsMember({required this.user, required this.isMember});
}

class EditEventMembers extends StatefulWidget {
  final int eventId;
  final Function()? onChange;

  const EditEventMembers({super.key, required this.eventId, this.onChange});

  @override
  State<EditEventMembers> createState() => _EditEventMembersState();
}

class _EditEventMembersState extends State<EditEventMembers> {
  late EventApiDetailClient _eventApiClient;
  late Future<Iterable<UserAsMember>> _possibleMembers;

  @override
  void initState() {
    super.initState();
    _eventApiClient = ApiModel.fromContext(context).api.event.detail(widget.eventId);
    _possibleMembers = _eventApiClient.member.possible().then(
            (items) => items.map(
                    (user) => UserAsMember(user: user, isMember: false)
            )
    );
  }

  void handleUserStatusChange(User user, bool status) {
    Future response = status
        ? _eventApiClient.member.add(user.id)
        : _eventApiClient.member.delete(user.id);
    if (widget.onChange != null)
      response.then((value) => widget.onChange!());
  }

  @override
  Widget build(BuildContext context) {
    return getFutureBuilder(
        _possibleMembers,
            (members) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: members
                  .map(
                    (pm) => Column(children: [
                  UserAsSelector(
                      user: pm.user,
                      defaultValue: pm.isMember,
                      onChanged: (value) =>
                          handleUserStatusChange(pm.user, value)),
                  const Divider()
                ]),
              )
                  .toList(),
            ),
          ),
        ));
  }
}
