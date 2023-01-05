//
//  ViewController.swift
//  taskapp
//
//  Created by 牧野達也 on 2022/12/31.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Realmインスタンスの取得
    let realm = try!Realm()
    
    // DB内のタスクが格納されるリスト
    // 日付の近い順でソート
    // 以降、内容をアップデートするとリスト内は自動で更新される　＜昇順でソート＞
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    
    var categoryList: [String] = []
    var pickerView: UIPickerView = UIPickerView()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTxtField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 罫線表示
        tableView.fillerRowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self

        // プロトコルの設定
        pickerView.delegate = self
        pickerView.dataSource = self

        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 35))
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ViewController.done))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(ViewController.cancel))
        toolbar.setItems([cancelItem, doneItem], animated: true)
        self.searchTxtField.inputView = pickerView
        self.searchTxtField.inputAccessoryView = toolbar
        
    }
    @objc func cancel() {
        self.searchTxtField.text = ""
        self.searchTxtField.endEditing(true)
    }

    @objc func done() {
        self.searchTxtField.endEditing(true)
        self.searchTxtField.text = "\(categoryList[pickerView.selectedRow(inComponent: 0)])"
    }
    
    // カテゴリリストの作成を行う
    func createCategoryList() {
        var i: Int = 1
        if !categoryList.contains("") {
            categoryList.append("")
        }

        for param in taskArray {
            // 重複カテゴリの削除
            if !categoryList.contains(param.category) {
                categoryList.append(param.category)
                print(String(categoryList.count) + ":" + categoryList[i])
                i += 1
            }
        }
    }

    // -----------------------------------------
    // UIPickerViewDataSource
    // -----------------------------------------

    // ピッカービューに表示する列を返却
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // アイテムの表示個数を返す
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryList.count
    }

    // -----------------------------------------
    // UIPickerViewDelegate
    // -----------------------------------------
    // 表示する文字列を返す
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryList[row]
    }
    
    // 選択時の処理
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if categoryList[row] != "" {
            let predicate = NSPredicate(format: "category==%@", categoryList[row])
            taskArray = try! Realm().objects(Task.self).filter(predicate).sorted(byKeyPath: "date", ascending: true)
        } else {
            taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
        }
        tableView.reloadData()
    }

    // -----------------------------------------
    // UITableViewDataSource
    // -----------------------------------------
    // セルの数を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Realmデータファイルパスの出力
//        print(Realm.Configuration.defaultConfiguration.fileURL)
        // realmで取得したレコード数を返却
        return taskArray.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能なセルを取得
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title + " / Category: " + task.category
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString: String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    // Deleteボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
print("tableview:削除=")

        if editingStyle == .delete {
            // 削除するタスクを取得する
            let task = self.taskArray[indexPath.row]
            
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            // データベースから削除する
            try! realm.write{
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }

//            taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
            createCategoryList()


            // 未通知のローカル通知一覧のログを出力する
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest] ) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
    }

    // -----------------------------------------
    // UITableViewDelegate
    // -----------------------------------------
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // segueのIdentifierを指定して遷移させる
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    // セルが削除可能であることを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
print("tableview:削除可能")
        return.delete
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            inputViewController.task = task
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
print("viewWillAppear")
        //カテゴリリストの作成
        createCategoryList()
        // 入力画面から戻ってきた時にTableViewを更新させる
        tableView.reloadData()
    }
}

