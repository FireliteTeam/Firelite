[![Build Status](https://travis-ci.org/FireliteTeam/Firelite.svg?branch=master)](https://travis-ci.org/FireliteTeam/Firelite)
# Firelite

pod 'Firelite'

Object rules :

All your objects need to have an id as String

Relationship rules :

To one :

-entity :
    -id : String
    -attribut : Type
    -object : id (of object relation )

To many :
    -id : String
    -attribut : Type
    -objects :
        - id : true
        - id : true
        -etc...


Some use example  : (look at https://github.com/FireliteTeam/FireliteExample)

```
let fireliteEntity = FireliteEntity()

let entities = ["User":"users",
                "Store":"stores",
                "Product":"products",
                "Operator":"operators"]

func syncCoredataToFirebase(){

    guard let context = self.context else { return }
    for entity in entities{

    ref.child(entity.value).observe(.childAdded, with: { (snapshot) in
        if let json = snapshot.value as? [String:Any]{
            self.fireliteEntity.coreDataSave(context: context, dictionnary: json, entityName: entity.key)
            try? self.context?.save()
        }
    })

    //Update coredata entity at each firebase modifications
    ref.child(entity.value).observe(.childChanged, with: { (snapshot) in
        if let json = snapshot.value as? [String:Any]{
            self.fireliteEntity.coreDataSave(context: context, dictionnary: json, entityName: entity.key)
            try? self.context?.save()
        }
    })

    //Delete coredata entity
    ref.child(entity.value).observe(.childRemoved, with: { (snapshot) in
        if let json = snapshot.value as? [String:Any]{
            self.fireliteEntity.coreDataSave(method: .delete, context: context, dictionnary: json, entityName: entity.key)
            try? self.context?.save()
        }
    })
    }
}

```
