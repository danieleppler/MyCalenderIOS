//
//  AddLocationViewController.swift
//  MyCalender
//

import UIKit
import MapKit

class AddLocationViewController: UIViewController {

    var onLocationSelected: ((String) -> Void)?

    private let backButton = UIButton(type: .system)
    private let searchBar = UISearchBar()
    private let tableView = UITableView()

    private let searchCompleter = MKLocalSearchCompleter()
    private var results: [MKLocalSearchCompletion] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        searchCompleter.delegate = self
        searchCompleter.resultTypes = [.pointOfInterest, .address]
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LocationCell")
    }

    private func setupLayout() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        var backConfig = UIButton.Configuration.plain()
        backConfig.image = UIImage(systemName: "chevron.left")
        backButton.configuration = backConfig
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Search location"
        searchBar.autocapitalizationType = .none
        searchBar.searchBarStyle = .minimal

        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(backButton)
        view.addSubview(searchBar)
        view.addSubview(tableView)

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 8),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            searchBar.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            searchBar.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 4),
            searchBar.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -8),

            tableView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
        ])
    }

    @objc private func backTapped() {
        if presentingViewController != nil {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    private func dismissSelf() {
        if presentingViewController != nil {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}

extension AddLocationViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            results = []
            tableView.reloadData()
            return
        }
        searchCompleter.queryFragment = trimmed
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension AddLocationViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results = completer.results
        tableView.reloadData()
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
        print("Location search failed: \(error)")
    }
}

extension AddLocationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        let result = results[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = result.title
        config.secondaryText = result.subtitle
        cell.contentConfiguration = config
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = results[indexPath.row]
        let locationText = result.subtitle.isEmpty
            ? result.title
            : "\(result.title), \(result.subtitle)"
        onLocationSelected?(locationText)
        dismissSelf()
    }
}
