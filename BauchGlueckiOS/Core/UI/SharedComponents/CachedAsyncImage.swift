//
//  CachedAsyncImage.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 04.11.24.
//

import SwiftUI 

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    @StateObject private var loader: AsyncImageLoader
        private let content: (Image) -> Content
        private let placeholder: Placeholder

        init(
            url: URL?,
            @ViewBuilder content: @escaping (Image) -> Content,
            @ViewBuilder placeholder: () -> Placeholder
        ) {
            _loader = StateObject(wrappedValue: AsyncImageLoader(url: url))
            self.content = content
            self.placeholder = placeholder()
        }

        var body: some View {
            if let image = loader.image {
                content(Image(uiImage: image))
            } else {
                placeholder
            }
        }
}
