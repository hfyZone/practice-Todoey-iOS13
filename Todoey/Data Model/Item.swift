//
//  Item.swift
//  Todoey
//
//  Created by 韩飞洋 on 2024/3/26.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item:Object{
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    //对应Item的let items = List<Item>()
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
