# iOS Interview Questions & Answers

---

## 1. How do you fetch data from an API call in iOS?

The standard tool is `URLSession`. The flow has four phases: build the request → fire a task → handle the response on a background queue → marshal results to the main thread for UI updates.

### Step-by-step

```swift
// 1. Build a URL
guard let url = URL(string: "https://api.example.com/holidays?month=5") else { return }
let request = URLRequest(url: url)

// 2. Create a data task with a completion handler
let task = URLSession.shared.dataTask(with: request) { data, response, error in

    // 3. Inspect the response on a background queue
    if let error = error {
        print("Network error: \(error)")
        return
    }
    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode),
          let data = data else {
        return
    }

    // 4. Decode the JSON into Swift types (Codable)
    do {
        let result = try JSONDecoder().decode(MyResponse.self, from: data)

        // 5. Marshal back to main thread for UI updates
        DispatchQueue.main.async {
            self.handle(result)
        }
    } catch {
        print("Decode error: \(error)")
    }
}

// 6. Don't forget to actually start the task
task.resume()
```

### Key points

- **`URLSession.shared`** is fine for simple GETs; for more control (delegate queue, custom configuration) use `URLSession(configuration:delegate:delegateQueue:)`.
- **`task.resume()`** is required — tasks are created in a *suspended* state.
- **`Codable`** + `JSONDecoder` is the standard parsing tool.
- **The completion handler runs on a background thread by default** — always hop to main with `DispatchQueue.main.async` before touching UIKit.
- **Modern alternative:** `async/await`:

  ```swift
  let (data, _) = try await URLSession.shared.data(from: url)
  let result = try JSONDecoder().decode(MyResponse.self, from: data)
  ```

  Same flow, no nested closures — read top to bottom.

---

## 2. The different initializers in Swift (table)

| Form | Example | Purpose |
|---|---|---|
| **Memberwise** (structs only) | `Holiday(title:date:category:hebrew:)` | Free initializer Swift gives every struct automatically — one parameter per stored property |
| **Designated** (classes) | `init(_ number: Int, month: Int, year: Int)` | Primary initializer; must assign all stored properties |
| **Private** | `private init() { ... }` | Restricts access — typically used for singletons (`EventStore.shared`) |
| **Failable** (`init?`) | `init?(hex: String)` | Returns `nil` if construction can't succeed (invalid input) |
| **Convenience** | `convenience init?(hex:)` | Secondary initializer that delegates to a designated init via `self.init(...)` |
| **Required** | `required init?(coder: NSCoder)` | Subclasses *must* implement; forced by superclass (e.g., `UIView`) |
| **Throwing** (`init throws`) | `init(url: URL) throws` | Fails by throwing a rich error instead of returning `nil` |
| **Decodable** (synthesized) | `init(from decoder: Decoder) throws` | Auto-generated for `Codable` types; powers JSON decoding |

### Quick rules

- **`struct` gets memberwise init for free; `class` does not.**
- **`convenience init` must call another initializer of the same class** via `self.init(...)`.
- **`required` propagates down the class hierarchy** — once required, all subclasses must implement.
- **`failable (init?)`** is for "couldn't parse / invalid state" failures; **`throws`** is for "needs to explain *why* it failed."

---

## 3. Difference between `if let` and `guard let`

Both **unwrap an optional** and bind it to a non-optional name. The difference is **scope** and **control flow**.

### `if let` — the unwrapped value is available **inside** the `if` block

```swift
if let event = currEvent {
    // event is non-optional here
    eventTitle.text = event.eventTitle
}
// event is NOT available here
```

Use when the absence is *not* an error — you simply want to do something extra *if* the value exists.

### `guard let` — the unwrapped value is available in the **rest of the enclosing scope**

```swift
func saveEvent() {
    guard let title = eventTitle.text, !title.isEmpty else {
        showToast(message: "Title required")
        return
    }
    // title is non-optional here, AND for the rest of the function
    eventToSave.eventTitle = title
}
```

Use when the absence is an **early-exit condition**. The `else` branch must transfer control out (`return`, `throw`, `break`, `continue`, `fatalError`).

### Comparison table

| | `if let` | `guard let` |
|---|---|---|
| Where the unwrapped name is available | Inside the `if` block | Rest of the enclosing scope |
| Used for | Optional side branches | Preconditions / early returns |
| `else` requirement | Optional | Must exit the scope |
| Reads like | "if this exists, do X" | "this must exist, otherwise bail" |

### Style benefit of `guard let`

It **flattens nesting**. Compare:

```swift
// Pyramid of doom with if let
func handle() {
    if let event = currEvent {
        if let title = event.eventTitle {
            if !title.isEmpty {
                save(title)
            }
        }
    }
}

// Flat with guard let
func handle() {
    guard let event = currEvent,
          let title = event.eventTitle,
          !title.isEmpty else { return }
    save(title)
}
```

`guard` is preferred when "absence" is exceptional. `if let` is preferred when both branches are normal cases.

---

## 4. What is `weak self`?

`[weak self]` is part of a closure's **capture list**, telling the closure to hold a **weak reference** to `self` instead of a strong one.

### The problem it solves: retain cycles

By default, closures capture references **strongly**. If a closure is stored on another object that `self` also owns (directly or indirectly), you get a cycle:

```
self  ──owns──▶  someObject
   ▲                  │
   │                  │ stores closure
   │                  ▼
closure ◀──captures── strong self
```

Neither side can be deallocated. Memory leak.

### How `[weak self]` breaks it

```swift
detailsVC.onEventUpdated = { [weak self] in
    self?.refreshEvents()
}
```

The closure now holds a **weak** pointer to `self`. Inside the closure, `self` is an Optional. If `self` has been deallocated by the time the closure runs, `self?` is `nil` and the call is a no-op.

### When to use `[weak self]`

| Situation | Use weak self? |
|---|---|
| Closure stored on another object (`onSomething: ...`) | ✅ Yes — would cycle otherwise |
| `Timer.scheduledTimer(... repeats: true)` | ✅ Yes — timer retains the block forever |
| `URLSession` completion handlers | ✅ Yes — avoids keeping self alive during network calls |
| `UIView.animate { ... }` one-shot | ❌ No — closure is released right after running |
| Sync functional ops (`array.map { self.f($0) }`) | ❌ No — closure ends with the call |

### Difference from `[unowned self]`

- **`weak`** → optional, safe; if `self` is gone, value is `nil`.
- **`unowned`** → non-optional; if `self` is gone when the closure runs, **crash**.

Use `unowned` only when you're 100% certain `self` outlives the closure. `weak` is the safer default.

### What `self?.method()` means

When you capture `self` weakly, it becomes `Optional`. So:

```swift
self?.refreshEvents()
```

means "if `self` is still alive, call `refreshEvents()`; otherwise, do nothing."

---

## 5. What is Core Data, and benefits of using `NSManagedObject`

### What Core Data is

Core Data is **Apple's object graph and persistence framework**. It's not a database (though it usually sits on top of SQLite under the hood) — it's a framework for:

1. **Modeling** your app's data as an object graph (`.xcdatamodeld` files).
2. **Storing** that graph durably (SQLite, in-memory, or binary).
3. **Tracking changes** to the graph and saving them as transactions.
4. **Querying** with `NSFetchRequest` + `NSPredicate` + `NSSortDescriptor`.
5. **Undo / redo**, validation, faulting, lazy loading, cascading deletes, parent-child contexts — all out of the box.

### What `NSManagedObject` is

Every object in the Core Data graph subclasses `NSManagedObject`. Either:
- You subclass it directly (e.g., `class Event: NSManagedObject { ... }`).
- Xcode auto-generates the subclass from your `.xcdatamodeld` entity.

`Event` in this project is exactly this:

```swift
@objc(Event)
public class Event: NSManagedObject {
    static let defaultTitle = "(No title)"
    func setTitleOrDefault(_ rawTitle: String?) { ... }
}

extension Event {
    @NSManaged public var eventTitle: String?
    @NSManaged public var eventStartDate: Date?
    @NSManaged public var isAllDay: Bool
    // ... etc
}
```

### Benefits of using `NSManagedObject`

| Benefit | What it means in practice |
|---|---|
| **Automatic persistence** | Setting `event.eventTitle = "New title"` queues a change. `context.save()` writes it to SQLite — you write no SQL. |
| **Lazy loading (faulting)** | Fetching 1,000 events doesn't load all their properties immediately. Properties are loaded on first access. Saves memory. |
| **Change tracking** | The context knows which objects you inserted, updated, deleted, and gives you `hasChanges`, `updatedObjects`, etc. |
| **Relationships** | Define `events: NSSet` on a Day entity → fetching a day gives you its events automatically, optionally lazily. |
| **Undo / redo** | Wire up `context.undoManager` and you get unlimited undo on every change for free. |
| **Queries via predicates** | `NSPredicate(format: "eventStartDate >= %@", date)` — type-safe-ish, fast (translated to SQL under the hood). |
| **Migration support** | Versioned `.xcdatamodeld` lets you evolve your schema with automatic or custom migrations. |
| **Background contexts** | Heavy work on `performBackgroundTask { ... }` doesn't block the main thread. |
| **Identity uniqueness** | Inside a context, an entity with a given `objectID` is always the same Swift instance — no duplicates. |
| **KVC / KVO support** | Free observation of property changes via `@NSManaged` (powers things like SwiftUI's `@FetchRequest`). |

### Trade-offs (worth knowing for an interview)

- **Steeper learning curve** than a simple `Codable + FileManager` approach.
- **Threading is strict** — every context belongs to a single queue.
- **Hard to unit-test** without setting up an in-memory store.
- **Schema migrations** can get tricky for non-trivial changes.

### When you'd choose Core Data

- App stores **a lot** of structured data that needs to be queried/sorted/related.
- You want change tracking, undo, validation for free.
- The data model is going to evolve (you'll need migrations).

### When you'd skip it

- A handful of objects → `Codable` to JSON in a file is simpler.
- Trivial key/value storage → `UserDefaults`.
- New project today → many teams reach for **SwiftData** (iOS 17+), Apple's modern wrapper that uses Core Data under the hood with cleaner Swift ergonomics.

---

## Quick interview-prep summary

- **Networking:** `URLSession.dataTask(with:completion:)` → parse with `Codable` → marshal to main thread → call `task.resume()`.
- **Initializers:** know memberwise, designated, convenience, failable, required, and `init(from:)`.
- **Optionals:** `if let` for side branches, `guard let` for preconditions.
- **`[weak self]`:** avoid retain cycles in stored closures and long-lived async work.
- **Core Data + `NSManagedObject`:** persistence, change tracking, querying, lazy loading, relationships, and undo — all for free.
