# Windows Tiny7 ISO Patcher

Автоматически патчит и облегчает ISO через GitHub Actions.

## Как использовать

### 1. Загрузить ISO в репозиторий

```bash
git clone https://github.com/ВАШ_НИК/win7-patcher
cd win7-patcher
# Скопируй ISO в корень репозитория
cp /путь/к/Windows.Tiny7.Rev01.Unattended.Activated.CD.eXPerience.iso .
git add *.iso
git commit -m "add source iso"
git push
```

> ⚠️ **GitHub ограничивает файлы до 100 MB** без Git LFS.  
> Если ISO больше — подключи Git LFS:
> ```bash
> git lfs install
> git lfs track "*.iso"
> git add .gitattributes
> git commit -m "track iso with lfs"
> ```

### 2. Воркфлов запустится автоматически

При пуше ISO-файла GitHub Actions автоматически:

| Шаг | Что делает |
|-----|-----------|
| Извлечь ISO | Монтирует и копирует содержимое |
| Патч install.wim | Удаляет Help, лишние шрифты, ненужные языки, примеры медиа |
| Патч boot.wim | Перепаковывает с LZX-сжатием |
| Очистка дерева | Убирает upgrade/, compat/, мусорные файлы |
| Сборка ISO | Пересобирает загрузочный ISO (xorriso / genisoimage) |

### 3. Скачать результат

После успешного запуска — вкладка **Actions → последний run → Artifacts → Windows-Tiny7-Patched-Slim**.

---

## Ручной запуск

Actions → **Patch & Slim Windows Tiny7 ISO** → **Run workflow** → (опционально укажи имя ISO).

---

## Что убирается из образа

- `Windows/Help` — справка (~30–60 MB)
- Редкие шрифты (оставляются латиница + кириллица)
- Ненужные языковые пакеты (остаются `en-US` + `ru-RU`)
- Sample Music / Pictures / Videos
- `upgrade/`, `compat/` из дерева ISO
- Мусорные файлы (`Thumbs.db`, `*.log`, `desktop.ini`)
- WIM перепаковывается в **LZX Solid** — максимальное сжатие

---

## Структура проекта

```
.
├── .github/
│   └── workflows/
│       └── patch-iso.yml      # GitHub Actions workflow
├── scripts/
│   ├── patch_wim.sh           # Патчит install.wim
│   ├── patch_boot.sh          # Оптимизирует boot.wim
│   ├── slim_iso_tree.sh       # Чистит дерево ISO
│   └── rebuild_iso.sh         # Собирает финальный ISO
└── README.md
```

---

## Требования

- GitHub Actions (ubuntu-latest)
- Пакеты: `xorriso`, `wimtools`, `p7zip-full`, `rsync`  
  (устанавливаются автоматически в workflow)
