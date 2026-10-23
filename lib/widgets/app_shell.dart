import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/assignment_model.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Schedule',
          ),

          const NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Courses',
          ),

          NavigationDestination(
            icon: Consumer<AssignmentModel>(
              builder: (context, model, child) {
                return Badge(
                  isLabelVisible: model.count > 0,
                  label: Text('${model.count}'),
                  child: child,
                );
              },
              child: const Icon(Icons.assignment_outlined),
            ),
            selectedIcon: Consumer<AssignmentModel>(
              builder: (context, model, child) {
                return Badge(
                  isLabelVisible: model.count > 0,
                  label: Text('${model.count}'),
                  child: child,
                );
              },
              child: const Icon(Icons.assignment),
            ),
            label: 'Assignments',
          ),

          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
