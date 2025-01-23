//
//  UsersListViewModel.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 21.01.25.
//

import Combine
import UIKit

final class UsersListViewModel {
    typealias ImageForItem = (image: UIImage?, item: UserEntityUIRepresentation)
    
    struct Input {
        let viewReady: AnyPublisher<Void, Never>
        let entityNeedImage: AnyPublisher<UserEntityUIRepresentation, Never>
        let newDataRequired: AnyPublisher<Void, Never>
        let itemSelected: AnyPublisher<Int, Never>
        let dataRefresh: AnyPublisher<Void, Never>
        let logoutInitiated: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let sessionType: AnyPublisher<SessionType?, Never>
        let dataFetched: AnyPublisher<[UserEntityUIRepresentation], Never>
        let dataUpdate: AnyPublisher<[UserEntityUIRepresentation], Never>
        let imageLoaded: AnyPublisher<ImageForItem, Never>
        let errorPublisher: AnyPublisher<String, Never>
        let loadedItemsCount: AnyPublisher<Int, Never>
    }
    
    var itemSelected: ((UserEntity) -> Void)?
    var logoutPerformed: (() -> Void)?
    
    private let errorSubject = PassthroughSubject<String, Never>()
    private let dataFetchedSubject = PassthroughSubject<[UserEntity], Never>()
    private let dataLoadedSubject = PassthroughSubject<[UserEntity], Never>()
    private let imageLoadedSubject = PassthroughSubject<ImageForItem, Never>()
    private let entitiesCountSubject = PassthroughSubject<Int, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    private var entities: [UserEntity] = [] {
        didSet {
            entitiesCountSubject.send(entities.count)
        }
    }
    
    private let dataService: UsersDataService
    private let imageLoader: ImageLoader
    private let sessionKeeper: SessionKeeper
    
    //just as long as session could become invalid during the work, we going to fix the state here
    private let session: Session?
    
    init(dataService: UsersDataService, imageLoader: ImageLoader, sessionKeeper: SessionKeeper) {
        self.dataService = dataService
        self.imageLoader = imageLoader
        self.sessionKeeper = sessionKeeper
        self.session = sessionKeeper.getSession()
    }
    
    func transform(input: Input) -> Output {
        let initialized = input.viewReady.share()
        
        initialized
            .sink { [weak self] in
                self?.fetchData()
            }
            .store(in: &cancellables)
                
        let sessionType = initialized
            .flatMap { [weak self] Void -> AnyPublisher<SessionType?, Never> in
                return Just(self?.session?.type).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        
        input.dataRefresh
            .sink { [weak self] in
                self?.updateData(refreshing: true)
            }
            .store(in: &cancellables)
        
        input.entityNeedImage
            .removeDuplicates()
            .sink { [weak self] item in
                self?.loadImage(for: item)
            }
            .store(in: &cancellables)
        
        input.newDataRequired
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] in
                self?.updateData(refreshing: false)
            }
            .store(in: &cancellables)
        
        input.itemSelected
            .sink { [weak self] index in
                if let entity = self?.entities[index] {
                    self?.itemSelected?(entity)
                }
            }
            .store(in: &cancellables)
        
        input.logoutInitiated
            .sink { [weak self] in
                self?.processLogout()
            }
            .store(in: &cancellables)
        
        let dataLoaded = dataLoadedSubject
            .map {
                var uiRepresentations = [UserEntityUIRepresentation]()
                
                $0.forEach { entity in
                    let uiRepresentation = UserEntityUIRepresentation(with: entity)
                    uiRepresentations.append(uiRepresentation)
                }
                
                return uiRepresentations
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        let dataFetched = dataFetchedSubject
            .map {
                var uiRepresentations = [UserEntityUIRepresentation]()
                
                $0.forEach { entity in
                    let uiRepresentation = UserEntityUIRepresentation(with: entity)
                    uiRepresentations.append(uiRepresentation)
                }
                
                return uiRepresentations
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        let imageLoaded = imageLoadedSubject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        let error = errorSubject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        let loadedItemsCount = entitiesCountSubject
            .filter{ $0 != 0 }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        let output = Output(
            sessionType: sessionType,
            dataFetched: dataFetched,
            dataUpdate: dataLoaded,
            imageLoaded: imageLoaded,
            errorPublisher: error,
            loadedItemsCount: loadedItemsCount
        )
        
        return output
    }
    
    private func fetchData() {
        guard let session else {
            return
        }
        
        Task {
            do {
                let data = try await dataService.fetchData(for: session)
                entities = data
                print(data.count)
                data.forEach { e in
                    print(e.name)
                }
                dataFetchedSubject.send(data)
            } catch {
                self.errorSubject.send(error.localizedDescription)
            }
        }
    }
    
    private func updateData(refreshing: Bool) {
        guard let session else {
            return
        }
        
        Task {
            do {
                let data: [UserEntity]
                if refreshing {
                    //drop cached data on refresh
                    entities.removeAll()
                    try await dataService.clearData()
                    
                    data = try await dataService.updateData(in: session, startingFrom: 0)
                } else {
                    data = try await dataService.updateData(in: session, startingFrom: entities.count)
                }
                 
                entities.append(contentsOf: data)
                dataLoadedSubject.send(data)
            } catch {
                self.errorSubject.send(error.localizedDescription)
            }
        }
    }
    
    private func loadImage(for item: UserEntityUIRepresentation) {
        Task {
            do {
                if let dataItem = entities.first(where: { $0.email == item.email }) {
                    let data = try await imageLoader.getImageData(absoluteURL: dataItem.picture.medium)
                    let image = UIImage(data: data) ?? UserEntityUIRepresentation.DefaultImages.errorLoadingImage
                    imageLoadedSubject.send(ImageForItem(image: image, item: item))
                }
            } catch {
                let image = UserEntityUIRepresentation.DefaultImages.errorLoadingImage
                imageLoadedSubject.send(ImageForItem(image: image, item: item))
                //log
            }
        }
    }
    
    private func processLogout() {
        Task {
            try await self.dataService.clearData()
            try await sessionKeeper.invalidateCurrentSession()
            await MainActor.run {
                self.logoutPerformed?()
            }
        }
    }
}
