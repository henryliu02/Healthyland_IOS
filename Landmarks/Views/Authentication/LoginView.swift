//
//  LoginView.swift
//  Healthyland
//
//  Created by Henry Liu on 4/17/23.
//  Copyright © 2023 Apple. All rights reserved.
//


import SwiftUI
import AuthenticationServices
import FirebaseAnalyticsSwift
import FirebaseCore


//class AppDelegate: NSObject, UIApplicationDelegate {
//  func application(_ application: UIApplication,
//                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//    FirebaseApp.configure()
//    return true
//  }
//}
//
//@main
//struct LandmarksApp: App {
////    // register app delegate for Firebase setup
////    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
//    @StateObject var authenticationViewModel = AuthenticationViewModel()
//
//    @StateObject private var modelData = ModelData()
//    @State var isLoggedIn = false
//
//    var body: some Scene {
//        WindowGroup {
//            if isLoggedIn {
//                ContentView()
//                    .environmentObject(modelData)
//            } else {
////                LoginView(isLoggedIn: $isLoggedIn)
//                LoginView()
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .background(Color.white)
//                    .ignoresSafeArea()
//                    .environmentObject(authenticationViewModel)
//            }
//        }
//    }
//}


struct LoginView: View {
    @StateObject private var modelData = ModelData()
    @EnvironmentObject var viewModel: AuthenticationViewModel
    
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
                
                SignInWithAppleButton(.signIn){
                request in
                    viewModel.handleSignInWithAppleRequest(request)
                }
                onCompletion: { result in
                    viewModel.handleSignInWithAppleCompletion(result)
                }
                .signInWithAppleButtonStyle(.white)
                .frame(width: 200, height: 50)
                .padding()
                .background(Color.white)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                .scaleEffect(1.0)
                .animation(nil) // disable animation for SignInWithAppleButton

                Button(action: {
                    viewModel.signInAsGuest()
                }) {
                    Text("Continue as Guest")
                        .font(.headline)
                        .foregroundColor(.black)
                }
                .padding(.bottom, 20)
                .animation(nil) // disable animation for guest button
            }
            
            // Moving food symbols
            GeometryReader { geo in
                ForEach(foodSymbols, id: \.self) { symbolName in
                    Image(systemName: symbolName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.white)
                        .frame(width:20, height: 10)
                        .onAppear{
                            symbolOffsets = [symbolName:geo.size]
                        }
                        .offset(symbolOffsets[symbolName, default: randomOffset(in: geo.size)])
                        .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
                            // Update offset with animation
                            withAnimation(Animation.easeInOut(duration: 5).repeatForever(autoreverses: false)) {
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
    @State var symbolOffsets: [String: CGSize] = [:]
    
    
    // Helper functions to calculate the random offset for each symbol
    private func calculateXOffset(from width: CGFloat) -> CGFloat {
            let minOffset = -width / 15
            let maxOffset = width * 15
            return CGFloat.random(in: minOffset...maxOffset)
        }
        
        private func calculateYOffset(from height: CGFloat) -> CGFloat {
            let minOffset = -height / 30
            let maxOffset = height * 30
            return CGFloat.random(in: minOffset...maxOffset)
        }
    
    private func randomOffset(in size: CGSize) -> CGSize {
        let x = CGFloat.random(in:  -1...size.width)
        let y = CGFloat.random(in:  -1...size.height)
           return CGSize(width: x, height: y)
       }
}



struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
//        LoginView(isLoggedIn: .constant(false))
            LoginView()
            .environmentObject(AuthenticationViewModel())
            .environmentObject(ModelData())
    }
}

