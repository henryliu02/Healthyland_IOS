/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view showing the details for a landmark.
*/

import SwiftUI
import MapKit
import EventKit


struct LandmarkDetail: View {
    @EnvironmentObject var modelData: ModelData
    @State private var showSheet = false
    @State private var minutes = 30 // default minutes value
    @State var dayOfWeek: Int = 1 // default day value
    @State private var selectedTime = 6 // default to 6 am
    let weekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    @State private var showAlert = false
    
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
    
    var landmark: Workout

    var landmarkIndex: Int {
        modelData.landmarks.firstIndex(where: { $0.id == landmark.id })!
    }

    var body: some View {
        ScrollView {
            MapView()
                .ignoresSafeArea(edges: .top)
                .frame(height: 300)
            
            CircleImage(image: landmark.image)
                .offset(y: -130)
                .padding(.bottom, -130)

            VStack(alignment: .leading) {
                HStack {
                    Text(landmark.name)
                        .font(.title)
                        .bold()
                    FavoriteButton(isSet: $modelData.landmarks[landmarkIndex].isFavorite)
                }

                HStack {
                    Text(landmark.calo_burn < 0 ? "Steady Calories burn" : String(landmark.calo_burn) + " Calories burn/min")
                    Spacer()
                    Text(landmark.category.rawValue)
                }
                .font(.subheadline)
                .foregroundColor(.secondary)

                Divider()

                Text("About \(landmark.name)")
                    .font(.title2)
                Text(landmark.description)
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
        .navigationTitle(landmark.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSheet) {
            // option 1: text entry for workout detail
//            NavigationView {
//                VStack {
//                    Form {
//                        Section(header: Text("Workout Details")) {
//                            TextField("Minutes", value: $minutes, formatter: NumberFormatter())
//                                .keyboardType(.numberPad)
//                        }
//                    }
//                    Button(action: {
//                        let newSchedule = Schedule(workout: landmark, minutes: minutes)
//                        modelData.schedules.append(newSchedule)
//                        showSheet.toggle()
//                    }) {
//                        Text("Save")
//                    }
//                }
//                .navigationTitle("Add to Schedule")
//            }
            
            //option 2: scorlling effect for workout detail
            NavigationView {
                VStack {
                    Form {
                        
                        Section(header: Text("Workout Details")) {
                            Picker(selection: $minutes, label: Text("Minutes")) {
                                ForEach(1..<1000) { i in
                                    Text("\(i) minutes").tag(i)
                                }
                            }
                            // text entry for date
                            Picker(selection: $dayOfWeek, label: Text("Day")) {
                                ForEach(1..<8) { i in
                                    Text(self.getDayOfWeekString(day: i)).tag(i)
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
                    }
                    
                    // save button in add to schedule button
                    Button(action: {
                        // Check if there is already a scheduled event at the selected time
                            let existingEvent = modelData.schedules.first(where: {
                                $0.selectedTime == self.getTimeString(forTime: selectedTime)
//                              &&  $0.dayOfWeek == dayOfWeek
                            })
                        if existingEvent != nil {
                            // Display an alert if there is already an event at the selected time
                            showAlert = true
                        } else {
                            
                            let eventStore = EKEventStore()
                            let newEvent = EKEvent(eventStore: eventStore)
                            newEvent.title = landmark.name
                            // Create a Date object representing the current date
                            let now = Date()
                            
                            // Get the current calendar
                            let calendar = Calendar.current
                            
                            // Get the hour and minute components of the selected time
                            let hour = selectedTime
                            let minute = 0
                            
                            // Create a DateComponents object for the selected time
                            var components = DateComponents()
                            components.year = calendar.component(.year, from: now)
                            components.month = calendar.component(.month, from: now)
                            components.day = calendar.component(.day, from: now)
                            components.hour = hour
                            components.minute = minute
                            
                            // Create a Date object for the selected time
                            let selectedDate = calendar.date(from: components)
                            
                            // Check if the selected time is in the past
                            if selectedDate?.compare(now) == .orderedAscending {
                                // Add one day to the date components
                                components.day = (components.day ?? 0) + 1
                                
                                // Create a Date object for the selected time on the next day
                                let nextDayDate = calendar.date(from: components)
                                
                                // Set the start date of the event to the selected date on the next day
                                newEvent.startDate = nextDayDate
                            } else {
                                // Set the start date of the event to the selected date on the current day
                                newEvent.startDate = selectedDate
                                
                            }
                            
                            newEvent.endDate = newEvent.startDate.addingTimeInterval(Double(minutes * 60))
                            newEvent.notes = landmark.description
                            newEvent.calendar = eventStore.defaultCalendarForNewEvents
                            
                            eventStore.requestAccess(to: .event) { granted, error in
                                if granted, error == nil {
                                    // save event to calendar app
                                    do {
                                        try eventStore.save(newEvent, span: .thisEvent)
                                        showSheet.toggle()
                                    } catch {
                                        print("Error saving event: \(error.localizedDescription)")
                                    }
                                } else {
                                    print("Access to calendar denied")
                                }
                            }
                            // create new schedule element to be added to list later
                            let newSchedule = Schedule(workout: landmark, minutes: minutes,date: newEvent.startDate ,selectedTime: self.getTimeString(forTime: selectedTime), isSelected:false)
                            modelData.schedules.append(newSchedule) // add to the schedule list to display in health view
                            
                    }
                    }) {
                        Text("Save")
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Cannot Add Same Sport"), message: Text("The selected sport is already scheduled at this time."), dismissButton: .default(Text("OK")))
                    }
                }
                .navigationTitle("Add to Schedule")
            }
        }
    }
}


struct Previews_LandmarkDetail_Previews: PreviewProvider {
    static var landmarks = ModelData().landmarks
    
    static var previews: some View {
        LandmarkDetail(landmark: landmarks[0])
            .environmentObject(ModelData())
    }
}




