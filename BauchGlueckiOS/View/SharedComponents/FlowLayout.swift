//
//  FlowLayout.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 29.10.24.
//
import SwiftUI

struct FlowLayout<Content: View>: View {
    var horizontalSpacing: CGFloat
    var verticalSpacing: CGFloat
    var items: [String]
    let content: (String) -> Content

    init(
        items: [String],
        horizontalSpacing: CGFloat = 10,
        verticalSpacing: CGFloat = 10,
        @ViewBuilder content: @escaping (String) -> Content
    ) {
        self.items = items
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading) {
            createRows()
        }.frame(maxWidth: .infinity)
    }
    
    private func createRows() -> some View {
        var rows: [[String]] = [[]]
        var currentWidth: CGFloat = 0
        let screenWidth = UIScreen.main.bounds.width
        
        for item in items {
            let itemWidth = approximateWidth(for: item)
            
            if currentWidth + itemWidth + horizontalSpacing > screenWidth {
                // Beginne eine neue Zeile
                rows.append([item])
                currentWidth = itemWidth + horizontalSpacing
            } else {
                // Füge das Element zur aktuellen Zeile hinzu
                rows[rows.count - 1].append(item)
                currentWidth += itemWidth + horizontalSpacing
            }
        }
        
        return VStack(alignment: .leading, spacing: verticalSpacing) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: horizontalSpacing) {
                    ForEach(row, id: \.self) { item in
                        content(item)
                    }
                }
            }
        }
    }
    
    // Eine ungefähre Breitenberechnung für jedes Element
    private func approximateWidth(for item: String) -> CGFloat {
        return CGFloat(item.count * 10 + 20)
    }
}
