import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/section.dart';
import '../providers/section_provider.dart';

/// Экран создания/редактирования раздела
class _SectionTemplate {
  final String name;
  final String icon;
  final int color;

  const _SectionTemplate(this.name, this.icon, this.color);
}

class SectionFormScreen extends StatefulWidget {
  final String? sectionId;

  const SectionFormScreen({super.key, this.sectionId});

  @override
  State<SectionFormScreen> createState() => _SectionFormScreenState();
}

class _SectionFormScreenState extends State<SectionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String _selectedIcon = '📁';
  int _selectedColor = 0xFF2196F3; // Синий по умолчанию
  bool _isLoading = false;
  Section? _editingSection;

  // Доступные иконки
  static const _availableIcons = [
    '📁', '💰', '🍔', '🚗', '🏠', '💊', '🎓', '🎮',
    '✈️', '🛒', '💳', '📱', '⚡', '🎵', '🏃', '🎨',
  ];

  // Доступные цвета
  static const _availableColors = [
    0xFF2196F3, // Синий
    0xFFF44336, // Красный
    0xFF4CAF50, // Зелёный
    0xFFFF9800, // Оранжевый
    0xFF9C27B0, // Фиолетовый
    0xFF00BCD4, // Голубой
    0xFFFFEB3B, // Жёлтый
    0xFF795548, // Коричневый
    0xFF607D8B, // Серый
    0xFFE91E63, // Розовый
  ];

  static const _templates = [
    _SectionTemplate('Продукты', '🛒', 0xFF4CAF50),
    _SectionTemplate('Транспорт', '🚗', 0xFFFF9800),
    _SectionTemplate('Подписки', '📱', 0xFF9C27B0),
    _SectionTemplate('Здоровье', '💊', 0xFFF44336),
    _SectionTemplate('Жильё', '🏠', 0xFF2196F3),
  ];

  void _applyTemplate(_SectionTemplate template) {
    setState(() {
      _nameController.text = template.name;
      _selectedIcon = template.icon;
      _selectedColor = template.color;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.sectionId != null) {
      _loadSection();
    }
  }

  Future<void> _loadSection() async {
    final section = await context.read<SectionProvider>().getSectionById(widget.sectionId!);
    if (section != null) {
      setState(() {
        _editingSection = section;
        _nameController.text = section.name;
        _selectedIcon = section.icon;
        _selectedColor = section.color;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.sectionId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Редактировать раздел' : 'Новый раздел'),
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
                    if (!isEditing) ...[
                      const Text(
                        'Шаблоны',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _templates.map((template) {
                          return ActionChip(
                            avatar: Text(template.icon),
                            label: Text(template.name),
                            onPressed: () => _applyTemplate(template),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                    // Название
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Название раздела',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Введите название';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Выбор иконки
                    const Text(
                      'Иконка',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableIcons.map((icon) {
                        final isSelected = icon == _selectedIcon;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIcon = icon;
                            });
                          },
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                icon,
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Выбор цвета
                    const Text(
                      'Цвет',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableColors.map((color) {
                        final isSelected = color == _selectedColor;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Color(color),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.black
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),

                    // Кнопка сохранения
                    ElevatedButton(
                      onPressed: _saveSection,
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

  Future<void> _saveSection() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final section = Section(
        id: _editingSection?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        icon: _selectedIcon,
        color: _selectedColor,
        createdAt: _editingSection?.createdAt ?? now,
        updatedAt: now,
      );

      if (_editingSection != null) {
        await context.read<SectionProvider>().updateSection(section);
      } else {
        await context.read<SectionProvider>().createSection(section);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _editingSection != null
                  ? 'Раздел обновлён'
                  : 'Раздел создан',
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
