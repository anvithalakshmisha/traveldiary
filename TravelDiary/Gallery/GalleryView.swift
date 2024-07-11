//
//  GalleryView.swift
//  TravelDiary
//
//  Created by Bhavesh Raja on 12/04/24.
//

import SwiftUI
import CoreData

struct GalleryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var userAuth: UserAuth
    @FetchRequest var trips: FetchedResults<Trip>
    // This state will keep track of the selected image for presentation
    @State private var selectedImage: UIImage?
    @State private var isShowingDetailView = false
    
    
    init() {
        // Configure the fetch request to dynamically filter based on the logged-in user
        let request: NSFetchRequest<Trip> = Trip.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Trip.startDate, ascending: true)]
        // Placeholder for user filter, to be replaced in `.onAppear` with actual user
        request.predicate = NSPredicate(format: "user == nil")
        _trips = FetchRequest(fetchRequest: request)
    }
    
    private var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 4) // Adjust the count as needed for your design
    
    var body: some View {
        ScrollView {
            LazyVStack {
                if trips.isEmpty {
                    // Show message when there are no trips
                    Text("Add trips and your memories of the trips")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(trips) { trip in
                        Section(header: Text(trip.title ?? "Trip")
                            .font(.headline)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)) {
                                if trip.momentsArray.isEmpty {
                                    // Show message when there are trips but no moments
                                    Text("No moments for this trip yet")
                                        .foregroundColor(.gray)
                                        .padding()
                                } else {
                                    LazyVGrid(columns: columns, spacing: 10) {
                                        ForEach(trip.momentsArray.flatMap { $0.imagesArray.compactMap { UIImage(data: $0) } }, id: \.self) { image in
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 100, height: 100)
                                                .clipped()
                                                .padding(10)
                                            // Add your image tap action here
                                                .onTapGesture {
                                                    // When an image is tapped, update the selected image and show the detail view
                                                    self.selectedImage = image
                                                    self.isShowingDetailView = true
                                                }
                                        }
                                    }
                                }
                            }
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingDetailView) {
            // This will present the selected image in a detail view
            if let selectedImage = selectedImage {
                ImageViewer(image: selectedImage)
            }
        }
        .onAppear {
            updateFetchRequest()
        }
    }
    
    private func updateFetchRequest() {
        // Assuming `userAuth.currentUser` is of the same type expected in the Trip entity's user relationship
        if let user = userAuth.currentUser {
            trips.nsPredicate = NSPredicate(format: "user == %@", user)
        }
    }
}

extension Trip {
    var momentsArray: [Moment] {
        (moments?.allObjects as? [Moment]) ?? []
    }
}

extension Moment {
    var imagesArray: [Data] {
        guard let imagesData = imagesData else { return [] }
        
        do {
            if let array = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(imagesData) as? [Data] {
                return array
            }
        } catch {
            print("Failed to unarchive imagesData")
        }
        
        return []
    }
}


struct GalleryView_Previews: PreviewProvider {
    static var previews: some View {
        GalleryView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(UserAuth(context: PersistenceController.preview.container.viewContext))
    }
}

