import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/date_utils.dart';
import '../../domain/usecases/money_aggregation_service.dart';
import '../../domain/usecases/quantity_aggregation_service.dart';
import '../providers/statistics_provider.dart';

/// Экран статистики с агрегацией данных
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<StatisticsProvider>().refreshData();
            },
          ),
        ],
      ),
      body: Consumer<StatisticsProvider>(
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
                    onPressed: () => provider.refreshData(),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Фильтр периода
                _PeriodFilter(),
                const SizedBox(height: 24),

                // Информация о периоде
                _PeriodInfo(),
                const SizedBox(height: 24),

                // Денежная статистика
                if (provider.moneyAggregations.isNotEmpty) ...[
                  _SectionTitle(
                    title: 'Деньги',
                    icon: Icons.attach_money,
                  ),
                  const SizedBox(height: 12),
                  ...provider.moneyAggregations.map((agg) => _MoneyCard(agg)),
                  const SizedBox(height: 24),
                ],

                // Количественная статистика
                if (provider.quantityAggregations.isNotEmpty) ...[
                  _SectionTitle(
                    title: 'Количества',
                    icon: Icons.numbers,
                  ),
                  const SizedBox(height: 12),
                  ...provider.quantityAggregations.map((agg) => _QuantityCard(agg)),
                  const SizedBox(height: 24),
                ],

                // Если нет данных
                if (provider.moneyAggregations.isEmpty &&
                    provider.quantityAggregations.isEmpty) ...[
                  Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.analytics_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Нет данных за выбранный период',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${provider.entriesCount} записей',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Фильтр выбора периода
class _PeriodFilter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StatisticsProvider>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Период',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _PeriodChip(
                  label: 'День',
                  period: PeriodType.day,
                  isSelected: provider.selectedPeriod == PeriodType.day,
                ),
                _PeriodChip(
                  label: 'Неделя',
                  period: PeriodType.week,
                  isSelected: provider.selectedPeriod == PeriodType.week,
                ),
                _PeriodChip(
                  label: 'Месяц',
                  period: PeriodType.month,
                  isSelected: provider.selectedPeriod == PeriodType.month,
                ),
                _PeriodChip(
                  label: 'Год',
                  period: PeriodType.year,
                  isSelected: provider.selectedPeriod == PeriodType.year,
                ),
                _PeriodChip(
                  label: 'Всё время',
                  period: PeriodType.all,
                  isSelected: provider.selectedPeriod == PeriodType.all,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Чип для выбора периода
class _PeriodChip extends StatelessWidget {
  final String label;
  final PeriodType period;
  final bool isSelected;

  const _PeriodChip({
    required this.label,
    required this.period,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          context.read<StatisticsProvider>().setPeriod(period);
        }
      },
    );
  }
}

/// Информация о текущем периоде
class _PeriodInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StatisticsProvider>();
    final range = DateTimeUtils.getPeriodRange(
      provider.selectedDate,
      provider.selectedPeriod,
    );

    String periodText;
    if (provider.selectedPeriod == PeriodType.all) {
      periodText = 'Всё время';
    } else {
      periodText =
          '${DateTimeUtils.formatDate(range.start)} — ${DateTimeUtils.formatDate(range.end)}';
    }

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    periodText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${provider.entriesCount} записей',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Заголовок секции
class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Карточка денежной агрегации
class _MoneyCard extends StatelessWidget {
  final MoneyAggregation aggregation;

  const _MoneyCard(this.aggregation);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  aggregation.displayName,
                  style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    aggregation.unitCode,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${aggregation.amountInMainUnits.toStringAsFixed(2)} ${aggregation.displayName}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Карточка количественной агрегации
class _QuantityCard extends StatelessWidget {
  final QuantityAggregation aggregation;

  const _QuantityCard(this.aggregation);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  aggregation.displayName,
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    aggregation.unitCode,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    aggregation.formatted,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
