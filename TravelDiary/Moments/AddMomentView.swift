//
//  AddMomentView.swift
//  TravelDiary
//
//  Created by Bhavesh Raja on 14/04/24.
//

import Foundation
import SwiftUI
import CoreData
import PhotosUI


struct AddMomentView: View {
    let trip:Trip
    //@State private var trip: Trip
    @Environment(\.presentationMode) var presentationMode  // Inject the environment variable
    @Environment(\.managedObjectContext) var viewContext
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var images: [UIImage] = []
    @State private var isImagePickerPresented = false
    @State private var alertMessage: AlertMessage?
    
    init(trip: Trip) {
        self.trip = trip
        // Initialize other properties as needed
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Moment Details")) {
                    TextField("Title", text: $title)
                    TextEditor(text: $description)
                        .frame(height: 200)
                }
                
                Section(header: Text("Images")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(images, id: \.self) { img in
                                Image(uiImage: img)
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    
                    Button(action: {
                        self.isImagePickerPresented = true
                    }) {
                        Text("Pick Images")
                    }
                }
                
            }
            .navigationTitle("Add Moment")
            .navigationBarItems(leading: Button("Cancel") {
                // Add action to dismiss the view
                self.presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                saveMoment()
            })
            .sheet(isPresented: $isImagePickerPresented) {
                PhotoPicker(images: $images)
            }
            .alert(item: $alertMessage) { alertMessage in
                Alert(title: Text(alertMessage.title), message: Text(alertMessage.message), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func saveMoment() {
        guard !title.isEmpty, !description.isEmpty else {
            alertMessage = AlertMessage(title: "Error", message: "Title and description are required.")
            return
        }
        
        let newMoment = Moment(context: viewContext)
        newMoment.title = title
        newMoment.desc = description
        newMoment.timestamp = Date()
        newMoment.trip = trip
        
        // Convert and store the images
        let imageDataArray = images.map { $0.jpegData(compressionQuality: 1.0) }
        let imagesData = try? NSKeyedArchiver.archivedData(withRootObject: imageDataArray, requiringSecureCoding: false)
        
        newMoment.imagesData = imagesData
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            alertMessage = AlertMessage(title: "Error", message: "There was an error saving the moment: \(error.localizedDescription)")
        }
    }

    
    struct PhotoPicker: UIViewControllerRepresentable {
        @Binding var images: [UIImage]
        
        func makeUIViewController(context: Context) -> PHPickerViewController {
            var config = PHPickerConfiguration()
            config.selectionLimit = 0 // 0 means no limit
            config.filter = .images
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = context.coordinator
            return picker
        }
        
        func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        class Coordinator: NSObject, PHPickerViewControllerDelegate {
            var parent: PhotoPicker
            
            init(_ parent: PhotoPicker) {
                self.parent = parent
            }
            
            func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
                picker.dismiss(animated: true)
                for result in results {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                        if let image = image as? UIImage {
                            DispatchQueue.main.async {
                                self.parent.images.append(image)
                                        print("Selected image: \(image), size: \(image.size)")
                            }
                        } else if let error = error {
                            print("Error loading image: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
    
    
    struct AlertMessage: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }
    
    
    struct AddMomentView_Previews: PreviewProvider {
        static var previews: some View {
            let mockTrip = Trip(context: PersistenceController.preview.container.viewContext)
            // Set up the mockTrip as needed for the preview
            return AddMomentView(trip: mockTrip)
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
    
}
