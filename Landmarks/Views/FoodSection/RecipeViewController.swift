//
//  RecipeViewController.swift
//  Healthyland
//
//  Created by Henry Liu on 4/18/23.
//  Copyright © 2023 Apple. All rights reserved.
//
import SwiftUI
import Foundation


struct MealListView: View {
//    @State private var meals: [Meals] = []
    @EnvironmentObject var modeldata : ModelData

    var body: some View {
        if modeldata.meals.isEmpty {
            Button(action: {
                load_daily_meals_plan()
            }) {
                Text("Get meal plan")
                    .font(.headline)
                    .foregroundColor(.black)
            }
            .padding(.bottom, 20)
        } else {
            List(modeldata.meals, id: \.id) { meal in
                Text(meal.title)
            }
        }
    }

    // use rapidAPI - spoonacular to generate daily meal plan for user, specify needs
    // Generate a meal plan with three meals per day (breakfast, lunch, and dinner).
    func load_daily_meals_plan() {
        // ... same as before ...
        print("loading")
        let headers = [
            "X-RapidAPI-Key": "a5152753a2mshfc2bdfb8d6827d0p12166cjsnc3d253f069f4",
            "X-RapidAPI-Host": "spoonacular-recipe-food-nutrition-v1.p.rapidapi.com"
        ]

        let request = NSMutableURLRequest(url: NSURL(string: "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/mealplans/generate?timeFrame=day&targetCalories=3000&diet=vegetarian&exclude=shellfish%2C%20olives")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error!)
            } else {
                do {
                    print("here")
                    let responseDict = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
                    if let mealsArray = responseDict?["meals"] as? [[String: Any]],
                       let nutrients = responseDict?["nutrients"] as? [String: Any],
                        let calories = nutrients["calories"] as? Double,
                        let protein = nutrients["protein"] as? Double,
                        let carbohydrates = nutrients["carbohydrates"] as? Double,
                        let fat = nutrients["fat"] as? Double {
                            var meals: [Meal] = []
                            for mealDict in mealsArray {
                                if let id = mealDict["id"] as? Int,
                                    let title = mealDict["title"] as? String,
                                    let rec_serving = mealDict["servings"] as? Double,
                                    let readyInMinutes = mealDict["readyInMinutes"] as? Int {
                                    let meal = Meal(id: id, title: title, readyInMinutes: readyInMinutes, rec_serving: rec_serving, calories: calories, protein: protein, carbohydrates: carbohydrates, fat: fat, isFavorite: false, isFeatured: false, category: Meal.Category(rawValue: "unknown")!)
                                        meals.append(meal)
                                }
                            }
//                        self.meals = meals
                        self.modeldata.meals = meals
//                        modeldata.meals = meals
                        print("Loaded \(modeldata.meals) meals.")
                    }
                } catch let error {
                    print(error)
                }
            }
        })
        print("here2")
        dataTask.resume()
        print("here3")
    }
}


//struct Meals: Identifiable {
//    let id: Int
//    let title: String
//}

struct MealListView_Previews: PreviewProvider {
    static var previews: some View {
        MealListView()
            .environmentObject(ModelData())
    }
}


//struct MealListView: View {
//    @State private var meals: [Meals] = []
//
//    var body: some View {
//        List(meals, id: \.id) { meal in
//            Text(meal.title)
//        }
//        .onAppear {
//            loadData()
//        }
//    }
//
//    func loadData() {
//        let headers = [
//            "X-RapidAPI-Key": "d1d6ce0fadmsh1553dc0b01c48f7p1861d7jsnb92b5fd0ad06",
//            "X-RapidAPI-Host": "spoonacular-recipe-food-nutrition-v1.p.rapidapi.com"
//        ]
//
//        let request = NSMutableURLRequest(url: NSURL(string: "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/mealplans/generate?timeFrame=day&targetCalories=2000&diet=vegetarian&exclude=shellfish%2C%20olives")! as URL,
//                                          cachePolicy: .useProtocolCachePolicy,
//                                          timeoutInterval: 10.0)
//        request.httpMethod = "GET"
//        request.allHTTPHeaderFields = headers
//
//        let session = URLSession.shared
//        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
//            if (error != nil) {
//                print(error!)
//            } else {
//                do {
//                    let responseDict = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
//                    if let mealsArray = responseDict?["meals"] as? [[String: Any]] {
//                        var meals: [Meals] = []
//                        for mealDict in mealsArray {
//                            if let id = mealDict["id"] as? Int, let title = mealDict["title"] as? String {
//                                let meal = Meals(id: id, title: title)
//                                meals.append(meal)
//                            }
//                        }
//                        self.meals = meals
//                    }
//                } catch let error {
//                    print(error)
//                }
//            }
//        })
//        dataTask.resume()
//    }
//}

