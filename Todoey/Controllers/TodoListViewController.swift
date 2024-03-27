//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
class TodoListViewController: UITableViewController {

    var toDoItems: Results<Item>?
    let realm = try! Realm()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedCategory: Category? {
        //触发当被设置值时
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
        //在storyboard连接searchBar和控制器？好像现在xcode自己就做了委托了
        //loadItems()
    }
    
    //MARK: - TableView的数据源方法
    //给出一个tableView有多少条数据
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }
    //根据IndexPath生成cell并返回给TV
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "ToDoItemCell")
        print(indexPath)
        if let item = toDoItems?[indexPath.row]{
            print(item)
            //TODO: cell.textLabel已标记弃用，学习UIListContentConfiguration
            cell.textLabel?.text = item.title
            //根据Model状态确定View状态
            cell.accessoryType = item.done ? .checkmark : .none
        }else{
            //如果toDoItems为空，在上一个方法会返回1，这个1的内容指定为如下
            cell.textLabel?.text = "目前未添加备忘录"
        }
        return cell
    }
    
    //MARK: - TableView的用户交互委托方法，备忘录状态变更
    //TV的用户交互row委托方法
    //当用户对tableView的indexPath的cell进行点击操作触发的方法
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO: 删除呢？咋没后续了一会看一下。
        //删除数据
        //context.delete(itemArray[indexPath.row])
        //删除view中的cell元素
        //itemArray.remove(at: indexPath.row)
        //Realm的更改数据
        if let item = toDoItems?[indexPath.row]{
            do{
                try realm.write{
                    //简易实现realm的删除
                    //realm.delete(item)
                    item.done = !item.done
                }
            }catch{
                print("Error saving status, \(error)")
            }
        }
        tableView.reloadData()
    
        //设置tv的当前行取消被选中状态，以实现选中动画
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - 新增项目
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        //新建一个alert窗口，用来给用户新建备忘录
        let alert = UIAlertController(title: "新建备忘录", message: "", preferredStyle: .alert)
        //新建一个alert的action（按钮），在回调函数中确定用户点击”增加“按钮的时候的行动
        let action = UIAlertAction(title: "增加", style: .default){
            (action) in
            if let currentCategory = self.selectedCategory {
                do{
                    try self.realm.write{
                        let newItem = Item()
                        newItem.title = textField.text!
                        //newItem.parentCategory = selectedCategory
                        //在Realm中直接添加到selectedCategory的itemList里即可
                        currentCategory.items.append(newItem)
                    }
                }catch {
                    print("Error saving new Item,\(error)")
                }
            }
            self.tableView.reloadData()
        }
        //为alert装载一个输入框,并将闭包内输入框状态传至方法内的输入框（引用传递)
        //此方法是在alert的输入框初始化的时候运行，因此用户输入的数据无法获取
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "请填写备忘内容"
            textField = alertTextField
        }
        //为alert装载action
        alert.addAction(action)
        //触发alert
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - 保存读取数据
    //load Items by passed parameters, simply all-quiried is defult
    //predicate设置为可选值，默认为空
    func loadItems() {
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
}

//MARK: - 搜索栏
//extension TodoListViewController: UISearchBarDelegate{
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        //建立用于获取数据库Context的Request
//        let request: NSFetchRequest<Item> = Item.fetchRequest()
//        //The method is to search the items by a keyword of title
//        //The content of the searchBar will replace %@
//        let predicate = NSPredicate(format: "title CONTAINS %@", searchBar.text!)
//        request.predicate = predicate
//        //set the principle of sort for request
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//        //fetch result form db
//        loadItems(with: request, predicate: predicate)
//        tableView.reloadData()
//    }
//    //show the origin page if nothing in searchBar
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        
//        if searchBar.text?.count == 0 {
//            loadItems()
//            //用户取消输入时，主线程，消除键盘和搜索框光标
//            DispatchQueue.main.async {
//                //取消选中状态的方法，必须放在主线程里执行，否则不生效
//                searchBar.resignFirstResponder()
//            }
//            
//        }
//    }
//}
