/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The top-level definition of the Landmarks app.
*/
//

//import SwiftUI
//
//@main
//struct LandmarksApp: App {
//    @StateObject private var modelData = ModelData()
//
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//                .environmentObject(modelData)
//        }
//    }
//}
//

import SwiftUI
import AuthenticationServices
import FirebaseCore


//class AppDelegate: NSObject, UIApplicationDelegate {
//  func application(_ application: UIApplication,
//                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//    FirebaseApp.configure()
//    return true
//  }
//}

@main
struct LandmarksApp: App {
    // register app delegate for Firebase setup
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject private var modelData = ModelData()
    @State var isLoggedIn = false
    
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
//                MealListView()
                ContentView()
                    .environmentObject(modelData)
            } else {
                LoginView(isLoggedIn: $isLoggedIn)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                    .ignoresSafeArea()
            }
        }
    }
}

//struct LoginView: View {
//    @Binding var isLoggedIn: Bool
//
//    var body: some View {
//        VStack {
//            Text("Welcome to Healthy Land")
//                .font(.largeTitle)
//                .bold()
//                .padding()
//            SignInWithAppleButton(
//                onRequest: { request in
//                    request.requestedScopes = [.fullName, .email]
//                },
//                onCompletion: { result in
//                    switch result {
//                    case .success(let authResults):
//                        guard let credential = authResults.credential as? ASAuthorizationAppleIDCredential else {
//                            return
//                        }
//                        // Handle successful login here...
//                        print("Successfully authenticated with Apple ID")
//                        isLoggedIn = true
//                    case .failure(let error):
//                        // Handle error here...
//                        print("Error: \(error.localizedDescription)")
//                    }
//                }
//            )
//            .signInWithAppleButtonStyle(.black)
//            .frame(width: 200, height: 44)
//            .padding()
//        }
//    }
//}

//struct LoginView: View {
//    @Binding var isLoggedIn: Bool
//
//    var body: some View {
//        ZStack {
//            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.green]), startPoint: .top, endPoint: .bottom)
//                .edgesIgnoringSafeArea(.all)
//
//            VStack(spacing: 30) {
//                Text("Welcome to Healthy Land")
//                    .font(.system(size: 32, weight: .bold, design: .rounded))
//                    .foregroundColor(.white)
//                    .multilineTextAlignment(.center)
//                    .padding(.top, 80)
//
//                Spacer()
//
//                SignInWithAppleButton(
//                    onRequest: { request in
//                        request.requestedScopes = [.fullName, .email]
//                    },
//                    onCompletion: { result in
//                        switch result {
//                        case .success(let authResults):
//                            guard let credential = authResults.credential as? ASAuthorizationAppleIDCredential else {
//                                return
//                            }
//                            // Handle successful login here...
//                            print("Successfully authenticated with Apple ID")
//                            isLoggedIn = true
//                        case .failure(let error):
//                            // Handle error here...
//                            print("Error: \(error.localizedDescription)")
//                        }
//                    }
//                )
//                .signInWithAppleButtonStyle(.white)
//                .frame(width: 200, height: 44)
//                .padding()
//                .background(Color.white)
//                .clipShape(Capsule())
//                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
//                .scaleEffect(1.0)
//                .animation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.2))
//
//                Spacer()
//            }
//        }
//    }
//}

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    
    let foodSymbols = ["takeoutbag.and.cup.and.straw.fill", "figure.basketball", "figure.outdoor.cycle", "figure.strengthtraining.traditional","soccerball","figure.yoga","figure.soccer","sportscourt.circle", "carrot", "volleyball.fill","carrot.fill","bolt.heart.fill","list.clipboard.fill","bed.double.circle.fill","cup.and.saucer.fill","takeoutbag.and.cup.and.straw","fork.knife","sun.min","moon.circle.fill","figure.american.football","figure.archery","figure.australian.football","figure.barre","figure.baseball","figure.boxing","figure.bowling"]

    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.green]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            

            VStack(spacing: 30) {
                Text("Welcome!\nYour healthyland\n")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 100)
                
                Spacer()
                
                SignInWithAppleButton(
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        switch result {
                        case .success(let authResults):
                            guard authResults.credential is ASAuthorizationAppleIDCredential else {
                                return
                            }
                            // Handle successful login here...
                            print("Successfully authenticated with Apple ID")
                            isLoggedIn = true
                        case .failure(let error):
                            // Handle error here...
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                )
                .signInWithAppleButtonStyle(.white)
                .frame(width: 200, height: 50)
                .padding()
                .background(Color.white)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                .scaleEffect(1.0)
                .animation(nil) // disable animation for SignInWithAppleButton
//                Spacer()
//                Text("OR")
//                    .foregroundColor(.white)
                Button(action: {
                    isLoggedIn = true
                }) {
                    Text("Continue as Guest")
                        .font(.headline)
                        .foregroundColor(.black)
                }
                .padding(.bottom, 20)
//                .frame(width: 200, height: 50)
//                .background(Color.white)
//                .clipShape(Capsule())
//                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
//                .scaleEffect(1.0)
                
            }
            
            // Moving food symbols
            GeometryReader { geo in
                ForEach(foodSymbols, id: \.self) { symbolName in
                    Image(systemName: symbolName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.white)
                        .frame(width: 20, height: 40)
                        .offset(symbolOffsets[symbolName, default: randomOffset(in: geo.size)])
//                        .onAppear() {
//                            // Set initial offset
////                            symbolOffsets[symbolName] = randomOffset(in: geo.size)
////                            symbolOffsets[symbolName] = CGSize(width: calculateXOffset(from: geo.size.width), height: calculateYOffset(from: geo.size.height))
//                        }
                        .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
                            // Update offset with animation
                            withAnimation(Animation.linear(duration: 20).repeatForever(autoreverses: true)) {
                                symbolOffsets[symbolName]?.width = calculateXOffset(from: geo.size.width)
                                symbolOffsets[symbolName]?.height = calculateYOffset(from: geo.size.height)
                            }
                        }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // Dictionary to store the offset of each symbol
    @State private var symbolOffsets: [String: CGSize] = [:]
    
    // Helper functions to calculate the random offset for each symbol
    private func calculateXOffset(from width: CGFloat) -> CGFloat {
            let minOffset = -width / 2
            let maxOffset = width / 2
            return CGFloat.random(in: minOffset...maxOffset)
        }
        
        private func calculateYOffset(from height: CGFloat) -> CGFloat {
            let minOffset = -height / 2
            let maxOffset = height / 2
            return CGFloat.random(in: minOffset...maxOffset)
        }
    
    private func randomOffset(in size: CGSize) -> CGSize {
           let x = CGFloat.random(in: 0...size.width)
           let y = CGFloat.random(in: 0...size.height)
           return CGSize(width: x, height: y)
       }
}



struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(isLoggedIn: .constant(false))
    }
}
