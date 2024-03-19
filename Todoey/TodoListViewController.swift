//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {

    //拟定三个备忘字符串
    let itemArray = ["起床", "做早饭吃早饭", "工作"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    //MARK: - TableView的数据源方法
    //给出一个tableView有多少条数据
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    //根据IndexPath生成cell并返回给TV
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row]//TODO: cell.textLabel已标记弃用，学习UIListContentConfiguration
        return cell
    }
    
    //MARK: - TableView的用户交互委托方法
    //TV的用户交互row委托方法
    //当用户对tableView的indexPath的cell进行点击操作触发的方法
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(itemArray[indexPath.row])
        //设置tv的当前行取消被选中状态，以实现选中动画
        tableView.deselectRow(at: indexPath, animated: true)
        //指定tv当前的cell的标记符号为选中/取消选中
        let currentCell = tableView.cellForRow(at: indexPath)
        currentCell?.accessoryType = currentCell?.accessoryType == .checkmark ? .none : .checkmark
        
        
        
    }
    

 
}

