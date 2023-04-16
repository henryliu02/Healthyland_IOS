/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view showing featured landmarks above a list of landmarks grouped by category.
*/


import SwiftUI

struct FoodHome: View {
    @EnvironmentObject var modelData: ModelData
    @State private var showingProfile = false

    var body: some View {
        NavigationView {
            List {
                FoodItem(food: modelData.all_meals[88])
//                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
                    .listRowInsets(EdgeInsets())

                ForEach(modelData.meal_categories.keys.sorted(), id: \.self) { key in
                    FoodRow(categoryName: key, items: modelData.meal_categories[key]!)
                }
                .listRowInsets(EdgeInsets())
            }
            .listStyle(.inset)
            .navigationTitle("Featured")
            .toolbar {
                Button {
                    showingProfile.toggle()
                } label: {
                    Label("User Profile", systemImage: "person.crop.circle")
                }
            }
            .sheet(isPresented: $showingProfile) {
                ProfileHost()
                    .environmentObject(modelData)
            }
        }
    }
}


struct FoodHome_Previews: PreviewProvider {
    static var previews: some View {
        FoodHome()
            .environmentObject(ModelData())
    }
}

