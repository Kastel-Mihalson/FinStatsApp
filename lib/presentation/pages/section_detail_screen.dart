import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/enums/sort_type.dart';
import '../../core/utils/amount_utils.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/entities/entry.dart';
import '../../domain/entities/unit.dart';
import '../../domain/usecases/money_aggregation_service.dart';
import '../../domain/usecases/quantity_aggregation_service.dart';
import '../providers/entry_provider.dart';
import '../providers/section_provider.dart';
import '../providers/unit_provider.dart';
import 'entry_form_screen.dart';

/// Экран деталей раздела: период, итоги, сортировка и список записей
class SectionDetailScreen extends StatefulWidget {
  final String sectionId;

  const SectionDetailScreen({
    super.key,
    required this.sectionId,
  });

  @override
  State<SectionDetailScreen> createState() => _SectionDetailScreenState();
}

class _SectionDetailScreenState extends State<SectionDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EntryProvider>().openSection(widget.sectionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder(
          future: context.read<SectionProvider>().getSectionById(widget.sectionId),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return Text(snapshot.data!.name);
            }
            return const Text('Раздел');
          },
        ),
        actions: [
          Consumer<EntryProvider>(
            builder: (context, provider, child) {
              return PopupMenuButton<SortType>(
                icon: const Icon(Icons.sort),
                tooltip: 'Сортировка',
                initialValue: provider.sort,
                onSelected: provider.setSort,
                itemBuilder: (context) => [
                  for (final type in SortType.values)
                    PopupMenuItem<SortType>(
                      value: type,
                      child: Text(type.displayName),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const _PeriodBar(),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EntryFormScreen(
                sectionId: widget.sectionId,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<EntryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.refreshEntries(),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          if (provider.entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    provider.period == PeriodType.all
                        ? 'Нет записей'
                        : 'Нет записей за период',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.period == PeriodType.all
                        ? 'Добавьте первую запись'
                        : 'Выберите другой период или добавьте запись',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              _TotalsCard(
                entries: provider.entries,
                units: context.watch<UnitProvider>().units,
              ),
              Expanded(child: _buildList(provider)),
            ],
          );
        },
      );
  }

  Widget _buildList(EntryProvider provider) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.entries.length,
            itemBuilder: (context, index) {
              final entry = provider.entries[index];
              final unit = context.read<UnitProvider>().getUnitById(entry.unitId);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    entry.description,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        DateTimeUtils.formatDate(
                          entry.occurredAt,
                          format: 'dd.MM.yyyy HH:mm',
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (entry.note != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          entry.note!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ],
                  ),
                  trailing: Text(
                    _formatAmount(entry, unit?.displayName ?? ''),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EntryFormScreen(
                          sectionId: widget.sectionId,
                          entryId: entry.id,
                        ),
                      ),
                    );
                  },
                  onLongPress: () {
                    _showEntryOptions(context, entry.id);
                  },
                ),
              );
            },
          );
  }

  String _formatAmount(Entry entry, String unitDisplayName) {
    return '${AmountUtils.formatNumber(entry.amount, entry.valueType)} $unitDisplayName';
  }

  void _showEntryOptions(BuildContext context, String entryId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Редактировать'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EntryFormScreen(
                        sectionId: widget.sectionId,
                        entryId: entryId,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Удалить',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, entryId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, String entryId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Удалить запись?'),
          content: const Text('Это действие нельзя отменить.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await context.read<EntryProvider>().deleteEntry(entryId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Запись удалена')),
                  );
                }
              },
              child: const Text(
                'Удалить',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Панель выбора периода: чипы «День / Неделя / Месяц / Год / Всё»
/// и стрелки перехода к предыдущему/следующему периоду.
class _PeriodBar extends StatelessWidget {
  const _PeriodBar();

  static const _labels = <PeriodType, String>{
    PeriodType.day: 'День',
    PeriodType.week: 'Неделя',
    PeriodType.month: 'Месяц',
    PeriodType.year: 'Год',
    PeriodType.all: 'Всё',
  };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EntryProvider>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final entry in _labels.entries)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(entry.value),
                      selected: provider.period == entry.key,
                      onSelected: (_) => provider.setPeriod(entry.key),
                    ),
                  ),
              ],
            ),
          ),
          if (provider.canNavigatePeriod)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Предыдущий период',
                  onPressed: provider.previousPeriod,
                ),
                Text(
                  provider.periodLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  tooltip: 'Следующий период',
                  onPressed: provider.nextPeriod,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Итоги раздела за выбранный период: деньги — по валютам,
/// количества — по единицам измерения.
class _TotalsCard extends StatelessWidget {
  final List<Entry> entries;
  final List<Unit> units;

  const _TotalsCard({required this.entries, required this.units});

  @override
  Widget build(BuildContext context) {
    final money = MoneyAggregationService.getAggregationsList(
      entries: entries,
      units: units,
    );
    final quantities = QuantityAggregationService.getAggregationsList(
      entries: entries,
      units: units,
    );

    final lines = <String>[
      for (final m in money)
        '${m.amountInMainUnits.toStringAsFixed(2)} ${m.displayName}',
      for (final q in quantities) q.formatted,
    ];
    if (lines.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Итого · записей: ${entries.length}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                for (final line in lines)
                  Text(
                    line,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
