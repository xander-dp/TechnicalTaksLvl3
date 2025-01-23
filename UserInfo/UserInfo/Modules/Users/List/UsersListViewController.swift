//
//  UsersListViewController.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 21.01.25.
//

import UIKit
import Combine

final class UserCell: UITableViewCell {
    static let identifier = "userCellReuseIdentifier"
}

fileprivate enum Section {
    case main
}

final class UsersListViewController: UIViewController {
    var viewModel: UsersListViewModel!
    
    private var dataSource: UITableViewDiffableDataSource<Section, UserEntityUIRepresentation>! = nil
    private var entities: [UserEntityUIRepresentation] = []
    private var fetchedCount: Int = 0
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.identifier)
        tableView.refreshControl = refreshControl
        return tableView
    }()
    
    private let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .primaryActionTriggered)
        return refreshControl
    }()
    
    private lazy var exitButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem()
        barButton.title = "Exit"
        barButton.style = .plain
        barButton.target = self
        barButton.action = #selector(exitButtonTapped)
        return barButton
    }()
    
    private lazy var logoutButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem()
        barButton.title = "Logout"
        barButton.style = .plain
        barButton.target = self
        barButton.action = #selector(logoutButtonTapped)
        return barButton
    }()
    
    private var cancellables = Set<AnyCancellable>()
    
    private let viewReadySubject = PassthroughSubject<Void, Never>()
    private let needImageForItem = PassthroughSubject<UserEntityUIRepresentation, Never>()
    private let cellSelected = PassthroughSubject<Int, Never>()
    private let refreshSubject = PassthroughSubject<Void, Never>()
    private let requestMoreDataSubject = PassthroughSubject<Void, Never>()
    private let logoutInitiatedSubject = PassthroughSubject<Void, Never>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        initDataSource()
        bindViewModel()
        
        viewReadySubject.send()
    }
    
    private func setupLayout() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func bindViewModel() {
        let input = UsersListViewModel.Input(
            viewReady: viewReadySubject.eraseToAnyPublisher(),
            entityNeedImage: needImageForItem.eraseToAnyPublisher(),
            newDataRequired: requestMoreDataSubject.eraseToAnyPublisher(),
            itemSelected: cellSelected.eraseToAnyPublisher(),
            dataRefresh: refreshSubject.eraseToAnyPublisher(),
            logoutInitiated: logoutInitiatedSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        
        output.sessionType
            .sink { [weak self] type in
                guard let type else {
                    self?.processInvalidSession()
                    return
                }
                
                let button: UIBarButtonItem?
                switch type {
                case .guest:
                    button = self?.exitButton
                case .user:
                    button = self?.logoutButton
                }
                self?.navigationItem.rightBarButtonItem = button
            }
            .store(in: &cancellables)
        
        output.dataFetched
            .sink { [weak self] data in
                if !data.isEmpty {
                    if var snapshot = self?.dataSource.snapshot() {
                        snapshot.appendItems(data)
                        self?.updateDataSource(with: snapshot)
                    }
                } else {
                    self?.requestMoreDataSubject.send()
                }
            }
            .store(in: &cancellables)
        
        output.dataUpdate
            .drop(while: { entities in
                entities.isEmpty
            })
            .sink { [weak self] data in
                if var snapshot = self?.dataSource.snapshot() {
                    snapshot.appendItems(data)
                    self?.updateDataSource(with: snapshot)
                }
                self?.refreshControl.endRefreshing()
            }
            .store(in: &cancellables)
        
        output.imageLoaded
            .sink { loadedImage, entity in
                if loadedImage != entity.image {
                    var updatedSnapshot = self.dataSource.snapshot()
                    if let datasourceIndex = updatedSnapshot.indexOfItem(entity){
                        let item = updatedSnapshot.itemIdentifiers[datasourceIndex]
                        item.image = loadedImage
                        updatedSnapshot.reloadItems([item])
                        self.updateDataSource(with: updatedSnapshot)
                    }
                }
            }
            .store(in: &self.cancellables)
        
        output.loadedItemsCount
            .sink { [weak self] count in
                self?.fetchedCount = count
            }
            .store(in: &cancellables)
        
        output.errorPublisher
            .sink { [weak self] description in
                self?.showErrorAlert(errorMessage: description)
            }
            .store(in: &cancellables)
    }
    
    private func initDataSource() {
        self.dataSource = UITableViewDiffableDataSource<Section, UserEntityUIRepresentation>(
            tableView: self.tableView
        ) { tableView, indexPath, entity in
            let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.identifier, for: indexPath)
            
            if entity.needImageLoading {
                self.needImageForItem.send(entity)
            }
            
            var content = cell.defaultContentConfiguration()
            content.text = entity.name
            content.secondaryText = "\(entity.birthDate) (\(entity.age) y.o.)"
            content.image = entity.image
            
            cell.contentConfiguration = content
            return cell
        }
        
        self.dataSource.defaultRowAnimation = .automatic
        
        setInitialSnapshot()
    }
    
    private func setInitialSnapshot() {
        var initialSnapshot = NSDiffableDataSourceSnapshot<Section, UserEntityUIRepresentation>()
        initialSnapshot.appendSections([.main])
        initialSnapshot.appendItems(entities)
        self.dataSource.apply(initialSnapshot, animatingDifferences: true)
    }
    
    @objc private func refreshData() {
        self.setInitialSnapshot()
        refreshSubject.send()
    }
    
    @objc private func exitButtonTapped() {
        let alert = UIAlertController(
            title: "Ending sesion",
            message: "Thank you for trialing this app",
            preferredStyle: .alert
        )
        
        let okButton = UIAlertAction(title: "OK", style: .default) { _ in
            self.logoutInitiatedSubject.send()
        }
        
        alert.addAction(okButton)
        
        self.present(alert, animated: true)
    }
    
    @objc private func logoutButtonTapped() {
        logoutInitiatedSubject.send()
    }
    
    private func processInvalidSession() {
        let alert = UIAlertController(
            title: "Error",
            message: "Session invalid",
            preferredStyle: .alert
        )
        
        let okButton = UIAlertAction(title: "OK", style: .default) { _ in
            self.logoutInitiatedSubject.send()
        }
        
        alert.addAction(okButton)
        
        self.present(alert, animated: true)
    }
    
    private func showErrorAlert(errorMessage: String) {
        let alert = UIAlertController(
            title: "Error",
            message: errorMessage,
            preferredStyle: .alert
        )
        
        let okButton = UIAlertAction(title: "OK", style: .default) { _ in
            alert.dismiss(animated: true)
        }
        
        alert.addAction(okButton)
        
        self.present(alert, animated: true)
    }
    
    private func updateDataSource(with snapshot: NSDiffableDataSourceSnapshot<Section, UserEntityUIRepresentation>) {
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension UsersListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        cellSelected.send(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == fetchedCount - 1 {
            requestMoreDataSubject.send()
        }
    }
}
