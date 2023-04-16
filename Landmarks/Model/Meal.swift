//
//  Meal.swift
//  Healthyland
//
//  Created by Henry Liu on 4/16/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
import SwiftUI

struct Meal: Identifiable, Decodable {
    var id: Int
    var title: String
    var image: String?
    var restaurantChain : String?
    var imageType: String?
    var readyInMinutes:Int?
    var servings: Servings? // change type to Servings
    var rec_serving: Double?
    var calories: Double?
    var protein: Double?
    var carbohydrates: Double?
    var fat: Double?
    var description: String?
    var isFavorite: Bool
    var isFeatured: Bool
    
    var category: Category
    enum Category: String, CaseIterable, Codable {
        case breakfast = "breakfast"
        case dinner = "dinner"
        case lunch = "lunch"
        case unknown = "unknown"
        
    }


//    var image_to_display: Image {
//        if let loadedImage = breakfastImages[imageName] {
//            return Image(uiImage: loadedImage)
//        } else {
//            return Image(systemName: "photo")
//        }
//    }
}

struct Servings: Hashable, Codable {
    var number: Int
    var size: Double?
    var unit: String?
}
