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

    //拟定三个备忘字符串
    //对象数组的声明方式
    var itemArray = [Item]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //let defaults = UserDefaults.standard
    
    /* userDomainMask指此处保存本应用的个人数据
     Optional(file:///Users/hanfeiyang/Library/Developer/CoreSimulator/Devices/F9F07048-A738-4773-861F-20E4EBA8C802/data/Containers/Data/Application/610C73A6-9678-4AA2-A0A6-1F333D277DB3/Documents/)
     */
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
        //在storyboard连接searchBar和控制器？好像现在xcode自己就做了委托了
        
        loadItems()
    }
    
    //MARK: - TableView的数据源方法
    //给出一个tableView有多少条数据
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    //根据IndexPath生成cell并返回给TV
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*
         弃用以下可重用cell，会导致超出视口的cell被用作新进入视口的cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        使用以下自定义cell,解决以上问题，但是离开视口的cell被销毁，如果被选中的cell再次出现是为选中状态
         因此需要将 选中状态（C） 和 数据（M） 关联起来，而不是 选中状态（C） 和 cell（V） 关联起来。
         */
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
        //删除数据
        //context.delete(itemArray[indexPath.row])
        //删除view中的cell元素
        //itemArray.remove(at: indexPath.row)
        
        //根据索引确定当前交互的Model数据更改
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        //以下被取消因为View的状态变更已经与用户动作无直接关系，而是用户修改数据、数据影响View的间接关系，因此此部分逻辑移到数据渲染的方法中
        //指定tv当前的cell的标记符号为选中/取消选中
//        let currentCell = tableView.cellForRow(at: indexPath)
//        currentCell?.accessoryType = currentCell?.accessoryType == .checkmark ? .none : .checkmark
        
        //用户修改选中状态后同样要更新Items
        saveItems()
        //在每次用户交互完后要主动触发数据M与页面V的交互
        //tableView.reloadData()
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
        //将备忘录列表存入用户默认内存中
        //在itemArray为对象列表时会报错因为UD不接受
        //self.defaults.set(self.itemArray, forKey: "ToDoListArray")
        
        do{
            try context.save()
        } catch {
           print("Error saving context \(error)")
        }
        //触发tv的数据渲染流程
        self.tableView.reloadData()
    }
    
    func loadItems() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        do{
            itemArray = try context.fetch(request)
        }catch {
            print("error fetch \(error)")
        }
        
    }
    
    
}

//MARK: - 搜索栏
//每个其他功能实现用extension实现
extension TodoListViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //建立用于获取数据库Context的Request
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        //The method is to search the items by a keyword of title
        //The content of the searchBar will replace %@
        let predicate = NSPredicate(format: "title CONTAINS %@", searchBar.text!)
        request.predicate = predicate
        //set the principle of sort for request
//        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
//        request.sortDescriptors = [sortDescriptor]
        //abb for above two lines
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        //fetch result form db
        do{
            itemArray = try context.fetch(request)
        }catch {
            print("error fetch \(error)")
        }
        tableView.reloadData()
    }
}
