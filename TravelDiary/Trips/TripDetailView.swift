//
//  TripDetailView.swift
//  TravelDiary
//
//  Created by Bhavesh Raja on 12/04/24.
//

import SwiftUI
import CoreData

struct TripDetailView: View {
    @ObservedObject var trip: Trip
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest var moments: FetchedResults<Moment>
    @State private var showingAddMomentView = false
    @State private var showingDeleteConfirmation = false
    @State private var momentToDelete: Moment?
    @State private var showingEditTripView = false
    @Binding var listKey: UUID

    
    init(trip: Trip, listKey: Binding<UUID>) {
        self._listKey = listKey
        self.trip = trip
        _moments = FetchRequest<Moment>(
            sortDescriptors: [NSSortDescriptor(keyPath: \Moment.timestamp, ascending: true)],
            predicate: NSPredicate(format: "trip == %@", trip)
        )
    }
    
    var body: some View {
        List {
            Section(header: Text("Trip Details")) {
                if let imageData = trip.thumbnail, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .listRowInsets(EdgeInsets())
                }
                
                VStack(alignment: .leading) {
                    Text(trip.title ?? "Untitled Trip")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if let location = trip.location {
                        Text(location)
                            .font(.headline)
                    }
                    
                    if let startDate = trip.startDate, let endDate = trip.endDate {
                        Text("From \(startDate, formatter: itemFormatter) to \(endDate, formatter: itemFormatter)")
                            .font(.subheadline)
                    }
                }
            }
            Section(header: Text("Moments")) {
                if moments.isEmpty {
                    Text("No moments yet.")
                        .foregroundColor(.secondary)
                } else {
                        // List of MomentRows
                        ForEach(moments) { moment in
                            MomentRow(moment: moment)
                            .swipeActions {
                                Button(role: .destructive) {
                                    momentToDelete = moment
                                    showingDeleteConfirmation = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        .onDelete(perform: deleteMoments)
                        .onAppear {
                            // Force the fetch request to update
                            self.moments.nsPredicate = NSPredicate(format: "trip == %@", self.trip)
                        }
                }
                    
                
                // Add new moment button
                Button(action: {
                    showingAddMomentView = true
                }) {
                    Text("Add New Moment")
                        .foregroundColor(.blue)
                }
            }
            .alert("Are you sure you want to delete this moment?", isPresented: $showingDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    if let momentToDelete = momentToDelete, let index = moments.firstIndex(of: momentToDelete) {
                        deleteMoments(offsets: IndexSet(integer: index))
                    }
                }
                Button("Cancel", role: .cancel) {
                    // Reset the state when canceling
                    momentToDelete = nil
                    showingDeleteConfirmation = false
                }
            }
            .onDisappear {
                // When the view disappears, reset the state variables
                self.momentToDelete = nil
                self.showingDeleteConfirmation = false
            }

        }
        .navigationBarTitle(Text(trip.title ?? "Trip Details"), displayMode: .inline)
        .navigationBarItems(trailing:
        Button(action: {
            showingEditTripView = true
        }) {
            Image(systemName: "pencil")
        })
        .sheet(isPresented: $showingAddMomentView) {
            AddMomentView(trip: trip).environment(\.managedObjectContext, self.viewContext)
        }
        .sheet(isPresented: $showingEditTripView) {
            EditTripView(trip: trip, listKey: $listKey)
                .environment(\.managedObjectContext, self.viewContext)
        }
    }
    
    private func deleteMoments(offsets: IndexSet) {
        withAnimation {
            offsets.map { moments[$0] }.forEach { moment in
                viewContext.delete(moment)
            }
            do {
                try viewContext.save()
            } catch {
                // Handle the error
                print("Error when deleting moment: \(error)")
            }
        }
    }

    private var itemFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }
}

// Uncomment and adjust the preview provider as necessary
// struct TripDetailView_Previews: PreviewProvider {
//     static var previews: some View {
//         TripDetailView(trip: Trip())
//             .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//     }
// }
