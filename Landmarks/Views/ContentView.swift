/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view showing featured landmarks above a list of all of the landmarks.
*/

import SwiftUI

struct ContentView: View {
    @State private var selection: Tab = .featured
    

    enum Tab {
        case featured
        case health
        case food
        case list

    }

    var body: some View {
        TabView(selection: $selection) {
            CategoryHome()
                .tabItem {
                    Label("Workout", systemImage: "star")
                }
                .tag(Tab.featured)
            
            FoodHome()
                .tabItem {
                    Label("Food", systemImage: "leaf.fill")
                }
                .tag(Tab.food)
            
            HealthView()
                .tabItem {
                    Image(systemName: "heart.circle.fill")
                    Text("Health")
                }
                .tag(Tab.health)

            LandmarkList()
                .tabItem {
                    Label("Collect", systemImage: "list.bullet")
                }
                .tag(Tab.list)
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ModelData())
    }
}
