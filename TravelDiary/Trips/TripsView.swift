//
//  TripsView.swift
//  TravelDiary
//
//  Created by Bhavesh Raja on 12/04/24.
//

import SwiftUI
import CoreData

struct TripsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var userAuth: UserAuth
    @FetchRequest(
        entity: Trip.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Trip.startDate, ascending: true)]
    ) var allTrips: FetchedResults<Trip>
    @State private var showingAddTripView = false
    @State private var showingDeleteConfirmation = false
    @State private var deleteIndexSet: IndexSet?
    @State private var listKey = UUID()
    
    var userTrips: [Trip] {
        allTrips.filter { $0.user == userAuth.currentUser }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if userTrips.isEmpty {
                    // Show message when there are no trips
                    Text("Add trips and your memories of the trips!")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(userTrips, id: \.self) { trip in
                            NavigationLink(destination: TripDetailView(trip: trip, listKey: $listKey)) {
                                TripRow(trip: trip)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button("Delete") {
                                    showingDeleteConfirmation = true
                                    deleteIndexSet = IndexSet(integer: allTrips.firstIndex(of: trip)!)
                                }
                                .tint(.red)
                            }
                        }
                        .onDelete(perform: deleteTrips)
                    }
                    .id(listKey)
                    .alert("Are you sure you want to delete this trip?", isPresented: $showingDeleteConfirmation) {
                        Button("Delete", role: .destructive) {
                            if let indexSet = deleteIndexSet {
                                deleteTrips(offsets: indexSet)
                            }
                        }
                        Button("Cancel", role: .cancel) { }
                    }
                }
            }
            .navigationBarTitle("Trips")
            .navigationBarItems(trailing: Button(action: {
                self.showingAddTripView = true
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingAddTripView) {
                AddTripView(currentUser: userAuth.currentUser).environment(\.managedObjectContext, self.viewContext)
            }
            .onAppear {
                // Refresh the view when it appears
                listKey = UUID()
            }
        }
    }

    private func deleteTrips(offsets: IndexSet) {
        withAnimation {
            offsets.map { allTrips[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                // handle the Core Data error
                print(error)
            }
        }
    }
}

struct TripRow: View {
    let trip: Trip

    var body: some View {
        HStack {
            // If there is a thumbnail, display it; otherwise, display a placeholder
            Group {
                if let thumbnailData = trip.thumbnail, let uiImage = UIImage(data: thumbnailData) {
                    Image(uiImage: uiImage)
                        .resizable()
                } else {
                    Image(systemName: "photo.on.rectangle.angled") // Placeholder image
                        .resizable()
                }
            }
            .frame(width: 60, height: 60)
            .aspectRatio(contentMode: .fill)
            .clipped()
            .cornerRadius(6)
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.white, lineWidth: 1))
            
            VStack(alignment: .leading) {
                Text(trip.title ?? "Untitled Trip")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(trip.location ?? "Unknown location")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if let startDate = trip.startDate, let endDate = trip.endDate {
                    Text("From \(startDate, formatter: itemFormatter) to \(endDate, formatter: itemFormatter)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private var itemFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
}


//struct TripsView_Previews: PreviewProvider {
//    static var previews: some View {
//        TripsView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext).environmentObject(UserAuth(context: PersistenceController.preview.container.viewContext))
//    }
//}
