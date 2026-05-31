import 'package:financial_tracker/common/theme/app_theme.dart';
import 'package:financial_tracker/common/types/date_filter_type.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFilterTransactions extends StatefulWidget {
  final Function(DateTime? startDate, DateTime? endDate) onFilterChanged;
  final Function() onAllTransactionsFiltered;
  final Function(DateFilterType type, DateTime? startDate, DateTime? endDate) onUpdateFilter;
  final VoidCallback? onTapHideFilter;
  final ({DateFilterType type, DateTime? startDate, DateTime? endDate}) filtro;

  const DateFilterTransactions({
    super.key,
    required this.onFilterChanged,
    required this.filtro,
    this.onTapHideFilter,
    required this.onAllTransactionsFiltered,
    required this.onUpdateFilter,
  });

  @override
  State<DateFilterTransactions> createState() => _DateFilterWidgetState();
}

class _DateFilterWidgetState extends State<DateFilterTransactions> {
  late DateFilterType _filterType;
  DateTime? _startDate;
  DateTime? _endDate;

  static const _labels = {
    DateFilterType.all: 'Tudo',
    DateFilterType.today: 'Hoje',
    DateFilterType.week: 'Esta Semana',
    DateFilterType.month: 'Este Mês',
    DateFilterType.custom: 'Personalizado',
  };

  @override
  void initState() {
    super.initState();
    _filterType = widget.filtro.type;
    _startDate = widget.filtro.startDate;
    _endDate = widget.filtro.endDate;
    _initializeDates();
  }

  void _initializeDates() {
    final now = DateTime.now();
    final range = _filterType.resolveRange(now, _startDate, _endDate);
    setState(() {
      _startDate = range?.start;
      _endDate = range?.end;
    });
  }

  void _applyFilter(DateFilterType type) {
    setState(() {
      _filterType = type;
      _initializeDates();
    });
    if (type == DateFilterType.all) {
      widget.onAllTransactionsFiltered();
    } else {
      widget.onFilterChanged(_startDate, _endDate);
    }
    widget.onUpdateFilter(_filterType, _startDate, _endDate);
  }

  Future<void> _selectCustomDateRange() async {
    final now = DateTime.now();
    final maxDate = now.add(const Duration(days: 1));
    final safeRange = _filterType
        .resolveRange(now, _startDate, _endDate)
        ?.cappedAt(maxDate);

    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: safeRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.blue700,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _filterType = DateFilterType.custom;
        _startDate = picked.start;
        _endDate = DateTime(
            picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);
      });
      widget.onFilterChanged(_startDate, _endDate);
      widget.onUpdateFilter(_filterType, _startDate, _endDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2D40) : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF2A3A50) : AppColors.grey200,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Icon(Icons.tune_rounded,
                    size: 16, color: AppColors.blue700),
                const SizedBox(width: 8),
                Text(
                  'Filtro de Data',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.white : AppColors.grey800,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: widget.onTapHideFilter,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF243347) : AppColors.grey100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(Icons.close_rounded,
                        size: 14,
                        color: isDark ? AppColors.grey400 : AppColors.grey600),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Filter chips
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: DateFilterType.values.map((type) {
                final isSelected = _filterType == type;
                return GestureDetector(
                  onTap: () {
                    if (type == DateFilterType.custom) {
                      _selectCustomDateRange();
                    } else {
                      _applyFilter(type);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.blue700
                          : (isDark ? const Color(0xFF243347) : AppColors.grey100),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.blue700
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _labels[type] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.grey400 : AppColors.grey600),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            // Custom date range display
            if (_filterType == DateFilterType.custom && _startDate != null && _endDate != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _selectCustomDateRange,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.blue50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.blue200, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.date_range_rounded,
                          size: 14, color: AppColors.blue700),
                      const SizedBox(width: 8),
                      Text(
                        '${DateFormat('dd/MM/yyyy').format(_startDate!)} → ${DateFormat('dd/MM/yyyy').format(_endDate!)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.blue700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.edit_rounded,
                          size: 12, color: AppColors.blue700),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}