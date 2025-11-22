import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:atlas_dashboard/models/telemetry_models.dart';

// --- Events ---
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object> get props => [];
}

class LoadDashboardData extends DashboardEvent {}

class SelectClient extends DashboardEvent {
  final String clientId;
  const SelectClient(this.clientId);
  @override
  List<Object> get props => [clientId];
}

class SelectDevice extends DashboardEvent {
  final String deviceId;
  const SelectDevice(this.deviceId);
  @override
  List<Object> get props => [deviceId];
}

class DeleteAllSnapshots extends DashboardEvent {}


// --- States ---
abstract class DashboardState extends Equatable {
  const DashboardState();
}

class DashboardLoading extends DashboardState {
  @override
  List<Object?> get props => [];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
  @override
  List<Object> get props => [message];
}

class DashboardLoaded extends DashboardState {
  final DashboardData data;
  final String selectedClientId;
  final String selectedDeviceId;

  const DashboardLoaded({
    required this.data,
    required this.selectedClientId,
    required this.selectedDeviceId,
  });

  DeviceData? get selectedDevice {
    return data.clients[selectedClientId]?.devices[selectedDeviceId];
  }

  TelemetrySnapshot? get latestSnapshot {
    return selectedDevice?.latestSnapshot;
  }

  @override
  List<Object?> get props => [data, selectedClientId, selectedDeviceId];
}

// --- Bloc ---
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  Stream<DatabaseEvent>? _dataStream;

  DashboardBloc() : super(DashboardLoading()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<SelectClient>(_onSelectClient);
    on<SelectDevice>(_onSelectDevice);
    on<DeleteAllSnapshots>(_onDeleteAllSnapshots);
  }

  Future<void> _onLoadDashboardData(
      LoadDashboardData event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    _dataStream = _dbRef.onValue;

    await emit.onEach(_dataStream!, onData: (event) {
      try {
        final data = event.snapshot.value;
        if (data != null && data is Map) {

          final Map<String, dynamic> rawMap = {};
          (data as Map).forEach((key, value) {
            if (key is String) {
              rawMap[key] = value;
            }
          });

          final dashboardData = DashboardData.fromJson(rawMap);

          if (dashboardData.clients.isEmpty) {
            emit(const DashboardError("No client data found."));
            return;
          }

          // --- Auto-Selection Logic ---
          String selectedClientId = state is DashboardLoaded
              ? (state as DashboardLoaded).selectedClientId
              : dashboardData.clients.keys.first;

          if (!dashboardData.clients.containsKey(selectedClientId)) {
            selectedClientId = dashboardData.clients.keys.first;
          }

          final client = dashboardData.clients[selectedClientId]!;
          if (client.devices.isEmpty) {
            emit(DashboardError("Client '$selectedClientId' has no devices."));
            return;
          }

          String selectedDeviceId = state is DashboardLoaded
              ? (state as DashboardLoaded).selectedDeviceId
              : client.devices.keys.first;

          if (!client.devices.containsKey(selectedDeviceId)) {
            selectedDeviceId = client.devices.keys.first;
          }
          // --- End Auto-Selection ---

          emit(DashboardLoaded(
            data: dashboardData,
            selectedClientId: selectedClientId,
            selectedDeviceId: selectedDeviceId,
          ));
        } else {
          emit(const DashboardError('No data found in Firebase.'));
        }
      } catch (e, stack) {
        if (kDebugMode) {
          print('Error processing data: $e \n$stack');
        }
        emit(DashboardError('Failed to parse data: $e'));
      }
    });
  }

  void _onSelectClient(SelectClient event, Emitter<DashboardState> emit) {
    if (state is DashboardLoaded) {
      final loadedState = state as DashboardLoaded;
      final newClient = loadedState.data.clients[event.clientId];

      if (newClient != null && newClient.devices.isNotEmpty) {
        // Auto-select the first device of the new client
        final newDeviceId = newClient.devices.keys.first;
        emit(DashboardLoaded(
          data: loadedState.data,
          selectedClientId: event.clientId,
          selectedDeviceId: newDeviceId,
        ));
      }
    }
  }

  void _onSelectDevice(SelectDevice event, Emitter<DashboardState> emit) {
    if (state is DashboardLoaded) {
      final loadedState = state as DashboardLoaded;
      emit(DashboardLoaded(
        data: loadedState.data,
        selectedClientId: loadedState.selectedClientId,
        selectedDeviceId: event.deviceId,
      ));
    }
  }

  Future<void> _onDeleteAllSnapshots(
      DeleteAllSnapshots event, Emitter<DashboardState> emit) async {
    if (state is DashboardLoaded) {
      final loadedState = state as DashboardLoaded;
      final devicePath = 'clients/${loadedState.selectedClientId}/devices/${loadedState.selectedDeviceId}/snapshots';
      try {
        await _dbRef.child(devicePath).remove();
      } catch (e) {
        emit(DashboardError("Failed to delete snapshots: $e"));
      }
    }
  }
}
