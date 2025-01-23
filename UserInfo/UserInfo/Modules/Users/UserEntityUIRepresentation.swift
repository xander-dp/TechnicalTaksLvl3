//
//  UserEntityUIRepresentation.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 22.01.25.
//

import UIKit
import Combine

final class UserEntityUIRepresentation: Hashable {
    enum DefaultImages {
        static let placeHolderImage = UIImage(systemName: "photo.circle.fill")
        static let errorLoadingImage = UIImage(systemName: "photo.badge.exclamationmark")
    }
    
    let email: String
    let name: String
    let fullName: String
    let birthDate: String
    let age: String
    var image: UIImage?
    
    var needImageLoading: Bool {
        self.image == DefaultImages.placeHolderImage
    }
    
    init(with entity: UserEntity) {
        self.email = entity.email
        self.name = "\(entity.name.first) \(entity.name.last)"
        self.fullName = entity.name.full
        self.birthDate = entity.birthData.date.formatted(date: .abbreviated, time: .omitted)
        self.age = String(entity.birthData.age)
        self.image = DefaultImages.placeHolderImage
    }
    
    static func == (lhs: UserEntityUIRepresentation, rhs: UserEntityUIRepresentation) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
