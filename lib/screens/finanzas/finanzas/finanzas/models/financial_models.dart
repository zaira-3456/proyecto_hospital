class FinancialMetrics {
  final double dailyIncome;
  final double dailyExpenses;
  final double cashFlow;
  final double incomePercentageChange;
  final double expensesPercentageChange;
  final double cashFlowPercentageChange;

  FinancialMetrics({
    required this.dailyIncome,
    required this.dailyExpenses,
    required this.cashFlow,
    required this.incomePercentageChange,
    required this.expensesPercentageChange,
    required this.cashFlowPercentageChange,
  });
}

class AreaData {
  final String areaName;
  final double amount;

  AreaData({
    required this.areaName,
    required this.amount,
  });
}

class UrgentTask {
  final String description;
  final int priority; // 1 = high, 2 = medium, 3 = low

  UrgentTask({
    required this.description,
    required this.priority,
  });
}

class User {
  final String username;
  final String name;
  final String role; // 'finance', 'doctor', 'admin', etc.

  User({
    required this.username,
    required this.name,
    required this.role,
  });
}

class ExpenseRecord {
  final String id;
  final DateTime date;
  final double amount;
  final String area;
  final String type;
  final bool hasInvoice;
  final String status;

  ExpenseRecord({
    required this.id,
    required this.date,
    required this.amount,
    required this.area,
    required this.type,
    required this.hasInvoice,
    required this.status,
  });
}

class ExpenseRequest {
  final String id;
  final DateTime date;
  final double amount;
  final String area;
  final String type;
  final String status;
  final String requestedBy;
  final String description;
  final List<ChangeHistoryEntry> changeHistory;

  ExpenseRequest({
    required this.id,
    required this.date,
    required this.amount,
    required this.area,
    required this.type,
    required this.status,
    required this.requestedBy,
    required this.description,
    required this.changeHistory,
  });
}

class IncomeRecord {
  final String id;
  final DateTime date;
  final String client;
  final double amount;
  final String paymentMethod;
  final String area;

  IncomeRecord({
    required this.id,
    required this.date,
    required this.client,
    required this.amount,
    required this.paymentMethod,
    required this.area,
  });
}

enum ExportOption {
  excel,
  pdf,
  print,
}

class ChangeHistoryEntry {
  final String id;
  final DateTime timestamp;
  final String description;
  final String modifiedBy;

  ChangeHistoryEntry({
    required this.id,
    required this.timestamp,
    required this.description,
    required this.modifiedBy,
  });
}
