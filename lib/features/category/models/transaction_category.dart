// lib/models/transaction_category.dart
import 'package:flutter/material.dart';

import '../../transaction/models/transaction_type.dart';

final Map<String, IconData> iconMap = {
  'account_balance': Icons.account_balance,
  'add_circle': Icons.add_circle,
  'apartment': Icons.apartment,
  'brush': Icons.brush,
  'build': Icons.build,
  'business_center': Icons.business_center,
  'card_giftcard': Icons.card_giftcard,
  'category': Icons.category,
  'checkroom': Icons.checkroom,
  'computer': Icons.computer,
  'devices': Icons.devices,
  'directions_car': Icons.directions_car,
  'fitness_center': Icons.fitness_center,
  'flight': Icons.flight,
  'home': Icons.home,
  'local_hospital': Icons.local_hospital,
  'local_taxi': Icons.local_taxi,
  'medication': Icons.medication,
  'menu_book': Icons.menu_book,
  'movie': Icons.movie,
  'payments': Icons.payments,
  'pets': Icons.pets,
  'phone': Icons.phone,
  'power': Icons.power,
  'receipt': Icons.receipt,
  'redeem': Icons.redeem,
  'restaurant': Icons.restaurant,
  'school': Icons.school,
  'security': Icons.security,
  'sell': Icons.sell,
  'shopping_bag': Icons.shopping_bag,
  'shopping_cart': Icons.shopping_cart,
  'show_chart': Icons.show_chart,
  'subscriptions': Icons.subscriptions,
  'volunteer_activism': Icons.volunteer_activism,
};

class TransactionCategory {
  final int id;
  final String nameRu;
  final String nameEn;
  final String icon;
  final String color;
  final TransactionType type;
  final bool system;

  TransactionCategory({
    required this.id,
    required this.nameRu,
    required this.nameEn,
    required this.icon,
    required this.color,
    required this.type,
    required this.system,
  });

  factory TransactionCategory.fromJson(Map<String, dynamic> json) {
    return TransactionCategory(
      id: json['id'],
      nameRu: json['nameRu'],
      nameEn: json['nameEn'],
      icon: json['icon'],
      color: json['color'],
      type: TransactionType.values.byName(json['type']),
      system: json['system'],
    );
  }

  String displayName(String lang) => lang == 'en' ? nameEn : nameRu;

  IconData get iconData => iconMap[icon] ?? Icons.category;

  Color get colorValue {
    final hex = color.replaceFirst('#', '');
    final value = hex.length == 6 ? 'FF$hex' : hex;
    return Color(int.parse(value, radix: 16));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TransactionCategory && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
