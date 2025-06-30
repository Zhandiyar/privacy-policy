import 'package:fintrack/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintrack/blocs/expense_bloc.dart';
import 'package:fintrack/blocs/expense_event.dart';
import 'package:fintrack/blocs/currency/currency_bloc.dart';
import 'package:fintrack/blocs/currency/currency_state.dart';
import 'package:fintrack/models/expense.dart';
import 'package:fintrack/models/expense_category.dart';
import 'package:fintrack/services/storage_service.dart';
import 'package:intl/intl.dart';

class ExpenseFormScreen extends StatefulWidget {
  final Expense? expense;

  const ExpenseFormScreen({Key? key, this.expense}) : super(key: key);

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late ExpenseCategory _category;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  bool _isNumericKeyboard = true; // Флаг для отслеживания текущей клавиатуры

  @override
  void initState() {
    super.initState();
    _category = widget.expense?.category ?? ExpenseCategory.OTHER;
    _amountController = TextEditingController(
      text: widget.expense?.amount != null 
          ? widget.expense!.amount.toStringAsFixed(0).replaceAll(RegExp(r'\.0*$'), '')
          : '',
    );
    _descriptionController = TextEditingController(
      text: widget.expense?.description ?? '',
    );
    _selectedDate = widget.expense?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    // Базовая валидация
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите сумму')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Некорректный формат числа')),
      );
      return;
    }

    // Проверка на максимальное значение
    if (amount > 999999999) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сумма не может быть больше 999 999 999')),
      );
      return;
    }

    final description = _descriptionController.text.trim();
    final expense = widget.expense?.copyWith(
      category: _category,
      amount: amount,
      date: _selectedDate,
      description: description.isNotEmpty ? description : null,
    ) ?? Expense(
      category: _category,
      amount: amount,
      date: _selectedDate,
      description: description.isNotEmpty ? description : null,
    );

    if (widget.expense == null) {
      context.read<ExpenseBloc>().add(AddExpenseEvent(expense));
    } else {
      context.read<ExpenseBloc>().add(UpdateExpenseEvent(expense));
    }

    Navigator.of(context).pop(expense);
  }

  // Проверка валидности вводимого числа
  bool _isValidNumberInput(String value, String newDigit) {
    if (newDigit == '.') {
      return !value.contains('.');
    }

    final newValue = value + newDigit;
    
    // Проверка на максимальное значение
    if (value.contains('.')) {
      final parts = value.split('.');
      if (parts[0].length > 9) return false; // Максимум 9 цифр до точки
      if (parts.length > 1 && parts[1].length >= 2) return false; // Максимум 2 цифры после точки
    } else {
      if (newValue.length > 9) return false; // Максимум 9 цифр для целого числа
    }

    return true;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _selectedDate.hour,
        minute: _selectedDate.minute,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Верхняя панель
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Расход',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Сумма большими цифрами
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(width: 16), // Добавляем отступ слева
                          BlocBuilder<CurrencyBloc, CurrencyState>(
                            builder: (context, state) {
                              return Text(
                                state.currency.symbol,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Center(
                              child: Container(
                                constraints: const BoxConstraints(maxWidth: 280),
                                child: ValueListenableBuilder<TextEditingValue>(
                                  valueListenable: _amountController,
                                  builder: (context, value, child) {
                                    String displayText = value.text.isEmpty ? '0' : value.text;
                                    // Форматируем число с разделителями
                                    if (displayText != '0') {
                                      displayText = NumberFormat('#,###', 'ru').format(
                                        int.parse(displayText)
                                      );
                                    }
                                    return Text(
                                      displayText,
                                      style: TextStyle(
                                        fontSize: displayText.length > 8 ? 36 : 48,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16), // Добавляем отступ справа
                        ],
                      ),
                    ),

                    // Невидимое поле для ввода
                    Opacity(
                      opacity: 0,
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            if (newValue.text.isEmpty) return newValue;
                            if (!_isValidNumberInput(oldValue.text, newValue.text.substring(newValue.text.length - 1))) {
                              return oldValue;
                            }
                            return newValue;
                          }),
                        ],
                      ),
                    ),

                    // Поля ввода
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          // Заметка
                          TextField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              hintText: 'Добавить заметку',
                              border: UnderlineInputBorder(),
                              prefixIcon: Icon(Icons.edit_outlined),
                            ),
                            onTap: () {
                              setState(() {
                                _isNumericKeyboard = false;
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          // Категория
                          DropdownButtonFormField<ExpenseCategory>(
                            value: _category,
                            items: ExpenseCategory.values.map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Row(
                                children: [
                                  Icon(cat.icon, color: cat.color),
                                  const SizedBox(width: 12),
                                  Text(cat.displayName),
                                ],
                              ),
                            )).toList(),
                            onChanged: (value) => setState(() {
                              _category = value ?? ExpenseCategory.OTHER;
                            }),
                            decoration: const InputDecoration(
                              hintText: 'Категория',
                              border: UnderlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Дата
                          InkWell(
                            onTap: _pickDate,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined),
                                  const SizedBox(width: 12),
                                  Text(
                                    DateFormat('d MMMM y', 'ru').format(_selectedDate),
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  const Spacer(),
                                  InkWell(
                                    onTap: _pickTime,
                                    child: Row(
                                      children: [
                                        const Icon(Icons.access_time),
                                        const SizedBox(width: 8),
                                        Text(
                                          DateFormat('HH:mm').format(_selectedDate),
                                          style: Theme.of(context).textTheme.bodyLarge,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Клавиатура
            if (_isNumericKeyboard)
              Container(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                child: Column(
                  children: [
                    [7, 8, 9],
                    [4, 5, 6],
                    [1, 2, 3],
                    ['.', 0, 'C'],
                  ].map((row) => Row(
                    children: row.map((key) {
                      return Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              if (key == 'C') {
                                if (_amountController.text.isNotEmpty) {
                                  _amountController.text = _amountController.text.substring(0, _amountController.text.length - 1);
                                }
                              } else {
                                final newDigit = key.toString();
                                if (_isValidNumberInput(_amountController.text, newDigit)) {
                                  _amountController.text += newDigit;
                                }
                              }
                            });
                          },
                          child: Container(
                            height: 64,
                            alignment: Alignment.center,
                            child: key == 'C' 
                                ? const Icon(Icons.backspace_outlined)
                                : Text(
                                    key.toString(),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                        ),
                      );
                    }).toList(),
                  )).toList(),
                ),
              )
            else
              // Кнопка для возврата к цифровой клавиатуре
              Container(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isNumericKeyboard = true;
                    });
                  },
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calculate, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Вернуться к цифровой клавиатуре',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Кнопка подтверждения
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Добавить',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
