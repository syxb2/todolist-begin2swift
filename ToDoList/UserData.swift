//
//  UserData.swift
//  ToDoList
//
//  Created by 白家乐 on 2025/9/22.
//

import Foundation
import Combine

var encoder = JSONEncoder()
var decoder = JSONDecoder()

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
            self.ToDoList.append(SingleToDo(title: item.title, duedate: item.duedate, isChecked: item.isChecked, id: self.count))
            count += 1
        }
    }
    
    func check(id: Int) {
        self.ToDoList[id].isChecked.toggle()
        self.dataStore()
    }
    
    func add(data: SingleToDo) {
        self.ToDoList.append(SingleToDo(title: data.title, duedate: data.duedate, id: self.count))
        self.count += 1
        
        self.sort()
        self.dataStore()
    }
    
    func edit(id: Int, data: SingleToDo) {
        self.ToDoList[id].title = data.title
        self.ToDoList[id].duedate = data.duedate
        self.ToDoList[id].isChecked = false
        
        self.sort()
        self.dataStore()
    }
    
    func sort() {
        self.ToDoList.sort(by: {
            (data1: SingleToDo, data2: SingleToDo) in
                return data1.duedate.timeIntervalSince1970 < data2.duedate.timeIntervalSince1970 // .timeIntervalSince1970 返回 1970 到当前时间的秒数
        })
        for i in 0..<self.ToDoList.count { // 调整 id
            self.ToDoList[i].id = i
        }
    }
    
    func delete(id: Int) {
        // self.ToDoList.remove(at: id) // 这里不能直接 remove，因为会使数组数量减小，由于 swift 视图刷新机制不是全局刷新，故会导致报错
        self.ToDoList[id].deleted = true
        self.sort()
        
        self.count -= 1
        
        self.dataStore()
    }
    
    func dataStore() {
        let dataStored = try! encoder.encode(self.ToDoList) // encoder 可以抛出错误，try! 表示强制忽略错误
        UserDefaults.standard.set(dataStored, forKey: "ToDoList") // value 是要存储的值
    }
}

struct SingleToDo: Identifiable, Codable { // Identifiable 才可以放入 ForEach，Codable 表示可编码的，用于存储数据，因为数据不能明文存储，所以需要编码
    var title: String = ""
    var duedate: Date = Date()
    var isChecked: Bool = false
    
    var deleted: Bool = false
    
    var id: Int = 0 // Identifiable 要求声明一个整形变量 id
}
