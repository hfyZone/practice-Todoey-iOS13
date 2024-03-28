//
//  Catehory.swift
//  Todoey
//
//  Created by 韩飞洋 on 2024/3/26.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift
class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var colorHex: String = ""
    //外键,Realm provides the List methord
    let items = List<Item>()
}
