# App Launch Order - MVVM Architecture

This document outlines the order in which files/functions run when launching and navigating through the MVVM Notes app.

## App Startup (Cold Launch)

1) Process start
- `@main` in `AppDelegate` creates the application delegate instance.

2) AppDelegate launch
- `AppDelegate.application(_:didFinishLaunchingWithOptions:)`
  - First app logic entry point.

3) Scene configuration
- `AppDelegate.application(_:configurationForConnecting:options:)`
  - Returns the scene config named "Default Configuration".

4) Scene connection
- `SceneDelegate.scene(_:willConnectTo:options:)`
  - With `UISceneStoryboardFile` = `Main` in Info.plist, iOS loads `Main.storyboard` automatically and attaches a window.

5) Initial storyboard VC lifecycle
- `ViewController.viewDidLoad()`
- `ViewController.viewWillAppear(_:)`
- `ViewController.viewDidAppear(_:)`

6) Foreground/active callbacks
- `SceneDelegate.sceneDidBecomeActive(_:)`

## From Welcome → Notes List (MVVM Flow)

7) User taps Get Started
- `ViewController.getStartedTapped(_:)`
  - Calls `setupMVVMArchitecture()`
  - Instantiates `NotesListViewController` (storyboard identifier: `NotesListViewController`)
  - **Creates `NotesListViewModel`** (MVVM key difference)
  - Embeds in `UINavigationController` and presents full screen

8) Notes list lifecycle and MVVM setup
- `NotesListViewController.viewDidLoad()`
  - `setupView()` (styling)
  - `setupViewModel()`
    - **Creates `NotesListViewModel(repository: NotesRepository())`** 
      - `NotesRepository.init()` accesses `CoreDataManager.shared`
        - `CoreDataManager.init()` → `setupSampleDataIfNeeded()`
          - Calls `fetchAllNotes()` (triggers lazy `persistentContainer.loadPersistentStores`) → prints success
          - Seeds sample notes if store is empty
    - **Sets up data binding** between ViewModel and View
  - `setupBindings()`
    - **Binds `viewModel.notes` to table view updates**
    - **Binds `viewModel.isLoading` to loading indicator**
    - **Binds `viewModel.errorMessage` to error display**
  - **ViewModel automatically loads notes** via `loadNotes()`
- Usual lifecycle continues: `viewWillAppear(_:)` → `viewDidAppear(_:)`

## MVVM Interactions in Notes List

9) Create a note (MVVM flow)
- Tap + (bar button)
  - `NotesListViewController.addButtonTapped(_:)` → **`viewModel.addNewNote()`**
  - **`NotesListViewModel`** handles navigation logic
  - Creates and configures `NoteDetailViewController` with **`NoteDetailViewModel`**

10) Edit a note (MVVM flow)
- Select a row
  - `tableView(_:didSelectRowAt:)` → **`viewModel.selectNote(at: indexPath.row)`**
  - **ViewModel** prepares note data and triggers navigation
  - **ViewController** presents `NoteDetailViewController` with pre-configured **`NoteDetailViewModel`**

11) Delete a note (MVVM flow)
- Swipe to delete
  - `tableView(_:commit:forRowAt:)` → **`viewModel.deleteNote(at: indexPath.row)`**
  - **`NotesListViewModel.deleteNote()`** → **`repository.deleteNote()`** → `CoreDataManager.deleteNote()`
  - **Data binding automatically refreshes UI** when `viewModel.notes` updates

## MVVM Note Detail Flow

12) Detail screen lifecycle (MVVM setup)
- `NoteDetailViewController.viewDidLoad()`
  - `setupView()` (styling)
  - `setupViewModel()` → **creates or receives `NoteDetailViewModel`**
  - `setupBindings()` 
    - **Binds `viewModel.title` to title text field**
    - **Binds `viewModel.content` to content text view**  
    - **Binds `viewModel.isLoading` to loading state**
    - **Binds `viewModel.errorMessage` to error display**
    - **Binds `viewModel.noteSaved` to navigation back**
  - **ViewModel populates fields** via Observable properties

13) Save / Cancel (MVVM commands)
- Save: `saveButtonTapped(_:)`
  - **`viewModel.saveNote(title: titleTextField.text, content: contentTextView.text)`**
  - **`NoteDetailViewModel`** validates input and coordinates with Repository
  - **Repository** handles Core Data operations
  - **Data binding triggers UI updates and navigation**
- Cancel: `cancelButtonTapped(_:)` → **`viewModel.cancel()`** pops without saving

## MVVM Data Flow Summary

**Key MVVM Differences from MVC:**
- **ViewControllers are lightweight** - only handle UI binding and user interactions
- **ViewModels contain all UI logic** and state management
- **Repository pattern** abstracts data access from ViewModels  
- **Reactive data binding** automatically updates UI when ViewModel state changes
- **Two-way data flow** between View and ViewModel
- **No direct Model-View communication** - everything goes through ViewModel

## Backgrounding & Termination

14) App goes to background
- `SceneDelegate.sceneDidEnterBackground(_:)`
  - Calls `(UIApplication.shared.delegate as? AppDelegate)?.saveContext()` → `CoreDataManager.shared.saveContext()`

15) App terminates
- `AppDelegate.applicationWillTerminate(_:)`
  - Calls `CoreDataManager.shared.saveContext()`

---

## MVVM Architecture Benefits in Launch Flow

✅ **Reactive Updates**: Data binding ensures UI stays in sync with ViewModel state
✅ **Testable Logic**: ViewModels can be unit tested independently of UI
✅ **Clean Separation**: ViewControllers focus purely on UI, ViewModels handle logic
✅ **Scalable**: Easy to add new features by extending ViewModels
✅ **Repository Pattern**: Clean data access abstraction

This sequence reflects the MVVM project's architecture with proper separation of concerns, reactive data binding, and clean data flow patterns.

![App Launch Flow Diagram - MVVM](app_launch_order_diagram.svg)

## Related Files

- **Model Layer:**
  - `CoreDataManager.swift`: Core Data stack management and persistence
  - `notemakingmvvmuikit.xcdatamodeld`: Core Data model definition

- **ViewModel Layer:**  
  - `NotesListViewModel.swift`: Notes list UI logic and state
  - `NoteDetailViewModel.swift`: Note detail UI logic and state
  - `NotesRepository.swift`: Data access coordination and abstraction

- **View Layer:**
  - `NotesListViewController.swift`: Notes list UI binding and interactions
  - `NoteDetailViewController.swift`: Note detail UI binding and interactions
  - `ViewController.swift`: Welcome screen and app entry point
  - `Main.storyboard`: UI layouts and navigation
  - `DesignSystem.swift`: Consistent visual styling

- **Support:**
  - `AppDelegate.swift`: App lifecycle management
  - `SceneDelegate.swift`: Scene lifecycle and window management
  - `Assets.xcassets`: Asset catalog (loaded by name at runtime)
  - `Info.plist`: Launch configuration (`UISceneStoryboardFile = Main`)
  - `MVVM_Architecture_Guide.swift`: Educational documentation (not in execution path)

## MVVM Flow Patterns

**Data Flow Pattern:**
```
User Action → View captures → ViewModel processes → Repository coordinates → 
Core Data updates → Repository returns → ViewModel updates Observable → 
View refreshes automatically via binding
```

**Communication Pattern:**
```
View ↔ ViewModel ↔ Repository ↔ Core Data
```

**Binding Pattern:**
```swift
// In ViewController
viewModel.notes.bind { [weak self] notes in
    DispatchQueue.main.async {
        self?.tableView.reloadData()
    }
}
```

This MVVM implementation demonstrates modern iOS architecture with reactive programming, clean separation of concerns, and excellent testability.