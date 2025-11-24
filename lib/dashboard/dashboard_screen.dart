import 'package:atlas_dashboard/screens/pages/UsbPage.dart';
import 'package:atlas_dashboard/screens/pages/settings_page.dart';
import 'package:atlas_dashboard/widgets/dashboard/live_status_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:atlas_dashboard/bloc/dashboard_bloc.dart';
import 'package:atlas_dashboard/widgets/shared/glass_navigation_rail.dart';

// Import all the pages
import 'package:atlas_dashboard/screens/pages/overview_page.dart';
import 'package:atlas_dashboard/screens/pages/system_page.dart';
import 'package:atlas_dashboard/screens/pages/network_page.dart';
import 'package:atlas_dashboard/screens/pages/connectivity_page.dart';
import 'package:atlas_dashboard/screens/pages/hardware_page.dart';
import 'package:atlas_dashboard/screens/pages/apps_page.dart';
import 'package:atlas_dashboard/screens/pages/sensors_page.dart';
import 'package:atlas_dashboard/screens/pages/codecs_page.dart';
import 'package:atlas_dashboard/screens/pages/permissions_page.dart';
import 'package:atlas_dashboard/screens/pages/location_page.dart';
import 'package:atlas_dashboard/screens/pages/client_page.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DashboardError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Error: ${state.message}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            );
          }
          if (state is DashboardLoaded) {
            final device = state.selectedDevice;
            final snapshot = state.latestSnapshot;

            if (device == null || snapshot == null) {
              return const Center(child: Text("No device data available."));
            }

            final List<Widget> pages = [
              OverviewPage(device: device),
              SystemPage(device: device),
              NetworkPage(device: device),
              ConnectivityPage(snapshot: snapshot),
              HardwarePage(snapshot: snapshot),
              LocationPage(device: device),
              AppsPage(snapshot: snapshot),
              SensorsPage(device: device),
              CodecsPage(snapshot: snapshot),
              PermissionsPage(snapshot: snapshot),
              UsbPage(device: device),
              ClientPage(snapshot: snapshot),
              const SettingsPage(),
            ];

            int? railIndex;
            if (_pageIndex < 12) {
              railIndex = _pageIndex;
            }

            return SafeArea(
              child: Row(
                children: [
                  GlassNavigationRail(
                    selectedIndex: railIndex,
                    onDestinationSelected: (index) {
                      setState(() {
                        _pageIndex = index;
                      });
                    },
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        LiveStatusHeader(
                          state: state,
                          onSettingsTap: () {
                            setState(() {
                              _pageIndex = pages.length - 1;
                            });
                          },
                        ),
                        Expanded(
                          child: IndexedStack(
                            index: _pageIndex,
                            children: pages,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text("Unknown state."));
        },
      ),
    );
  }
}
