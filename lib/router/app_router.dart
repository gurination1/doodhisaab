import 'package:go_router/go_router.dart';

import '../models/customer.dart';
import '../screens/customers/add_edit_customer_screen.dart';
import '../screens/customers/customer_list_screen.dart';
import '../screens/customers/customer_profile_screen.dart';
import '../screens/customers/route_reorder_screen.dart';
import '../screens/delivery/delivery_entry_screen.dart';
import '../screens/expenses/expense_entry_screen.dart';
import '../screens/home_screen.dart';
import '../screens/lock_screen.dart';
import '../screens/onboarding/onboarding_wizard.dart';
import '../screens/other_income/other_income_entry_screen.dart';
import '../screens/payments/payment_entry_screen.dart';
import '../screens/placeholder_screen.dart';
import '../screens/privacy/privacy_policy_screen.dart';
import '../screens/reports/customer_statement_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/settings/calculator_screen.dart';
import '../screens/settings/backup_screen.dart';
import '../screens/settings/export_screen.dart';
import '../screens/settings/price_settings_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/tutorial/tutorial_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// app_router.dart
//
// CRITICAL ORDERING RULES (go_router matches top-to-bottom):
//
//   /customers/reorder  must come BEFORE  /customers/:id
//   /customers/new      must come BEFORE  /customers/:id
//
// If /:id is declared first, 'reorder' and 'new' match as id='reorder'/'new'
// and the wrong screen opens every time.
//
// Same applies to /reports/statement/:id — declared after literal /reports.
// ─────────────────────────────────────────────────────────────────────────────

final router = GoRouter(
  initialLocation: '/lock',
  routes: [
    // ── Entry / shell ────────────────────────────────────────────────────────
    GoRoute(
      path: '/lock',
      builder: (_, __) => const LockScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (_, __) => const HomeScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (_, __) => const OnboardingWizard(),
    ),

    // ── Delivery ─────────────────────────────────────────────────────────────
    GoRoute(
      path: '/delivery/entry',
      builder: (_, __) => const DeliveryEntryScreen(),
    ),

    // ── Payment ──────────────────────────────────────────────────────────────
    // customerId passed via GoRouter.extra — pre-selects the customer.
    // null is valid: payment screen shows a customer picker.
    GoRoute(
      path: '/payment/entry',
      builder: (_, state) => PaymentEntryScreen(
        customerId: state.extra as String?,
      ),
    ),

    // ── Customers ────────────────────────────────────────────────────────────
    GoRoute(
      path: '/customers',
      builder: (_, __) => const CustomerListScreen(),
    ),

    // CRITICAL: /customers/reorder and /customers/new MUST be declared
    // before /customers/:id. Literal paths take priority only when listed first.
    GoRoute(
      path: '/customers/reorder',
      builder: (_, __) => const RouteReorderScreen(),
    ),
    GoRoute(
      path: '/customers/new',
      // Customer? via extra: null = add mode, non-null = edit mode.
      builder: (_, state) => AddEditCustomerScreen(
        customer: state.extra as Customer?,
      ),
    ),
    GoRoute(
      path: '/customers/:id',
      builder: (_, state) => CustomerProfileScreen(
        customerId: state.pathParameters['id']!,
      ),
    ),

    // ── Reports ──────────────────────────────────────────────────────────────
    GoRoute(
      path: '/reports',
      builder: (_, __) => const ReportsScreen(),
    ),
    // Declared after /reports (literal) — no conflict.
    GoRoute(
      path: '/reports/statement/:id',
      builder: (_, state) => CustomerStatementScreen(
        customerId: state.pathParameters['id']!,
      ),
    ),

    // ── Expenses + Other Income ───────────────────────────────────────────────
    GoRoute(
      path: '/expenses/new',
      builder: (_, __) => const ExpenseEntryScreen(),
    ),
    GoRoute(
      path: '/income/new',
      builder: (_, __) => const OtherIncomeEntryScreen(),
    ),

    // ── Settings ─────────────────────────────────────────────────────────────
    GoRoute(
      path: '/settings',
      builder: (_, __) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/settings/price',
      builder: (_, __) => const PriceSettingsScreen(),
    ),
    GoRoute(
      path: '/settings/backup',
      builder: (_, __) => const BackupScreen(),
    ),
    GoRoute(
      path: '/settings/export',
      builder: (_, __) => const ExportScreen(),
    ),
    GoRoute(
      path: '/settings/calculator',
      builder: (_, __) => const CalculatorScreen(),
    ),
    GoRoute(
      path: '/tutorial',
      builder: (_, __) => const TutorialScreen(),
    ),
    GoRoute(
      path: '/privacy',
      builder: (_, __) => const PrivacyPolicyScreen(),
    ),

    // ── Placeholder — wired routes not yet built ──────────────────────────────
    // Remove each entry as the real screen is built.
    // Currently: none remaining — all routes above have real implementations.
    GoRoute(
      path: '/placeholder',
      builder: (_, __) => const PlaceholderScreen(title: 'Coming Soon'),
    ),
  ],
);
