//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData
class TodoListViewController: UITableViewController {

    var itemArray = [Item]()
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
        return itemArray.count
    }
    //根据IndexPath生成cell并返回给TV
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "ToDoItemCell")
        //TODO: cell.textLabel已标记弃用，学习UIListContentConfiguration
        cell.textLabel?.text = itemArray[indexPath.row].title
        //根据Model状态确定View状态
        cell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none
        
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
        
        //根据索引确定当前交互的Model数据更改
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        //用户修改选中状态后同样要更新Items
        saveItems()
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
            //使用CoreData提供的Item类
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            //done属性不可为空
            newItem.done = false
            //在DM中设置了外键，在ViewDidLoad中接收到了Segue传来的selected Category
            newItem.parentCategory = self.selectedCategory
            //将新增备忘录加入备忘录列表中
            self.itemArray.append(newItem)
            self.saveItems()
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
    func saveItems(){
        do{
            try context.save()
        } catch {
           print("Error saving context \(error)")
        }
        //触发tv的数据渲染流程
        self.tableView.reloadData()
    }
    //load Items by passed parameters, simply all-quiried is defult
    //predicate设置为可选值，默认为空
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        //根据当前目录从数据库取数据
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
        }else{
            request.predicate = categoryPredicate
        }
//        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, predicate])
//        request.predicate = predicate
        do{
            itemArray = try context.fetch(request)
        }catch {
            print("error fetch \(error)")
        }
        //清理注释的时候误删了！！！
        tableView.reloadData()
    }
}

//MARK: - 搜索栏
extension TodoListViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //建立用于获取数据库Context的Request
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        //The method is to search the items by a keyword of title
        //The content of the searchBar will replace %@
        let predicate = NSPredicate(format: "title CONTAINS %@", searchBar.text!)
        request.predicate = predicate
        //set the principle of sort for request
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        //fetch result form db
        loadItems(with: request, predicate: predicate)
        tableView.reloadData()
    }
    //show the origin page if nothing in searchBar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            loadItems()
            //用户取消输入时，主线程，消除键盘和搜索框光标
            DispatchQueue.main.async {
                //取消选中状态的方法，必须放在主线程里执行，否则不生效
                searchBar.resignFirstResponder()
            }
            
        }
    }
}
