//
//  UserDetailsViewModel.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 23.01.25.
//

import Combine
import UIKit

final class UserDetailsViewModel {
    struct Input {
        let viewReady: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let presentData: AnyPublisher<UserEntityUIRepresentation, Never>
        let imageLoaded: AnyPublisher<UIImage?, Never>
    }
    
    private let imageLoadedSubject = PassthroughSubject<UIImage?, Never>()
    
    private let cancellables = Set<AnyCancellable>()
    private let entity: UserEntity
    private let imageLoader: ImageLoader
    
    init(entity: UserEntity, imageLoader: ImageLoader) {
        self.entity = entity
        self.imageLoader = imageLoader
    }
    
    func transform(_ input: Input) -> Output {
        let presentData = input.viewReady
            .flatMap {
                let representation = UserEntityUIRepresentation(with: self.entity)
                if representation.needImageLoading {
                    self.requestImage()
                }
                return Just(representation)
            }
            .eraseToAnyPublisher()
        
        let imageLoaded = imageLoadedSubject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        return Output(presentData: presentData, imageLoaded: imageLoaded)
    }
    
    private func requestImage() {
        Task {
            do {
                let data = try await imageLoader.getImageData(absoluteURL: entity.picture.large)
                let image = UIImage(data: data) ?? UserEntityUIRepresentation.DefaultImages.errorLoadingImage
                imageLoadedSubject.send(image)
            } catch {
                let image = UserEntityUIRepresentation.DefaultImages.errorLoadingImage
                imageLoadedSubject.send(image)
                //log
            }
        }
    }
}
