import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/amount_utils.dart';
import '../../domain/entities/entry.dart';
import '../../domain/entities/unit.dart';
import '../providers/entry_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/unit_provider.dart';

/// Экран создания/редактирования записи
class EntryFormScreen extends StatefulWidget {
  final String sectionId;
  final String? entryId;

  const EntryFormScreen({
    super.key,
    required this.sectionId,
    this.entryId,
  });

  @override
  State<EntryFormScreen> createState() => _EntryFormScreenState();
}

class _EntryFormScreenState extends State<EntryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  ValueType _valueType = ValueType.money;
  int? _selectedUnitId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  Entry? _editingEntry;

  @override
  void initState() {
    super.initState();
    if (widget.entryId != null) {
      _loadEntry();
    } else {
      // Выбрать первую валюту по умолчанию для новой записи
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final defaultId = _defaultCurrencyId();
        if (defaultId != null) {
          setState(() {
            _selectedUnitId = defaultId;
          });
        }
      });
    }
  }

  /// Id валюты по умолчанию из настроек (если такой нет — первая в списке).
  int? _defaultCurrencyId() {
    final currencies = context.read<UnitProvider>().currencies;
    if (currencies.isEmpty) return null;
    final code = context.read<SettingsProvider>().defaultCurrencyCode;
    for (final c in currencies) {
      if (c.code == code) return c.id;
    }
    return currencies.first.id;
  }

  Future<void> _loadEntry() async {
    final entry = await context.read<EntryProvider>().getEntryById(widget.entryId!);
    if (entry != null) {
      setState(() {
        _editingEntry = entry;
        _descriptionController.text = entry.description;
        _amountController.text =
            AmountUtils.formatNumber(entry.amount, entry.valueType);
        _noteController.text = entry.note ?? '';
        _valueType = entry.valueType;
        _selectedUnitId = entry.unitId;
        _selectedDate = entry.occurredAt;
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.entryId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Редактировать запись' : 'Новая запись'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Описание
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Описание',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Введите описание';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Тип значения
                    const Text(
                      'Тип',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<ValueType>(
                      segments: const [
                        ButtonSegment(
                          value: ValueType.money,
                          label: Text('Деньги'),
                          icon: Icon(Icons.attach_money),
                        ),
                        ButtonSegment(
                          value: ValueType.quantity,
                          label: Text('Количество'),
                          icon: Icon(Icons.numbers),
                        ),
                      ],
                      selected: {_valueType},
                      onSelectionChanged: (Set<ValueType> newSelection) {
                        setState(() {
                          _valueType = newSelection.first;
                          _selectedUnitId = _valueType == ValueType.money
                              ? _defaultCurrencyId()
                              : null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Единица измерения
                    Consumer<UnitProvider>(
                      builder: (context, provider, child) {
                        final units = _valueType == ValueType.money
                            ? provider.currencies
                            : provider.countUnits;

                        if (units.isEmpty) {
                          return const Text('Нет доступных единиц');
                        }

                        return DropdownButtonFormField<int>(
                          value: _selectedUnitId,
                          decoration: const InputDecoration(
                            labelText: 'Единица измерения',
                            border: OutlineInputBorder(),
                          ),
                          items: units.map((unit) {
                            return DropdownMenuItem<int>(
                              value: unit.id,
                              child: Text('${unit.code} (${unit.displayName})'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedUnitId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Выберите единицу измерения';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Сумма
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: _valueType == ValueType.money
                            ? 'Сумма'
                            : 'Количество',
                        border: const OutlineInputBorder(),
                        helperText: _valueType == ValueType.money
                            ? 'Например: 123.45'
                            : 'Например: 12.5 (до 3 знаков)',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(
                            _valueType == ValueType.money
                                ? r'^\d+\.?\d{0,2}'
                                : r'^\d+\.?\d{0,3}',
                          ),
                        ),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Введите значение';
                        }
                        final number = double.tryParse(value);
                        if (number == null || number <= 0) {
                          return 'Введите корректное значение';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Дата
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Дата'),
                      subtitle: Text(
                        '${_selectedDate.day.toString().padLeft(2, '0')}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year} ${_selectedDate.hour.toString().padLeft(2, '0')}:${_selectedDate.minute.toString().padLeft(2, '0')}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _selectDateTime,
                    ),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Заметка (необязательно)
                    TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'Заметка (необязательно)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // Кнопка сохранения
                    ElevatedButton(
                      onPressed: _saveEntry,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        isEditing ? 'Сохранить' : 'Создать',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedUnitId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выберите единицу измерения'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text);
      final amountInMinorUnits = AmountUtils.toStored(amount, _valueType);
      final now = DateTime.now();

      final entry = Entry(
        id: _editingEntry?.id ?? const Uuid().v4(),
        sectionId: widget.sectionId,
        description: _descriptionController.text.trim(),
        valueType: _valueType,
        amount: amountInMinorUnits,
        unitId: _selectedUnitId!,
        occurredAt: _selectedDate,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        createdAt: _editingEntry?.createdAt ?? now,
        updatedAt: now,
      );

      if (_editingEntry != null) {
        await context.read<EntryProvider>().updateEntry(entry);
      } else {
        await context.read<EntryProvider>().createEntry(entry);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _editingEntry != null ? 'Запись обновлена' : 'Запись создана',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
