import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:tubesync/app/app_theme.dart';
import 'package:tubesync/app/home/home_screen.dart';
import 'package:tubesync/clients/media_client.dart';
import 'package:tubesync/model/objectbox.g.dart';
import 'package:tubesync/model/preferences.dart';
import 'package:tubesync/services/downloader_service.dart';
import 'package:tubesync/services/media_service.dart';
import 'package:window_manager/window_manager.dart';

final rootNavigator = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppTheme.isDesktop) {
    await WindowManager.instance.ensureInitialized();
    WindowManager.instance.setMinimumSize(const Size(480, 360));
  }

  // DB Initialization
  final objectDB = await openStore(
    directory: (await getApplicationSupportDirectory()).path,
  );

  AppTheme.dynamicColors.value = objectDB.box<Preferences>().getValue(
        Preference.materialYou,
        true,
      )!;

  await DownloaderService.init(objectDB);
  await MediaService.init();
  await MediaClient.init();

  MaterialApp app({
    required ThemeData light,
    required ThemeData dark,
    required Widget home,
  }) {
    return MaterialApp(
      navigatorKey: rootNavigator,
      debugShowCheckedModeBanner: false,
      theme: light,
      darkTheme: dark,
      scrollBehavior: AppTheme.scrollBehavior,
      home: home,
    );
  }

  runApp(
    Directionality(
      textDirection: TextDirection.ltr,
      child: DragToResizeArea(
        child: ValueListenableBuilder(
          valueListenable: AppTheme.dynamicColors,
          builder: (_, dynamicColor, home) {
            if (dynamicColor == true) {
              return DynamicColorBuilder(
                builder: (light, dark) => app(
                  light: AppTheme(colorScheme: light).light,
                  dark: AppTheme(colorScheme: dark).dark,
                  home: home!,
                ),
              );
            }

            return app(
              light: AppTheme().light,
              dark: AppTheme().dark,
              home: home!,
            );
          },
          child: Provider<Store>(
            create: (context) => objectDB,
            child: const HomeScreen(),
          ),
        ),
      ),
    ),
  );

  // Ensure permissions
  Future.wait([
    Permission.notification.isDenied,
    Permission.ignoreBatteryOptimizations.isDenied
  ]).then((result) async {
    if (result[0]) await Permission.notification.request();
    if (result[1]) await Permission.ignoreBatteryOptimizations.request();
  }).catchError((_) {});
}
