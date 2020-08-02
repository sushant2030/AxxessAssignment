//
//  RealmDataModel.swift
//  CavistaAssignement
//
//  Created by Sushant Alone on 01/08/20.
//  Copyright © 2020 Sushant Alone. All rights reserved.
//

import Foundation
import RealmSwift

class ItemObject : Object {
    @objc dynamic var iid = 0
    @objc dynamic var dataType = ""
    @objc dynamic var date = ""
    @objc dynamic var data = ""
    @objc dynamic var imgWidth = 0.0
    @objc dynamic var imgHeight = 0.0
    override static func primaryKey() -> String? {
        return "iid"
    }
}


extension ItemDataModel: Persistable {
    public init(managedObject: ItemObject) {
        id = "\(managedObject.iid)"
        type = DataType(rawValue: managedObject.dataType)!
        date = managedObject.date
        data = managedObject.data
        imgWidth = managedObject.imgWidth
        imgHeight = managedObject.imgHeight
    }
    public func managedObject() -> ItemObject {
        let item = ItemObject()
        item.iid = Int(id) ?? 0
        item.dataType = type.rawValue
        item.date = date ?? ""
        item.data = data ?? ""
        item.imgWidth = imgWidth ?? 0.0
        item.imgHeight = imgHeight ?? 0.0
        return item
    }
}
