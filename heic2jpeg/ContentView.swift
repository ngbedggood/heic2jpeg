//
//  ContentView.swift
//  heic2jpeg
//
//  Created by Nathaniel Bedggood on 05/04/2025.
//

import SwiftUI
import CoreImage
import PhotosUI

struct FullScreenImageItem: Identifiable {
    let id = UUID()
    let image: UIImage
}

struct ContentView: View {
    
    let context = CIContext()
    
    @State private var selectedData: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    
    @State private var isDelete: Bool = false
    
    @State private var fullScreenImageItem: FullScreenImageItem?
    
    @State private var quality: Double = 80.0
    @State private var estimatedFileSizeBefore = 0.0
    @State private var estimatedFileSizeAfter = 0.0
    
    let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 80)) // Creates columns that adapt to available width
    ]
    
    var body: some View {
        VStack {
            Text("HEIC to JPEG Image Converter")
                .fontWeight(.bold)
                .font(.title2)
            HStack {
                PhotosPicker(selection: $selectedData, maxSelectionCount: nil, matching: .images) {
                    Text("Select Images")
                }
                Button("Remove Images") {
                    isDelete.toggle()
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .disabled(selectedImages.isEmpty)
            }
            
            .onChange(of: selectedData) { _, newItem in
                Task {
                    selectedImages = [] // Clear previous selections
                    for item in newItem {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            if let uiImage = UIImage(data: data) {
                                selectedImages.append(uiImage)
                                let size = Measurement(value: Double(data.count), unit: UnitInformationStorage.bytes)
                                estimatedFileSizeBefore += size.converted(to: .megabytes).value
                                // PLACEHOLDER NOT ACCURATE
                                estimatedFileSizeAfter += size.converted(to: .megabytes).value * quality / 100
                            }
                        }
                    }
                }
                selectedData = []
            }
            .buttonStyle(.bordered)
            NavigationStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(selectedImages, id: \.self) { image in
                            ZStack {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                                    .aspectRatio(1, contentMode: .fit)
                                    .cornerRadius(8)
                                    .onTapGesture {
                                        fullScreenImageItem = FullScreenImageItem(image: image)
                                    
                                    }
                                if isDelete {
                                    Button("Delete", systemImage: "xmark.circle.fill") {
                                        selectedImages.remove(at: selectedImages.firstIndex(of: image)!)
                                    }
                                    .font(.title)
                                    .foregroundStyle(.red)
                                    .labelStyle(.iconOnly)
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.2))
            }
            
            Text("Output Quality")
                .fontWeight(.bold)
            HStack {
                Slider(value: $quality, in: 10...100, step: 1.0)
                Text("\(quality, specifier: "%.0f")%")
            }
            .onChange(of: quality) {
                // PLACEHOLDER NOT ACCURATE
                estimatedFileSizeAfter = estimatedFileSizeBefore * quality / 100
            }
            
            VStack {
                Text("Estimated Average File Size Reduction:")
                    .font(.caption)
                Text("\(estimatedFileSizeBefore, specifier: "%.1f") MB -> \(estimatedFileSizeAfter, specifier: "%.1f") MB")
                    .font(.caption)
            }
            .padding()
            
            Button("Convert Images") {
                for image in selectedImages {
                    if let data = image.jpegData(compressionQuality: quality/100) {
                        saveJpegDataToPhotoLibrary(jpegData: data)
                    }
                }
                
            }
            .buttonStyle(.borderedProminent)
            
        }
        .padding(20)
        .fullScreenCover(item: $fullScreenImageItem) { item in
            let image = Image(uiImage: item.image)
            FullScreenImageView(image: image)
        }
    }
    
    func saveJpegDataToPhotoLibrary(jpegData: Data) {
            PHPhotoLibrary.shared().performChanges {
                let creationRequest = PHAssetCreationRequest.forAsset()
                creationRequest.addResource(with: .photo, data: jpegData, options: nil)
            } completionHandler: { success, error in
                DispatchQueue.main.async { // Update UI on the main thread
                    if success {
                        print("JPEG data saved successfully to Photo Library.")
                        // Optionally show an alert or update UI to indicate success
                    } else if let error = error {
                        print("Error saving JPEG data: \(error.localizedDescription)")
                        // Optionally show an alert with the error message
                    }
                }
            }
        }
    
}

#Preview {
    ContentView()
}
