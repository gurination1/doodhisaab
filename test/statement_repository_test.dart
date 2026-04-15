import 'package:doodhisaab/db/customer_repository.dart';
import 'package:doodhisaab/db/db_provider.dart';
import 'package:doodhisaab/db/delivery_repository.dart';
import 'package:doodhisaab/db/expense_repository.dart';
import 'package:doodhisaab/db/other_income_repository.dart';
import 'package:doodhisaab/db/payment_repository.dart';
import 'package:doodhisaab/db/statement_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseProvider.dbNameOverrideForTesting = 'doodhisaab_statement_test.db';
  });

  setUp(() async {
    await DatabaseProvider.closeAndReset();
    final path = p.join(
      await getDatabasesPath(),
      DatabaseProvider.dbNameOverrideForTesting ?? kDbName,
    );
    await deleteDatabase(path);
  });

  group('StatementRepository', () {
    test('getMonthlySummary aggregates revenue, income, expenses, and collections', () async {
      final customerRepo = CustomerRepository();
      final deliveryRepo = DeliveryRepository();
      final paymentRepo = PaymentRepository();
      final expenseRepo = ExpenseRepository();
      final incomeRepo = OtherIncomeRepository();
      final statementRepo = StatementRepository();

      final customer = await customerRepo.addCustomer(
        name: 'Aman',
        defaultLiters: 2.0,
      );

      await deliveryRepo.upsertSessionDraft(
        sessionId: 'session-1',
        customerId: customer.customerId,
        date: '2026-04-06',
        liters: 1.5,
        pricePerLiter: 62.25,
        deviceId: 'device-1',
      );
      await deliveryRepo.confirmSession('session-1');

      await paymentRepo.insertPayment(
        customerId: customer.customerId,
        date: '2026-04-06',
        amount: 50.10,
        deviceId: 'device-1',
      );

      await expenseRepo.addExpense(
        category: 'Feed',
        amount: 15.789,
        date: '2026-04-06',
      );
      await incomeRepo.addOtherIncome(
        category: 'Ghee Sale',
        amount: 20.555,
        date: '2026-04-06',
      );

      final summary = await statementRepo.getMonthlySummary(2026, 4);

      expect(summary.totalLiters, 1.5);
      expect(summary.totalMilkRevenue, closeTo(93.38, 0.0001));
      expect(summary.otherIncome, closeTo(20.56, 0.0001));
      expect(summary.totalExpenses, closeTo(15.79, 0.0001));
      expect(summary.totalCollected, closeTo(50.10, 0.0001));
      expect(summary.grossProfit, closeTo(98.15, 0.0001));
      expect(summary.activeCustomerCount, 1);
      expect(summary.hasData, isTrue);
    });

    test('getCustomerStatement ignores session drafts and computes balance from confirmed deliveries only', () async {
      final customerRepo = CustomerRepository();
      final deliveryRepo = DeliveryRepository();
      final paymentRepo = PaymentRepository();
      final statementRepo = StatementRepository();

      final customer = await customerRepo.addCustomer(
        name: 'Gurpreet',
        defaultLiters: 2.0,
      );

      await deliveryRepo.upsertSessionDraft(
        sessionId: 'session-confirmed',
        customerId: customer.customerId,
        date: '2026-04-02',
        liters: 2.0,
        pricePerLiter: 60.0,
        deviceId: 'device-1',
      );
      await deliveryRepo.confirmSession('session-confirmed');

      await deliveryRepo.upsertSessionDraft(
        sessionId: 'session-draft',
        customerId: customer.customerId,
        date: '2026-04-03',
        liters: 3.0,
        pricePerLiter: 60.0,
        deviceId: 'device-1',
      );

      await paymentRepo.insertPayment(
        customerId: customer.customerId,
        date: '2026-04-04',
        amount: 40.0,
        deviceId: 'device-1',
      );

      final statement = await statementRepo.getCustomerStatement(
        customer.customerId,
        2026,
        4,
      );

      expect(statement.deliveries, hasLength(1));
      expect(statement.payments, hasLength(1));
      expect(statement.totalLiters, 2.0);
      expect(statement.totalValue, 120.0);
      expect(statement.totalPaid, 40.0);
      expect(statement.balance, 80.0);
    });
  });
}
