//
//  UserData.swift
//  ToDoList
//
//  Created by 白家乐 on 2025/9/22.
//

import Foundation
import UserNotifications
import Combine

var encoder = JSONEncoder()
var decoder = JSONDecoder()

let notificationContent = UNMutableNotificationContent() // 用于承载通知内容
// app 本地通知实际是先发给一个统一的分发机构（内容有通知内容以及此通知计划发送的时间），再由分发机构在合适的时间发出通知（因为 app 不运行时，是不会执行发送通知的代码的）

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
        
        self.sort()
    }
    
    func add(data: SingleToDo) {
        self.ToDoList.append(SingleToDo(title: data.title, duedate: data.duedate, id: self.count))
        self.count += 1
        
        self.sort()
        self.dataStore()
        
        self.sendNotification(id: self.ToDoList.count - 1)
    }
    
    func edit(id: Int, data: SingleToDo) {
        self.withdrawNotification(id: id)
        
        self.ToDoList[id].title = data.title
        self.ToDoList[id].duedate = data.duedate
        self.ToDoList[id].isChecked = false
        
        self.sort()
        self.dataStore()
        
        self.sendNotification(id: id)
    }
    
    func sendNotification(id: Int) {
        notificationContent.title = self.ToDoList[id].title // 通知的标题
        notificationContent.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: self.ToDoList[id].duedate.timeIntervalSinceNow, repeats: false) // 通知触发器：在时间间隔 self.ToDoList[id].duedate.timeIntervalSinceNow 之后触发
        let request = UNNotificationRequest(identifier: self.ToDoList[id].title + self.ToDoList[id].duedate.description, content: notificationContent, trigger: trigger) // identifier 是这个通知的 id，方便撤回通知等后续操作
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func withdrawNotification(id: Int) {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [self.ToDoList[id].title + self.ToDoList[id].duedate.description]) // 这个方法只能撤回已经发送到通知中心中的通知，无法撤回还没发到通知中心的通知
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [self.ToDoList[id].title + self.ToDoList[id].duedate.description]) // 撤回还未发到通知中心的通知
    }
    
    func sort() {
        self.ToDoList.sort(by: {
            (data1: SingleToDo, data2: SingleToDo) in
            return data1.duedate.timeIntervalSince1970 < data2.duedate.timeIntervalSince1970 // .timeIntervalSince1970 返回 1970 到当前时间的秒数
        })
        self.ToDoList.sort(by: {
            (data1: SingleToDo, data2: SingleToDo) in
            return data1.isChecked == false && data2.isChecked == true
        })
        
        // 调整 id
        for i in 0..<self.ToDoList.count {
            self.ToDoList[i].id = i
        }
    }
    
    func delete(id: Int) {
        self.withdrawNotification(id: id)
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
