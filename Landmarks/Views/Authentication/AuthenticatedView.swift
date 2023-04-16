//
//  AuthenticatedView.swift
//  Healthyland
//
//  Created by Henry Liu on 4/16/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import SwiftUI
import AuthenticationServices

// see https://michael-ginn.medium.com/creating-optional-viewbuilder-parameters-in-swiftui-views-a0d4e3e1a0ae
extension AuthenticatedView where Unauthenticated == EmptyView {
  init(@ViewBuilder content: @escaping () -> Content) {
    self.unauthenticated = nil
    self.content = content
  }
}

struct AuthenticatedView<Content, Unauthenticated>: View where Content: View, Unauthenticated: View {
  @StateObject private var viewModel = AuthenticationViewModel()
  @State private var presentingLoginScreen = false
  @State private var presentingProfileScreen = false
  @StateObject private var modelData = ModelData()

  var unauthenticated: Unauthenticated?
  @ViewBuilder var content: () -> Content

  public init(unauthenticated: Unauthenticated?, @ViewBuilder content: @escaping () -> Content) {
    self.unauthenticated = unauthenticated
    self.content = content
  }

  public init(@ViewBuilder unauthenticated: @escaping () -> Unauthenticated, @ViewBuilder content: @escaping () -> Content) {
    self.unauthenticated = unauthenticated()
    self.content = content
  }


  var body: some View {
      if viewModel.isSignedInAsGuest{
          ContentView()
              .environmentObject(viewModel)
              .environmentObject(modelData)
      }else{
          switch viewModel.authenticationState {
          case .unauthenticated, .authenticating:
              AuthenticationView()
                  .environmentObject(viewModel)
          case .authenticated:
              content()
              
                  .onReceive(NotificationCenter.default.publisher(for: ASAuthorizationAppleIDProvider.credentialRevokedNotification)) { event in
                      viewModel.signOut()
                      if let userInfo = event.userInfo, let info = userInfo["info"] {
                          print(info)
                      }
                  }
                  .sheet(isPresented: $presentingProfileScreen) {
                      ProfileHost()
                          .environmentObject(modelData)
                          .environmentObject(viewModel)
                  }
              //      .sheet(isPresented: $presentingProfileScreen) {
              //        NavigationView {
              //          UserProfileView()
              //            .environmentObject(viewModel)
              //        }
              //      }
          }
      }
  }
}

struct AuthenticatedView_Previews: PreviewProvider {
  static var previews: some View {
    AuthenticatedView {
      Text("You're signed in.")
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(.yellow)
    }
  }
}
