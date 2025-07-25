import 'package:intl/intl.dart';

class Helpers {
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatCurrency(double amount) {
    return NumberFormat.currency(
      symbol: AppConstants.currencySymbol,
    ).format(amount);
  }
}

class AppConstants {
  static const String appName = 'Drive Hailing Driver';
  static const String currencySymbol = 'Tsh';
}
