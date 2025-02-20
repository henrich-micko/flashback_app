import "package:collection/collection.dart";
import "package:flashbacks/models/event.dart";
import "package:flashbacks/models/user.dart";
import "package:flashbacks/providers/api.dart";
import "package:flashbacks/services/api/event.dart";
import "package:flashbacks/utils/widget.dart";
import "package:flashbacks/var.dart";
import "package:flashbacks/widgets/style.dart";
import "package:flashbacks/widgets/user.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:logger/logger.dart";
import 'package:material_symbols_icons/material_symbols_icons.dart';


class UserAsMember {
  final UserContextual user;
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

    _possibleMembers.then(Logger().i);
  }

  void handleUserStatusChange(UserContextual user, bool status) {
    Future response = status
        ? _eventApiClient.member.invite(user.id)
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
                    (pm) => Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: UserAsSelector(
                          user: pm.user,
                          defaultValue: pm.isMember,
                          onChanged: (value) =>
                              handleUserStatusChange(pm.user, value)),
                    ),
              )
                  .toList(),
            ),
          ),
        ));
  }
}

class EventInviteCard extends StatelessWidget {
  final EventInvite eventInvite;
  final Function() onActionPress;

  const EventInviteCard({
    super.key,
    required this.eventInvite,
    required this.onActionPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.transparent,
        width: double.infinity,
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                UserProfilePicture(profilePictureUrl: eventInvite.user.profileUrl, size: 25),
                buildProfileInfo()
              ],
            ),

            OutlinedButton(
              onPressed: onActionPress,
              style: outlinedButtonStyle.copyWith(padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),),
              child: const Text(
                  "Invited",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400)
              ),
            ),
          ],
        ));
  }

  Widget buildProfileInfo() {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(eventInvite.user.username,
              style: const TextStyle(color: Colors.white, fontSize: 20.0)),
          if (eventInvite.invitedBy != null)
            Text("Invited ${eventInvite.invitedBy!.username}", style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}


class EventPossibleMemberCard extends StatelessWidget {
  final EventPossibleMember possibleMember;
  final Function() onActionButtonPress;

  const EventPossibleMemberCard({
    super.key,
    required this.possibleMember,
    required this.onActionButtonPress
  });

  String _getMemberStatusLabel() {
    if (possibleMember.status == EventPossibleMemberStatus.member) {
      return "Member";
    } else if (possibleMember.status == EventPossibleMemberStatus.invited) {
      return "Invited";
    } else {
      return "Invite";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.transparent,
        width: double.infinity,
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                UserProfilePicture(profilePictureUrl: possibleMember.profileUrl, size: 25),
                buildProfileInfo()
              ],
            ),

            SizedBox(
              width: 120,
              child: OutlinedButton(
                onPressed: onActionButtonPress,
                style: outlinedButtonStyle.copyWith(padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),),
                child: Text(
                    _getMemberStatusLabel(),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400)
                ),
              ),
            ),
          ],
        ));
  }

  Widget buildProfileInfo() {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(possibleMember.username,
              style: const TextStyle(color: Colors.white, fontSize: 20.0)),
        ],
      ),
    );
  }
}


class EventMemberCard extends StatelessWidget {
  final EventMember eventMember;
  final Function() onRemove;

  const EventMemberCard({
    super.key,
    required this.eventMember,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.transparent,
        width: double.infinity,
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                UserProfilePicture(profilePictureUrl: eventMember.user.profileUrl, size: 25),
                buildProfileInfo()
              ],
            ),

            OutlinedButton(
              onPressed: onRemove,
              style: outlinedButtonStyle.copyWith(padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),),
              child: const Text(
                  "Member",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400)
              ),
            ),
          ],
        ));
  }

  Widget buildProfileInfo() {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(eventMember.user.username,
              style: const TextStyle(color: Colors.white, fontSize: 20.0)),
          if (eventMember.addedBy != null)
            Text("Added ${eventMember.addedBy!.username}", style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}


class EventMemberManager extends StatefulWidget {
  final int eventId;
  const EventMemberManager({super.key, required this.eventId});

  @override
  State<EventMemberManager> createState() => _EventMemberManagerState();
}

class _EventMemberManagerState extends State<EventMemberManager> {
  final TextEditingController _searchController = TextEditingController();
  late EventApiDetailClient _eventApiClient;
  String? _search;
  List<EventMember> _members = [];
  List<EventInvite> _invited = [];
  List<EventPossibleMember> _results = [];

  @override
  void initState() {
    super.initState();
    _eventApiClient = ApiModel.fromContext(context).api.event.detail(widget.eventId);
    _load();
  }

  void _load() {
    _loadInvited();
    _loadMembers();
    if (_search != null) _searchUsers(_search!);
  }

  void _loadMembers() {
    _eventApiClient.member.all().then((members) => setState(() {
      _members = List.from(members);
    }));
  }

  void _loadInvited() {
    _eventApiClient.member.invites().then((invited) => setState(() {
      _invited = List.from(invited);
    }));
  }

  void _searchUsers(String value) {
    if (value.isEmpty) {
      setState(() {
        _search = null;
        _results = [];
      });
      return;
    }
    setState(() {
      _search = value;
    });
    _eventApiClient.member.possible(search: value).then((users) => setState(() {
      _results = List.from(users);
    }));
  }

  void _removeMember(int userPk) {
    _eventApiClient.member.delete(userPk).then((_) => _load());
  }

  void _deleteInvite(int userPk) {
    _eventApiClient.member.deleteInvite(userPk).then((_) => _load());
  }

  void _invite(int userPk) {
    _eventApiClient.member.invite(userPk).then((_) => _load());
  }

  void _handleResultActionPress(int resultIndex) {
    final epm = _results[resultIndex];
    switch (epm.status) {
      case EventPossibleMemberStatus.member:
        _showDeleteMemberDialog(epm.id);
        return;
      case EventPossibleMemberStatus.invited:
        _deleteInvite(epm.id);
        return;
      case EventPossibleMemberStatus.none:
        _invite(epm.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 5),
            child: _buildSearchInput(),
          ),
          if (_results.isNotEmpty) _buildResultsColumn(),
          if (_search == null && _invited.isNotEmpty) _buildInvitedColumn(),
          if (_search == null && _members.isNotEmpty) _buildMembersColumn()
        ],
      ),
    );
  }

  Widget _buildInvitedColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 5, left: 10, top: 20),
          child: Text("Invited", style: TextStyle(fontSize: 20, color: Colors.grey)),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 14, right: 14, bottom: 15),
          child: Column(
            children: _invited.map((item) => EventInviteCard(
                eventInvite: item,
                onActionPress: () => _deleteInvite(item.user.id)
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMembersColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 5, left: 10),
          child: Text("Members", style: TextStyle(fontSize: 20, color: Colors.grey)),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 14, right: 14, bottom: 15),
          child: Column(
            children: _members.map((item) => EventMemberCard(
                eventMember: item,
                onRemove: () => _showDeleteMemberDialog(item.user.id)
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsColumn() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 15),
      child: Column(
        children: _results.mapIndexed<Widget>((index, item) => EventPossibleMemberCard(
            possibleMember: item,
            onActionButtonPress: () => _handleResultActionPress(index)
        )).toList(),
      ),
    );
  }

  Widget _buildSearchInput() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: const BorderRadius.all(Radius.circular(11)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _searchUsers,
              onSubmitted: (_) => {},
              style: const TextStyle(color: Colors.white70, fontSize: 17),
              decoration: const InputDecoration(
                fillColor: Colors.transparent,
                hintText: "Search for users",
                filled: true,
                hintStyle: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w400),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: () => {
              if (_search != null)
                setState(() {
                  _search = null;
                  _searchController.clear();
                  _results = [];
                })
            },
            icon: Icon(_results.isEmpty ? Symbols.search : Symbols.close),
            color: Colors.white,
          )
        ],
      ),
    );
  }

  void _showDeleteMemberDialog(int userPk) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
            side: const BorderSide(color: Colors.grey, width: 1),
          ),j
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Remove"),
              Icon(Symbols.delete)
            ],
          ),
          content: const Text("Are you sure you want to remove this member?"), // something cool about not logging out git?
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text("Cancel", style: TextStyle(color: Colors.white)),
            ),

            TextButton(
              onPressed: () {
                context.pop();
                _removeMember(userPk);
              },
              child: const Text("Remove", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}