//
//  AddTripView.swift
//  TravelDiary
//
//  Created by Bhavesh Raja on 12/04/24.
//

import SwiftUI
import CoreData
import MapKit
import CoreLocation
import AVFoundation

struct AddTripView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    @State private var thumbnail: UIImage?
    @State private var title: String = ""
    @State private var location: String = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var showingImagePicker = false
    @State private var showingMap = false
    @State private var alertMessage: AlertMessage?
    @State private var showingLocationPicker = false
    @State private var selectedLatitude: CLLocationDegrees = 0.0
    @State private var selectedLongitude: CLLocationDegrees = 0.0
    @State private var showingActionSheet = false
    @State private var sourceType: UIImagePickerController.SourceType?
    
    var currentUser: User? // The current user, passed from the previous view
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Thumbnail")) {
                    Button(action: {
                        self.showingActionSheet = true
                    }) {
                        if let thumbnail = self.thumbnail {
                            Image(uiImage: thumbnail)
                                .resizable()
                                .scaledToFit()
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    .frame(height: 200)
                }
                
                Section(header: Text("Details")) {
                    TextField("Title", text: $title)
                    HStack {
                        TextField("Location", text: $location)
                            .disabled(true)
                        Button(action: {
                            self.showingLocationPicker = true
                        }) {
                            Image(systemName: "location")
                        }
                    }
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }
                
                Button("Save") {
                    saveTrip()
                }
            }
            .navigationTitle("Add New Trip")
            .sheet(isPresented: $showingImagePicker) {
                if let sourceType = self.sourceType {
                    ImagePicker(image: self.$thumbnail, sourceType: sourceType)
                }
            }
            .actionSheet(isPresented: $showingActionSheet) {
                ActionSheet(title: Text("Add Image"), buttons: [
                    .default(Text("Take Picture"), action: {
                        sourceType = .camera
                        checkCameraPermission()
                    }),
                    .default(Text("Upload from Library"), action: {
                        sourceType = .photoLibrary
                        showingImagePicker = true
                    }),
                    .cancel()
                ])
            }
            .sheet(isPresented: $showingLocationPicker) {
                LocationPickerView(selectedLocation: $location, selectedLatitude: $selectedLatitude, selectedLongitude: $selectedLongitude)
            }
            .alert(item: $alertMessage) { alertMessage in
                Alert(title: Text(alertMessage.title), message: Text(alertMessage.message), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                sourceType = .camera // Set the source type
                showingImagePicker = true
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        DispatchQueue.main.async {
                            self.sourceType = .camera // Set the source type
                            self.showingImagePicker = true
                        }
                    } else {
                        // Handle denied access
                        self.alertMessage = AlertMessage(title: "Camera access denied", message: "Please allow access to the camera in your device settings.")
                    }
                }
            case .denied, .restricted:
                // Handle denied access
                self.alertMessage = AlertMessage(title: "Camera access denied", message: "Please allow access to the camera in your device settings.")
            default:
                break
        }
    }


    
    func saveTrip() {
        guard let currentUser = currentUser else {
            alertMessage = AlertMessage(title: "Error", message: "You must be logged in to add a trip.")
            return
        }
        
        guard !title.isEmpty, !location.isEmpty else {
            alertMessage = AlertMessage(title: "Error", message: "All fields are required.")
            return
        }
        
        let newTrip = Trip(context: viewContext)
        newTrip.thumbnail = thumbnail?.jpegData(compressionQuality: 1.0)
        newTrip.title = title
        newTrip.location = location
        newTrip.startDate = startDate
        newTrip.endDate = endDate
        newTrip.latitude = selectedLatitude
        newTrip.longitude = selectedLongitude
        currentUser.addToTrips(newTrip) // Associate trip with the current user
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            alertMessage = AlertMessage(title: "Error", message: "There was an error saving the trip.")
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            
            picker.dismiss(animated: true)
        }
    }
}

struct AlertMessage: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}


struct AddTripView_Previews: PreviewProvider {
    static var previews: some View {
        AddTripView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}


#Preview {
    AddTripView()
}

