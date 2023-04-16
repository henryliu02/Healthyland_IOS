/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Storage for model data.
*/

import Foundation
import Combine
import HealthKit
import UIKit
import SwiftUI


struct Schedule: Identifiable {
    var id = UUID()
    var workout: Workout
    var minutes: Int
    var date: Date = Date()
    var selectedTime : String
    var isSelected: Bool
    
}

struct FoodSchedule: Identifiable {
    var id = UUID()
    var food: Meal
    var calories: Double
    var servings: Int
    var date: Date = Date()
    var selectedTime : String
    var isSelected: Bool
}


//struct Food: Hashable, Codable, Identifiable {
//    var id: Int
//    var title: String
//    var image: String
//    var restaurantChain : String
//    var imageType: String
//}

struct HealthStatus: Identifiable, Codable {
    var id: UUID
    var type: HealthDataType
    var value: Double
    var date: Date
    var heartRate: Double? // optional property for heart rate data
    var sleepTime: Double? // optional property for sleep time data
    var steps: Int? // optional property for step count data
    var calories: Double? // optional property for calorie burn data
    
    
    enum HealthDataType: String, CaseIterable, Codable {
        case heartRate
        case sleepTime
        case steps
        case calories
        // add additional cases for other health data types as needed
    }
}

struct PersonalData: Codable {
    var name: String?
    var sex: String?
    var dob: String?
    var blood: String?
    var age: Int?
    var height: String?
    var weight: String?
    var medicalCondition: String?
    
}


final class ModelData: ObservableObject {
    @Published var landmarks: [Workout] = load("workoutData.json")
    var hikes: [Hike] = load("hikeData.json")
    @Published var profile = Profile.default
    @Published var schedules: [Schedule] = [] // new property to hold schedules
    @Published var all_meals: [Meal] = load("all_meals.json")
    
    @Published var meals: [Meal] = [] // new property to hold meals
    
    @Published var mealSchedule: [FoodSchedule] = [] // new property to hold meals
    
    
    @Published var healthStatuses: [HealthStatus] = []
    @Published var personalData: PersonalData = PersonalData()
    @Published var totalCalories: Int = 0 // new property to hold total calories
    
    
    var features: [Workout] {
        landmarks.filter { $0.isFeatured }
    }

    var categories: [String: [Workout]] {
        Dictionary(
            grouping: landmarks,
            by: { $0.category.rawValue }
        )
    }
    
    
    var meal_features: [Meal] {
        all_meals.filter { $0.isFeatured }
    }
    
    var meal_categories: [String: [Meal]] {
        Dictionary(
            grouping: all_meals,
            by: { $0.category.rawValue }
        )
    }
    
    
    let healthStore = HKHealthStore() // create a HealthStore instance
        
    func requestAuthorization() {
        let typesToShare: Set<HKSampleType> = []
        let typesToRead = Set([
                HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
                HKObjectType.quantityType(forIdentifier: .heartRate)!,
                HKObjectType.quantityType(forIdentifier: .stepCount)!,
                HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                HKSampleType.characteristicType(forIdentifier: .biologicalSex)!,
                HKSampleType.characteristicType(forIdentifier: .dateOfBirth)!,
                HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!,
                HKSampleType.quantityType (forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
                
            ])
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            if let error = error {
                print("Error requesting authorization: \(error.localizedDescription)")
            } else {
                print("Authorization request successful.")
            }
        }
        readData()
        readMostRecentHeight_Weight()
        DispatchQueue.main.async {
            self.healthStatuses.removeAll()
        }
        retrieveHealthData()
    }
    func readData(){
        var age : Int?
        var sex : HKBiologicalSex?
        var sexData : String = "Unknown"
        var bloodtype:String = "n/a"
        var birth: String = "Unknown"

        do{
            let birthDay = try healthStore.dateOfBirthComponents()
            print("birthday raw:\(birthDay)")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy"
            dateFormatter.calendar = Calendar(identifier: .gregorian)

            let date = birthDay.date ?? Date()
            let dateString = dateFormatter.string(from: date)
            birth = dateString
            let calendar = Calendar.current
            let currentYear = calendar.component(.year, from: Date() )
            age = currentYear - birthDay.year!
            
        }catch{
            
        }

        do{
            let getSex = try healthStore.biologicalSex()
            sex = getSex.biologicalSex
            if let data = sex {
                sexData = self.getReadableBiologicalSex(biologicalSex: data)
            }
        }catch{}
        
        do{
            let bloodType = try healthStore.bloodType()
            let bloodTypeString = HKBloodTypeString(bloodType: bloodType.bloodType)
            print(bloodTypeString) // Output: "O+"
            bloodtype = bloodTypeString

        }catch{
        }

        print("Age: \(age ?? 0)")
        print("Sex: \(sexData)")
        print("BloodType:\(bloodtype)")
        print("DOB:\(birth)")
        DispatchQueue.main.async {
            self.personalData.dob = birth
            self.personalData.age = age ?? 0
            self.personalData.sex = sexData
            self.personalData.blood = bloodtype
        }
    }
    
    func HKBloodTypeString(bloodType: HKBloodType) -> String {
        switch bloodType {
        case .notSet:
            return "Not Set"
        case .aPositive:
            return "A+"
        case .aNegative:
            return "A-"
        case .bPositive:
            return "B+"
        case .bNegative:
            return "B-"
        case .abPositive:
            return "AB+"
        case .abNegative:
            return "AB-"
        case .oPositive:
            return "O+"
        case .oNegative:
            return "O-"
        @unknown default:
            fatalError("Unknown blood type")
        }
    }

    func getReadableBiologicalSex(biologicalSex: HKBiologicalSex?) -> String{
        var biologicalSexTest = "Not Retrived"

        if biologicalSex != nil {
            switch biologicalSex!.rawValue{
                case 0:
                    biologicalSexTest = ""
                case 1:
                    biologicalSexTest = "Female"
                case 2:
                    biologicalSexTest = "Male"
                case 3:
                    biologicalSexTest = "Other"
                default:
                    biologicalSexTest = ""
            }
        }

        return biologicalSexTest
    }
    
    func readMostRecentHeight_Weight(){
        var recent_weight: String = "Weight: n/a"
        var recent_height: String = "Height: n/a"
        let weightType = HKSampleType.quantityType (forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
        let heightType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!

        let queryWeight = HKSampleQuery(sampleType: weightType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in

            if let result = results?.last as? HKQuantitySample {
                print("weight => \(result.quantity)")
                recent_weight = result.quantity.description
                
            }else{print("no weight data")}
            DispatchQueue.main.async {
                self.personalData.weight = recent_weight
            }
        }
        


        let queryHeight = HKSampleQuery(sampleType: heightType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in

            if let result = results?.last as? HKQuantitySample {
                print("height => \(result.quantity)")
                recent_height = result.quantity.description
            }else{print("no height data")}
            DispatchQueue.main.async {
                self.personalData.height = recent_height
            }
        }

        healthStore.execute(queryWeight)
        healthStore.execute(queryHeight)
    }
    

    func retrieveHealthData() {
        // 1. Define the types of data to be retrieved
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let activeCaloriesType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        
        // 2. Define the date range for the data to be retrieved
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now).addingTimeInterval(-60 * 60 * 24 * 7)

        // 3. Define the predicates for each type of data
        
        let sleepPredicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictEndDate)
        let heartRatePredicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictEndDate)
        let stepCountPredicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictEndDate)
        let activeCaloriesPredicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictEndDate)
        
        


        // 4. Define the queries for each type of data
        
        let sleepQuery = HKSampleQuery(sampleType: sleepType, predicate: sleepPredicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { (query, results, error) in
            if let samples = results as? [HKCategorySample] {
                var totalTimeInBed: TimeInterval = 0
                for sample in samples {
                    let timeInBed = sample.endDate.timeIntervalSince(sample.startDate)
                    totalTimeInBed += timeInBed
                }
                let averageTimeInBed = totalTimeInBed / Double(samples.count)
                DispatchQueue.main.async {
                    self.healthStatuses.append(HealthStatus(
                        id: UUID(),
                        type: .sleepTime,
                        value: Double(averageTimeInBed),
                        date: Date(),
                        heartRate: nil,
                        sleepTime: averageTimeInBed,
                        steps: nil,
                        calories: nil
                    ))
                }
            }
        }

        let heartRateQuery = HKSampleQuery(sampleType: heartRateType, predicate: heartRatePredicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { (query, results, error) in
            if let samples = results as? [HKQuantitySample] {
                var averageHeartRate: Double = 0
                for sample in samples {
                    let heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
                    averageHeartRate += heartRate
                }
                averageHeartRate /= Double(samples.count)
                DispatchQueue.main.async {
                    self.healthStatuses.append(HealthStatus(
                        id: UUID(),
                        type: .heartRate,
                        value: Double(averageHeartRate),
                        date: Date(),
                        heartRate: averageHeartRate,
                        sleepTime: nil,
                        steps: nil,
                        calories: nil
                    ))
                }
            }
        }

        let stepCountQuery = HKSampleQuery(sampleType: stepCountType, predicate: stepCountPredicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { (query, results, error) in
            if let samples = results as? [HKQuantitySample] {
                var totalStepCount: Int = 0
                for sample in samples {
                    let stepCount = Int(sample.quantity.doubleValue(for: HKUnit.count()))
                    totalStepCount += stepCount
                }
                DispatchQueue.main.async {
                    self.healthStatuses.append(HealthStatus(
                        id: UUID(),
                        type: .steps,
                        value: Double(totalStepCount),
                        date: Date(),
                        heartRate: nil,
                        sleepTime: nil,
                        steps: totalStepCount,
                        calories: nil
                    ))
                }
            }
        }

        let activeCaloriesQuery = HKSampleQuery(sampleType: activeCaloriesType, predicate: activeCaloriesPredicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { (query, results, error) in
            if let samples = results as? [HKQuantitySample] {
                var totalActiveCalories: Double = 0
                for sample in samples {
                    let activeCalories = sample.quantity.doubleValue(for: HKUnit.kilocalorie())
                    totalActiveCalories += activeCalories
                }
                DispatchQueue.main.async {
                    self.healthStatuses.append(HealthStatus(
                        id: UUID(),
                        type: .calories,
                        value: Double(totalActiveCalories),
                        date: Date(),
                        heartRate: nil,
                        sleepTime: nil,
                        steps: nil,
                        calories: totalActiveCalories
                    ))
                }
            }
        }

        // 5. Execute the queries
        healthStore.execute(sleepQuery)
        healthStore.execute(heartRateQuery)
        healthStore.execute(stepCountQuery)
        healthStore.execute(activeCaloriesQuery)
    }
}


func load<T: Decodable>(_ filename: String) -> T {
    let data: Data

    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }

    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}
