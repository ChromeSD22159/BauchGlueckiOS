//
//  Settings.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 22.10.24.
//

import SwiftUI
import StoreKit

struct SettingSheet: ViewModifier {
    private let theme: Theme = Theme.shared
    
    @EnvironmentObject var authManager: FirebaseService
    @StateObject var viewModel: SettingViewModel

    var isSettingSheet: Binding<Bool>
  
    var onDismiss: () -> Void
    
    init(isSettingSheet: Binding<Bool>, authManager: FirebaseService, onDismiss: @escaping() -> Void) {
        self.isSettingSheet = isSettingSheet
        self.onDismiss = onDismiss
        _viewModel = StateObject(wrappedValue: SettingViewModel(authManager: authManager))
    }

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: isSettingSheet, onDismiss: {
                viewModel.updateProfile()
            }, content: {
                NavigationView {
                    ZStack {
                        theme.background.ignoresSafeArea()
                        
                        List {
                            
                            TimeSinceSurgeryBadge()
                            
                            
                            Section {
                                NavigationLink {
                                    ProfileEditView(viewModel: viewModel)
                                        .navigationBackButton(
                                            color: theme.onBackground,
                                            destination: Destination.settings,
                                            firebase: authManager,
                                            onDismissAction: {
                                                viewModel.updateProfile()
                                            }
                                        )
                                } label: {
                                    RowItem(icon: "person.fill", text: "Profile")
                                        .listRowBackground(theme.backgroundGradient)
                                }
       
                                RowItem(image: .iconStromach, text: "Bypass since:", surgeryDateBinding: viewModel.surgeryDateBinding)
                                
                            } header: {
                                Text("Profile")
                            }
                            
                            Section{
                                RowItem(icon: "envelope", text: "Support + Feedback", url: "mailto:jon.doe@mail.com")
                                RowItem(icon: "star.fill", text: "Rate 5 stars", action: { requestAppReview() }, background: .regular)
                            } header: {
                                Text("Support")
                            }
                            
                            Section {
                                RowItem(icon: "globe", text: "Instagram des Entwicklers", url: "https://www.instagram.com/frederik.code/")
                           
                                RowItem(icon: "globe", text: "Webseite des Entwicklers", url: "https://www.frederikkohler.de")
                                
                                RowItem(icon: "square.grid.2x2.fill", text: "Apps des Entwicklers", url: "https://apps.apple.com/at/developer/frederik-kohler/id1692240999")
                                
                                let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
                                let build = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
                                let string = "Version \(version) (Build Number: \(build))"
                                RowItem(icon: "info.circle", text: LocalizedStringKey(string))
                            } header: {
                                Text("Developer")
                            }
                            
                            RowItem(
                                icon: "iphone.and.arrow.forward",
                                text: "Abmelden",
                                action: { viewModel.authManager.signOut() },
                                background: .backgroundGradient
                            )
                            .listRowBackground(theme.backgroundGradient)
                                
                        }
                    }
                    .navigationTitle("⚙️ Einstellungen")
                    .navigationBarTitleDisplayMode(.inline)
                }
            })
    }
    
    @ViewBuilder func TimeSinceSurgeryBadge() -> some View {
        Section {
            VStack {
                HStack(alignment: .top, spacing: 10) {
                    Image(.iconStromach)
                        .resizable()
                        .frame(width: 32.0, height: 32.0)
                        .foregroundStyle(theme.onPrimary)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(viewModel.greeting)
                            .font(theme.headlineText)
                        
                        Text("Unglaublicht, wie schnell die Zeit vergeht!").font(.footnote)
                        Text(viewModel.timeSinceSurgery).font(.footnote)
                    }
                    .foregroundStyle(theme.onPrimary)
                    .font(.callout)
                    .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 10)
            }
        }
        .foregroundStyle(theme.backgroundGradient)
        .listRowBackground(theme.backgroundGradient)
    }
    
    private func requestAppReview() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            AppStore.requestReview(in: windowScene)
        }
    }
}

struct RowItem: View {
    var icon: String?
    var image: ImageResource?
    var text: LocalizedStringKey
    var url: String?
    var type: RowItem.RowItemType
    var fill: RowItem.RowItemFill
    var surgeryDateBinding: Binding<Date>?
    var action: () -> Void
    var toggle: Binding<Bool>?
    
    private let theme: Theme = Theme.shared
    
    init(icon: String? = "", image: ImageResource? = nil, text: LocalizedStringKey) {
        self.icon = icon
        self.text = text
        self.image = image
        self.url = nil
        self.type = RowItem.RowItemType.text
        self.action = {}
        self.toggle = nil
        self.fill = .regular
    }
    
    init(icon: String? = nil, image: ImageResource? = nil, text: LocalizedStringKey, url: String) {
        self.icon = icon
        self.text = text
        self.image = image
        self.url = url
        self.type = RowItem.RowItemType.link
        self.action = {}
        self.toggle = nil
        self.fill = .regular
    }
    
    init(icon: String? = nil, image: ImageResource? = nil, text: LocalizedStringKey, surgeryDateBinding: Binding<Date>) {
        self.icon = icon
        self.image = image
        self.text = text
        self.type = RowItem.RowItemType.datePicker
        self.surgeryDateBinding = surgeryDateBinding
        self.action = {}
        self.toggle = nil
        self.fill = .regular
    }
    
    init(icon: String? = nil, image: ImageResource? = nil, text: LocalizedStringKey, action: @escaping () -> Void, background: RowItem.RowItemFill) {
        self.icon = icon
        self.image = image
        self.text = text
        self.type = RowItem.RowItemType.button
        self.action = action
        self.toggle = nil
        self.fill = background
    }
    
    init(icon: String? = nil, image: ImageResource? = nil, text: LocalizedStringKey, toggle: Binding<Bool>) {
        self.icon = icon
        self.image = image
        self.text = text
        self.type = RowItem.RowItemType.toggle
        self.action = {}
        self.toggle = toggle
        self.fill = .regular
    }
    
    enum RowItemType {
        case text, link, datePicker, button, toggle
    }
    
    enum RowItemFill {
        case regular, backgroundGradient
    }
    
    var body: some View {
        HStack {
            if let icon = icon {
                BackgroundCircleIcon(icon: icon)
            } else if let image = image {
                BackgroundCircleImage(image: image)
            }
           
            switch type {
                case .text: Text(text)
                case .link: Link(text, destination: URL(string: url ?? "")!)
                case .datePicker: if let surgeryDateBinding = surgeryDateBinding {
                    DatePicker("Operiert seit:", selection: surgeryDateBinding , displayedComponents: .date)
                }
                case .button: Text(text).onTapGesture { action() }
                case .toggle: Toggle(isOn: toggle ?? .constant(false), label: {}).labelsHidden()
            }
        }
        .foregroundStyle(fill == .regular ? theme.onBackground : theme.onPrimary)
        .font(.callout)
        .padding(.vertical, 5)
    }
    
    @ViewBuilder func BackgroundCircleIcon(icon:String) -> some View {
        ZStack {
            Circle()
                .fill(theme.backgroundGradient)
                .frame(width: 30, height: 30)
            
            Image(systemName: icon)
                .padding(10)
                .foregroundStyle(theme.onPrimary)
        }
    }
    
    @ViewBuilder func BackgroundCircleImage(image: ImageResource) -> some View {
        ZStack {
            Circle()
                .fill(theme.backgroundGradient)
                .frame(width: 30, height: 30)
            
            Image(image)
                .padding(10)
                .foregroundStyle(theme.onPrimary)
        }
    }
}
