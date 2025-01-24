//
//  UsersStorageCoreData.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 21.01.25.
//

import CoreData
import OSLog


final class UsersStorageCoreData: NSObject, UsersStorage {
    private static let modelName = "UsersModel"
    
    private let container: NSPersistentContainer
    
    var managedContext: NSManagedObjectContext {
        return self.container.viewContext
    }
    
    lazy var backgroundContext: NSManagedObjectContext = {
        let newbackgroundContext = container.newBackgroundContext()
        newbackgroundContext.automaticallyMergesChangesFromParent = true
        return newbackgroundContext
    }()
    
    override init() {
        self.container = NSPersistentContainer(name: Self.modelName)
        self.container.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
        
        self.container.loadPersistentStores { (storeDescription, error) in
            Logger.dataStorage.error("Unable to load PersistentStore: \(error)")
            assert(
                error == nil,
                "Unable to load CoreData's Persistent Store. Error: \(error.debugDescription)"
            )
        }
    }
    
    private func saveContext() throws {
        guard backgroundContext.hasChanges else { return }
        
        try self.backgroundContext.performAndWait {
            try backgroundContext.save()
        }
    }
    
    func writeUnique(entities: [UserEntity], with token: UUID) async throws(DataStorageError) -> [UserEntity] {
        do {
            try await saveToken(token)
        } catch {
            Logger.dataStorage.error("Unable to save token: \(error)")
        }
        
        var newUniqueEntities: [UserEntity] = []
        
        for entity in entities {
            if !existing(email: entity.email) {
                _ = UserEntityMO(context: self.backgroundContext, with: entity)
                newUniqueEntities.append(entity)
            }
        }
        
        do {
            try saveContext()
        } catch {
            throw DataStorageError.creation
        }
        
        return newUniqueEntities
    }
    
    func read(with token: UUID) async throws(DataStorageError) -> [UserEntity] {
        do {
            if try tokenColidesWithExistent(token) {
                try await clearStorage()
                return []
            }
        } catch {
            Logger.dataStorage.error("Unable to check token before request: \(error)")
        }
        
        let fetchRequest = UserEntityMO.fetchRequest()
        
        do {
            let data = try self.backgroundContext.fetch(fetchRequest)
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
    
    private func saveToken(_ token: UUID) async throws {
        let request = SessionRecordMO.fetchRequest()
        request.fetchLimit = 1
        
        let tokenExist = try self.backgroundContext.count(for: request) > 0
        
        if tokenExist {
            //override & data cleanup
            guard let existentRecord = try self.backgroundContext.fetch(request).first else {
                return
            }
            
            if existentRecord.token != token {
                try await clearStorage()
                existentRecord.token = token
                try saveContext()
            }
        } else {
            //save
            let sessionRecord = SessionRecordMO(context: backgroundContext)
            sessionRecord.token = token
            try saveContext()
        }
    }
    
    private func tokenColidesWithExistent(_ token: UUID) throws -> Bool {
        let request = SessionRecordMO.fetchRequest()
        
        guard let existentRecord = try self.backgroundContext.fetch(request).first else {
            return false
        }
        
        return existentRecord.token != token
    }
    
    private func existing(email: String) -> Bool {
        getEntity(with: email) != nil
    }
    
    private func getEntity(with email: String) -> UserEntityMO? {
          do {
              let lhs = NSExpression(forConstantValue: email)
              let rhs = NSExpression(forKeyPath: "email")
              let predicate = NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .direct, type: .equalTo)
              
              let request = UserEntityMO.fetchRequest()
              request.predicate = predicate
              request.fetchLimit = 1
              
              let entity = try self.backgroundContext.fetch(request)
              return entity.first
          } catch {
              Logger.dataStorage.error("Unable to find entity with email: \(email), error: \(error)")
              return nil
          }
      }
}
