//
//  CategoryViewController.swift
//  Todoey
//
//  Created by 韩飞洋 on 2024/3/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework
class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    //设置为Realm的查询结果容器
    //关于Optional的unwrap，需要不同地方的配合和程序的逻辑
    var categories: Results<Category>?
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        
        tableView.separatorStyle = .none

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navbar = navigationController?.navigationBar else {fatalError("Navigation controller doesnt exist.")}
        navbar.backgroundColor = UIColor(hexString: "1D9BF6")
    }
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        //新建一个alert窗口，用来给用户新建备忘录
        let alert = UIAlertController(title: "新建目录", message: "", preferredStyle: .alert)
        //新建一个alert的action（按钮），在回调函数中确定用户点击”增加“按钮的时候的行动
        let action = UIAlertAction(title: "增加", style: .default){
            (action) in
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.colorHex = UIColor.randomFlat().hexValue()
            //不再需要主动给目录列表添加新的实例，因为Realm会自动更新实现了Object的Categor
            //将新增备忘录加入备忘录列表中
            //self.categories.append(newCategory)
            self.save(category: newCategory)
        }
        //为alert装载一个输入框,并将闭包内输入框状态传至方法内的输入框（引用传递)
        //此方法是在alert的输入框初始化的时候运行，因此用户输入的数据无法获取
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "请填写分类名称"
            textField = alertTextField
        }
        //为alert装载action
        alert.addAction(action)
        //触发alert
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - TableView 数据源
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //对Optional的解包，如果为空则值为??后的值
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //从超类中获取cell
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.name
            //guard可以保证其后面的语句不会为nil
            guard let categoryColor = UIColor(hexString: category.colorHex) else {fatalError("categoryColor ERROR")}
            cell.backgroundColor = UIColor(hexString: category.colorHex)
            cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
        }
        
        
        
        return cell
    }
    //MARK: - TableView 交互
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        
        
        //设置tv的当前行取消被选中状态，以实现选中动画
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            //selectedCategory是一个Optional，且在赋值时会触发didSet
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    //MARK: - 数据操作
    func save(category:Category){
        do{
            //修改为realm的存储
            try realm.write{
                realm.add(category)
            }
        } catch {
           print("Error saving context \(error)")
        }
        self.tableView.reloadData()
    }
    //load Items by passed parameters, simply all-quiried is defult
    func loadCategories() {
        //load all categories from Realm
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    //MARK: - 移除
    override func updateModel(at indexPath: IndexPath) {
        if let category = self.categories?[indexPath.row] {
            do {
                try self.realm.write{
                    self.realm.delete(category)
                }
            }catch{
                print("Error deleting category, \(error)")
            }
        }
    }
}

