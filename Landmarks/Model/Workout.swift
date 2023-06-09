/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A representation of a single landmark.
*/

import Foundation
import SwiftUI
import CoreLocation

struct Workout: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
    var park: String
    var calo_burn: Float
    var state: String
    var description: String
    var isFavorite: Bool
    var isFeatured: Bool

    var category: Category
    enum Category: String, CaseIterable, Codable {
        case weeks_program = "Weeks Long Program"
        case indoor = "Indoor"
        case outdoor = "Outdoor"
    }
    
    private var imageName: String
    var image: Image {
        Image(imageName)
    }

//    private var coordinates: Coordinates
//    var locationCoordinate: CLLocationCoordinate2D {
//        CLLocationCoordinate2D(
//            latitude: coordinates.latitude,
//            longitude: coordinates.longitude)
//    }
//
//    struct Coordinates: Hashable, Codable {
//        var latitude: Double
//        var longitude: Double
//    }
}
