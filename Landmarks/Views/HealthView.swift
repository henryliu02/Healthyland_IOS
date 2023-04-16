//
//  HealthView.swift
//  Landmarks
//
//  Created by Henry Liu on 4/8/23.
//  Copyright © 2023 Apple. All rights reserved.
//


import SwiftUI

struct PulseAnimation: ViewModifier {
    @Binding var shouldAnimate: Bool

    func body(content: Content) -> some View {
        content
            .scaleEffect(shouldAnimate ? 1.3 : 1)
            .opacity(shouldAnimate ? 0 : 1)
            .animation(Animation.easeInOut(duration: 0.5))
    }
}

struct HealthView: View {
    @EnvironmentObject var modelData: ModelData
    @State private var selectedWorkouts = Set<Int>()
    @State private var addedCalories = false
    @State private var isAnimating = false
    @State private var totalCalories = 0
    @State private var selectedStatus: [(index: Int, isSelected: Bool)] = []
    @State private var isExpanded = true // Add a @State property to keep track of whether the view is expanded or not
    @State private var scheduleExpanded = true
    @State private var dietaryExpanded = true



//    func toggleSelectedWorkout(index: Int) {
//        modelData.schedules[index].isSelected.toggle()
//        calculateTotalCalories()
//    }
//
//    func calculateTotalCalories() -> Int {
//        var totalCalories = 0
//        for index in selectedWorkouts {
//            let schedule = modelData.schedules[index]
//            totalCalories += Int(schedule.workout.calo_burn * Float(schedule.minutes))
//        }
//        return totalCalories
//    }

    func getTotalCalories() -> Int {
        return totalCalories
    }

    // update totalCalories variable when a workout is added
    func addWorkoutToTotalCalories(workout: Workout, minutes: Int) {
        totalCalories += Int(workout.calo_burn * Float(minutes))
    }

    // update totalCalories variable when a workout is deleted
    func deleteWorkoutFromTotalCalories(workout: Workout, minutes: Int) {
        totalCalories -= Int(workout.calo_burn * Float(minutes))
    }


        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Image(systemName: "hourglass.circle.fill")
                            .foregroundColor(.purple)
                            .font(.system(size: 30))
                        Text("Daily Schedule")
                            .font(.title)
                            .fontWeight(.bold)
                        Spacer() // seperate between text and button horizontally
                        Button(action: {
                           scheduleExpanded.toggle() // Toggle the @State property when the "Expand" button is tapped
                       }, label: {
                           if scheduleExpanded {
                               Image(systemName: "arrow.down.right.and.arrow.up.left")
                           } else {
                               Image(systemName: "arrow.up.backward.and.arrow.down.forward")
                           }
                       })
                    }
                    .padding(.top, 40)

//                    if modelData.schedules.isEmpty {
//                        Text("You have no workout schedules.")
//                            .foregroundColor(.secondary)
//                    } else {
//                        ForEach(Array(modelData.schedules.enumerated()).sorted { (schedule1, schedule2) -> Bool in
//                            let formatter = DateFormatter()
//                            formatter.dateFormat = "h:mm a"
//                            return formatter.date(from: schedule1.element.selectedTime)! < formatter.date(from: schedule2.element.selectedTime)!
//                        }, id: \.1.id) { index, schedule in
//                            VStack(alignment: .leading) {
//                                HStack {
//                                    Text(schedule.workout.name)
//                                        .font(.headline)
//                                    Spacer()
//                                    Button(action: {
//                                        if selectedWorkouts.contains(index) {
//                                            selectedWorkouts.remove(index)
//                                            if selectedWorkouts.isEmpty {
//                                                addedCalories = false
//                                            }
//                                        } else {
//                                            selectedWorkouts.insert(index)
//                                            addedCalories = true
//                                        }
//                                    }) {
//                                        if selectedWorkouts.contains(index) {
//                                            Image(systemName: "checkmark.circle.fill")
//                                                .foregroundColor(.green)
//                                        } else {
//                                            Image(systemName: "circle")
//                                        }
//                                    }
//                                }
//                                Text("Duration: \(schedule.minutes) min")
//                                    .font(.subheadline)
//                                Text(schedule.date, style: .date)
//                                    .font(.subheadline)
//                                Text(schedule.selectedTime)
//                                    .font(.subheadline)
//
//                                if addedCalories && selectedWorkouts.contains(index) {
//                                    let calories = Int(schedule.workout.calo_burn * Float(schedule.minutes))
//
//                                    Text("Calories: \(calories)")
//                                        .font(.headline)
//                                        .fontWeight(.bold)
//                                        .foregroundColor(.green)
//                                        .modifier(PulseAnimation(shouldAnimate: $isAnimating))
//                                } else {
//                                    Text("Calories will burn: \(Int(schedule.workout.calo_burn * Float(schedule.minutes))) Cals")
//                                }
//                            }
//                            .padding(.vertical, 8)
//                        }
//
//                        if addedCalories {
//                            Text("Total Calories burned: \(totalCalories) Cals")
//                                .font(.headline)
//                                .fontWeight(.bold)
//                                .foregroundColor(.green)
//                                .modifier(PulseAnimation(shouldAnimate: $isAnimating))
//                                .padding(.top)
//                        }
//                    }

// version 2
                    if scheduleExpanded {
                        if modelData.schedules.isEmpty {
                            Text("You have no workout schedules.")
                                .foregroundColor(.secondary)
                        } else {
                            //                        ForEach(Array(modelData.schedules.enumerated()).sorted { (schedule1, schedule2) -> Bool in
                            //                            let formatter = DateFormatter()
                            //                            formatter.dateFormat = "h:mm a"
                            //                            return formatter.date(from: schedule1.element.selectedTime)! < formatter.date(from: schedule2.element.selectedTime)!
                            //                        }, id: \.1.id) { index, schedule in
                            ForEach(Array(modelData.schedules.enumerated()).sorted { (schedule1, schedule2) -> Bool in
                                let formatter = DateFormatter()
                                formatter.dateFormat = "MMM d, yyyy"
                                let date1 = schedule1.element.date
                                let date2 = schedule2.element.date
                                if date1 == date2 {
                                    formatter.dateFormat = "h:mm a"
                                    let time1 = formatter.date(from: schedule1.element.selectedTime)!
                                    let time2 = formatter.date(from: schedule2.element.selectedTime)!
                                    if time1 == time2 {
                                        return schedule1.offset < schedule2.offset // use index for stable sorting
                                    }
                                    return time1 < time2
                                }
                                return date1 < date2
                            }, id: \.1.id) { index, schedule in
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(schedule.workout.name)
                                            .font(.headline)
                                        Spacer()
                                        Button(action: {
                                            if selectedWorkouts.contains(index) {
                                                selectedWorkouts.remove(index)
                                                if selectedWorkouts.isEmpty {
                                                    addedCalories = false
                                                    totalCalories = 0
                                                } else {
                                                    deleteWorkoutFromTotalCalories(workout: schedule.workout, minutes: schedule.minutes)
                                                    totalCalories = getTotalCalories()
                                                }
                                            } else {
                                                selectedWorkouts.insert(index)
                                                addedCalories = true
                                                addWorkoutToTotalCalories(workout: schedule.workout, minutes: schedule.minutes)
                                                totalCalories = getTotalCalories()
                                            }
                                        }) {
                                            if selectedWorkouts.contains(index) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                            } else {
                                                Image(systemName: "circle")
                                            }
                                        }
                                        // need to restart the loop after schedule in schedule list is deleted
                                        if !selectedWorkouts.contains(index) {
                                            Button(action: {
                                                modelData.schedules.remove(at: index)
                                                // Update selectedWorkouts array
                                                selectedWorkouts = selectedWorkouts.filter { $0 != index }
                                                // Delete from schedule list, need return to break from current loop to reiterate the correct idnex, avoid index out of bound
                                                return
                                            }) {
                                                Image(systemName: "trash")
                                                    .foregroundColor(.red)
                                            }
                                        }
                                        
                                        
                                        
                                    }
                                    Text("Duration: \(schedule.minutes) min")
                                        .font(.subheadline)
                                    Text(schedule.date, style: .date)
                                        .font(.subheadline)
                                    Text(schedule.selectedTime)
                                        .font(.subheadline)
                                    
                                    if addedCalories && selectedWorkouts.contains(index) {
                                        let calories = Int(schedule.workout.calo_burn * Float(schedule.minutes))
                                        
                                        Text("Calories: \(calories)")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.green)
                                            .modifier(PulseAnimation(shouldAnimate: $isAnimating))
                                    } else {
                                        Text("Calories will burn: \(Int(schedule.workout.calo_burn * Float(schedule.minutes))) Cals")
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                            
                            if addedCalories {
                                Text("Total Calories burned: \(self.getTotalCalories()) Cals")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                    .modifier(PulseAnimation(shouldAnimate: $isAnimating))
                                    .padding(.top)
                            }
                        }
                    }

//                        //version 3
//                    if modelData.schedules.isEmpty {
//                        Text("You have no workout schedules.")
//                            .foregroundColor(.secondary)
//                    } else {
//                        ForEach(Array(modelData.schedules.enumerated()).sorted { (schedule1, schedule2) -> Bool in
//                            let formatter = DateFormatter()
//                            formatter.dateFormat = "h:mm a"
//                            return formatter.date(from: schedule1.element.selectedTime)! < formatter.date(from: schedule2.element.selectedTime)!
//                        }, id: \.1.id) { index, schedule in
//                            VStack(alignment: .leading) {
//                                HStack {
//                                    Text(schedule.workout.name)
//                                        .font(.headline)
//                                    Spacer()
//                                    Button(action: {
//                                        if selectedWorkouts.contains(index) {
//                                            selectedWorkouts.remove(index)
//                                            if selectedWorkouts.isEmpty {
//                                                addedCalories = false
//                                                totalCalories = 0
//                                            } else {
//                                                deleteWorkoutFromTotalCalories(workout: schedule.workout, minutes: schedule.minutes)
//                                                totalCalories = getTotalCalories()
//                                            }
//                                        } else {
//                                            selectedWorkouts.insert(index)
//                                            addedCalories = true
//                                            addWorkoutToTotalCalories(workout: schedule.workout, minutes: schedule.minutes)
//                                            totalCalories = getTotalCalories()
//                                        }
//                                    }) {
//                                        if selectedWorkouts.contains(index) {
//                                            Image(systemName: "checkmark.circle.fill")
//                                                .foregroundColor(.green)
//                                        } else {
//                                            Image(systemName: "circle")
//                                        }
//                                    }
//                                    // need to restart the loop after schedule in schedule list is deleted
//                                    if !selectedWorkouts.contains(index) {
//                                        Button(action: {
//                                            modelData.schedules.remove(at: index)
//                                            // Update selectedWorkouts array
//                                            selectedWorkouts = selectedWorkouts.filter { $0 != index }
//                                            // Delete from schedule list, need return to break from current loop to reiterate the correct idnex, avoid index out of bound
//                                            return
//                                        }) {
//                                            Image(systemName: "trash")
//                                                .foregroundColor(.red)
//                                        }
//                                    }
//
//
//
//                                }
//                                Text("Duration: \(schedule.minutes) min")
//                                    .font(.subheadline)
//                                Text(schedule.date, style: .date)
//                                    .font(.subheadline)
//                                Text(schedule.selectedTime)
//                                    .font(.subheadline)
//
//                                if addedCalories && selectedWorkouts.contains(index) {
//                                    let calories = Int(schedule.workout.calo_burn * Float(schedule.minutes))
//
//                                    Text("Calories: \(calories)")
//                                        .font(.headline)
//                                        .fontWeight(.bold)
//                                        .foregroundColor(.green)
//                                        .modifier(PulseAnimation(shouldAnimate: $isAnimating))
//                                } else {
//                                    Text("Calories will burn: \(Int(schedule.workout.calo_burn * Float(schedule.minutes))) Cals")
//                                }
//                            }
//                            .padding(.vertical, 8)
//                        }
//
//                        if addedCalories {
//                            Text("Total Calories burned: \(self.getTotalCalories()) Cals")
//                                .font(.headline)
//                                .fontWeight(.bold)
//                                .foregroundColor(.green)
//                                .modifier(PulseAnimation(shouldAnimate: $isAnimating))
//                                .padding(.top)
//                        }
//                    }


                    Divider()
                    HStack {
                        Image(systemName: "fork.knife.circle.fill")
                            .foregroundColor(Color(red: 10/255, green: 186/255, blue: 181/255)) // color tiffany and co I really like
                            .font(.system(size: 30))
                        Text("Dietary")
                            .font(.title)
                            .fontWeight(.bold)
                        Spacer()
                        Button(action: {
                           dietaryExpanded.toggle() // Toggle the @State property when the "Expand" button is tapped
                       }, label: {
                           if dietaryExpanded {
                               Image(systemName: "arrow.down.right.and.arrow.up.left")
                           } else {
                               Image(systemName: "arrow.up.backward.and.arrow.down.forward")
                           }
                       })
                    }

                    if dietaryExpanded{
                        if modelData.meals.isEmpty {
                            Text("You have no dietary schedules.")
                                .foregroundColor(.secondary)
                        } else {
                            
                            ForEach(modelData.all_meals) { meal in
                                VStack(alignment: .leading) {
                                    Text(meal.title)
                                        .font(.headline)
                                    Text("Calories: ")
                                        .font(.subheadline)
                                }
                                .padding(.vertical, 8)
                            }
                        }
                    }


                    Divider()

                    HStack {
                        Image(systemName: "heart.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 30))
                        Text("Health Status")
                            .font(.title)
                            .fontWeight(.bold)
                        Spacer()
                        Button(action: {
                           isExpanded.toggle() // Toggle the @State property when the "Expand" button is tapped
                       }, label: {
                           if isExpanded {
                               Image(systemName: "arrow.down.right.and.arrow.up.left")
                           } else {
                               Image(systemName: "arrow.up.backward.and.arrow.down.forward")
                           }
                       })
                    }
                    if isExpanded { // Use an if statement to conditionally display the additional content when the view is expanded
                    if modelData.healthStatuses.isEmpty {
                        Text("You have no health statuses.")
                            .foregroundColor(.secondary)
                    } else {
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "person.crop.circle.fill")
                                    .foregroundColor(.orange)
                                Text("Personal Information")
                                    .font(.headline)
                            }
                            Text("Sex: \(modelData.personalData.sex ?? "Unknown")")
                                .font(.subheadline)
                            Text("DOB: \(modelData.personalData.dob ?? "Unknown")")
                                .font(.subheadline)
                            Text("Blood Type: \(modelData.personalData.blood ?? "Unknown")")
                                .font(.subheadline)
                            Text("Age: \(modelData.personalData.age ?? 0)")
                                .font(.subheadline)
                        }
                        .padding(.vertical, 8)
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "scalemass.fill")
                                    .foregroundColor(.green)
                                Text("Weight")
                                    .font(.headline)
                            }
                            Text("\(modelData.personalData.weight ?? "Unknown")")
                                .font(.subheadline)
                        }
                        .padding(.vertical, 8)
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "bolt.fill")
                                    .foregroundColor(.green)
                                Text("Height")
                                    .font(.headline)
                            }
                            Text("\(modelData.personalData.height ?? "Unknown")")
                                .font(.subheadline)
                        }
                        .padding(.vertical, 8)
                        
                        ForEach(modelData.healthStatuses) { healthStatus in
                            VStack(alignment: .leading) {
                                HStack {
                                    if (healthStatus.type.rawValue == "sleepTime"){
                                        Image(systemName: "bed.double.circle.fill")
                                            .foregroundColor(.green)
                                        Text(healthStatus.type.rawValue)
                                            .font(.headline)
                                    }
                                    else if(healthStatus.type.rawValue == "steps"){
                                        Image(systemName: "figure.walk.circle.fill")
                                            .foregroundColor(.green)
                                        Text(healthStatus.type.rawValue)
                                            .font(.headline)
                                    }
                                    else if(healthStatus.type.rawValue == "calories"){
                                        Image(systemName: "carrot.fill")
                                            .foregroundColor(.green)
                                        Text(healthStatus.type.rawValue)
                                            .font(.headline)
                                    }
                                    else{
                                        Image(systemName: "heart.fill")
                                            .foregroundColor(.green)
                                        Text(healthStatus.type.rawValue)
                                            .font(.headline)
                                    }
                                    
                                }
                                Text("Value: \(healthStatus.value)")
                                    .font(.subheadline)
                                Text(healthStatus.date, style: .date)
                                    .font(.subheadline)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    }
                }
                    
                .padding(.horizontal)
                .onAppear {
                        modelData.requestAuthorization() // Request authorization to access HealthKit data
                    }
            }
            .navigationTitle("Health")
        }
    }

//struct HealthView: View {
//    @EnvironmentObject var modelData: ModelData
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading) {
//                HStack {
//                    Image(systemName: "heart.circle.fill")
//                        .foregroundColor(.pink)
//                        .font(.system(size: 30))
//                    Text("Health Status")
//                        .font(.title)
//                        .fontWeight(.bold)
//                }
//
//                if modelData.healthStatuses.isEmpty {
//                    Text("You have no health statuses.")
//                        .foregroundColor(.secondary)
//                } else {
//                    VStack(alignment: .leading) {
//                        HStack {
//                            Image(systemName: "person.crop.circle.fill")
//                                .foregroundColor(.purple)
//                            Text("Personal Information")
//                                .font(.headline)
//                        }
//                        Text("Sex: \(modelData.personalData.sex ?? "Unknown")")
//                            .font(.subheadline)
//                        Text("DOB: \(modelData.personalData.dob ?? "Unknown")")
//                            .font(.subheadline)
//                        Text("Blood Type: \(modelData.personalData.blood ?? "Unknown")")
//                            .font(.subheadline)
//                        Text("Age: \(modelData.personalData.age ?? 0)")
//                            .font(.subheadline)
//                    }
//                    .padding(.vertical, 8)
//
//                    VStack(alignment: .leading) {
//                        HStack {
//                            Image(systemName: "scalemass.fill")
//                                .foregroundColor(.green)
//                            Text("Weight")
//                                .font(.headline)
//                        }
//                        Text("\(modelData.personalData.weight ?? "Unknown") lbs")
//                            .font(.subheadline)
//                    }
//                    .padding(.vertical, 8)
//
//                    VStack(alignment: .leading) {
//                        HStack {
//                            Image(systemName: "scaleabel.fill")
//                                .foregroundColor(.green)
//                            Text("Height")
//                                .font(.headline)
//                        }
//                        Text("\(modelData.personalData.height ?? "Unknown") ft")
//                            .font(.subheadline)
//                    }
//                    .padding(.vertical, 8)
//
//                    ForEach(modelData.healthStatuses) { healthStatus in
//                        VStack(alignment: .leading) {
//                            HStack {
//                                Image(systemName: "heart.fill")
//                                    .foregroundColor(.red)
//                                Text(healthStatus.type.rawValue)
//                                    .font(.headline)
//                            }
//                            Text("Value: \(healthStatus.value)")
//                                .font(.subheadline)
//                            Text(healthStatus.date, style: .date)
//                                .font(.subheadline)
//                        }
//                        .padding(.vertical, 8)
//                    }
//                }
//            }
//            .padding(.horizontal)
//            .onAppear {
//                    modelData.requestAuthorization() // Request authorization to access HealthKit data
//                    modelData.retrieveHealthData() // Retrieve sleep time data from HealthKit
//                }
//        }
//        .navigationTitle("Health")
//    }
//}


    // wchich swping but buggy
//    var body: some View {
//        List {
//            VStack(alignment: .leading, spacing: 20) {
//                Text("Daily Workout")
//                    .font(.title)
//                    .fontWeight(.bold)
//
//
//                if modelData.schedules.isEmpty {
//                    Text("You have no workout schedules.")
//                        .foregroundColor(.secondary)
//                } else {
//                    ForEach(Array(modelData.schedules.enumerated()).sorted { (schedule1, schedule2) -> Bool in
//                        let formatter = DateFormatter()
//                        formatter.dateFormat = "h:mm a"
//                        return formatter.date(from: schedule1.element.selectedTime)! < formatter.date(from: schedule2.element.selectedTime)!
//                    }, id: \.1.id) { index, schedule in
//                        VStack(alignment: .leading) {
//                            HStack {
//                                Text(schedule.workout.name)
//                                    .font(.headline)
//                                Spacer()
//                                Button(action: {
//                                    if selectedScheduleIndex == index {
//                                        selectedScheduleIndex = nil
//                                        addedCalories = false
//                                    } else {
//                                        selectedScheduleIndex = index
//                                        addedCalories = true
//                                    }
//                                }) {
//                                    if selectedScheduleIndex == index {
//                                        Image(systemName: "checkmark.circle.fill")
//                                            .foregroundColor(.green)
//                                    } else {
//                                        Image(systemName: "circle")
//                                    }
//                                }
//                            }
//                            Text("Duration: \(schedule.minutes) min")
//                                .font(.subheadline)
//                            Text(schedule.date, style: .date)
//                                .font(.subheadline)
//                            Text(schedule.selectedTime)
//                                .font(.subheadline)
//
//                            if addedCalories && selectedScheduleIndex == index {
//                                let calories = Int(schedule.workout.calo_burn * Float(schedule.minutes))
//
//                                Text("Calories: \(calories)")
//                                    .font(.headline)
//                                    .fontWeight(.bold)
//                                    .foregroundColor(.green)
//                                    .modifier(PulseAnimation(shouldAnimate: $isAnimating))
//                            } else {
//                                Text("Calories will burn: \(Int(schedule.workout.calo_burn * Float(schedule.minutes))) Cals")
//                            }
//                        }
//                        .padding(.vertical, 8)
//                        .swipeActions {
//                            Button {
//                                modelData.schedules.remove(at: index)
//                                if selectedScheduleIndex == index {
//                                    selectedScheduleIndex = nil
//                                    addedCalories = false
//                                }
//                            } label: {
//                                Label("Delete", systemImage: "trash")
//                                    .foregroundColor(.red)
//                            }
//                        }
//                    }
//                    if addedCalories {
//                        Text("Total Calories burned: \(totalCalories) Cals")
//                            .font(.headline)
//                            .fontWeight(.bold)
//                            .foregroundColor(.green)
//                            .modifier(PulseAnimation(shouldAnimate: $isAnimating))
//                            .padding(.top)
//                    }
//                }
//            }
//        }
//        .listStyle(InsetGroupedListStyle())
//    }
//}

struct HealthView_Previews: PreviewProvider {
    static var previews: some View {
        HealthView()
            .environmentObject(ModelData())
    }
}



