import 'package:fintrack/features/category/blocs/category_bloc.dart';
import 'package:fintrack/features/category/blocs/category_event.dart';
import 'package:fintrack/features/category/blocs/category_state.dart';
import 'package:fintrack/features/transaction/blocs/transaction_bloc.dart';
import 'package:fintrack/features/transaction/blocs/transaction_event.dart';
import 'package:fintrack/features/category/models/transaction_category.dart';
import 'package:fintrack/features/transaction/models/transaction_type.dart';
import 'package:fintrack/features/transaction/models/transaction_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../blocs/transaction_state.dart';
import '../models/transaction_response.dart';

class TransactionFormScreen extends StatefulWidget {
  final TransactionResponseDto? transaction;
  final TransactionType type;

  const TransactionFormScreen(
      {super.key, this.transaction, this.type = TransactionType.EXPENSE});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  TransactionCategory? _selectedCategory;
  TransactionType _currentType = TransactionType.EXPENSE;

  @override
  void initState() {
    super.initState();
    _currentType = widget.type;
    _amountController = TextEditingController(
        text: widget.transaction?.amount.toStringAsFixed(0) ?? '');
    _descriptionController =
        TextEditingController(text: widget.transaction?.comment ?? '');
    _selectedDate = widget.transaction?.date ?? DateTime.now();
    _selectedCategory = null;
    _loadCategories();
  }

  void _loadCategories() {
    context.read<CategoryBloc>().add(LoadCategories(_currentType));
  }

  void _onTypeChanged(TransactionType? newType) {
    if (newType == null) return;
    setState(() {
      _currentType = newType;
      _selectedCategory = null;
      _loadCategories();
    });
  }

  void _submit() {
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null || amount > 999999999 || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Введите корректную сумму и выберите категорию')),
      );
      return;
    }

    final dto = TransactionRequestDto(
      id: widget.transaction?.id,
      amount: amount,
      date: _selectedDate,
      comment: _descriptionController.text.trim(),
      type: _currentType,
      categoryId: _selectedCategory!.id,
    );

    context.read<TransactionBloc>().add(AddTransaction(dto));
    Navigator.of(context).pop(dto);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _selectedDate = DateTime(picked.year, picked.month,
          picked.day, _selectedDate.hour, _selectedDate.minute));
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );
    if (picked != null) {
      setState(() => _selectedDate = DateTime(_selectedDate.year,
          _selectedDate.month, _selectedDate.day, picked.hour, picked.minute));
    }
  }

  Widget _buildFormContent(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text('Транзакция',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<TransactionType>(
                      value: _currentType,
                      onChanged: _onTypeChanged,
                      items: TransactionType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child:
                              Text(type.name == 'INCOME' ? 'Доход' : 'Расход'),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Text('₸', style: Theme.of(context).textTheme.headlineSmall),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _amountController,
                      builder: (context, value, _) {
                        final display = value.text.isEmpty
                            ? '0'
                            : NumberFormat('#,###', 'ru')
                                .format(int.parse(value.text));
                        return Text(
                          display,
                          style: TextStyle(
                              fontSize: display.length > 8 ? 36 : 48,
                              fontWeight: FontWeight.w500),
                        );
                      },
                    ),
                    Opacity(
                      opacity: 0,
                      child: TextField(controller: _amountController),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        hintText: 'Добавить заметку',
                        prefixIcon: Icon(Icons.edit_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    BlocBuilder<CategoryBloc, CategoryState>(
                      builder: (context, state) {
                        if (state is CategoryLoading) {
                          return const CircularProgressIndicator();
                        }
                        if (state is CategoryLoaded) {
                          final categories = state.categories;
                          final lastUsed = categories.take(4).toList();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                children: lastUsed.map((cat) {
                                  return ChoiceChip(
                                    label: Text(cat.displayName('ru')),
                                    avatar: Icon(cat.iconData,
                                        color: cat.colorValue),
                                    selected: _selectedCategory?.id == cat.id,
                                    onSelected: (_) =>
                                        setState(() => _selectedCategory = cat),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<TransactionCategory>(
                                value: _selectedCategory,
                                hint: const Text('Выбрать категорию'),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                ),
                                items: categories.map((cat) {
                                  return DropdownMenuItem(
                                    value: cat,
                                    child: Row(
                                      children: [
                                        Icon(cat.iconData,
                                            color: cat.colorValue),
                                        const SizedBox(width: 8),
                                        Text(cat.displayName('ru')),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) =>
                                    setState(() => _selectedCategory = val),
                              ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _pickDate,
                      child: Row(children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 8),
                        Text(
                            DateFormat('d MMMM y', 'ru').format(_selectedDate)),
                        const Spacer(),
                        InkWell(
                          onTap: _pickTime,
                          child: Row(children: [
                            const Icon(Icons.access_time),
                            const SizedBox(width: 8),
                            Text(DateFormat('HH:mm').format(_selectedDate)),
                          ]),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: Theme.of(context).colorScheme.surfaceVariant,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  for (var row in [
                    ["7", "8", "9"],
                    ["4", "5", "6"],
                    ["1", "2", "3"],
                    [".", "0", "C"],
                  ])
                    Row(
                      children: row
                          .map((key) => Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (key == 'C') {
                                        final text = _amountController.text;
                                        if (text.isNotEmpty) {
                                          _amountController.text = text
                                              .substring(0, text.length - 1);
                                        }
                                      } else {
                                        _amountController.text += key;
                                      }
                                    });
                                  },
                                  child: Container(
                                    height: 64,
                                    alignment: Alignment.center,
                                    child: key == 'C'
                                        ? const Icon(Icons.backspace_outlined)
                                        : Text(key,
                                            style: const TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w500)),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Добавить', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is TransactionSuccess) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: SafeArea(child: _buildFormContent(context)),
      ),
    );
  }
}
