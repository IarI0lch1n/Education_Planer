import 'package:flutter/material.dart';

class EduPlanDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const EduPlanDrawer({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      backgroundColor: colorScheme.primary,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: colorScheme.onPrimary,
                    child: Icon(
                      Icons.school_outlined,
                      size: 34,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'EduPlan',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Iolchin I.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'TI-236 · FCIM',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: colorScheme.onPrimary.withValues(alpha: 0.25),
              height: 1,
            ),
            const SizedBox(height: 8),
            _DrawerItem(
              icon: Icons.calendar_month_outlined,
              label: 'Schedule',
              selected: selectedIndex == 0,
              onTap: () => onDestinationSelected(0),
            ),
            _DrawerItem(
              icon: Icons.menu_book_outlined,
              label: 'Courses',
              selected: selectedIndex == 1,
              onTap: () => onDestinationSelected(1),
            ),
            _DrawerItem(
              icon: Icons.assignment_outlined,
              label: 'Tasks',
              selected: selectedIndex == 2,
              onTap: () => onDestinationSelected(2),
            ),
            _DrawerItem(
              icon: Icons.person_outline,
              label: 'Profile',
              selected: selectedIndex == 3,
              onTap: () => onDestinationSelected(3),
            ),
            const Spacer(),
            Divider(
              color: colorScheme.onPrimary.withValues(alpha: 0.25),
              height: 1,
            ),
            _DrawerItem(
              icon: Icons.logout,
              label: 'Exit',
              selected: false,
              onTap: () => onDestinationSelected(4),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 2,
      ),
      child: ListTile(
        selected: selected,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        selectedTileColor: colorScheme.onPrimary.withValues(alpha: 0.16),
        leading: Icon(
          icon,
          color: colorScheme.onPrimary,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}