//
//  HandleErrorsByShowingAlertViewModifier.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 19.11.24.
//

import Foundation
import SwiftUI

// MARK: - Protokolle und Fehler

/// Protokoll zur Vereinheitlichung der Fehlerbeschreibung.
protocol ErrorHandlingProtocol {
    var localizedDescription: String { get }
}
 
/// Benutzerdefinierte Fehler mit lokalisierter Beschreibung.
enum CustomError: Error, LocalizedError {
    case test
    
    var localizedDescription: String {
        switch self {
        case .test:
            return "Test Error"
        }
    }
}



// MARK: - Modelle

/// Fehler-Alert-Modell für SwiftUI Alerts.
struct ErrorButton {
    var text: String
    var action: () throws -> Void
}
 
/// Modell für Fehler-Buttons zur Interaktion bei Fehlern.
struct ErrorAlert: Identifiable {
    var id = UUID()
    var message: String
    var dismissAction: (() -> Void)?
}



// MARK: - ViewModel

/// ObservableObject zur zentralen Fehlerverwaltung.
class ErrorHandling: ObservableObject {
    /// `ErrorHandling` ist eine ObservableObject-Klasse, die den aktuellen Fehlerzustand der App verwaltet.
    /// Sie speichert den aktuellen `ErrorAlert` und stellt eine Methode `handle` bereit, um Fehler in Alerts umzuwandeln.
    /// Es prüft, ob der Fehler `TestError` ist, um die benutzerdefinierte Beschreibung anzuzeigen,
    /// andernfalls wird die Standard-Fehlerbeschreibung (`localizedDescription`) genutzt.
    
    @Published var currentAlert: ErrorAlert? = nil
    
    func handle(error: Error) {
        if let customError = error as? CustomError {
            currentAlert = ErrorAlert(message: customError.localizedDescription)
        } else {
            currentAlert = ErrorAlert(message: error.localizedDescription)
        }
    }
}



// MARK: - ViewModifiers

/// ViewModifier für Alerts basierend auf Fehlern.
struct HandleErrorsByShowingAlertViewModifier: ViewModifier {
    /// Der `HandleErrorsByShowingAlertViewModifier` ist ein ViewModifier, der dem View einen Alert hinzufügt.
    /// Dieser Modifier überwacht das `currentAlert` in der `ErrorHandling`-Umgebung und zeigt bei Bedarf einen Alert an.
    /// Der Alert zeigt den Fehlertitel und die Nachricht an und bietet eine "Ok"-Taste, um ihn zu schließen.
    ///
    @EnvironmentObject var errorHandling: ErrorHandling

    func body(content: Content) -> some View {
        content
            .background(
                EmptyView()
                    .alert(item: $errorHandling.currentAlert) { currentAlert in
                        Alert(
                            title: Text("Error"),
                            message: Text(currentAlert.message),
                            dismissButton: .default(Text("Ok")) {
                                currentAlert.dismissAction?()
                            }
                        )
                    }
            )
    }
}

/// ViewModifier für Popover-Anzeige bei Fehlern.
struct WithErrorPopover: ViewModifier {
    @EnvironmentObject var errorHandling: ErrorHandling
    
    var errorButton: ErrorButton? = nil
    
    init(errorButton: ErrorButton? = nil) {
        self.errorButton = errorButton
    }
    
    func body(content: Content) -> some View {
        ZStack {
           content
           if let currentAlert = errorHandling.currentAlert {
               VStack {
                   HStack {
                       FootLineText(currentAlert.message.description)
                       if let errorButton = errorButton {
                           Spacer()
                           
                           Button(errorButton.text) {
                               do {
                                   try errorButton.action()
                               } catch {
                                   errorHandling.handle(error: error)
                               }
                           }
                           .buttonStyle(CapsuleButtonStyle())
                       }
                   }
                   .onAppear {
                       startTimer()
                   }
                   .padding()
                   .background(Material.thickMaterial.opacity(0.9))
                   .cornerRadius(10)
                   
                   Spacer()
               }
               .padding()
               .transition(.move(edge: .top))
           }
       }
       .animation(.easeInOut, value: errorHandling.currentAlert != nil)
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            withAnimation(.easeInOut(duration: 1.0)) {
                errorHandling.currentAlert = nil
            }
        }
    }
}
  
/// ViewModifier zur Steuerung der Sichtbarkeit einer View.
struct ShowView: ViewModifier {
    @Binding var isPresendet: Bool
    
    func body(content: Content) -> some View {
        content
            .opacity(isPresendet ? 1 : 0)
            .animation(.easeInOut, value: isPresendet)
    }
}

/// ViewModifier für Tap-Gesten mit Fehlerbehandlung.
struct ErrorHandlingTapModifier: ViewModifier {
    @EnvironmentObject var errorHandling: ErrorHandling
    
    let action: () throws -> Void

    func body(content: Content) -> some View {
        content.onTapGesture {
            do {
                try action()
            } catch {
                errorHandling.handle(error: error)
            }
        }
    }
}

// MARK: - Buttons
struct TryButton<Content: View>: View {
    @EnvironmentObject var errorHandling: ErrorHandling
    let label: Content
    var action: () async throws -> Void

    init(@ViewBuilder label: () -> Content, action: @escaping () async throws -> Void = {}) {
        self.label = label()
        self.action = action
    }

    init(text: String, action: @escaping () async throws -> Void = {}) where Content == Text {
        self.label = Text(text)
        self.action = action
    }

    var body: some View {
        Button(action: performAction) { label }
    }

    private func performAction() {
        Task {
            do {
                try await action()
            } catch {
                errorHandling.handle(error: error)
            }
        }
    }
}



// MARK: - Erweiterungen
extension View {
    /// Diese Erweiterung bietet die Methode `withErrorHandling`, um automatisch einen Alert für Fehler anzuzeigen.
    ///
    /// Der Modifier verwendet eine Fehlerbehandlungslösung, wie beispielsweise ein `EnvironmentObject`,
    /// das die Fehler sammelt und diese als Alert in der View präsentiert. Dies erleichtert die Integration
    /// von Fehlerbehandlungen in jede View.
    ///
    /// Beispiel:
    /// ```
    /// @StateObject var errorHandling = ErrorHandling()
    ///
    /// var body: some Scene {
    ///     WindowGroup {
    ///         ContentView()
    ///             .environmentObject(errorHandling)
    ///             .withErrorHandling()
    ///     }
    /// }
    /// ```
    /// - Returns: Eine modifizierte View, die Fehler durch einen Alert anzeigt.
    func withErrorHandling() -> some View {
        modifier(HandleErrorsByShowingAlertViewModifier())
    }
    
    /// Diese Erweiterung zeigt einen Fehler-Popover, falls Fehler auftreten, und bietet optional
    /// einen Fehler-Button zur Fehlerinteraktion an.
    ///
    /// Der Modifier verwendet ein `ErrorButton`-Objekt, das bei Fehlerereignissen angezeigt wird.
    /// Dies ist nützlich, wenn eine visuellere Darstellung von Fehlern benötigt wird,
    /// anstatt diese nur in einem Alert darzustellen.
    ///
    /// Beispiel:
    /// ```
    ///   View()
    ///     .withErrorPopover(errorButton: ErrorButton(title: "Fehler anzeigen")) 
    ///
    ///   View()
    ///     .withErrorPopover()
    /// ```
    /// - Parameter errorButton: Ein optionaler `ErrorButton`, der benutzerdefinierte Interaktionen ermöglicht.
    /// - Returns: Eine modifizierte View, die Fehler als Popover anzeigt.
    func withErrorPopover(errorButton: ErrorButton? = nil) -> some View {
        modifier(WithErrorPopover(errorButton: errorButton))
    }
    
    /// Diese Erweiterung zeigt oder verbirgt eine View basierend auf einem `@Binding`,
    /// das steuert, ob die View präsentiert wird.
    ///
    /// Dies ist besonders nützlich, um modale Präsentationen oder Overlay-Views zu steuern.
    ///
    /// Beispiel:
    /// ```
    /// @State private var isPresented = false
    ///
    /// var body: some View {
    ///     Button("Show View") {
    ///         isPresented.toggle()
    ///     }
    ///
    ///     Text("Test")
    ///         .showView(isPresendet: $isPresented)
    /// }
    /// ```
    /// - Parameter isPresendet: Ein `@Binding`, das steuert, ob die View angezeigt wird.
    /// - Returns: Eine modifizierte View, die die Anzeigezustände basierend auf dem Binding kontrolliert.
    func showView(@Binding isPresendet: Bool) -> some View {
        modifier(ShowView(isPresendet: $isPresendet))
    }
    
    /// Diese Erweiterung fügt einer View eine Tap-Geste hinzu, die eine Aktion mit Fehlerbehandlung ausführt.
    ///
    /// Die Aktion wird in einem `do-catch`-Block ausgeführt, und bei einem Fehler wird dieser
    /// automatisch an die Fehlerbehandlung weitergeleitet.
    ///
    /// Beispiel:
    /// ```
    /// Text("Test")
    ///     .onTapGestureWithErrorHandling {
    ///         // Potenziell fehlerhafte Aktion
    ///         try someRiskyAction()
    ///     }
    /// ```
    /// - Parameter action: Eine Aktion, die potenziell Fehler werfen kann und sicher ausgeführt werden soll.
    /// - Returns: Eine modifizierte View, die eine Tap-Geste mit Fehlerbehandlung unterstützt.
    func onTapGestureWithErrorHandling(
        action: @escaping () throws -> Void
    ) -> some View {
        modifier(ErrorHandlingTapModifier(action: action))
    }
}



// MARK: - Preview
/// In der Preview wird eine `StateObject`-Instanz von `ErrorHandling` verwendet, um den Fehlerzustand zu simulieren.
/// Ein Button wird verwendet, um den Fehler `TestError.test` auszulösen und die Fehlerbehandlung zu testen.
/// Der Alert wird angezeigt, sobald der Fehler ausgelöst wird, und nutzt die `withErrorHandling`-Methode.
/// Die `environmentObject`-Methode sorgt dafür, dass die Fehlerinstanz im View-Hierarchie verfügbar ist.
#Preview {
    @Previewable @StateObject var errorHandling = ErrorHandling()
    
    // @EnvironmentObject var errorHandling: ErrorHandling
    
    ScreenHolder { 
        
        TryButton(text: "Test Alert", action: {
            throw CustomError.test
        })
        .frame(maxWidth: .infinity)
        //.withErrorHandling()
        
    }
    .withErrorPopover(errorButton: ErrorButton(text: "CUSTOM", action: {
        
    }))
    .environmentObject(errorHandling)
}
