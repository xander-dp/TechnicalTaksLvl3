//
//  UserEntityMO.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 21.01.25.
//

import CoreData

final class UserEntityMO: NSManagedObject, Identifiable {
    @NSManaged var email: String
    @NSManaged public var birthData: BirthDataMO
    @NSManaged public var name: NameMO
    @NSManaged public var picture: UserPictureMO
    
    static let entityName = "UserEntity"
    
    @nonobjc static func fetchRequest() -> NSFetchRequest<UserEntityMO> {
        return NSFetchRequest<UserEntityMO>(entityName: Self.entityName)
    }
    
    convenience init(context: NSManagedObjectContext, with entity: UserEntity) {
        self.init(context: context)
        
        self.email = entity.email
        self.name = NameMO(context: context, with: entity.name)
        self.birthData = BirthDataMO(context: context, with: entity.birthData)
        self.picture = UserPictureMO(context: context, with: entity.picture)
    }
    
    func toUserEntity() -> UserEntity {
        let name = Name(title: name.title, first: name.first, last: name.last)
        let birthData = BirthData(date: birthData.date, age: birthData.age)
        let picture = UserPicture(medium: picture.medium, large: picture.large)
        
        return UserEntity(email: email, name: name, birthData: birthData, picture: picture)
    }
}

final class NameMO: NSManagedObject, Identifiable {
    @NSManaged var first: String
    @NSManaged var last: String
    @NSManaged var title: String
    @NSManaged var user: UserEntityMO

    //tmp
    //TODO: delete
    @nonobjc public class func fetchRequest() -> NSFetchRequest<NameMO> {
        return NSFetchRequest<NameMO>(entityName: "Name")
    }
    
    convenience init(context: NSManagedObjectContext, with entity: Name) {
        self.init(context: context)
        
        self.title = entity.title
        self.first = entity.first
        self.last = entity.last
    }
}

final class BirthDataMO: NSManagedObject, Identifiable {
    @NSManaged var date: Date
    @NSManaged var age: Int
    @NSManaged var user: UserEntityMO
    
    convenience init(context: NSManagedObjectContext, with entity: BirthData) {
        self.init(context: context)
        
        self.date = entity.date
        self.age = entity.age
    }
}

final class UserPictureMO: NSManagedObject, Identifiable {
    @NSManaged var medium: String
    @NSManaged var large: String
    @NSManaged var user: UserEntityMO
    
    convenience init(context: NSManagedObjectContext, with entity: UserPicture) {
        self.init(context: context)
        
        self.medium = entity.medium
        self.large = entity.large
    }
}
