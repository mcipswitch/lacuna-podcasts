//
//  SearchResultsController.swift
//  LacunaPodcasts
//
//  Created by Priscilla Ip on 2020-07-13.
//  Copyright © 2020 Priscilla Ip. All rights reserved.
//

import UIKit

protocol SearchResultsControllerDelegate: class {
    func didSelectSearchResult(_ episode: Episode)
}

class SearchResultsController: UITableViewController {
    
    weak var delegate: SearchResultsControllerDelegate?
    
    deinit { print("SearchResultsController memory being reclaimed...") }

    var filteredEpisodes: [Episode] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var isLoading: Bool = false {
        didSet {
            tableView.reloadData()
        }
    }
    
    //MARK: - Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
        setupObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIApplication.mainNavigationController()?.miniPlayerIsVisible == true {
            let miniPlayerViewHeight = UIApplication.mainNavigationController()?.minimizedTopAnchorConstraint.constant ?? 0
            //guard let safeAreaInsetBottom = UIWindow.key?.safeAreaInsets.bottom else { return }
            tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -miniPlayerViewHeight, right: 0)
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -miniPlayerViewHeight, right: 0)
        }
    }
    
    //MARK: - Setup Observers
    
    fileprivate func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleSearchControllerProgress), name: .searchControllerProgress, object: nil)
    }
    
    @objc private func handleSearchControllerProgress(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any] else { return }
        guard let searchText = userInfo["searchText"] as? String else { return }
        
        DispatchQueue.main.async {
            self.noResultsView.searchTextLabel.text = "Couldn't find \"\(searchText)\""
        }
    }
    
    // MARK: - Subviews

    let noResultsView: NoResultsView = {
        let view = NoResultsView()
        view.isHidden = true
        return view
    }()
    
    //MARK: - Setup
    
    private func setupView() {
        view.backgroundColor = UIColor.appColor(.midnight)
        view.addSubview(noResultsView)
        setupLayouts()
        noResultsView.isHidden = view.checkIfSubViewOfTypeExists(type: UIActivityIndicatorView.self) == true ? true : false
    }
    
    private func setupLayouts() {
        noResultsView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        noResultsView.center(in: view, xAnchor: true, yAnchor: false)
    }
    
    fileprivate func setupTableView() {
        tableView.separatorColor = UIColor.appColor(.blue)
        tableView.tableFooterView = UIView()
        tableView.register(EpisodeCell.nib, forCellReuseIdentifier: EpisodeCell.reuseIdentifier)
        tableView.keyboardDismissMode = .onDrag
    }
    
    //MARK: - TableView
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = filteredEpisodes[indexPath.row]
        dismiss(animated: true) {
            self.delegate?.didSelectSearchResult(episode)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredEpisodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EpisodeCell.reuseIdentifier, for: indexPath) as? EpisodeCell else { fatalError() }
        cell.episode = filteredEpisodes[indexPath.row]
        cell.episodeImageView.isHidden = false
        cell.detailsLabel.isHidden = true
        cell.descriptionLabel.numberOfLines = 2
        DispatchQueue.main.async {
            cell.isActive = true
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        K.downloadEpisodeCellHeight
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if isLoading {
            noResultsView.isHidden = true
            return AlertService.showActivityIndicator()
        } else {
            noResultsView.isHidden = false
            return UIView()
        }
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if filteredEpisodes.isEmpty {
            return K.downloadEpisodeCellHeight
        } else {
            noResultsView.isHidden = true
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
    }
}


