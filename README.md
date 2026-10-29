# Шаблон Flutter-приложения (Android + iOS)

Готовый проект для сборки через GitHub Actions. В приложении одна страница
`AppTemplatePage` с крупной надписью по центру. Всё остальное вы добавляете сами.

## Что внутри

| Файл | Зачем |
|---|---|
| `pubspec.yaml` | зависимости и версия приложения |
| `analysis_options.yaml` | правила проверки кода |
| `.gitignore` | что не попадает в репозиторий (в том числе ключи) |
| `.github/workflows/build.yml` | сборка APK, AAB и неподписанного IPA |
| `lib/main.dart` | запуск, тема (светлая/тёмная), показ ошибок вместо чёрного экрана |
| `lib/pages/app_template_page.dart` | главная страница |
| `new_app.py` | переименование шаблона под новое приложение |

Папок `android/` и `ios/` в проекте нет: GitHub Actions создаёт их при сборке
командой `flutter create`. Поэтому ничего устанавливать на компьютер не нужно.

## Как начать новое приложение

1. Распакуйте архив и в папке проекта выполните (нужен Python 3):

   ```
   python3 new_app.py --name "Моё приложение" --id my_app --org com.mycompany
   ```

   - `--name` — название под иконкой на телефоне;
   - `--id` — имя проекта: латиница, строчные, цифры и `_`;
   - `--org` — ваша организация; id приложения будет `com.mycompany.my_app`.

   Без Python то же самое делается вручную в трёх местах: `name:` в `pubspec.yaml`,
   блок `env:` в начале `.github/workflows/build.yml` и `appTitle` в `lib/main.dart`.
   `PROJECT_NAME` в workflow и `name` в `pubspec.yaml` должны совпадать.

2. Создайте репозиторий на GitHub и загрузите в него содержимое папки
   (включая скрытую папку `.github`), ветка `main`.

3. Откройте **Actions → Build apps**. Сборка запускается сама при каждом push,
   или вручную: **Run workflow**.

4. Готовые файлы лежат внизу страницы запуска, в разделе **Artifacts**:
   - `<имя>-android` — `app-release.apk` (для установки) и `app-release.aab` (для Google Play);
   - `<имя>-ios-unsigned` — IPA без подписи. Чтобы поставить его на iPhone,
     нужно подписать его своим Apple-сертификатом (например, через AltStore или Sideloadly).

## Обновление поверх старой версии (данные не пропадают)

Чтобы Android принял новый APK как обновление, нужны две вещи: один и тот же
ключ подписи и растущий номер сборки. Номер сборки workflow ставит сам
(`github.run_number`). Ключ нужно создать один раз.

1. Создайте ключ (нужна Java; команда одна на всю жизнь приложения):

   ```
   keytool -genkey -v -keystore debug.keystore -alias androiddebugkey \
     -storepass android -keypass android -keyalg RSA -keysize 2048 \
     -validity 10000 -dname "CN=Android Debug,O=Android,C=US"
   ```

2. Переведите файл в текст: `base64 -w0 debug.keystore` (на macOS: `base64 -i debug.keystore`).
3. В репозитории: **Settings → Secrets and variables → Actions → New repository secret**,
   имя `ANDROID_KEYSTORE_BASE64`, значение — этот текст.
4. Файл `debug.keystore` храните в надёжном месте и **никогда не добавляйте в репозиторий**.
   Потеряете его — обновления поверх старой версии станут невозможны.

Без секрета сборка всё равно пройдёт, но APK подпишется случайным ключом, и
перед установкой новой версии придётся удалять старую. Для публикации в Google Play
понадобится отдельный личный ключ загрузки.

## Что учесть при разработке

- **Версии библиотек.** Файла `pubspec.lock` в репозитории нет, поэтому сборка берёт
  самые свежие версии плагинов, и иногда новая версия ломает приложение.
  Для `shared_preferences_android` версия уже закреплена в `dependency_overrides`.
  Если плагин после обновления начал падать, закрепите проверенную версию там же.
- **Разрешения iOS** (камера, галерея): в `build.yml` есть закомментированный шаг,
  раскомментируйте его, если подключаете `image_picker`.
- **Иконка и название.** Название задаётся `APP_NAME` в `build.yml`. Иконку можно
  добавить пакетом `flutter_launcher_icons` (после `flutter create` в workflow).
- **Версия.** Номер до `+` в `version` в `pubspec.yaml` меняйте вручную
  (например, `1.1.0`), номер после `+` подставит workflow.

## Запуск на своём компьютере (по желанию)

```
flutter create . --platforms=android,ios --org com.mycompany --project-name my_app
flutter pub get
flutter run
```
