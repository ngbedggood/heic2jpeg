//
//  ContentView.swift
//  heic2jpeg
//
//  Created by Nathaniel Bedggood on 05/04/2025.
//

import SwiftUI
import CoreImage
import PhotosUI

struct ContentView: View {
    
    let context = CIContext()
    
    @State private var selectedData: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    
    var body: some View {
        
        VStack {
            if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 300)
                        } else {
                            Text("No image selected")
                                .foregroundColor(.gray)
                        }
            
            PhotosPicker(selection: $selectedData, matching: .images) {
                Text("Select Photos")
            }
            .buttonStyle(.borderedProminent)
            
        }
        .onChange(of: selectedData) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                        let uiImage = UIImage(data: data) {
                            selectedImage = uiImage
                        } else {
                            print("Failed to load image data.")
                        }
                    }
                }
        .padding()

        
        
    }
}

#Preview {
    ContentView()
}
