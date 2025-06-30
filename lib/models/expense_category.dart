import 'package:flutter/material.dart';

enum ExpenseCategory {
  /// Продукты питания и товары первой необходимости
  PRODUCTS('Продукты', Icons.shopping_cart, 'Продукты питания и товары первой необходимости'),
  
  /// Общественный транспорт, бензин, обслуживание автомобиля
  TRANSPORT('Транспорт', Icons.directions_car, 'Общественный транспорт, бензин, обслуживание автомобиля'),
  
  /// Развлечения, хобби, досуг
  ENTERTAINMENT('Развлечения', Icons.movie, 'Развлечения, хобби, досуг'),
  
  /// Медицинские услуги, лекарства
  HEALTH('Здоровье', Icons.local_hospital, 'Медицинские услуги, лекарства'),
  
  /// Аренда, ипотека, ремонт
  HOUSING('Жилье', Icons.home, 'Аренда, ипотека, ремонт'),
  
  /// Электричество, вода, газ, интернет
  UTILITIES('Коммунальные услуги', Icons.power, 'Электричество, вода, газ, интернет'),
  
  /// Одежда, обувь, аксессуары
  CLOTHING('Одежда', Icons.checkroom, 'Одежда, обувь, аксессуары'),
  
  /// Обучение, курсы, книги
  EDUCATION('Образование', Icons.school, 'Обучение, курсы, книги'),
  
  /// Телефон, интернет, ТВ
  COMMUNICATION('Связь', Icons.phone, 'Телефон, интернет, ТВ'),
  
  /// Рестораны, кафе, доставка еды
  CAFE('Кафе и рестораны', Icons.restaurant, 'Рестораны, кафе, доставка еды'),
  
  /// Спортзал, тренировки, спортивные товары
  SPORT('Спорт', Icons.fitness_center, 'Спортзал, тренировки, спортивные товары'),
  
  /// Косметика, салоны красоты
  BEAUTY('Красота', Icons.spa, 'Косметика, салоны красоты'),
  
  /// Питомцы, ветеринар, корм
  PETS('Питомцы', Icons.pets, 'Питомцы, ветеринар, корм'),
  
  /// Подарки и сувениры другим людям
  GIFTS('Подарки другим', Icons.card_giftcard, 'Подарки и сувениры другим людям'),
  
  /// Путешествия, отели, экскурсии
  TRAVEL('Путешествия', Icons.flight, 'Путешествия, отели, экскурсии'),
  
  /// Такси, каршеринг
  TAXI('Такси', Icons.local_taxi, 'Такси, каршеринг'),
  
  /// Покупки в магазинах
  SHOPPING('Покупки', Icons.shopping_bag, 'Покупки в магазинах'),
  
  /// Электроника, гаджеты
  ELECTRONICS('Электроника', Icons.devices, 'Электроника, гаджеты'),
  
  /// Страховые взносы: автострахование, медицинское, имущественное
  INSURANCE('Страхование', Icons.security, 'Страховые взносы: автострахование, медицинское, имущественное'),
  
  /// Погашение долгов: кредиты, займы, процентные платежи
  DEBT('Долги и кредиты', Icons.account_balance, 'Погашение долгов: кредиты, займы, процентные платежи'),
  
  /// Подписки на сервисы и приложения
  SUBSCRIPTIONS('Подписки', Icons.subscriptions, 'Подписки на сервисы и приложения'),
  
  /// Благотворительность и пожертвования
  CHARITY('Благотворительность', Icons.volunteer_activism, 'Благотворительность и пожертвования'),
  
  /// Прочие расходы
  OTHER('Другое', Icons.category, 'Прочие расходы');

  final String displayName;
  final IconData icon;
  final String description;

  const ExpenseCategory(this.displayName, this.icon, this.description);

  factory ExpenseCategory.fromString(String value) {
    return ExpenseCategory.values.firstWhere(
      (category) => category.name == value || category.displayName == value,
      orElse: () => ExpenseCategory.OTHER,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'displayName': displayName,
      'description': description,
    };
  }

  static ExpenseCategory fromJson(Map<String, dynamic> json) {
    return ExpenseCategory.fromString(json['name'] as String);
  }

  static List<ExpenseCategory> get mainCategories => [
    PRODUCTS,
    TRANSPORT,
    ENTERTAINMENT,
    HEALTH,
    HOUSING,
    UTILITIES,
    CLOTHING,
    EDUCATION,
    COMMUNICATION,
    CAFE,
    SUBSCRIPTIONS,
    DEBT,
    CHARITY,
  ];

  static List<ExpenseCategory> get additionalCategories => [
    SPORT,
    BEAUTY,
    PETS,
    GIFTS,
    TRAVEL,
    TAXI,
    SHOPPING,
    ELECTRONICS,
    INSURANCE,
    OTHER,
  ];

  Color get color {
    switch (this) {
      case ExpenseCategory.PRODUCTS:
        return Colors.green;
      case ExpenseCategory.TRANSPORT:
        return Colors.blue;
      case ExpenseCategory.ENTERTAINMENT:
        return Colors.purple;
      case ExpenseCategory.HEALTH:
        return Colors.red;
      case ExpenseCategory.HOUSING:
        return Colors.brown;
      case ExpenseCategory.UTILITIES:
        return Colors.orange;
      case ExpenseCategory.CLOTHING:
        return Colors.pink;
      case ExpenseCategory.EDUCATION:
        return Colors.indigo;
      case ExpenseCategory.COMMUNICATION:
        return Colors.teal;
      case ExpenseCategory.CAFE:
        return Colors.amber;
      case ExpenseCategory.SPORT:
        return Colors.lightBlue;
      case ExpenseCategory.BEAUTY:
        return Colors.deepPurple;
      case ExpenseCategory.PETS:
        return Colors.lime;
      case ExpenseCategory.GIFTS:
        return Colors.deepOrange;
      case ExpenseCategory.TRAVEL:
        return Colors.cyan;
      case ExpenseCategory.TAXI:
        return Colors.yellow;
      case ExpenseCategory.SHOPPING:
        return Colors.lightGreen;
      case ExpenseCategory.ELECTRONICS:
        return Colors.blueGrey;
      case ExpenseCategory.INSURANCE:
        return Colors.grey.shade700;
      case ExpenseCategory.DEBT:
        return Colors.red.shade700;
      case ExpenseCategory.SUBSCRIPTIONS:
        return Colors.purple.shade300;
      case ExpenseCategory.CHARITY:
        return Colors.pink.shade300;
      case ExpenseCategory.OTHER:
        return Colors.grey;
    }
  }
}
