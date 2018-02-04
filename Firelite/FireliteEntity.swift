//
//  FireliteEntity.swift
//  Firelite
//
//  Created by Alexandre Ménielle on 04/02/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import CoreData

open class FireliteEntity : NSObject {
    
    public enum Method {
        case insert
        case delete
    }
    
    public override init() {
        let objectName = String(describing: type(of: self))
        print("init " + objectName + " as FireliteEntity")
    }
    
    func findObjectBy(id : String, context : NSManagedObjectContext, entity: String) -> NSManagedObject?{
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: entity)
        request.predicate = NSPredicate(format: "%K == %@", "id", id)
        let objects = try? context.fetch(request)
        return objects?.first
    }
    
}
