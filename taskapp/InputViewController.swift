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
        }
        
        super.viewWillDisappear(animated)
    }
    
}
