//
//  Data.swift
//  Todoey
//
//  Created by 韩飞洋 on 2024/3/26.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift
//Object协议用于Realm
class Data: Object {
    //object-c 关键字 dynamic允许realm实时监控name并同步到数据库中
    @objc dynamic var name: String = ""
    @objc dynamic var age: Int = 0
}
