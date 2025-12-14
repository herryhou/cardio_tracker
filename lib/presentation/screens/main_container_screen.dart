import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/blood_pressure_provider.dart';
import '../providers/dual_chart_provider.dart';
import 'dashboard_content.dart';
import 'statistics_screen.dart';
import 'enhanced_settings_screen.dart';
import 'csv_editor_screen.dart';
import '../../widgets/app_actions/sync_status_indicator.dart';
import '../../widgets/app_actions/app_bar_export_button.dart';
import '../../widgets/settings/settings_sections.dart';

class MainContainerScreen extends StatefulWidget {
  const MainContainerScreen({super.key});

  @override
  State<MainContainerScreen> createState() => _MainContainerScreenState();
}

class _MainContainerScreenState extends State<MainContainerScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardContent(),
    const StatisticsScreen(),
    const EnhancedSettingsScreen(),
  ];

  final List<NavigationDestination> _destinations = [
    const NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    const NavigationDestination(
      icon: Icon(Icons.analytics_outlined),
      selectedIcon: Icon(Icons.analytics),
      label: 'Statistics',
    ),
    const NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Load readings when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BloodPressureProvider>().loadReadings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              title: const Text('Cardio Tracker'),
              elevation: 0,
              backgroundColor: Theme.of(context).colorScheme.surface,
              actions: const [
                SyncStatusIndicator(),
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: AppBarExportButton(),
                ),
              ],
            )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Only wrap the dashboard content with DualChartProvider
          _currentIndex == 0
              ? ChangeNotifierProvider(
                  create: (context) => DualChartProvider(),
                  child: const DashboardContent(),
                )
              : const SizedBox.shrink(),
          const StatisticsScreen(),
          const EnhancedSettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: _destinations,
        animationDuration: const Duration(milliseconds: 300),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => SettingsSections.showAddReading(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Reading'),
              elevation: 8,
            )
          : null,
    );
  }
}

// Enhanced Dashboard that can be embedded in the container
class EmbeddedDashboardScreen extends StatelessWidget {
  const EmbeddedDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Return the dashboard content without the AppBar
    return Consumer<BloodPressureProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return _buildErrorState(context, provider.error!);
        }

        return const DashboardContent();
      },
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load data',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.read<BloodPressureProvider>().loadReadings(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}