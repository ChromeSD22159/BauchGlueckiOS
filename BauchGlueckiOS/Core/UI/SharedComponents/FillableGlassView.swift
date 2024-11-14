//
//  FillableGlassView.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 27.10.24.
//
import SwiftUI
import Foundation

struct FillableGlassView: View {
    var defaultSize: CGFloat
    let theme = Theme.shared
    
    var onClick: () -> Void
    
    @Binding var isFilled: Bool
    @State private var fillLevel: CGFloat = 0.1
    @Binding var isActive: Bool
    @State private var bubbles: [Bubble] = []
    @State private var animateState = false
    @State private var timer: Timer?

    var animationDelay: Int
    var bgColor: Color
    
    init(
        defaultSize: CGFloat = 40,
        bgColor: Color,
        isActive: Binding<Bool>,
        isFilled: Binding<Bool>,
        bubbles: [Bubble] = [],
        onClick: @escaping () -> Void = {},
        animationDelay: Int
    ) {
        self.defaultSize = defaultSize
        self._isFilled = isFilled
        self._isActive = isActive
        self.fillLevel = 0.1
        self.onClick = onClick
        self.bubbles = bubbles
        self.animationDelay = animationDelay
        self.bgColor = bgColor
    }
    
    var body: some View {
        ZStack {
            Glass(filled: $fillLevel)
            Bubbles(filled: $fillLevel)
            LeftOverlay()
            RightOverlay()
            
            if isActive && !isFilled {
                Image(systemName: "plus")
                    .font(.headline)
                    .foregroundStyle(.black)
            }
        }
        .onAppLifeCycle(
            appear: {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(animationDelay) / 10, execute: {
                    withAnimation(.easeInOut) {
                        if isFilled {
                            fillLevel = 0.8
                            bubbles = BubbleService.generateBubbles(glassWidth: defaultSize * 0.8, glassHeight: defaultSize * 0.8, numBubbles: 5)
                            startBubbleAnimation()
                        }
                    }
                })
            },
            active: {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(animationDelay) / 10, execute: {
                    withAnimation(.easeInOut) {
                        if isFilled {
                            fillLevel = 0.8
                            bubbles = BubbleService.generateBubbles(glassWidth: defaultSize * 0.8, glassHeight: defaultSize * 0.8, numBubbles: 5)
                            startBubbleAnimation()
                        }
                    }
                })
            },
            background: {
                fillLevel = 0.1
            }
        )
        .onTapGesture {
            withAnimation(.easeInOut) {
                if (isActive) {
                    self.fillLevel = 0.8
                    onClick()
                } else if !isFilled {
                    self.fillLevel = 0.8
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        self.fillLevel = 0.1
                    })
                }
            }
        }
        .frame(width: defaultSize, height: defaultSize)
        .onChange(of: isFilled, {
            if !isFilled {
                self.fillLevel = 0.1
                self.bubbles = []
            } else {
                bubbles = BubbleService.generateBubbles(glassWidth: defaultSize * 0.8, glassHeight: defaultSize * 0.8, numBubbles: 5)
                startBubbleAnimation()
            }
        })
    }

    @ViewBuilder func LeftOverlay() -> some View {
        Path { path in
            let size = defaultSize
            let percent = defaultSize / 5
            path.move(to: CGPoint(x: 0 , y: 0))
            path.addLine(to: CGPoint(x: 0, y: size))
            path.addLine(to: CGPoint(x: percent, y: size))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.closeSubpath()
        }
        .fill(bgColor)
        .frame(width: defaultSize, height: defaultSize)
    }
    
    @ViewBuilder func RightOverlay() -> some View {
        Path { path in
            let size = defaultSize
            let percent = defaultSize / 5
            path.move(to: CGPoint(x: size , y: 0))
            path.addLine(to: CGPoint(x: size, y: size))
            path.addLine(to: CGPoint(x: (size - percent), y: size))
            path.addLine(to: CGPoint(x: size, y: 0))
            path.closeSubpath()
        }
        .fill(bgColor)
        .frame(width: defaultSize, height: defaultSize)
    }
    
    @ViewBuilder func Glass(
        filled: Binding<CGFloat>
    ) -> some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(Color.blue.opacity(0.25))
            
            Rectangle()
                .fill(Color.blue.opacity(0.25))
                .frame(
                      width: defaultSize,
                      height: defaultSize * filled.wrappedValue
                )
             
            
            Rectangle()
                .fill(LinearGradient(colors: [
                    Color.white.opacity(0.15),
                    Color.white.opacity(0.2),
                    Color.white.opacity(0.3),
                    Color.white.opacity(0.15),
                    Color.white.opacity(0.15)
                ], startPoint: .leading, endPoint: .trailing))
        }
        .frame(width: defaultSize, height: defaultSize)
        .border(bgColor, width: 1)
    }
    
    @ViewBuilder func Bubbles(
        filled: Binding<CGFloat>
    ) -> some View {
        ZStack {
            Canvas { context, size in
                for bubble in bubbles {
                    let circle = Path(ellipseIn: CGRect(x: bubble.x - bubble.radius, y: bubble.y - bubble.radius, width: bubble.radius * 2, height: bubble.radius * 2))
                    context.fill(circle, with: .color(Color.white.opacity(bubble.opacity)))
                }
            }
            .frame(width: defaultSize, height: defaultSize * filled.wrappedValue)
        }
    }
    
    private func startBubbleAnimation() {
        timer?.invalidate() // Stop any previous timer
        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            bubbles = bubbles.updateBubbles(deltaTime: 16, glassHeight: 40 / 0.8)
        }
    } 

    private func stopBubbleAnimation() {
      timer?.invalidate()
      timer = nil
    }
}

struct Bubble: Identifiable {
    var id: UUID
    var x: CGFloat
    var y: CGFloat
    var radius: CGFloat
    var opacity: CGFloat
}

class BubbleService {
    static func generateBubbles(glassWidth: CGFloat, glassHeight: CGFloat, numBubbles: Int = 10) -> [Bubble] {
        var newBubbles = [Bubble]()
        
        // Reduziere die Mindestabstände, damit auch kleinere Glasmaße funktionieren
        let minXPadding: CGFloat = 1
        let minYPadding: CGFloat = 1
        
        guard glassWidth > minXPadding * 2, glassHeight > minYPadding * 2 else {
            print("Glass dimensions are too small to generate bubbles")
            return newBubbles
        }
        
        for _ in 0..<numBubbles {
            let xRange = max(minXPadding, glassWidth - minXPadding)
            let yRange = max(minYPadding, glassHeight - minYPadding)
            
            let x = CGFloat.random(in: minXPadding..<xRange)
            let y = CGFloat.random(in: minYPadding..<yRange)
            let radius = CGFloat.random(in: 1..<2)
            let opacity = CGFloat.random(in: 0.1..<0.3)
            
            newBubbles.append(Bubble(id: UUID(), x: x, y: y, radius: radius, opacity: opacity))
        }
        
        return newBubbles
    }
}

extension [Bubble] {
    func updateBubbles(deltaTime: TimeInterval, glassHeight: CGFloat) -> [Bubble] {
        let bubbleSpeed: CGFloat = 10

        return self.map { bubble in
            var newY = bubble.y - CGFloat(deltaTime) / 1000.0 * bubbleSpeed

            // Wenn die Blase oben angekommen ist, setze sie unten wieder ein
            if newY + bubble.radius < (glassHeight * 0.2) {
                newY = glassHeight
            }

            return Bubble(id: bubble.id, x: bubble.x, y: newY, radius: bubble.radius, opacity: bubble.opacity)
        }
    }
}
