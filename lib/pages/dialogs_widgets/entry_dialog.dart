import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expense_tracker/models/category_model.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:flutter_expense_tracker/global_vars/global_expense.dart';
import 'package:flutter_expense_tracker/models/transaction_model.dart';
import 'package:flutter_expense_tracker/widgets/home_page_popup_items.dart';

class EntryDialog extends StatefulWidget {
  final Function(TransactionModel transactionModel, bool isIncome) changeData;
  const EntryDialog({
    Key? key,
    required this.changeData,
  }) : super(key: key);

  @override
  State<EntryDialog> createState() => _EntryDialogState();
}

class _EntryDialogState extends State<EntryDialog> {
  //
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  //
  DateTime selectedDate = DateTime.now();
  final formatter = DateFormat('yyyy-MM-dd');
  String get formattedDate => formatter.format(selectedDate);
  //
  final currentDateFormatted = DateFormat('yyyy-MM-dd').format(DateTime.now());

  // temp
  String? categoryItem;
  CategoryModel? categoryValueFromListItem;

  //
  Dialog setDateTimeDialog(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.now(),
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
            },
            focusedDay: DateTime.now(),
            onDaySelected: (selectedDay, focusedDay) {
              debugPrint(formattedDate.toString());
              setState(() {
                selectedDate = selectedDay;
              });
              context.pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      backgroundColor: Colors.grey.shade900,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 15,
            ),
            const PopupTextFieldTitle(
              title: "Date",
            ),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return setDateTimeDialog(context);
                  },
                );
              },
              child: PopupCategoryItems(
                title: (formattedDate == currentDateFormatted)
                    ? "Today"
                    : formattedDate.toString(),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            const PopupTextFieldTitle(
              title: "Amount",
            ),
            PopupTextFieldItems(
              textEditingController: amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                // FilteringTextInputFormatter.digitsOnly,
                FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}')),
              ],
              hintText: "Enter Amount",
            ),
            const SizedBox(
              height: 5,
            ),
            // const SaveAndCancelRow(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 10),
                  child: InkWell(
                    onTap: () {
                      context.pop();
                    },
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10, bottom: 10),
                  child: InkWell(
                    onTap: () {
                      if (categoryValueFromListItem != null) {
                        final transactionVal = TransactionModel(
                          year: 2023,
                          dateTime: selectedDate.toString(),
                          amount: int.parse(amountController.text),
                          category: categoryValueFromListItem?.transactionType
                              as String,
                          isIncome: categoryValueFromListItem?.isIncome as bool,
                          colorsValue:
                              categoryValueFromListItem?.colorsValue as int,
                        );
                        widget.changeData(transactionVal,
                            categoryValueFromListItem?.isIncome as bool);
                        debugPrint(transactionList.length.toString());
                      }
                      context.pop();
                    },
                    child: Text(
                      "Save",
                      style: TextStyle(
                        color: Colors.blue.shade400,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            const PopupTextFieldTitle(
              title: "Category",
            ),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      child: SizedBox(
                        height: 400,
                        child: Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    for (final listItem in listItems)
                                      ListTile(
                                        onTap: () {
                                          setState(() {
                                            categoryItem = listItem
                                                .transactionType
                                                .toString();
                                            categoryValueFromListItem =
                                                listItem;
                                          });
                                          context.pop();
                                        },
                                        leading: CircleAvatar(
                                          backgroundColor:
                                              listItem.isIncome == true
                                                  ? Colors.blue
                                                  : Colors.red,
                                          child: listItem.isIncome == true
                                              ? const Icon(
                                                  Icons.addchart,
                                                  color: Colors.white,
                                                )
                                              : const Icon(
                                                  Icons.highlight_remove_sharp,
                                                  color: Colors.white,
                                                ),
                                        ),
                                        //
                                        title: Text(listItem.transactionType),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            // TODO Create Make new category option. Remove expanded if not created
                            // const SaveAndCancelRow(),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: PopupCategoryItems(
                title: (categoryItem == null)
                    ? "Select Category"
                    : categoryItem as String,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            const PopupTextFieldTitle(
              title: "Note",
            ),
            PopupTextFieldItems(
              textEditingController: noteController,
              hintText: "Note(Optional)",
            ),
            const SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }
}
