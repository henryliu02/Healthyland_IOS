/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view showing the details for a landmark.
*/

import SwiftUI
import MapKit
import EventKit


struct FoodDetail: View {
    @EnvironmentObject var modelData: ModelData
    @State private var showSheet = false
    @State private var minutes = 30 // default minutes value
    @State var dayOfWeek: Int = 1 // default day value
    @State private var selectedTime = 6 // default to 6 am
    let weekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    @State private var showAlert = false
    @State private var image: Image = Image(systemName: "photo")
    
    // Variables
    @State private var caloriesPerServing: Int = 0
    @State private var numberOfServings: Int = 1
    @State private var mealType: Int = 1
    


    
    func getDayOfWeekString(day: Int) -> String {
        return weekdays[day-1]
    }
    
    func getTimeString(forTime time: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let hour = time % 12 == 0 ? 12 : time % 12
        let period = time > 12 ? "PM" : "AM"
        let timeString = String(format: "%d:%02d %@", hour, 0, period)
        return timeString
    }
    
    var food: Meal
    
        var foodIndex: Int {
            modelData.all_meals.firstIndex(where: { $0.id == food.id })!
        }
    
    var body: some View {
        ScrollView {
            MapView()
                .ignoresSafeArea(edges: .top)
                .frame(height: 300)
            
            CircleImage(image: image)
                .offset(y: -130)
                .padding(.bottom, -130)
            
            VStack(alignment: .leading) {
                HStack {
                    Text(food.title)
                        .font(.title)
                        .bold()
                    FavoriteButton(isSet: $modelData.all_meals[foodIndex].isFavorite)
                }
                
                HStack {
                    Text(food.restaurantChain ?? "Restraunt Unaviable")
                    Spacer()
                    //                    Text(food.category.rawValue)
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                
                Divider()
                
                Text("About")
                    .font(.title2)
                Text(food.description ?? "No description")
            }
            .padding()
            
            Button(action: {
                showSheet.toggle()
            }) {
                Text("Add to Schedule")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.top, 20)
            }
        }
        .navigationTitle(food.title)
        .onAppear {
            loadImage()
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSheet) {
            NavigationView {
                VStack {
                    Form {
                        
                        // New form sections
                        Section(header: Text("Calories per serving")) {
                            TextField("Calories per serving", value: $caloriesPerServing, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                        }
                        
                        Section(header: Text("Number of servings")) {
                            Picker(selection: $numberOfServings, label: Text("Servings")) {
                                ForEach(1..<100) { i in
                                    Text("\(i)").tag(i)
                                }
                            }
                        }
                        
                        Section(header: Text("Meal type")) {
                            Picker(selection: $mealType, label: Text("Type")) {
                                Text("Breakfast").tag(1)
                                Text("Lunch").tag(2)
                                Text("Dinner").tag(3)
                            }
                        }
                        
                        
                        // text entry for time
                        HStack {
                            Text("Time")
                            Spacer(minLength: 130)
                            Picker(selection: $selectedTime, label: Text("Time")) {
                                ForEach(1..<25) { i in
                                    Text(self.getTimeString(forTime: i)).tag(i)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(width: 120, height: 130)
                        }
                    }
                    
                    // Updated save button action
                    Button(action: {
                        // Check if there is already a scheduled meal at the selected time
                        let existingEvent = modelData.mealSchedule.first(where: {
                            $0.selectedTime == self.getTimeString(forTime: selectedTime)
                        })
                        
                        if existingEvent != nil {
                            showAlert = true
                        } else {
                            // Create new meal element to be added to the list later
                            let currentDate = Date()
                            
                            let newFoodSchedule = FoodSchedule(food: food, calories: Double(caloriesPerServing) * Double(numberOfServings), servings: numberOfServings, date: currentDate, selectedTime: self.getTimeString(forTime: selectedTime), isSelected: false)
                            modelData.mealSchedule.append(newFoodSchedule) // add to the food schedule list to display in health view
                            showSheet.toggle()
                        }
                    }) {
                        Text("Save")
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Cannot Add Same Meal"), message: Text("The selected meal is already scheduled at this time."), dismissButton: .default(Text("OK")))
                    }
                }
                .navigationTitle("Add to Schedule")
            }
        }
    }

    func loadImage() {
        guard let urlString = food.image, let url = URL(string: urlString) else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                // Resize the image to a specific size
                let newSize = CGSize(width: 200, height: 200) // set the size you want
                UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
                image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
                let newImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()

                DispatchQueue.main.async {
                    self.image = Image(uiImage: newImage!)
                }
            }
        }
        task.resume()
    }

}


struct Previews_FoodDetail_Previews: PreviewProvider {
    static var landmarks = ModelData().all_meals
    
    static var previews: some View {
        FoodDetail(food: landmarks[49])
            .environmentObject(ModelData())
    }
}




