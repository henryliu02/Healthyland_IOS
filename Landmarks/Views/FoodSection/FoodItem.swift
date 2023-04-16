/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view showing a single category item.
*/

import SwiftUI

struct FoodItem: View {
    var food: Meal
    @EnvironmentObject var modelData: ModelData
    @State private var image: Image = Image(systemName: "takeoutbag.and.cup.and.straw")

    var body: some View {
        VStack(alignment: .leading) {
            image
                .renderingMode(.original)
                .resizable()
                .frame(width: 155, height: 155)
                .cornerRadius(5)
            
            let strippedTitle = food.title
                .replacingOccurrences(of: "breakfast", with: "")
                .replacingOccurrences(of: "Breakfast", with: "")
                .replacingOccurrences(of: "dinner", with: "")
                .replacingOccurrences(of: "Dinner", with: "")
                .replacingOccurrences(of: "lunch", with: "")
                .replacingOccurrences(of: "Lunch", with: "")

            Text(String(strippedTitle.prefix(25)))
                .foregroundColor(.primary)
                .font(.system(size: 12))
                .lineLimit(1)

  
        }
        .padding(.leading, 15)
        .onAppear {
            loadImage()
        }
    }

    func loadImage() {
        guard let urlString = food.image, let url = URL(string: urlString) else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = Image(uiImage: image)
                }
            }
        }
        task.resume()
    }
}

struct FoodItem_Previews: PreviewProvider {
    static var previews: some View {
        FoodItem(food: ModelData().all_meals[0])
            .environmentObject(ModelData())
    }
}
