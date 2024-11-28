//
//  PickerExamples.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 28.11.24.
//
import SwiftUI

struct CirclePicker: View {
    let items: [String] = ["first", "second", "third"]
    
    let size: CGFloat = 15
    let selectedSize: CGFloat = 20
    
    @Namespace private var namespace
    
    @State private var selection: String = "first"
    //TODO: @Binding
    //TODO: Generic instead String
    
    var body: some View {
        VStack {
       
            ForEach(items, id: \.self) { item in
                HStack {
                    Circle().stroke(item == selection ? Color.accentColor :  Color.gray)
                        .frame(width: item == selection ? selectedSize : size,
                               height: item == selection ? selectedSize : size)
                        .matchedGeometryEffect(id: item, in: namespace, properties: .frame, isSource: true)
                    
                    /*
                     let frame = view.frame
                     */
                    
                    
                    Text(item)
                }
                .onTapGesture {
                    withAnimation(.spring()) {
                        selection = item
                    }
                    
                }
            }.background(
                
                Circle()
                    .fill(Color.accentColor)
                    .matchedGeometryEffect(id: selection, in: namespace,
                                           properties: .frame, isSource: false)
                    //                .frame(width: 10, height: 10)
                    .frame(width: 20, height: 20)
                
            )
            /*
             circle.frame = frame
             */
        
            
        }
    }
}

struct SliderPicker: View {
    
    @Namespace private var namespace
    let items: [String] = ["fish", "meat", "salade", "dessert"]
    
    @State private var selectedItem: String = "meat"
    
    let color = Color(.displayP3, red: 0, green: 0, blue: 1, opacity: 0.5)
    let selectedColor = Color(.displayP3, red: 0, green: 0, blue: 1, opacity: 1)
    
    var body: some View {
        HStack {
            ForEach(items, id: \.self) { item in
                
                Text(item)
                    .foregroundColor(selectedItem == item ? selectedColor : color)
                    .bold()
                    .padding(.bottom, 2)
                    .background(
                        Color.clear
                            .frame(height: 2)
                            .matchedGeometryEffect(id: item, in: namespace, properties: .frame, isSource: true)
                            .frame(maxHeight: .infinity, alignment: .bottom)
                            
                    )
                    
                    
                    .onTapGesture {
                        withAnimation {
                            selectedItem = item
                        }
                    }
            }
            .background(selectedColor
                            .matchedGeometryEffect(id: selectedItem, in: namespace, properties: .frame, isSource: false)
            )
            
        }
    }
}

struct CalenderView: View {
    @Namespace var namespace
    @State private var selection: Int = 1
    @State private var months: [Month] = Month.createMonts()
    
    var body: some View {
        VStack(spacing: 20) {
            LazyVGrid(columns: Array(repeating: GridItem(), count: 3), content: {
                ForEach(months.indices, id: \.self) { (monthID: Int) in
                    MonthView(selection: $selection, month: monthID)
                        .matchedGeometryEffect(id: monthID, in: namespace)
                }
            })
        }.background(
            RoundedRectangle(cornerRadius: 8).stroke(Color.green, lineWidth: 3)
                .matchedGeometryEffect(id: selection, in: namespace, isSource: false)
        )
        .onAppear {
            months = Month.createMonts()
        }
    }
    
   
    @ViewBuilder func MonthView(
        selection: Binding<Int>,
        month: Int
    ) -> some View {
        Text(months[month].name)
            .fixedSize()
            .padding(10)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.40)) {
                    selection.wrappedValue = month
                }
            }
    }
}

struct Month: Hashable {
    var id: UUID = UUID()
    var name: String
    
    static func createMonts() -> [Month] {
        let months = [
            "January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"
        ]
        
        return months.map { Month(name: $0 ) }
    }
}

struct PickerExamples: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Pick something").font(.title)
            
            CirclePicker()
            SliderPicker()
            
            Text("Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.")
                .font(.footnote)
            
            CalenderView()
           
        }.padding()
    }
}

#Preview {
    PickerExamples()
}
