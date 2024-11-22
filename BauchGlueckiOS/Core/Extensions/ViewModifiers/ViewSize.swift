//
//  ViewSize.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 22.11.24.
//
import SwiftUI

struct ViewSize: ViewModifier {
    let name: String
    
    let debugColor: Color
    
    @State var size: CGSize = .zero
    
    func body(content: Content) -> some View {
        content
            .background(GeometryReader { proxy -> Color in
                DispatchQueue.main.async {
                    self.size = proxy.size
                    print("🔥 \(name):  \(proxy.size)")
                }
                return debugColor
            })
         
    }
}


// TODO: https://stackoverflow.com/questions/61311007/dynamically-size-a-geometryreader-height-based-on-its-elements
