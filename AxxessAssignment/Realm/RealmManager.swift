//
//  RealmManager.swift
//  AxxessAssignment
//
//  Created by Sushant Alone on 01/08/20.
//  Copyright © 2020 Sushant Alone. All rights reserved.
//

import Foundation
import RealmSwift


public final class WriteTransaction {
    private let realm: Realm
    internal init(realm: Realm) {
        self.realm = realm
    }
    public func add<T: Persistable>(_ value: T) {
        realm.add(value.managedObject(), update: .all)
    }
}
// Implement the Container
public final class Container {

    private let realm: Realm
    public convenience init() throws {
        try self.init(realm: Realm())
    }
    internal init(realm: Realm) {
        self.realm = realm
    }
    public func write(_ block: (WriteTransaction) throws -> Void)
    throws {
        let transaction = WriteTransaction(realm: realm)
        try realm.write {
            try block(transaction)
        }
    }
    
    func fetchData(with predicate:NSPredicate, classObject: Object.Type) -> Results<Object>{
        return self.realm.objects(classObject).filter(predicate)
    }
}

public protocol Persistable {
    associatedtype ManagedObject: RealmSwift.Object
    init(managedObject: ManagedObject)
    func managedObject() -> ManagedObject
}

extension Persistable {
    
}
