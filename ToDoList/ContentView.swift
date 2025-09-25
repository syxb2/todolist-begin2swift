//
//  ContentView.swift
//  ToDoList
//
//  Created by 白家乐 on 2025/9/22.
//

import SwiftUI

func initUserData() -> [SingleToDo] {
    var output: [SingleToDo] = [ ]
    if let dataStored = UserDefaults.standard.object(forKey: "ToDoList") as? Data { // 当没有 ToDoLst 这个 key 时，UserDefaults 返回空，此时就需要 as? Data 让 dataStored 的类型为 Data
        let data = try! decoder.decode([SingleToDo].self, from: dataStored)
        for item in data {
            if !item.deleted {
                output.append(SingleToDo(title:item.title, duedate: item.duedate, isChecked: item.isChecked, id: output.count))
            }
        }
    }
    return output
}

struct ContentView: View {
    
    @ObservedObject var UserData: ToDo = ToDo(data: initUserData())
    
    @State var showEditingPage: Bool = false
    @State var editingMode: Bool = false
    @State var selection: [Int] = [ ]

    var body: some View {
        ZStack { // ZStack 中越往后写元素越往上层
            NavigationView {
                ScrollView(.vertical) {
                // 创建滚动视图 -> 一种结合视图的方式
                // .vertical 表示纵向滚动
                    Spacer()
                    VStack {
                            ForEach(self.UserData.ToDoList) { item in // 一般控制流 for 循环不能与 ViewBuilder 一起使用
                                if !item.deleted {
                                    SingleCardView(index: item.id, editingMode: self.$editingMode, selection: self.$selection) // 将 self.editingMode 与 SingleCardView 中的 editingMode 绑定
                                        .environmentObject(self.UserData)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 6)
                                }
                            }
                    }
                }
                .navigationTitle("提醒事项")
                .navigationBarTitleDisplayMode(.automatic)
                .toolbar(content: {
                    if self.editingMode {
                        ToolbarItem(content: {
                            DeleteButton(selection: self.$selection, editingMode: self.$editingMode)
                                .environmentObject(self.UserData) //! 没有这一条就无法在 DeleteButton 中调用 UserData 的方法
                        })
                    }
                    ToolbarItem(content: {
                        EditingButton(editingMode: self.$editingMode, selection: self.$selection)
                    })
                })
                .animation(.default, value: self.editingMode) // 当 editingMode 属性变化时触发动画
            }
            
            HStack {
                Spacer()
                VStack() {
                    Spacer()
                    Button(action: {
                        self.showEditingPage = true
                    }) {
                        Image(systemName: "plus")
                            .frame(width: 40, height: 50) // 画布大小
                            .font(.system(size: 35))
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.blue) // 改变背景色为蓝色
                    .padding(30)
                    .sheet(isPresented: self.$showEditingPage, content: {
                        EditingPage()
                            .environmentObject(self.UserData)
                    })
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

struct EditingButton: View {
    
    @Binding var editingMode: Bool
    @Binding var selection: [Int]
    
    var body: some View {
        Button(action: {
            self.editingMode.toggle()
            self.selection.removeAll()
        }, label: {
            if !self.editingMode {
                Image(systemName: "pencil")
                    .imageScale(.large)
            }
            else {
                Image(systemName: "checkmark")
                    .imageScale(.large)
            }
        })
    }
}

struct DeleteButton: View {
    
    @Binding var selection: [Int]
    @Binding var editingMode: Bool
    @EnvironmentObject var UserData: ToDo // 因为要调用 UserData 里的方法，所以要写一个 EnvironmentObject
    
    var body: some View {
        Button(action: {
            self.editingMode.toggle()
            for i in self.selection {
                self.UserData.delete(id: i)
            }
        }, label: {
            Image(systemName: "trash")
                .imageScale(.large)
        })
    }
}

struct SingleCardView: View {
    
    @EnvironmentObject var UserData: ToDo // 子视图使用到父视图中声明的类时，要加 EnvironmentObject
    var index: Int
    
    @State var showEditingPage: Bool = false
    @Binding var editingMode: Bool // 绑定者（子结构体中，要绑定父结构体中的变量）
    @Binding var selection: [Int]
    
    var body: some View {
        
        // body 的返回值为 HStack，只有一个返回值，return 可以省略
        HStack {
            Rectangle()
                .frame(width: 6.0) // Rectangle() 的画幅大小
                .foregroundColor(.blue)
            
            if self.editingMode {
                Image(systemName: self.selection.firstIndex(where: {$0 == self.index}) == nil ? "circle": "checkmark.circle.fill")
                    .imageScale(.large) // 图片大小
                    .padding(.leading)
                    .onTapGesture { // 点击图片时执行代码
                        if self.selection.firstIndex(where: { // 数组自带的方法
                            $0 == self.index // 这是一个闭包，返回的是数组中找到项的位置
                        }) == nil {
                            self.selection.append(self.index)
                        }
                        else {
                            self.selection.remove(at: self.selection.firstIndex(where: {
                                $0 == self.index
                            })!)
                        }
                    }
            }
            
            Button(action: { // 将 SingleCardView 放入一个 button
                if !self.editingMode {
                    self.showEditingPage = true
                }
                else {
                    if self.selection.firstIndex(where: {$0 == self.index}) == nil {
                        self.selection.append(self.index)
                    }
                    else {
                        self.selection.remove(at: self.selection.firstIndex(where: {
                            $0 == self.index
                        })!)
                    }
                }
            }, label: {
                VStack(alignment: .leading, spacing: 6.0) { // 一般写 Vstack 时括号可以省略，因为参数只有最后一个 content 闭包，而它可以写成大括号内的形式
                    Text(self.UserData.ToDoList[index].title)
                        .font(.headline)
                        .foregroundStyle(.black)
                        //* .font 是 Text 的一种方法，返回值也是 Text 类型的视图。简单理解就是 Text 的修饰符。
                        //* 完整写法是 .font(font: Font.headline)，因为 swift 中“点语法”在上下文清晰的情况下会自动推断类型
                        .fontWeight(.heavy)
                    Text(self.UserData.ToDoList[index].duedate, style: .date) // date 不能直接转换成字符串，正确显示时间的方法
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                    .padding(.leading) // .leading 只在左侧填充
                
                Spacer()
            })
            .sheet(isPresented: self.$showEditingPage, content: {
                EditingPage(title: self.UserData.ToDoList[self.index].title, duedate: self.UserData.ToDoList[self.index].duedate ,id: self.index)
                    .environmentObject(self.UserData)
            })
            
            if !editingMode {
                Image(systemName: self.UserData.ToDoList[index].isChecked ? "checkmark.square.fill" : "square")
                    .imageScale(.large) // 图片大小
                    .padding(.trailing)
                    .padding(.trailing)
                    .onTapGesture { // 点击图片时执行代码
                        self.UserData.check(id: index)
                    }
            }
        }
        .frame(height: 80)
        .background(Color.white)
        .cornerRadius(10) // 半径为 10 的圆角
        .shadow(radius: 10, x: 0, y: 10) // 阴影，只有 y 轴有阴影
        .animation(.default, value: self.editingMode)
        .animation(.default, value: self.selection)
        .animation(.default, value: self.UserData.count)
        .animation(.default, value: self.UserData.ToDoList[index].isChecked)
    }
}

#Preview {
    ContentView(UserData: ToDo(data: [SingleToDo(title: "写作业", duedate: Date()), SingleToDo(title: "复习", duedate: Date())]))
}
