//
//  FireliteTests.swift
//  FireliteTests
//
//  Created by Alexandre Ménielle on 04/02/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import XCTest
@testable import Firelite
import CoreData

class FireliteTests: XCTestCase {
    
    var context : NSManagedObjectContext?
    let fireliteEntity = FireliteEntity()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.context = loadContext()
    }
    
    func testSimpleUser(){
        if let context = self.context {
            let json = ["id":"-L4-LRo4qdULFsH4YdNj","name":"Alex"] as [String:Any]
            fireliteEntity.coreDataSave(method: .insert, context: context, dictionnary: json, entityName: "User")
            let request : NSFetchRequest<User> = User.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", "-L4-LRo4qdULFsH4YdNj")
            if let users = try? context.fetch(request), let user = users.first {
                let managedObjectJson = toJson(managedObject: user)
                for attribut in json {
                    XCTAssertEqual("\(managedObjectJson[attribut.key] ?? "")", "\(attribut.value)")
                }
                return
            }
            XCTFail()
        }
    }
    
    func testSimpleUserFail1(){
        if let context = self.context {
            let json = ["id":"-L4-LRo4qdULFsH4YdNj",name:1] as [String:Any]
            fireliteEntity.coreDataSave(method: .insert, context: context, dictionnary: json, entityName: "User")
            let request : NSFetchRequest<User> = User.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", "-L4-LRo4qdULFsH4YdNj")
            if let users = try? context.fetch(request), let user = users.first {
                let managedObjectJson = toJson(managedObject: user)
                for attribut in json {
                    if attribut.key == "id" {
                        XCTAssertEqual("\(managedObjectJson[attribut.key] ?? "")", "\(attribut.value)")
                    }
                    if attribut.key == "name"{
                        XCTAssertEqual(user.name, nil)
                    }
                }
                return
            }
            XCTFail()
        }
    }
    
    func testDelete(){
        guard let context = self.context else { return }
        let json = ["id":"-L4-LRo4qdULFsH4YdNj","name":"Alex"] as [String:Any]
        fireliteEntity.coreDataSave(method: .insert, context: context, dictionnary: json, entityName: "User")
        let request : NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", "-L4-LRo4qdULFsH4YdNj")
        if let users = try? context.fetch(request), users.count > 0 {
            fireliteEntity.coreDataSave(method: .delete, context: context, dictionnary: json, entityName: "User")
        }
        if let users = try? context.fetch(request) {
            XCTAssertEqual(users.count, 0)
        }
    }
    
    func testOneToOneRelation(){
        if let context = self.context {
            let userJson = ["id":"-L4-LRo4qdULFsH4YdNj",
                            "name":"Alex",
                            "store":"-L4-LRo4qdULFsH4YdNk"] as [String:Any]
            
            fireliteEntity.coreDataSave(method: .insert, context: context, dictionnary: userJson, entityName: "User")
            let request : NSFetchRequest<User> = User.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", "-L4-LRo4qdULFsH4YdNj")
            
            let storeJson = ["id":"-L4-LRo4qdULFsH4YdNk",
                             "name":"Apple Store",
                             "user":"-L4-LRo4qdULFsH4YdNj"] as [String:Any]
            
            fireliteEntity.coreDataSave(method: .insert, context: context, dictionnary: storeJson, entityName: "Store")
            let requestStore : NSFetchRequest<Store> = Store.fetchRequest()
            requestStore.predicate = NSPredicate(format: "id == %@", "-L4-LRo4qdULFsH4YdNk")
            
            if let stores = try? context.fetch(requestStore), let store = stores.first, let users = try? context.fetch(request), let user = users.first, let storeUser = store.user, let userStore = user.store{
                
                XCTAssertEqual(user, storeUser)
                XCTAssertEqual(store, userStore)
            }else{
                XCTFail()
            }
        }
    }
    
    func testOneToOneRelationFail1(){
        if let context = self.context {
            let userJson = ["id":"-L4-LRo4qdULFsH4YdNj",
                            "name":"Alex",
                            "store":"-L4-LRo4qdULFsH4YdNk"] as [String:Any]
            
            fireliteEntity.coreDataSave(method: .insert, context: context, dictionnary: userJson, entityName: "User")
            let request : NSFetchRequest<User> = User.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", "-L4-LRo4qdULFsH4YdNj")
            
            let storeJson = ["id":"-L4-LRo4qdULFsH4YdNk",
                             "name":"Apple Store",
                             "user":"-L4-LRo4qdULFsH4YdN_FAIL"] as [String:Any]
            
            fireliteEntity.coreDataSave(method: .insert, context: context, dictionnary: storeJson, entityName: "Store")
            let requestStore : NSFetchRequest<Store> = Store.fetchRequest()
            requestStore.predicate = NSPredicate(format: "id == %@", "-L4-LRo4qdULFsH4YdNk")
            
            if let stores = try? context.fetch(requestStore),
                let store = stores.first,
                let users = try? context.fetch(request),
                let user = users.first {
                
                XCTAssertNotEqual(user.store?.id, "-L4-LRo4qdULFsH4YdNk")
                XCTAssertEqual(store.user?.id, "-L4-LRo4qdULFsH4YdN_FAIL")
            }else{
                XCTFail()
            }
        }
    }
    
    func testOneToOneRelationFail2(){
        if let context = self.context {
            let userJson = ["id":"-L4-LRo4qdULFsH4YdNj",
                            "name":"Alex",
                            "store":"-L4-LRo4qdULFsH4YdN_FAIL1"] as [String:Any]
            
            fireliteEntity.coreDataSave(method: .insert, context: context, dictionnary: userJson, entityName: "User")
            let request : NSFetchRequest<User> = User.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", "-L4-LRo4qdULFsH4YdNj")
            
            let storeJson = ["id":"-L4-LRo4qdULFsH4YdNk",
                             "name":"Apple Store",
                             "user":"-L4-LRo4qdULFsH4YdN_FAIL2"] as [String:Any]
            
            fireliteEntity.coreDataSave(method: .insert, context: context, dictionnary: storeJson, entityName: "Store")
            let requestStore : NSFetchRequest<Store> = Store.fetchRequest()
            requestStore.predicate = NSPredicate(format: "id == %@", "-L4-LRo4qdULFsH4YdNk")
            
            if let stores = try? context.fetch(requestStore),
                let store = stores.first,
                let users = try? context.fetch(request),
                let user = users.first {
                
                XCTAssertNotEqual(user.store?.id, "-L4-LRo4qdULFsH4YdNk")
                XCTAssertNotEqual(store.user?.id, "-L4-LRo4qdULFsH4YdNj")
            }else{
                XCTFail()
            }
        }
    }
    
    func testOneToManyRelation(){
        if let context = self.context {
            let userJson = ["id":"-L4-LRo4qdULFsH4YdNj",
                            "name":"Alex",
                            "animals":
                                ["-L4-LRo4qdULFsH4YdN1":true,
                                 "-L4-LRo4qdULFsH4YdN2":true]
                ] as [String:Any]
            
            fireliteEntity.coreDataSave(method: .insert, context: context, dictionnary: userJson, entityName: "User")
            let request : NSFetchRequest<User> = User.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", "-L4-LRo4qdULFsH4YdNj")
            
            let animalJson1 = ["id":"-L4-LRo4qdULFsH4YdN1",
                               "name":"Idefix",
                               "user":"-L4-LRo4qdULFsH4YdNj"] as [String:Any]
            fireliteEntity.coreDataSave(method: .insert, context: context, dictionnary: animalJson1, entityName: "Animal")
            
            let animalJson2 = ["id":"-L4-LRo4qdULFsH4YdN2",
                               "name":"Minou",
                               "user":"-L4-LRo4qdULFsH4YdNj"] as [String:Any]
            fireliteEntity.coreDataSave(method: .insert, context: context, dictionnary: animalJson2, entityName: "Animal")
            
            let requestAnimal : NSFetchRequest<Animal> = Animal.fetchRequest()
            requestAnimal.predicate = NSPredicate(format: "user.id == %@", "-L4-LRo4qdULFsH4YdNj")
            
            if let animals = try? context.fetch(requestAnimal), let users = try? context.fetch(request), let user = users.first, let userAnimals = user.animals?.allObjects as? [Animal]{
                
                for animal in userAnimals {
                    XCTAssertEqual(animal.user, user)
                    XCTAssertTrue(animals.contains(animal))
                }
                //XCTAssertEqual(animals, userAnimals) ne fonctionne pas quand pas dans le même ordre
                XCTAssertEqual(animals.count, 2)
                XCTAssertEqual(animals.count, userAnimals.count)
            }else{
                XCTFail()
            }
        }
    }
    
    func testOneToManyRelationFail1(){
        if let context = self.context {
            let userJson = ["id":"-L4-LRo4qdULFsH4YdNj",
                            "name":"Alex",
                            "animals":
                                ["-L4-LRo4qdULFsH4YdN1_FAIL":true,
                                 "-L4-LRo4qdULFsH4YdN2":true]
                ] as [String:Any]
            
            fireliteEntity.coreDataSave(method: .insert, context: context, dictionnary: userJson, entityName: "User")
            let request : NSFetchRequest<User> = User.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", "-L4-LRo4qdULFsH4YdNj")
            
            let animalJson1 = ["id":"-L4-LRo4qdULFsH4YdN1",
                               "name":"Idefix",
                               "user":"-L4-LRo4qdULFsH4YdNj"] as [String:Any]
            fireliteEntity.coreDataSave(method: .insert, context: context, dictionnary: animalJson1, entityName: "Animal")
            
            let animalJson2 = ["id":"-L4-LRo4qdULFsH4YdN2",
                               "name":"Minou",
                               "user":"-L4-LRo4qdULFsH4YdNj"] as [String:Any]
            fireliteEntity.coreDataSave(method: .insert, context: context, dictionnary: animalJson2, entityName: "Animal")
            
            let requestAnimal : NSFetchRequest<Animal> = Animal.fetchRequest()
            requestAnimal.predicate = NSPredicate(format: "user.id == %@", "-L4-LRo4qdULFsH4YdNj")
            
            if let animals = try? context.fetch(requestAnimal), let users = try? context.fetch(request), let user = users.first, let userAnimals = user.animals?.allObjects as? [Animal]{
                
                for animal in animals{
                    if animal.name != nil {
                        XCTAssertEqual(animal.user?.id ?? "", "-L4-LRo4qdULFsH4YdNj")
                    }
                }
                XCTAssertNotEqual(userAnimals.map({$0.id ?? ""}), ["-L4-LRo4qdULFsH4YdN1","-L4-LRo4qdULFsH4YdN2"])
            }else{
                XCTFail()
            }
        }
    }
    
    func testOneToManyRelationFail2(){
        if let context = self.context {
            let userJson = ["id":"-L4-LRo4qdULFsH4YdNj",
                            "name":"Alex",
                            "animals":
                                ["-L4-LRo4qdULFsH4YdN1_FAIL":true,
                                 "-L4-LRo4qdULFsH4YdN2_FAIL":true]
                ] as [String:Any]
            
            fireliteEntity.coreDataSave(method: .insert, context: context, dictionnary: userJson, entityName: "User")
            let request : NSFetchRequest<User> = User.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", "-L4-LRo4qdULFsH4YdNj")
            
            let animalJson1 = ["id":"-L4-LRo4qdULFsH4YdN1",
                               "name":"Idefix",
                               "user":"-L4-LRo4qdULFsH4YdNj_FAIL"] as [String:Any]
            fireliteEntity.coreDataSave(method: .insert, context: context, dictionnary: animalJson1, entityName: "Animal")
            
            let animalJson2 = ["id":"-L4-LRo4qdULFsH4YdN2",
                               "name":"Minou",
                               "user":"-L4-LRo4qdULFsH4YdNj_FAIL"] as [String:Any]
            fireliteEntity.coreDataSave(method: .insert, context: context, dictionnary: animalJson2, entityName: "Animal")
            
            let requestAnimal : NSFetchRequest<Animal> = Animal.fetchRequest()
            requestAnimal.predicate = NSPredicate(format: "user.id == %@", "-L4-LRo4qdULFsH4YdNj")
            
            if let animals = try? context.fetch(requestAnimal), let users = try? context.fetch(request), let user = users.first, let userAnimals = user.animals?.allObjects as? [Animal]{
                
                for animal in animals{
                    if animal.name != nil {
                        XCTAssertNotEqual(animal.user?.id ?? "", "-L4-LRo4qdULFsH4YdNj")
                    }
                }
                XCTAssertNotEqual(userAnimals.map({$0.id ?? ""}), ["-L4-LRo4qdULFsH4YdN1","-L4-LRo4qdULFsH4YdN2"])
            }else{
                XCTFail()
            }
        }
    }
    
    func testManyToManyRelation(){
        if let context = self.context {
            let userJson = ["id":"-L4-LRo4qdULFsH4YdNj",
                            "name":"Alex",
                            "classes":
                                ["-L4-LRo4qdULFsH4Ydk1":true,
                                 "-L4-LRo4qdULFsH4Ydk2":true]
                ] as [String:Any]
            
            fireliteEntity.coreDataSave(method: .insert, context: context, dictionnary: userJson, entityName: "User")
            
            let userJson2 = ["id":"-L4-LRo4qdULFsH4YdNj-2",
                             "name":"Kevin",
                             "classes":
                                ["-L4-LRo4qdULFsH4Ydk1":true,
                                 "-L4-LRo4qdULFsH4Ydk2":true]
                ] as [String:Any]
            
            fireliteEntity.coreDataSave(method: .insert, context: context, dictionnary: userJson2, entityName: "User")
            let request : NSFetchRequest<User> = User.fetchRequest()
            //request.predicate = NSPredicate(format: "id == %@", "-L4-LRo4qdULFsH4YdNj")
            
            let classJson1 = ["id":"-L4-LRo4qdULFsH4Ydk1",
                              "name":"B12",
                              "users":["-L4-LRo4qdULFsH4YdNj":true,
                                       "-L4-LRo4qdULFsH4YdNj-2":true]
                ] as [String:Any]
            fireliteEntity.coreDataSave(method: .insert, context: context, dictionnary: classJson1, entityName: "Class")
            
            let classJson2 = ["id":"-L4-LRo4qdULFsH4Ydk2",
                              "name":"A7",
                              "users":["-L4-LRo4qdULFsH4YdNj":true,
                                       "-L4-LRo4qdULFsH4YdNj-2":true]] as [String:Any]
            fireliteEntity.coreDataSave(method: .insert, context: context, dictionnary: classJson2, entityName: "Class")
            
            let requestClass : NSFetchRequest<Class> = Class.fetchRequest()
            //requestClass.predicate = NSPredicate(format: "user.id == %@", "-L4-LRo4qdULFsH4YdNj")
            
            if let classes = try? context.fetch(requestClass), let users = try? context.fetch(request) {
                
                for user in users {
                    if let userClasses = user.classes?.allObjects as? [Class] {
                        for classe in classes {
                            XCTAssertTrue(userClasses.contains(classe))
                        }
                        XCTAssertEqual(userClasses.count, 2)
                        XCTAssertEqual(userClasses.count, classes.count)
                    }else{
                        XCTFail()
                    }
                }
                
                for classe in classes {
                    if let classUsers = classe.users?.allObjects as? [User] {
                        for user in users{
                            XCTAssertTrue(classUsers.contains(user))
                        }
                        XCTAssertEqual(classUsers.count, 2)
                        XCTAssertEqual(classUsers.count, users.count)
                    }else{
                        XCTFail()
                    }
                }
            }else{
                XCTFail()
            }
        }
    }
    
    func toJson(managedObject : NSManagedObject) -> [String:Any]{
        var json : [String:Any] = [:]
        
        let attributes = managedObject.entity.attributesByName.map({ (key: $0.key,value: $0.value.attributeType)})
        let relationships = managedObject.entity.relationshipsByName.map({ (key: $0.key,value: $0.value.destinationEntity)})
        
        for attribute in attributes {
            if let value = managedObject.value(forKey: attribute.key){
                json[attribute.key] = value
            }
        }
        for relationship in relationships {
            if let value = managedObject.value(forKey: relationship.key) as? NSManagedObject{
                if let id = value.value(forKey: "id") as? String {
                    json[relationship.key] = id
                }
            }
            if let values = (managedObject.value(forKey: relationship.key) as? NSSet)?.allObjects as? [NSManagedObject]{
                var jsonRelationships : [String:Bool] = [:]
                for value in values{
                    if let id = value.value(forKey: "id") as? String {
                        jsonRelationships[id] = true
                    }
                }
                json[relationship.key] = jsonRelationships
            }
        }
        
        return json
    }
    
    func loadContext() -> NSManagedObjectContext?{
        
        let bundle = Bundle(for: type(of: self))
        
        guard
            //let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let schemaURL = bundle.url(forResource: "FireliteUnitTests", withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: schemaURL) else { return nil }
        
        
        let storageURL = schemaURL.appendingPathComponent("FireliteTest.sqlite")
        print(storageURL)
        let store = NSPersistentStoreCoordinator(managedObjectModel: model)
        _ = try? store.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storageURL, options: nil)
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = store
        return context
    }
    
}
