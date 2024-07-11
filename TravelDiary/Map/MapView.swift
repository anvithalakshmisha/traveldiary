//
//  MapView.swift
//  TravelDiary
//
//  Created by Anvitha Lakshmisha on 4/23/24.
//

import SwiftUI
import MapKit
import CoreData

struct VisitedLocation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

struct MapView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var userAuth: UserAuth
    
    @State private var visitedLocations: [VisitedLocation] = []
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0))
    
    var body: some View {
        VStack {
            Map(coordinateRegion: $region, annotationItems: visitedLocations) { location in
                MapPin(coordinate: location.coordinate, tint: .red)
            }
            .onAppear {
                updateVisitedLocations()
            }
            
            HStack {
                Spacer()
                HStack {
                    Button(action: {
                        zoomIn()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                    .padding()
                    
                    Button(action: {
                        zoomOut()
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                    .padding()
                }
                Spacer()
            }

        }
    }
    
    private func updateVisitedLocations() {
        visitedLocations.removeAll()
        
        guard let currentUser = userAuth.currentUser else {
            return
        }
        
        let fetchRequest: NSFetchRequest<Trip> = Trip.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "user == %@", currentUser)
        
        do {
            let trips = try viewContext.fetch(fetchRequest)
            for trip in trips {
                let location = VisitedLocation(name: "Trip Location", coordinate: CLLocationCoordinate2D(latitude: trip.latitude, longitude: trip.longitude))
                visitedLocations.append(location)
            }
        } catch {
            print("Error fetching trips: \(error.localizedDescription)")
        }
    }
    
    private func zoomIn() {
        let newSpan = MKCoordinateSpan(latitudeDelta: region.span.latitudeDelta * 0.5, longitudeDelta: region.span.longitudeDelta * 0.5)
        let newRegion = MKCoordinateRegion(center: region.center, span: newSpan)
        region = newRegion
    }
    
    private func zoomOut() {
        let newSpan = MKCoordinateSpan(latitudeDelta: region.span.latitudeDelta * 2.0, longitudeDelta: region.span.longitudeDelta * 2.0)
        let newRegion = MKCoordinateRegion(center: region.center, span: newSpan)
        region = newRegion
    }
}



#Preview {
    MapView()
}
