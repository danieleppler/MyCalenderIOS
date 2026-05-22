# MyCalender — Architecture Overview

Five architectural decisions that shape this app, and why each was chosen over its alternatives.

---

## 1. UIKit + Storyboards + MVC (not SwiftUI)

**Decision.** Every screen is a `UIViewController` subclass declared in `Main.storyboard`, with `@IBOutlet` / `@IBAction` wiring the storyboard to Swift. The main flow is plain MVC.

**Why.** The app does a lot of *bespoke* drawing — the day view's hourly canvas (`timeToY`, hand-positioned event blocks), the multi-day banner that spans across month-grid cells with `CACornerMask`, and the day cell that renders a stack of variable-color banners. Those layouts depend on precise frame math, gesture recognizers, and direct layer manipulation that UIKit is built for.

**Alternative considered.** SwiftUI + Combine. Rejected because SwiftUI is awkward for absolutely-positioned content and for cross-cell drawing tricks. SwiftUI's `@FetchRequest` would also couple views to Core Data more tightly than the explicit-fetch pattern used here.

---

## 2. Core Data through a singleton `EventStore`

**Decision.** All event CRUD flows through `EventStore.shared` (`save`, `fetchEvents(forMonth:year:)`, `delete`). Holidays use a parallel `HolidaysStore`. View controllers never touch `NSManagedObjectContext` except when calling `Event(context:)`.

**Why.** Concentrating persistence in one type means future cross-cutting concerns (logging, threading, batched saves, notifications) have exactly one place to live. A controller calling `eventStore.delete(event)` is also more self-documenting than scattered `context.delete`/`context.save` pairs.

**Alternative considered.** A repository protocol with dependency injection (separate test/preview implementations). Useful in a multi-target codebase, but overkill here — there are no tests or previews to satisfy. The singleton is the cheapest reasonable abstraction.

---

## 3. In-memory domain model (`CalenderDay`) layered over Core Data

**Decision.** `CalenderDay` is a plain Swift class — *not* an `NSManagedObject` — holding `dayNumber`, `month`, `monthType` (`.previous`/`.current`/`.next`), and arrays of `Event` / `Holiday`. `CalenderDaysDataSource.buildCalendarDays(year:month:)` rebuilds the 42-cell grid for every month load.

**Why.** The month grid is *presentational state*, not persistent data. It always shows 42 cells (6 × 7) including leading/trailing days from adjacent months. Persisting that structure would mean writing UI state to disk and keeping it in sync as the user swipes between months. Building it in memory on each `loadMonth(_:year:)` is cheap and keeps the model honest: only events and holidays are real, the calendar layout is computed.

**Alternative considered.** A managed `Day` entity with relationships. Rejected because every month switch would require either ad-hoc graph mutation or expensive fetch + diff. The in-memory approach is O(42) and synchronous.

---

## 4. Closure-based callbacks for VC-to-VC communication

**Decision.** When a child screen needs to push a result back to its parent, the parent sets a closure on the child inside `prepare(for:)`. Examples:
- `EventDetailsPresentationViewController.onEventDeleted` → `DayViewViewController` removes the canvas view.
- `EventDetailsViewController.onEventUpdated` → `EventDetailsPresentationViewController.populateFields()`.
- `AddLocationViewController.onLocationSelected` → updates the "Add location" button title.
- `CalenderDaysDataSource.onHolidaysLoaded` → triggers a collection-view reload.

**Why.** Storyboard segues instantiate the destination for us, so there's no constructor available to inject a delegate. Closures are local, lightweight, and don't require declaring a one-callback protocol per screen. They also keep the call site readable — you can see right next to `performSegue` what should happen on completion.

**Alternative considered.** Delegate protocols — clean but verbose for single-callback handoffs. `NotificationCenter` — tried briefly for the delete-event flow and reverted; the loose coupling made cause-and-effect harder to trace, and ordering against `dismiss(animated:)` was fragile.

---

## 5. Programmatic-UI islands inside storyboard scenes

**Decision.** Storyboards lay out the static skeleton; dynamic, data-driven UI is built in Swift inside the controllers:
- Day view's event blocks, hour lines, current-time indicator, and all-day banners are constructed programmatically in `viewDidLayoutSubviews`.
- The month header is an empty 60pt UIView in the storyboard; the horizontal `UICollectionView` of month "cubes" is created in code.
- `AddLocationViewController` is a near-empty storyboard scene; its search bar + table view + back button are added programmatically.
- The toast, the color-preset menu (`UIMenu`), and the delete action menu live entirely in code.

**Why.** Storyboards work well for fixed forms (Event Details has a stable list of rows) but become friction-y when content depends on data: variable counts, dynamic sizing, custom per-cell corners, or context-driven layout. The hybrid approach keeps the storyboard small and predictable while letting controllers compose any UI they need at runtime.

**Alternative considered.** All-storyboard — impractical for the day-view canvas and the month banner that spans multiple cells. All-programmatic — would lose IB scene previews and the convenience of `@IBOutlet` wiring on the larger forms. The hybrid trades a little extra discipline (knowing which layer "owns" a screen) for ergonomic edits in both.
