import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterChipsWidget extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const FilterChipsWidget({
    Key? key,
    required this.selectedFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'key': 'all', 'label': 'الكل', 'icon': 'apps'},
      {'key': 'voice', 'label': 'صوت فقط', 'icon': 'mic'},
      {'key': 'video', 'label': 'فيديو', 'icon': 'videocam'},
      {'key': 'my_rooms', 'label': 'غرفي', 'icon': 'person'},
    ];

    return Container(
      height: 6.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter['key'];

          return Container(
            margin: EdgeInsets.only(right: 2.w),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: filter['icon'] as String,
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.onPrimary
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    filter['label'] as String,
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.onPrimary
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
              selectedColor: AppTheme.lightTheme.primaryColor,
              backgroundColor: AppTheme.lightTheme.colorScheme.surface,
              side: BorderSide(
                color: isSelected
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.outline,
                width: 1,
              ),
              onSelected: (selected) {
                if (selected) {
                  onFilterChanged(filter['key'] as String);
                }
              },
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }
}
