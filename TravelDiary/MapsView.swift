//
//  MapView.swift
//  TravelDiary
//
//  Created by Anvitha Lakshmisha on 4/23/24.
//

import SwiftUI
import MapKit

struct VisitedLocation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

struct MapView: View {
    @State private var visitedLocations: [VisitedLocation] = [
        VisitedLocation(name: "Location 1", coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)),
        VisitedLocation(name: "Location 2", coordinate: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437)),
        // Add more visited locations here...
    ]
    
    var body: some View {
        Map(coordinateRegion: .constant(getCoordinateRegion()), annotationItems: visitedLocations) { location in
            MapPin(coordinate: location.coordinate, tint: .red)
        }
        //        .edgesIgnoringSafeArea(.all)
    }
    
    private func getCoordinateRegion() -> MKCoordinateRegion {
        guard let initialLocation = visitedLocations.first else {
            return MKCoordinateRegion()
        }
        let span = MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
        return MKCoordinateRegion(center: initialLocation.coordinate, span: span)
    }
}

#Preview {
    MapView()
}
