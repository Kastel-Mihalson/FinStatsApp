#!/usr/bin/env python3
"""Превращает шаблон в новое приложение.

Пример:
    python3 new_app.py --name "Моё приложение" --id my_app --org com.mycompany

Что делает: меняет название приложения, имя проекта и организацию в
pubspec.yaml, .github/workflows/build.yml и lib/main.dart.
Запускать один раз, в корне проекта. Работает с любой версией Python 3.
"""
import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent


def sub_file(path, pattern, repl, flags=re.M):
    text = path.read_text(encoding="utf-8")
    new, n = re.subn(pattern, lambda m: repl(m) if callable(repl) else repl, text, count=1, flags=flags)
    if n != 1:
        sys.exit(f"Не нашёл нужную строку в {path.relative_to(ROOT)} (шаблон уже изменён?)")
    path.write_text(new, encoding="utf-8")


def main():
    p = argparse.ArgumentParser(description="Создать новое приложение из шаблона")
    p.add_argument("--name", required=True, help="название под иконкой, например: Моё приложение")
    p.add_argument("--id", required=True, help="имя проекта: латиница, строчные, цифры и _ (my_app)")
    p.add_argument("--org", default="com.example", help="организация, по умолчанию com.example")
    p.add_argument("--description", default=None, help="описание для pubspec.yaml")
    a = p.parse_args()

    if not re.fullmatch(r"[a-z][a-z0-9_]*", a.id):
        sys.exit("--id: только строчная латиница, цифры и _, начинать с буквы (my_app)")
    if not re.fullmatch(r"[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+", a.org):
        sys.exit("--org: вид com.mycompany (строчная латиница и цифры, через точки)")
    if '"' in a.name or "#" in a.name or "\\" in a.name or "'" in a.name:
        sys.exit("--name: уберите кавычки, # и обратные слэши")

    wf = ROOT / ".github/workflows/build.yml"
    pub = ROOT / "pubspec.yaml"
    main_dart = ROOT / "lib/main.dart"

    sub_file(wf, r"^(  APP_NAME:)[^\n]*$", lambda m: f"{m.group(1)} {a.name}")
    sub_file(wf, r"^(  PROJECT_NAME:)[^\n]*$", lambda m: f"{m.group(1)} {a.id}")
    sub_file(wf, r"^(  ORG:)[^\n]*$", lambda m: f"{m.group(1)} {a.org}")
    sub_file(pub, r"^name:.*$", f"name: {a.id}")
    if a.description:
        sub_file(pub, r"^description:.*$", lambda m: f"description: {a.description}")
    sub_file(main_dart, r"^const String appTitle = '[^']*';", lambda m: f"const String appTitle = '{a.name}';")

    print(f"Готово: «{a.name}», проект {a.id}, id приложения {a.org}.{a.id}")
    print("Дальше: загрузите проект в GitHub (ветка main) и запустите Actions → Build apps.")
    print("Файл new_app.py после этого можно удалить.")


if __name__ == "__main__":
    main()
