# CineScope

CineScope is a SwiftUI movie discovery app for iPhone and iPad. It uses The
Movie Database (TMDB) for movie information and lets people keep a local
watchlist, favorites, watched history, ratings, and reviews.

## Features

- Discover trending, now-playing, popular, upcoming, and top-rated movies.
- Search and browse movies by genre.
- View movie details, cast, trailers, and recommendations.
- Manage a watchlist, favorites, watched movies, personal ratings, and reviews.
- View library statistics and configure TMDB credentials and cache settings.

## Requirements

- Xcode and an iOS Simulator or device that support the project's iOS 26.2
  deployment target.
- A TMDB API key or Read Access Token for live movie data.

## Get started

1. Open `CineScope.xcodeproj` in Xcode and select the `CineScope` scheme.
2. Build and run on an iOS Simulator or device.
3. In the app, open **Settings** and enter a TMDB API key or Read Access Token.
   The app validates the credential before saving it.

For local development, credentials can also be provided without entering them
in the app:

- Set `TMDB_API_KEY` or `TMDB_ACCESS_TOKEN` in the app's run environment.
- Or create `CineScope/Resources/TMDBConfig.json` from
  `CineScope/Resources/TMDBConfig.example.json` and ensure the new file is
  included in the app target's resources.
- Or provide `TMDB_API_KEY` as an Info.plist build setting.

`APIConfig` checks credentials in this order: the value saved in app Settings,
the `TMDB_API_KEY` environment variable, the `TMDB_ACCESS_TOKEN` environment
variable, a bundled `TMDBConfig.json`, then the `TMDB_API_KEY` Info.plist value.
Credentials saved in Settings are stored in `UserDefaults`. Do not commit real
credentials or include them in shared build settings.

## Architecture

CineScope uses feature-oriented SwiftUI with MVVM and repository boundaries:

```text
SwiftUI Views
    ↓ user actions / observed state
Feature ViewModels (@Observable, @MainActor)
    ↓ protocols
Repositories
    ├── MovieRepository (actor) → APIClientProtocol → TMDB API
    └── UserMovieRepository (@MainActor) → SwiftData
```

- **Views** render state and forward user actions. Feature-specific view
  models own screen state and asynchronous presentation logic.
- **Repositories** isolate data access from features. `MovieRepository`
  fetches and caches remote movie data; `UserMovieRepository` manages local
  user movie state through SwiftData.
- **Networking** is defined by `APIClientProtocol` and `APIEndpoint`.
  `URLSessionAPIClient` performs requests and decodes responses; `APIError`
  represents request failures.
- **Models** represent TMDB responses and user movie status. `SavedMovieItem`
  is the SwiftData model for locally saved movie information and user activity.
- **Core** holds app-wide configuration, networking, persistence, image
  loading, utilities, and reusable design-system elements.
- **Features** group screens and their view models/components by user-facing
  area. `MainTabView` composes Discover, Search, Watchlist, Library, and
  Settings.

### Source layout

| Path | Responsibility |
| --- | --- |
| `CineScope/Core/Configuration/` | TMDB credential configuration |
| `CineScope/Core/Networking/` | Endpoints, API client, errors, connectivity |
| `CineScope/Core/Persistence/` | SwiftData model and persistence setup |
| `CineScope/Core/DesignSystem/` | Shared colors, metrics, and UI components |
| `CineScope/Core/ImageLoading/` | Cached remote image loading |
| `CineScope/Features/` | Tab screens, view models, and feature components |
| `CineScope/Models/` | Movie and API response types |
| `CineScope/Repositories/` | Remote and local data access |
| `CineScope/Resources/` | Bundled resources and TMDB config template |
| `CineScopeTests/` | Unit and view-model tests |
| `CineScopeUITests/` | App launch and navigation UI tests |

### Data and dependency flow

The app entry point creates the shared SwiftData model container and installs
it in the SwiftUI environment. Views access the model context through that
environment; feature view models receive repository protocols so data access
can be replaced with test doubles. Movie requests flow through
`MovieRepositoryProtocol` and `APIClientProtocol`, while watchlist and library
changes flow through `UserMovieRepositoryProtocol` and SwiftData.

When adding functionality, keep presentation state in the owning feature's
view model, put reusable remote or local data operations behind the existing
repository protocols, and keep shared infrastructure in `Core`. Extend the
existing model, endpoint, and test patterns rather than reaching directly
from a view into networking or persistence.

## Build and test

Build the app for the iOS Simulator:

```sh
xcodebuild build \
  -project CineScope.xcodeproj \
  -scheme CineScope \
  -destination 'generic/platform=iOS Simulator'
```

Run unit and UI tests on an installed simulator:

```sh
xcodebuild test \
  -project CineScope.xcodeproj \
  -scheme CineScope \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.2'
```

The available simulator name and OS version can differ by Xcode installation;
select an installed iOS simulator in Xcode or update the destination accordingly.
Most unit tests use mock API responses and an in-memory SwiftData container, so
they do not require a live TMDB credential.

## TMDB attribution

This product uses the TMDB API but is not endorsed or certified by TMDB.
The app includes a TMDB attribution card in Settings.
