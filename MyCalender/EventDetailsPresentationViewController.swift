//
//  EventDetailsPresentationViewController.swift
//  MyCalender
//
//  Created by Ron on 18/05/2026.
//

import UIKit

class EventDetailsPresentationViewController: UIViewController {

    var currEvent: Event?
    var onEventDeleted: ((Event) -> Void)?

    @IBOutlet weak var colorBox: UIView!
    @IBOutlet weak var eventTitleTextView: UITextView!
    @IBOutlet weak var eventDateTextView: UITextView!
    @IBOutlet weak var alertTimeDescTextView: UITextView!
    @IBOutlet weak var moreActionsButton: UIButton!

    private let eventStore = EventStore.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        populateFields()
        configureMoreActionsMenu()
    }

    private func configureMoreActionsMenu() {
        let deleteAction = UIAction(
            title: "Delete",
            image: UIImage(systemName: "trash"),
            attributes: .destructive
        ) { [weak self] _ in
            self?.deleteEvent()
        }
        moreActionsButton.menu = UIMenu(children: [deleteAction])
        moreActionsButton.showsMenuAsPrimaryAction = true
    }

    private func deleteEvent() {
        guard let event = currEvent else { return }
        do {
            try eventStore.delete(event)
            onEventDeleted?(event)
            NotificationCenter.default.post(name: .eventStoreDidChange, object: nil)
            dismiss(animated: true)
        } catch {
            print("Failed to delete event: \(error)")
        }
    }

    func populateFields() {
        guard let event = currEvent else { return }
        eventTitleTextView.text = event.eventTitle
        eventDateTextView.text = formatEventDateRange(event)
    }

    private func formatEventDateRange(_ event: Event) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let start = event.eventStartDate.map { dateFormatter.string(from: $0) } ?? ""
        let end = event.eventEndDate.map { dateFormatter.string(from: $0) } ?? ""
        return "\(start) - \(end)"
    }

    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func editTapped(_ sender: Any) {
        performSegue(withIdentifier: "editEvent", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editEvent",
           let editVC = segue.destination as? EventDetailsViewController {
            editVC.currEvent = currEvent
            editVC.onEventUpdated = { [weak self] in
                self?.populateFields()
            }
        }
    }
}

extension Notification.Name {
    static let eventStoreDidChange = Notification.Name("eventStoreDidChange")
}
