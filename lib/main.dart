import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pages/app_template_page.dart';

/// Название приложения внутри Flutter (заголовок в списке запущенных).
/// Название под иконкой задаётся в .github/workflows/build.yml (APP_NAME).
const String appTitle = 'AppTemplate';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Вместо серого/чёрного экрана при ошибке показываем её текст.
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            details.exceptionAsString(),
            textDirection: TextDirection.ltr,
            style: const TextStyle(color: Colors.red, fontSize: 14),
          ),
        ),
      ),
    );
  };

  SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF6750A4);
    return MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const AppTemplatePage(),
    );
  }
}
