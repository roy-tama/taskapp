//
//  Task.swift
//  taskapp
//
//  Created by 牧野達也 on 2023/01/01.
//

import RealmSwift

class Task: Object {
    // 管理用ID。プライマリーキー
    @objc dynamic var id = 0
    
    // タイトル
    @objc dynamic var title = ""
    
    // 内容
    @objc dynamic var contents = ""
    
    // 日時
    @objc dynamic var date = Date()
    
    // カテゴリ追加
    @objc dynamic var category: String = ""
    
    // IDをプライマリキーとして設定
    override static func primaryKey() -> String? {
        return "id"
    }
}
