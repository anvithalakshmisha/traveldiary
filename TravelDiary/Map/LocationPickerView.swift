import SwiftUI
import MapKit
import CoreLocation

//struct LocationPickerView: View {
//    @Binding var selectedLocation: String
//    @Binding var selectedLatitude: CLLocationDegrees
//    @Binding var selectedLongitude: CLLocationDegrees
//    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
//    @State private var locationManager = CLLocationManager()
//    @State private var placeName: String = ""
//    @Environment(\.presentationMode) var presentationMode
//
//    var body: some View {
//        VStack {
//            HStack {
//                Spacer()
//                Button(action: {
//                    selectedLocation = placeName // Update selectedLocation
//                    selectedLatitude = region.center.latitude // Update selectedLatitude
//                    selectedLongitude = region.center.longitude // Update selectedLongitude
//                    presentationMode.wrappedValue.dismiss() // Dismiss when "Done" is clicked
//                }) {
//                    Text("Done")
//                        .padding()
//                        .foregroundColor(.blue)
//                        .cornerRadius(8)
//                }
//            }
//            .padding(.horizontal)
//
//            Map(coordinateRegion: $region, showsUserLocation: true)
//                .edgesIgnoringSafeArea(.all)
//                .onAppear {
//                    locationManager.requestWhenInUseAuthorization()
//                    locationManager.startUpdatingLocation()
//                }
//                .onReceive(NotificationCenter.default.publisher(for: .locationUpdate)) { _ in
//                    if let location = locationManager.location {
//                        region.center = location.coordinate
//                        fetchPlaceName(for: location.coordinate)
//                    }
//                }
//                .onTapGesture {
//                    // Dismiss the keyboard if open
//                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//                }
//
//            Text(placeName)
//                .padding()
//
//            Spacer()
//
//            Button(action: {
//                useCurrentLocation()
//            }) {
//                Text("Use Current Location")
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .foregroundColor(.white)
//                    .background(Color.blue)
//                    .cornerRadius(8)
//            }
//            .padding()
//        }
//    }
//
//    private func useCurrentLocation() {
//        if let location = locationManager.location {
//            region.center = location.coordinate
//            fetchPlaceName(for: location.coordinate)
//            selectedLocation = placeName
//            selectedLatitude = location.coordinate.latitude
//            selectedLongitude = location.coordinate.longitude
//        }
//    }
//
//    private func fetchPlaceName(for coordinates: CLLocationCoordinate2D) {
//        let geocoder = CLGeocoder()
//        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
//        geocoder.reverseGeocodeLocation(location) { placemarks, error in
//            guard let placemark = placemarks?.first, error == nil else {
//                print("Error fetching placemark: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//            placeName = placemark.name ?? "Unknown"
//        }
//    }
//}
//
//extension Notification.Name {
//    static let locationUpdate = Notification.Name("locationUpdate")
//}


struct LocationPickerView: View {
    @Binding var selectedLocation: String
    @Binding var selectedLatitude: CLLocationDegrees
    @Binding var selectedLongitude: CLLocationDegrees
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
    @State private var placeName: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    selectedLocation = placeName // Update selectedLocation
                    selectedLatitude = region.center.latitude // Update selectedLatitude
                    selectedLongitude = region.center.longitude // Update selectedLongitude
                    presentationMode.wrappedValue.dismiss() // Dismiss when "Done" is clicked
                }) {
                    Text("Done")
                        .padding()
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            
            Map(coordinateRegion: $region, showsUserLocation: true)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    fetchPlaceName(for: region.center)
                }
                .onTapGesture {
                    let touchCoordinate = region.center
                    region.center = touchCoordinate
                    fetchPlaceName(for: touchCoordinate)
                }
            
            HStack {
                Text(placeName)
                    .padding()
                Spacer()
                
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
            
            Button(action: {
                useCurrentLocation()
            }) {
                Text("Use Current Location")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding()
        }
    }
    
    private func zoomIn() {
        let span = MKCoordinateSpan(latitudeDelta: region.span.latitudeDelta * 0.5, longitudeDelta: region.span.longitudeDelta * 0.5)
        let newRegion = MKCoordinateRegion(center: region.center, span: span)
        region = newRegion
    }
    
    private func zoomOut() {
        let span = MKCoordinateSpan(latitudeDelta: region.span.latitudeDelta * 2.0, longitudeDelta: region.span.longitudeDelta * 2.0)
        let newRegion = MKCoordinateRegion(center: region.center, span: span)
        region = newRegion
    }
    
    private func useCurrentLocation() {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization() // Request authorization
        if let location = locationManager.location {
            region.center = location.coordinate
            fetchPlaceName(for: location.coordinate)
            selectedLocation = placeName
            selectedLatitude = location.coordinate.latitude
            selectedLongitude = location.coordinate.longitude
        }
    }
    
    private func fetchPlaceName(for coordinates: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                print("Error fetching placemark: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            placeName = placemark.name ?? "Unknown"
        }
    }
}



extension Notification.Name {
    static let locationUpdate = Notification.Name("locationUpdate")
}
