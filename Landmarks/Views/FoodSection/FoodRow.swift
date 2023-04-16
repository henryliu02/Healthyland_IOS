/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view showing a scrollable list of landmarks.
*/

import SwiftUI

struct FoodRow: View {
    var categoryName: String
    var items: [Meal]

    var body: some View {
        VStack(alignment: .leading) {
            Text(categoryName)
                .font(.headline)
                .padding(.leading, 15)
                .padding(.top, 5)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 0) {
                    ForEach(items) { landmark in
                        NavigationLink {
                            FoodDetail(food: landmark)
                        } label: {
                            FoodItem(food: landmark)
                        }
                    }
                }
            }
            .frame(height: 185)
        }
    }
}

struct FoodRow_Previews: PreviewProvider {
    static var landmarks = ModelData().all_meals

    static var previews: some View {
        FoodRow(
            categoryName: "Breakfast",
            items: Array(landmarks.prefix(100))
        )
    }
}
