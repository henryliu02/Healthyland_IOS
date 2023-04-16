/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view that presents a map of a landmark.
*/

import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @StateObject private var locationViewModel = LocationViewModel()
    @State private var region = MKCoordinateRegion()

    var body: some View {
        Map(coordinateRegion: $region)
            .onAppear {
                locationViewModel.requestLocation()
            }
            .onReceive(locationViewModel.$region, perform: { newRegion in
                region = newRegion
            })
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}

class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var region = MKCoordinateRegion()

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let coordinate = location.coordinate
            region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user's location: \(error.localizedDescription)")
    }
}
