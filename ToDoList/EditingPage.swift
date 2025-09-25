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
    
    var id: Int? = nil
    
    @Environment(\.presentationMode) var presentation // 实现添加后页面自动消失
    
    var body: some View {
        NavigationStack { // 导航视图
            Form { // 表单
                Section(header: Text("详细信息")) {
                    TextField("事项内容", text: self.$title) // Binding 表示绑定的变量，只能传入 State 类型的变量
                    // 这里如果 title 变量改变，则表单中的内容也会改变；表单中的内容改变，title 变量也会随之改变（绑定）
                    DatePicker("截止时间", selection: self.$duedate) // 时间选择器
                }
//                Section {
//                    Button(action: { // action 闭包不是最后一个闭包，所以要写到括号里面
//                    }) { // content 闭包作为尾随闭包，放在括号外面的大括号中
//                        Text("确认")
//                    }
//                    Button(action: {
//                        self.presentation.wrappedValue.dismiss()
//                    }) {
//                        Text("取消")
//                    }
//                }
            }
            .navigationTitle("编辑提醒事项")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(content: {
                    Button(action: {
                        if self.id == nil {
                            self.UserData.add(data: SingleToDo(title: self.title, duedate: self.duedate))
                        }
                        else {
                            self.UserData.edit(id: self.id!, data: SingleToDo(title: self.title, duedate: self.duedate)) // id! 表示强制解包，因为这里 id 一定不是 nil
                        }
                        self.presentation.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "checkmark")
                    })
                    .buttonStyle(.borderedProminent) // 突出边框样式
                    .tint(.blue) // 改变背景色为橙色
                })
                ToolbarItem(placement: .topBarLeading, content: {
                    Button(action: {
                        self.presentation.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "multiply")
                    })
                })
            })
        }
    }
}

#Preview {
    EditingPage()
}
