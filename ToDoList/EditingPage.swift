//
//  EditingPage.swift
//  ToDoList
//
//  Created by 白家乐 on 2025/9/22.
//

import SwiftUI

struct EditingPage: View {
    
    @EnvironmentObject var UserData: ToDo
    
    @State var title: String = ""
    @State var duedate: Date = Date()
    
    @Environment(\.presentationMode) var presentation // 实现添加后页面自动消失
    
    var body: some View {
        NavigationView { // 导航视图
            Form { // 表单
                Section(header: Text("详细信息")) {
                    TextField("事项内容", text: self.$title) // Binding 表示绑定的变量，只能传入 State 类型的变量
                    // 这里如果 title 变量改变，则表单中的内容也会改变；表单中的内容改变，title 变量也会随之改变（绑定）
                    DatePicker("截止时间", selection: self.$duedate) // 时间选择器
                }
                Section {
                    Button(action: { // action 闭包不是最后一个闭包，所以要写到括号里面
                        self.UserData.add(data: SingleToDo(title: self.title, duedate: self.duedate))
                        self.presentation.wrappedValue.dismiss()
                    }) { // content 闭包作为尾随闭包，放在括号外面的大括号中
                        Text("确认")
                    }
                    Button(action: {
                        self.presentation.wrappedValue.dismiss()
                    }) {
                        Text("取消")
                    }
                }
            }
            .navigationTitle("添加 ToDoList")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    EditingPage()
}
