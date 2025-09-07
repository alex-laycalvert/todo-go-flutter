# todo-go-flutter

This is a basic TODO app built with [Flutter](https://flutter.dev/) and [Go](https://go.dev/).

## Packages

This project contains the `todo_backend` (Go) and `todo_mobile` (Flutter) packages.

### todo_backend

The backend for this project is written in Go and was started using [go-blueprint](https://docs.go-blueprint.dev/).

It uses a vertical slice architecture and the bulk of the project follows this structure:

```
todo_backend/
    internal/
        modules/
            myModule/
                domain/       # Business logic for this module, though largely unused as of now
                api/          # API route handlers (Presentation layer)
                repositories/ # Data access layer
                models/       # Database models
```

Each repository has been abstracted into an interface. This interface is the provided to the API handlers via dependency injection.

> Note: The scale of this app doesn't _really_ warrant the need to make the abstraction, but there's not a lot of overhead in doing so and it makes it easier to swap out the data layer if needed.

#### Future Plans

- The `FirebaseAuthMiddleware` in `internal/middleware/auth.go` is a little clunky since it relies directly on a `UserRepository`. I would like to find an abstraction for this that's a little cleaner.
- Type defintions are a little scattered. Most of the types are defined in the repositories and the API just uses them directly as needed, but it might be better to define some in `domain/`

### todo_mobile

The mobile app is written in Dart w/ Flutter and uses the Model-View-ViewModel (MVVM) architecture.

The basic structure:

```
todo_mobile/
    lib/
        services/     # External services such as an HTTP client
        models/       # Data models
        repositories/ # Data access layer (Abstracts services)
        use_cases/    # Business logic (Optional, Interacts with repositories)
        ui/
            core/                      # Shared UI components
            screen1/                   # Each screen has its own folder
                screen_view.dart           # The UI (View)
                screen_view_model.dart     # The ViewModel (Business logic)
```

Like the backend, repositories are abstracted into interfaces here as well with most of them having a `_remote` implementation that relies on an HTTP client.

Use cases are optional and in this case are utilized for business logic that may span multiple repositories or services. The only use case in this project is the `AuthenticatedUserUseCase` which combines the `AuthRepository` and `UserRepository` to provide a single source of truth for the authenticated user. This allows the `AuthRepository` to focus solely on Firebase authentication and not need to know about the details of the user data, _and_ for the `UserRepository` to not need to know about authentication at all.

While `services`, `models`, `repositories`, and `use_cases`, are flattened, the `ui` folder is a vertical slice on a per-screen basis with each screen having a dedicated View and ViewModel. In this setup, there is a strict one-to-one relationship between a View and ViewModel, and ViewModels cannot share state with other ViewModels. Instead, they rely on any number of repositories, services or use cases to get the data they need.
