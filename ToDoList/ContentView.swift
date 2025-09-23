//
//  ContentView.swift
//  ToDoList
//
//  Created by 白家乐 on 2025/9/22.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var UserData: ToDo = ToDo(data: [SingleToDo(title: "写作业")])
    
    @State var showEditingPage: Bool = false
    
    var body: some View {
        ZStack { // ZStack 中越往后写元素越往上层
            NavigationView {
                ScrollView(.vertical, showsIndicators: true) {
                // 创建滚动视图 -> 一种结合视图的方式
                // .vertical 表示纵向滚动
                    VStack {
                        ForEach(self.UserData.ToDoList) { item in // 一般控制流 for 循环不能与 ViewBuilder 一起使用
                            SingleCardView(index: item.id)
                                .environmentObject(self.UserData)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 6)
                        }
                    }
                }
                .navigationTitle("ToDoList")
            }
            
            HStack {
                Spacer()
                VStack() {
                    Spacer()
                    Button(
                        action: { self.showEditingPage = true
                    }) {
                        Image(systemName: "plus")
                            .frame(width: 40, height: 50) // 画布大小
                            .font(.system(size: 35))
                    }
                    .buttonStyle(.glassProminent)
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

struct SingleCardView: View {
    
    @EnvironmentObject var UserData: ToDo // 子视图使用到父视图中声明的类时，要加 EnvironmentObject
    var index: Int
    
    var body: some View {
        
        // body 的返回值为 HStack，只有一个返回值，return 可以省略
        HStack {
            Rectangle()
                .frame(width: 6.0) // Rectangle() 的画幅大小
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 6.0) { // 一般写 Vstack 时括号可以省略，因为参数只有最后一个 content 闭包，而它可以写成大括号内的形式
                Text(self.UserData.ToDoList[index].title)
                    .font(.headline)
                    //* .font 是 Text 的一种方法，返回值也是 Text 类型的视图。简单理解就是 Text 的修饰符。
                    //* 完整写法是 .font(font: Font.headline)，因为 swift 中“点语法”在上下文清晰的情况下会自动推断类型
                    .fontWeight(.heavy)
                Text(self.UserData.ToDoList[index].duedate.description) // date 不能直接转换成字符串
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
                .padding(.leading) // .leading 只在左侧填充
            
            Spacer()
            
            Image(systemName: self.UserData.ToDoList[index].isChecked ? "checkmark.square.fill" : "square")
                .imageScale(.large) // 图片大小
                .padding(.trailing)
                .padding(.trailing)
                .onTapGesture { // 点击图片时执行代码
                    self.UserData.check(id: index)
                }

        }
            .frame(height: 80)
            .background(Color.white)
            .cornerRadius(10) // 半径为 10 的圆角
            .shadow(radius: 10, x: 0, y: 10) // 阴影，只有 y 轴有阴影
    }
}

#Preview {
    ContentView()
}
