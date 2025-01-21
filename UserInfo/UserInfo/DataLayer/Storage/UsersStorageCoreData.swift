//
//  UsersStorageCoreData.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 21.01.25.
//

import CoreData

final class UsersStorageCoreData: NSObject, UsersStorage {
    private static let modelName = "UsersModel"
    
    private let container: NSPersistentContainer
    
    var managedContext: NSManagedObjectContext {
        return self.container.viewContext
    }
    
    override init() {
        self.container = NSPersistentContainer(name: Self.modelName)
        self.container.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
        
        self.container.loadPersistentStores { (storeDescription, error) in
            assert(
                error == nil,
                "Unable to load CoreData's Persistent Store. Error: \(error.debugDescription)"
            )
        }
    }
    
    func write(entities: [UserEntity]) async throws(DataStorageError) {
        for entity in entities {
            _ = UserEntityMO(context: self.managedContext, with: entity)
        }
        
        do {
            try self.managedContext.save()
        } catch {
            throw DataStorageError.creation
        }
    }
    
    func read() async throws(DataStorageError) -> [UserEntity] {
        let fetchRequest = UserEntityMO.fetchRequest()
        
        do {
            let data = try self.managedContext.fetch(fetchRequest)
            return data.map { $0.toUserEntity() }
        } catch {
            throw DataStorageError.reading
        }
    }
    
    func clearStorage() async throws(DataStorageError) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: UserEntityMO.entityName)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            let _ = try self.container.viewContext.execute(batchDeleteRequest)
        } catch {
            throw DataStorageError.deletion
        }
    }
}
