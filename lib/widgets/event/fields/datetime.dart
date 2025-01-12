import 'package:flashbacks/utils/errors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';


class DateTimeFieldCard extends StatefulWidget {
  late DateTime? initStartAt;
  late DateTime? initEndAt;
  late Function(DateTime startAt, DateTime endAt) onChange;

  FieldError? fieldError;

  final TextStyle ordWordStyle = const TextStyle(fontSize: 17, color: Colors.grey);
  final TextStyle specWordStyle = const TextStyle(fontSize: 17, color: Colors.white);

  DateTimeFieldCard({super.key, this.initStartAt, this.initEndAt, required this.onChange, this.fieldError}) {
    initStartAt ??= DateTime.now().add(const Duration(minutes: 15));
    initEndAt ??= initStartAt!.add(const Duration(hours: 8));
  }

  @override
  State<DateTimeFieldCard> createState() => _DateTimeFieldCardState();
}

class _DateTimeFieldCardState extends State<DateTimeFieldCard> {
  late DateTime _startAt;
  late DateTime _endAt;
  late bool _isEndAtRealAliasSetByTheUserOrIsTheUserJustFuckingSlowAhhhhhhhhhhhh;

  @override
  void initState() {
    super.initState();
    _startAt = widget.initStartAt!;
    _endAt = widget.initEndAt!;
    _isEndAtRealAliasSetByTheUserOrIsTheUserJustFuckingSlowAhhhhhhhhhhhh = false;
  }

  Future<void> _handleStartAtDateTap(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startAt,
      firstDate: DateTime.now(),
      lastDate:
        _isEndAtRealAliasSetByTheUserOrIsTheUserJustFuckingSlowAhhhhhhhhhhhh ? _endAt : DateTime(2100),
    );

    if (picked == null)
      return;
    setState(() => _startAt = picked);
    widget.onChange(_startAt, _endAt);
  }

  Future<void> _handleStartAtTimeTap(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked == null)
      return;
    setState(() {
      _startAt = DateTime(
        _startAt.year,
        _startAt.month,
        _startAt.day,
        picked.hour,
        picked.minute,
      );
    });
    widget.onChange(_startAt, _endAt);
  }

  Future<void> _handleEndAtDateTap(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endAt,
      firstDate: _startAt,
      lastDate: _startAt.add(const Duration(days: 30)),
    );

    if (picked == null)
      return;
    setState(() => _endAt = picked);
    widget.onChange(_startAt, _endAt);
  }

  Future<void> _handleEndAtTimeTap(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endAt),
    );

    if (picked == null)
      return;
    setState(() {
      _startAt = DateTime(
        _endAt.year,
        _endAt.month,
        _endAt.day,
        picked.hour,
        picked.minute,
      );
    });
    widget.onChange(_startAt, _endAt);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card.outlined(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_buildInfoSection(), _buildInputSection()],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, top: 8, bottom: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Title ", style: TextStyle(fontSize: 22.5)),

              if (widget.fieldError != null && widget.fieldError!.isActive)
                const Text("*", style: TextStyle(fontSize: 22.5, color: Colors.red)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(
            top: BorderSide(
              width: 1,
              color: Color(0xFF424242),
            )),
        color: Colors.transparent,
      ),
      child: Padding(
          padding: const EdgeInsets.only(left: 12, top: 10, bottom: 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildStartTimeSentence(context),
            const Gap(6),
            _buildEndTimeSentence(context),
            const Gap(6),
            _buildErrorMessage()
          ])
      ),
    );
  }

  Widget _buildStartTimeSentence(BuildContext context) {
    final dateFormatter = DateFormat('h:mm a');
    final timeString = dateFormatter.format(_startAt);

    return Row(
      children: [
        Text("From", style: widget.ordWordStyle),
        _buildSpecWord(_humanizeDateTime(_startAt), () => _handleStartAtDateTap(context)),
        Text("at", style: widget.ordWordStyle),
        _buildSpecWord(timeString, () => _handleStartAtTimeTap(context)),
      ],
    );
  }

  Widget _buildEndTimeSentence(BuildContext context) {
    final dateFormatter = DateFormat('h:mm a');
    final timeString = dateFormatter.format(_endAt);

    return Row(
      children: [
        Text("Till", style: widget.ordWordStyle),
        _buildSpecWord(_humanizeDateTime(_startAt), () => _handleEndAtDateTap(context)),
        Text("at", style: widget.ordWordStyle),
        _buildSpecWord(timeString, () => _handleEndAtTimeTap(context)),
      ],
    );
  }

  Widget _buildSpecWord(String label, Function() onTap) {
    label = label.endsWith(" ") ? label : "$label ";

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(right: 4, left: 7),
        child: Text(label, style: widget.specWordStyle),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return widget.fieldError != null
        ? widget.fieldError!.buildErrorMessage()
        : const SizedBox.shrink();
  }

  String _humanizeDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays == 0) {
      return 'Today';
    }

    if (difference.inDays == 1) {
      return 'Tomorrow';
    }

    if (difference.inDays > 1 && difference.inDays <= 7) {
      final weekday = DateFormat('EEEE').format(dateTime);
      return 'Next $weekday';
    }

    if (difference.inDays > 7 && dateTime.year == now.year) {
      return DateFormat('d MMM').format(dateTime);
    }

    return DateFormat('d MMM yyyy').format(dateTime);
  }
}
