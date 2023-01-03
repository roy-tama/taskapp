//
//  InputViewController.swift
//  taskapp
//
//  Created by 牧野達也 on 2022/12/31.
//

import UIKit
import RealmSwift

class InputViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var dataPicker: UIDatePicker!
    @IBOutlet weak var categoryTextField: UITextField!
    var task: Task!
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶ
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        // 各プロパティにtaskオブジェクトの対応する内容を代入
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        dataPicker.date = task.date
        categoryTextField.text = task.category
        
    }
    
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.dataPicker.date
            self.realm.add(self.task, update: .modified)
            self.task.category = self.categoryTextField.text!    // カテゴリ追加
        }
        setNotification(task: task)
        super.viewWillDisappear(animated)
    }
    
    func setNotification(task: Task){
        let content = UNMutableNotificationContent()
        // タイトルと内容を設定（中身がない場合、メッセージ無しで音だけの通知になるので「（XXなし）」を表示する）
        if task.title == "" {
            content.title = "タイトルなし"
        } else if task.category == "" {
            content.title = "タイトルあり、カテゴリなし"
        } else {
            content.title = task.title
        }
        if task.contents == "" {
            content.body = "(内容なし)"
        } else {
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default
        
        // ローカル通知が発動するtrigger（日付マッチ）を作成
        let calender = Calendar.current
        let dateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        // identifier, content, triggerからローカル通知を作成（identifierが同じであればローカルを上書き保存）
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
        
        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録　OK") //errorがnilならローカル通知に成功したと表示。errorが存在すればerrorを返す
        }
        
        // 未知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests{ (requests: [UNNotificationRequest]) in
            for request in requests{
                print("/---------------")
                print(request)
                print("---------------/")
            }
        }
            
    }
}
