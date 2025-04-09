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
    
    @State private var selectedData: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    
    @State private var quality: Double = 80.0
    @State private var estimatedFileSize = 0.0
    
    let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 80)) // Creates columns that adapt to available width
    ]
    
    var body: some View {
        VStack {
            Text("HEIC to JPEG Image Converter")
                .fontWeight(.bold)
                .font(.title2)
            PhotosPicker(selection: $selectedData, maxSelectionCount: nil, matching: .images) {
                    Text("Select Images")
            }
            .onChange(of: selectedData) { newItem in
                Task {
                    selectedImages = [] // Clear previous selections
                    for item in newItem {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            if let uiImage = UIImage(data: data) {
                                selectedImages.append(uiImage)
                            }
                        }
                    }
                }
            }
            .buttonStyle(.bordered)
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(selectedImages, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            .aspectRatio(1, contentMode: .fit) // Maintain square aspect ratio
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            Text("Output Quality")
                .fontWeight(.bold)
            HStack {
                Slider(value: $quality, in: 10...100, step: 1.0)
                Text("\(quality, specifier: "%.0f")%")
            }
            
            Text("Estimated Average File Size: \(estimatedFileSize, specifier: "%.1f") mb")
                .font(.caption)
                .padding()
            Button("Convert Images") {
                
            }
            .buttonStyle(.borderedProminent)

        }
        .padding(20)
    }
}
#Preview {
    ContentView()
}
