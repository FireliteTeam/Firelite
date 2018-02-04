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
    
    func saveManyChilds(context : NSManagedObjectContext, dictionnary : [String:Any], entityName : String = "\(String(describing: type(of: self)).lowercased)s"){
        //Save all object if array is detected or just save one
        for snapshot in dictionnary{
            guard let json = snapshot.value as? [String:Any] else {
                saveOneChild(context: context, dictionnary: dictionnary, entityName: entityName)
                return
            }
            guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
                print("No entity \(entityName) in context \(context.name ?? "")")
                return
            }
            
            //Initialize managedObject by finding one with id if exist or create it
            let managedObject = findObjectBy(id: snapshot.key, context: context, entity: entityName) ?? NSManagedObject(entity: entity, insertInto: context)
            let attributes = entity.attributesByName.map({ (key: $0.key,value: $0.value.attributeType)})
            let relationships = entity.relationshipsByName.map({ (key: $0.key,value: $0.value.destinationEntity)})
            fillManagedObject(context : context, managedObject: managedObject, dictionnary: json, attributes: attributes, relationships: relationships)
        }
    }

    func saveOneChild(context : NSManagedObjectContext, dictionnary : [String:Any], entityName : String = "\(String(describing: type(of: self)).lowercased)s"){
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            print("No entity \(entityName) in context \(context.name ?? "")")
            return
        }

        guard let id = dictionnary["id"] as? String else {
            print("No id found in \n\(dictionnary)")
            return
        }

        //Initialize managedObject by finding one with id if exist or create it
        let managedObject = findObjectBy(id: id, context: context, entity: entityName) ?? NSManagedObject(entity: entity, insertInto: context)
        let attributes = entity.attributesByName.map({ (key: $0.key,value: $0.value.attributeType)})
        let relationships = entity.relationshipsByName.map({ (key: $0.key,value: $0.value.destinationEntity)})
        fillManagedObject(context : context, managedObject: managedObject, dictionnary: dictionnary, attributes: attributes, relationships : relationships)
    }
    
    func fillManagedObject(context : NSManagedObjectContext, managedObject : NSManagedObject, dictionnary : [String:Any], attributes : [(key:String,value:NSAttributeType)], relationships : [(key:String,value:NSEntityDescription?)]){
        //Fill managedobject by checking attributes validity
        for objectAttribut in dictionnary {
            for attribut in attributes {
                if objectAttribut.key == attribut.key {
                    if checkAttributType(type: attribut.value, object: objectAttribut.value){
                        managedObject.setValue(objectAttribut.value, forKey: objectAttribut.key)
                    }else{
                        print("Attribut [\(attribut.key):\(objectAttribut.value)] is in wrong type")
                    }
                    break
                }
            }
            for relationship in relationships {
                // One to One / One to Many / Many to Many
                if objectAttribut.key == relationship.key,
                    let entity = relationship.value {
                    if let id = objectAttribut.value as? String{
                        //to One
                        var relationObject = findObjectBy(id: id, context: context, entity: entity.name ?? "")
                        if relationObject == nil {
                            relationObject = NSManagedObject(entity: entity, insertInto: context)
                            relationObject?.setValue(id, forKey: "id")
                        }
                        managedObject.setValue(relationObject, forKey: objectAttribut.key)
                        break
                    }else if let ids = objectAttribut.value as? [String:Any]{
                        //to Many
                        var array : [NSManagedObject] = []
                        for id in ids.keys{
                            var relationObject = findObjectBy(id: id, context: context, entity: entity.name ?? "")
                            if relationObject == nil {
                                relationObject = NSManagedObject(entity: entity, insertInto: context)
                                relationObject?.setValue(id, forKey: "id")
                            }
                            if let relationObject = relationObject{
                                array.append(relationObject)
                            }
                        }
                        managedObject.setValue(NSSet(array: array), forKey: objectAttribut.key)
                        break
                    }
                }
            }
        }
        
        print(managedObject)
    }
    
    func checkAttributType(type : NSAttributeType, object : Any) -> Bool{
        //return true when is valid
        switch type {
        case .stringAttributeType:
            return (object as? String) != nil
        case .doubleAttributeType:
            return (object as? Double) != nil
        case .floatAttributeType:
            return (object as? Float) != nil
        case .integer16AttributeType:
            return (object as? Int) != nil
            
        default:
            return false
        }
    }
}
