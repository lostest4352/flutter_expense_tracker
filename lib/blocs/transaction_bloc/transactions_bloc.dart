import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/database/isar_classes.dart';
import 'package:flutter_expense_tracker/database/isar_service.dart';

part 'transactions_event.dart';
part 'transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final IsarService isarService = IsarService();
  //
  TransactionsBloc() : super(TransactionsInitial()) {
    on<AddTransactionEvent>((event, emit) async {
      final isar = await isarService.isarDB;
      isar.writeTxn(() async {
        await isar.transactionModelIsars.put(event.transactionModelIsar);
      });
      emit(AddTransactionState());
    });

    on<EditTransactionEvent>((event, emit) async {
      final isar = await isarService.isarDB;
      final selectedUserModel = await isar.transactionModelIsars
          .get(event.selectedTransactionModelId);
      selectedUserModel?.amount = event.amount;
      selectedUserModel?.dateTime = event.dateTime;
      selectedUserModel?.note = event.note;
      //
      selectedUserModel?.transactionType = event.transactionType;
      selectedUserModel?.isIncome = event.isIncome;
      selectedUserModel?.colorsValue = event.colorsValue;
      //
      isar.writeTxn(() async {
        if (selectedUserModel != null) {
          await isar.transactionModelIsars.put(selectedUserModel);
        }
      });
      emit(EditTransactionState());
    });

    on<DeleteTransactionEvent>((event, emit) async {
      final isar = await isarService.isarDB;
      isar.writeTxn(() async {
        await isar.transactionModelIsars
            .delete(event.widgetTransactionModelIsar!.id);
      });
      emit(DeleteTransactionState());
    });
  }
}
