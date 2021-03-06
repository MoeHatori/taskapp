//
//  ViewController.swift
//  taskapp
//
//  Created by Chan Yama on 2020/09/17.
//  Copyright © 2020 moe.hatori2. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    //TableViewを使うからデリゲートを宣言

    //★searchBarを使うための宣言
    @IBOutlet weak var searchBar: UISearchBar!
    
    //TableViewを使うための宣言
    @IBOutlet weak var tableView: UITableView!
       
    
    //Realmインスタンスを取得
    let realm = try! Realm()
    
    //日付でソートするタスクが格納されるリスト
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    
    //検索結果の配列
    var searchResult = try! Realm().objects(Task.self)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        searchBar.enablesReturnKeyAutomatically = false
        
        searchResult = taskArray
        
    }
    
    //セル数を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return taskArray.count
        return searchResult.count
    }
    
    //各セルの内容を返すメソッド
    //セルを生成して返却するメソッドで、セルの数だけ呼び出される
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell" ,for: indexPath)
        
        let task = searchResult[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let categoryString:String = task.category
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = "日付：\(dateString)  カテゴリー：\(categoryString)"
        
        return cell
    }
    
    //★文字列検索
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        
        if (searchBar.text == ""){
            searchResult = taskArray
        }else{
            searchResult = try! Realm().objects(Task.self).filter("category = %@",searchBar.text!)
            print(searchResult)
        }
        tableView.reloadData()
        
    }
    
    
    
    
    //各セルを選択したときに実行されるメソッド
    //セルをタップしたときにタスク入力画面に遷移させる
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
    //セルが削除可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    
    //Deleteボタンが押されたときに呼ばれるメソッド
    //DBからタスクを削除する
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            // 削除するタスクを取得する
            let task = self.taskArray[indexPath.row]

            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])

            // データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }

            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
    }
    
    
    //segueで遷移するときに呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController

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
    
    //戻ってきたときにてtableviewを更新する
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }


}

