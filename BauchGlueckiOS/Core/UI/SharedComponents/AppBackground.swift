//
//  AppBackground.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 17.10.24.
//

import SwiftUI

struct AppBackground<Content: View>: View {
    var color: Color?
    var gradient: LinearGradient?
    var content: () -> Content

   init(color: Color, @ViewBuilder content: @escaping () -> Content) {
       self.color = color
       self.gradient = nil
       self.content = content
   }

   init(gradient: LinearGradient, @ViewBuilder content: @escaping () -> Content) {
       self.gradient = gradient
       self.color = nil
       self.content = content
   }
    
    var body: some View {
        ZStack {
            if let color = color {
               color
            } else if let gradient = gradient {
               gradient
            }
            
            content()
        }
        .edgesIgnoringSafeArea(.all)
    }
}
