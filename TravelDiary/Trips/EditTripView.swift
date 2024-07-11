import SwiftUI
import CoreData
import CoreLocation
import AVFoundation

struct EditTripView: View {
    @ObservedObject var trip: Trip
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    @State private var thumbnail: UIImage?
    @State private var title: String
    //@State private var location: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var showingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType?
    @Binding var listKey: UUID

    
    init(trip: Trip, listKey: Binding<UUID>) {
        self._listKey = listKey
        self.trip = trip
        _title = State(initialValue: trip.title ?? "")
        //_location = State(initialValue: trip.location ?? "")
        _startDate = State(initialValue: trip.startDate ?? Date())
        _endDate = State(initialValue: trip.endDate ?? Date())
        _thumbnail = State(initialValue: trip.thumbnail.flatMap(UIImage.init))
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Thumbnail")) {
                    Button(action: {
                        self.sourceType = .photoLibrary
                        self.showingImagePicker = true
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
                    //TextField("Location", text: $location)
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }

                Button("Save Changes") {
                    saveChanges()
                }
            }
            .navigationTitle("Edit Trip")
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: self.$thumbnail, sourceType: self.sourceType ?? .photoLibrary)
            }
        }
    }

    private func saveChanges() {
        // Update the trip with the new data
        trip.title = title
        //trip.location = location
        trip.startDate = startDate
        trip.endDate = endDate
        trip.thumbnail = thumbnail?.jpegData(compressionQuality: 1.0)

        do {
            try viewContext.save()
            self.listKey = UUID()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving trip: \(error)")
        }
    }
}


