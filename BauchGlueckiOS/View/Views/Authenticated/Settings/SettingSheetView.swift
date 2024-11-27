//
//  Settings.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 22.10.24.
//
import SwiftUI
import StoreKit

struct SettingSheetView: View {
    
    @Environment(\.theme) private var theme
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var settingViewModel: SettingViewModel
    @EnvironmentObject var errorHandling: ErrorHandling
    @EnvironmentObject var services: Services
    
    var body: some View {
        NavigationView {
            ZStack {
                theme.color.background.ignoresSafeArea()
                
                List {
                    
                    TimeSinceSurgeryBadge()
                    
                    
                    Section {
                        NavigationLink {
                            ProfileEditView(viewModel: settingViewModel)
                                .navigationBackButton(
                                    color: theme.color.onBackground,
                                    destination: Destination.settings,
                                    onDismissAction: {
                                        Task {
                                            try await settingViewModel.updateProfile()
                                        }
                                    },
                                    showSettingButton: false
                                )
                        } label: {
                            SettingRowItem(icon: "person.fill", text: "Profile")
                                .listRowBackground(theme.color.backgroundGradient)
                        }

                        SettingRowItem(image: .iconStromach, text: "Bypass since:", surgeryDateBinding: settingViewModel.surgeryDateBinding)
                        
                        Toggle(isOn: settingViewModel.syncingBinding, label: {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(theme.color.backgroundGradient)
                                        .frame(width: 30, height: 30)
                                    
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                        .padding(10)
                                        .foregroundStyle(theme.color.onPrimary)
                                }
                                Text("Backend Syncing")
                            }
                            .font(.callout)
                        })
                        
                    } header: {
                        Text("Profile")
                    }
                    
                    Section{
                        SettingRowItem(icon: "envelope", text: "Support + Feedback", url: "mailto:jon.doe@mail.com")
                        SettingRowItem(icon: "star.fill", text: "Rate 5 stars", action: { requestAppReview() }, background: .regular)
                    } header: {
                        Text("Support")
                    }
                    
                    Section {
                        SettingRowItem(icon: "globe", text: "Instagram des Entwicklers", url: "https://www.instagram.com/frederik.code/")
                   
                        SettingRowItem(icon: "globe", text: "Webseite des Entwicklers", url: "https://www.frederikkohler.de")
                        
                        SettingRowItem(icon: "square.grid.2x2.fill", text: "Apps des Entwicklers", url: "https://apps.apple.com/at/developer/frederik-kohler/id1692240999")
                        
                        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
                        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
                        let string = "Version \(version) (Build Number: \(build))"
                        SettingRowItem(icon: "info.circle", text: LocalizedStringKey(string))
                    } header: {
                        Text("Developer")
                    }
                    
                    if let userProfile = userViewModel.userProfile {
                        Section {
                            DeleteUserAccountAlert {
                                SettingRowItem(icon: "trash" ,text: "\(userProfile.firstName)`s Account Löschen", action: {
                                    Task {
                                        try await services.apiService.deleteDeviceTokenFromBackend()
                                        
                                        services.medicationService.removeAllMedicationNotifications()
                                        
                                        try await userViewModel.deleteAccount()
                                    }
                                }, background: .regular)
                            }
                        } header: {
                            Text("Account")
                        }
                    }
                    
                    
                    SettingRowItem(
                        icon: "iphone.and.arrow.forward",
                        text: "Abmelden",
                        action: {
                            Task {
                                do {
                                    try await services.apiService.deleteDeviceTokenFromBackend()
                                    
                                    services.medicationService.removeAllMedicationNotifications()
                                    
                                    try userViewModel.signOut()
                                } catch {
                                    errorHandling.handle(error: error)
                                }
                            }
                        },
                        background: .backgroundGradient
                    )
                    .listRowBackground(theme.color.backgroundGradient)
                        
                }
            }
            .navigationTitle("⚙️ Einstellungen")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder func TimeSinceSurgeryBadge() -> some View {
        Section {
            VStack {
                HStack(alignment: .top, spacing: 10) {
                    Image(.iconStromach)
                        .resizable()
                        .frame(width: 32.0, height: 32.0)
                        .foregroundStyle(theme.color.onPrimary)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        HeadLineText(settingViewModel.greeting, color: theme.color.onBackground)
                        FootLineText("Unglaublich, wie schnell die Zeit vergeht!", color: theme.color.onBackground)
                        FootLineText(settingViewModel.timeSinceSurgery, color: theme.color.onBackground)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 10)
            }
        }
        .foregroundStyle(theme.color.backgroundGradient)
        .listRowBackground(theme.color.backgroundGradient)
    }
    
    private func requestAppReview() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            AppStore.requestReview(in: windowScene)
        }
    }
}

struct SettingRowItem: View {
    @Environment(\.theme) private var theme
    
    var icon: String?
    var image: ImageResource?
    var text: LocalizedStringKey
    var url: String?
    var type: SettingRowItem.RowItemType
    var fill: SettingRowItem.RowItemFill
    var surgeryDateBinding: Binding<Date>?
    var action: () -> Void
    var toggle: Binding<Bool>? 
    
    init(icon: String? = "", image: ImageResource? = nil, text: LocalizedStringKey) {
        self.icon = icon
        self.text = text
        self.image = image
        self.url = nil
        self.type = SettingRowItem.RowItemType.text
        self.action = {}
        self.toggle = nil
        self.fill = .regular
    }
    
    init(icon: String? = nil, image: ImageResource? = nil, text: LocalizedStringKey, url: String) {
        self.icon = icon
        self.text = text
        self.image = image
        self.url = url
        self.type = SettingRowItem.RowItemType.link
        self.action = {}
        self.toggle = nil
        self.fill = .regular
    }
    
    init(icon: String? = nil, image: ImageResource? = nil, text: LocalizedStringKey, surgeryDateBinding: Binding<Date>) {
        self.icon = icon
        self.image = image
        self.text = text
        self.type = SettingRowItem.RowItemType.datePicker
        self.surgeryDateBinding = surgeryDateBinding
        self.action = {}
        self.toggle = nil
        self.fill = .regular
    }
    
    init(icon: String? = nil, image: ImageResource? = nil, text: LocalizedStringKey, action: @escaping () -> Void, background: SettingRowItem.RowItemFill) {
        self.icon = icon
        self.image = image
        self.text = text
        self.type = SettingRowItem.RowItemType.button
        self.action = action
        self.toggle = nil
        self.fill = background
    }
    
    init(icon: String? = nil, image: ImageResource? = nil, text: LocalizedStringKey, toggle: Binding<Bool>) {
        self.icon = icon
        self.image = image
        self.text = text
        self.type = SettingRowItem.RowItemType.toggle
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
        .foregroundStyle(fill == .regular ? theme.color.onBackground : theme.color.onPrimary)
        .font(.callout)
        .padding(.vertical, 5)
    }
    
    @ViewBuilder func BackgroundCircleIcon(icon:String) -> some View {
        ZStack {
            Circle()
                .fill(theme.color.backgroundGradient)
                .frame(width: 30, height: 30)
            
            Image(systemName: icon)
                .padding(10)
                .foregroundStyle(theme.color.onPrimary)
        }
    }
    
    @ViewBuilder func BackgroundCircleImage(image: ImageResource) -> some View {
        ZStack {
            Circle()
                .fill(theme.color.backgroundGradient)
                .frame(width: 30, height: 30)
            
            Image(image)
                .padding(10)
                .foregroundStyle(theme.color.onPrimary)
        }
    }
}

struct DeleteUserAccountAlert<Content: View>: View {
    @State var showAlert: Bool = false
    
    var content: Content
    var accept: (() -> Void)?
    
    init(content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack {
            Button(action: { self.showAlert = true }, label: { content })
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Schade.."),
                message: Text("Möchtest du dein Konto wirklich löschen?"),
                primaryButton: .cancel(),
                secondaryButton: .default(Text("Löschen")) { accept?() }
            )
        }
    }
}

struct SettingSheet: ViewModifier {
    @EnvironmentObject var errorHandling: ErrorHandling
    @StateObject private var viewModel: SettingViewModel
     
    var isSettingSheet: Binding<Bool>
  
    var onDismiss: () -> Void
    
    init(
        isSettingSheet: Binding<Bool>,
        @ObservedObject userViewModel: UserViewModel,
        onDismiss: @escaping() -> Void
    ) {
        self._viewModel = StateObject(wrappedValue: SettingViewModel(userViewModel: userViewModel))
        self.isSettingSheet = isSettingSheet
        self.onDismiss = onDismiss
    }

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: isSettingSheet, onDismiss: {
                Task {
                    do {
                        try await viewModel.updateProfile()
                    } catch {
                        errorHandling.handle(error: error)
                    }
                }
            }, content: {
                SettingSheetView()
                    .environmentObject(viewModel)
            })
            .presentationDragIndicator(.visible)
    }
}

#Preview {
    DeleteUserAccountAlert {
        Text("Delete")
    }
}
