//
//  FullScreenImageView.swift
//  heic2jpeg
//
//  Created by Nathaniel Bedggood on 14/04/2025.
//

import SwiftUI
import PhotosUI

struct FullScreenImageView: View {
    @Environment(\.dismiss) var dismiss
    let image: Image

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .onTapGesture {
                dismiss()
            }
        }
    }
}

#Preview {
    FullScreenImageView(image: Image(systemName: "figure.strengthtraining.functional"))
}
