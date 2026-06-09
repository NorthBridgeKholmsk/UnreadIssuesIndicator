# Redmine Unread Issues Indicator

Плагин для Redmine, добавляющий зелёный индикатор перед темой задачи, если в ней произошли изменения, которые пользователь ещё не видел. После просмотра задачи индикатор автоматически скрывается.

## Возможности

- 🟢 Зелёный кружок перед темой задачи во всех списках (назначенные мне, отслеживаемые, общие списки, связанные задачи).
- 🔄 Автоматическое обновление индикатора после открытия задачи.
- 📡 Поддержка динамической подгрузки (AJAX, бесконечная прокрутка).
- 🎨 Настраиваемый стиль через CSS.

## Требования

- **Redmine** ≥ 6.1.x
- **Ruby** ≥ 3.3
- **Rails** ≥ 7.2
- **База данных**: MySQL, MariaDB, PostgreSQL (работает без дополнительных изменений)

## Принцип работы

1. При открытии задачи (`IssuesController#show`) создаётся или обновляется запись в таблице `issue_read_marks` с временем последнего просмотра для пары *пользователь–задача*.
2. На страницах со списком задач JavaScript собирает ID всех отображаемых задач и отправляет их на эндпоинт `/unread_issues`.
3. Сервер сравнивает `updated_on` задачи с `last_viewed_at` пользователя и возвращает массив непрочитанных ID.
4. Для каждой непрочитанной задачи в DOM вставляется элемент `<span class="issue-unread-indicator">●</span>`.
5. `MutationObserver` отслеживает появление новых строк в таблицах (при динамической подгрузке) и обновляет индикаторы.

## Установка

1. Склонируйте репозиторий в директорию `plugins` вашего Redmine:

   ```bash
   cd /path/to/redmine/plugins
   git clone https://github.com/NorthBridgeKholmsk/redmine_unread_issues_indicator.git
2. Выполните миграцию:

   ```bash
   bundle exec rake redmine:plugins:migrate RAILS_ENV=production
3. (Опционально) Скомпилируйте ресурсы плагина:

   ```bash
   bundle exec rake redmine:plugins:assets RAILS_ENV=production
4. Перезапустите сервер Redmine.

## Настройка стилей
По умолчанию индикатор отображается в виде зелёного кружка. Чтобы изменить его внешний вид, отредактируйте файл assets/stylesheets/unread_indicator.css. Например:

  ```css
    .issue-unread-indicator {
     color: #3498db;
     font-size: 1.2em;
     margin-right: 5px;
     vertical-align: middle;
    }
  ```
После изменения стилей не забудьте выполнить redmine:plugins:assets (если не используется живая перекомпиляция) и очистить кеш браузера.

## Структура плагина
  ```text
redmine_unread_issues_indicator/
├── app/
│   ├── controllers/unread_issues_controller.rb   # API для получения статуса прочтения
│   └── models/issue_read_mark.rb                 # Модель для хранения меток просмотра
├── assets/stylesheets/unread_indicator.css       # Стили индикатора
├── config/routes.rb                              # Маршрут /unread_issues
├── db/migrate/001_create_issue_read_marks.rb     # Миграция для создания таблицы
├── lib/
│   └── redmine_unread_issues_indicator/
│       ├── hooks.rb                              # Внедрение JavaScript и CSS
│       └── patches/
│           └── issues_controller_patch.rb        # Патч контроллера для записи просмотра
└── init.rb                                       # Регистрация плагина
```
