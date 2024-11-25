//
//  NavigationBackButtonModifier.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 23.10.24.
//

import SwiftUI

struct NavigationBackButton<T: View>: ViewModifier {
  
   
    @EnvironmentObject var services: Services
    @EnvironmentObject var userViewModel: UserViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.theme) private var theme
    
    @State var isSettingSheet: Bool = false
    @ViewBuilder var toolbarItems: () -> T
    var color: Color
    var icon: String
    var destination: Destination
    var onDismissAction: () -> Void
    var showSettingButton: Bool
    
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 16) {
                        Image(systemName: icon)
                            .font(.body)
                        Text(destination.screen.title)
                            .font(.callout)
                    }
                    .onTapGesture {
                        onDismissAction()
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing, content: {
                    HStack(spacing: theme.layout.padding) {
                        toolbarItems()
                        
                        if showSettingButton {
                            Image(systemName: "gear")
                                .onTapGesture {
                                    isSettingSheet = !isSettingSheet
                                }
                        }
                    }
                })
            } 
            .settingSheet(isSettingSheet: $isSettingSheet, userViewModel: userViewModel, onDismiss: {})
    }
}
