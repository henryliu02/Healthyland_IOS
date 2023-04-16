//
//  HealthylandApp.swift
//  Healthyland
//
//  Created by Henry Liu on 4/16/23.
//  Copyright © 2023 Apple. All rights reserved.

//  The top-level definition of the Landmarks app.
//


import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct HealthylandApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  @StateObject private var modelData = ModelData()
  var body: some Scene {
    WindowGroup {
      NavigationView {
        AuthenticatedView {
        } content: {
          ContentView()
                .environmentObject(modelData)
//          Spacer()
        }
      }
    }
  }
}
