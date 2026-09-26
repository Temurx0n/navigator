import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:navigator_app/core/data/repositories/route_repository.dart';
import 'package:navigator_app/features/map/bloc/map_bloc.dart';
import 'package:navigator_app/features/map/bloc/map_event.dart';
import 'package:navigator_app/services/location_service.dart';
import 'package:navigator_app/services/notification_service.dart';

class MockLocationService extends Mock
    implements LocationService {}

class MockRouteRepository extends Mock
    implements RouteRepository {}

class MockNotificationService extends Mock
    implements NotificationService {}

class MockConnectivity extends Mock
    implements Connectivity {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockLocationService locationService;
  late MockRouteRepository routeRepository;
  late MockNotificationService notificationService;
  late MockConnectivity connectivity;

  setUp(() {
    locationService = MockLocationService();
    routeRepository = MockRouteRepository();
    notificationService = MockNotificationService();
    connectivity = MockConnectivity();

    when(
          () => connectivity.onConnectivityChanged,
    ).thenAnswer(
          (_) => const Stream<List<ConnectivityResult>>.empty(),
    );
  });

  test(
    'MapStarted location service ishlamasa loading tugaydi',
        () async {
      when(
            () => locationService.isLocationServiceEnabled(),
      ).thenAnswer(
            (_) async => false,
      );

      when(
            () => connectivity.checkConnectivity(),
      ).thenAnswer(
            (_) async => <ConnectivityResult>[],
      );

      final bloc = MapBloc(
        locationService: locationService,
        routeRepository: routeRepository,
        notificationService: notificationService,
        connectivity: connectivity,
      );

      bloc.add(MapStarted());

      await Future.delayed(
        const Duration(milliseconds: 200),
      );

      expect(
        bloc.state.isLoading,
        false,
      );

      await bloc.close();
    },
  );
}