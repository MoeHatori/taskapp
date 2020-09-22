//
//  Task.swift
//  taskapp
//
//  Created by Chan Yama on 2020/09/17.
//  Copyright © 2020 moe.hatori2. All rights reserved.
//

import RealmSwift

class Task: Object {
    // 管理用 ID　プライマリーキー
    @objc dynamic var id = 0

    // タイトル
    @objc dynamic var title = ""

    // 内容
    @objc dynamic var contents = ""

    // 日時
    @objc dynamic var date = Date()
    
    //★カテゴリを追加
    @objc dynamic var category = ""

    // id をプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "id"
    }
}
