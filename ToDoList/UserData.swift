//
//  UserData.swift
//  ToDoList
//
//  Created by 白家乐 on 2025/9/22.
//

import Foundation
import Combine

// 对数据的操作类 -> 方便管理数据
class ToDo: ObservableObject {
    @Published var ToDoList: [SingleToDo] // published 表示如果这个数组发生改变，就会刷新所有用到这个数组的视图
    var count: Int = 0
    
    init() {
        self.ToDoList = []
    }
    init(data: [SingleToDo]) { // 函数的多态，根据不同的参数调用不同的初始化函数
        self.ToDoList = [ ]
        for item in data {
            self.ToDoList.append(SingleToDo(title: item.title, duedate: item.duedate, id: self.count))
            count += 1
        }
    }
    
    func check(id: Int) {
        self.ToDoList[id].isChecked.toggle()
    }
    
    func add(data: SingleToDo) {
        self.ToDoList.append(SingleToDo(title: data.title, duedate: data.duedate, id: self.count))
        self.count += 1
    }
}

struct SingleToDo: Identifiable { // Identifiable 才可以放入 ForEach
    var title: String = ""
    var duedate: Date = Date()
    var isChecked: Bool = false
    
    var id: Int = 0 // Identifiable 要求声明一个整形变量 id
}
