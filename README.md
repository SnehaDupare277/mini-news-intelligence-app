# Briefly — Mini News Intelligence App

A Flutter 3+ assignment project for browsing news by category, searching stories, viewing article details, and saving favorites for offline access.

## Features

- Demo login with persisted login state using `shared_preferences`
- News feed by category, manual pagination, and pull-to-refresh
- API-backed search with a short debounce to avoid a request on every keystroke
- Article detail screen and saved stories
- Hive persistence for favorites
- Loading, empty, and error states
- Riverpod providers for API access and favorite state

## Tech stack

- Flutter / Dart with null safety
- Riverpod for app state
- NewsAPI.org for news data
- Hive for saved articles
- SharedPreferences for the demo login flag
- Material 3 widgets

## Run locally

1. Install Flutter 3+ and confirm `flutter doctor` is clean.
2. Get a NewsAPI.org API key. The API key is intentionally not committed to this repository.
3. From this project directory run:

   ```bash
   flutter pub get
   flutter run --dart-define=NEWS_API_KEY=YOUR_NEWS_API_KEY
   ```

   In your IDE, configure the same `NEWS_API_KEY` Dart define for debug runs.

## Architecture

```text
lib/
  main.dart                         App initialization and dependency scope
  app.dart                          Theme and root app
  core/
    models/article.dart             Article model and serialization
    services/news_api.dart          HTTP client wrapper and API error mapping
    storage/local_storage.dart      Hive and SharedPreferences setup
  features/
    auth/login_screen.dart          Demo authentication flow
    news/
      home_screen.dart              Feed, categories, refresh, pagination
      search_screen.dart             Debounced API search
      article_detail_screen.dart    Article detail and save action
      favorites_screen.dart         Offline saved stories
      news_providers.dart           Riverpod providers and favorite state
```

The UI depends on the `NewsApi` provider rather than constructing API requests inside widgets. Favorites are represented by a Riverpod `StateNotifier` and persisted to Hive, so the saved list can be restored after app restarts.

## Important notes / known limitations

- The login is a local demo flow, not secure server-side authentication. It stores a display name and a boolean flag only.
- NewsAPI.org free/developer plans may restrict requests from deployed apps and may not include all production features. Check the API plan and usage terms before public deployment.
- NewsAPI's `content` field is often truncated. The full story remains with the publisher.
- The “Original publisher link” action currently gives an in-app reminder rather than opening an external browser. This can be extended with `url_launcher`.
- Pagination is a simple page-based “Load more” button. The endpoint/API plan may return no additional articles.
- Run `flutter analyze` and `flutter test` locally before submission. This scaffold has not been executed in a Flutter environment here.

## Before submitting

- Add your own screenshots to this README.
- Test login persistence, category changes, search, favorites after app restart, refresh, and failure states.
- Keep the API key out of source control.
- Use small, meaningful Git commits and include the repository URL in your submission.
