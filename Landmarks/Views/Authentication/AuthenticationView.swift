//
//  AuthenticationView.swift
//  Healthyland
//
//  Created by Henry Liu on 4/16/23.
//  Copyright © 2023 Apple. All rights reserved.
//

//
// AuthenticationView.swift
// Favourites

import SwiftUI
import Combine

struct AuthenticationView: View {
  @EnvironmentObject var viewModel: AuthenticationViewModel
    @StateObject private var modelData = ModelData()

  var body: some View {
    VStack {
      switch viewModel.flow {
      case .login:
        LoginView()
          .environmentObject(viewModel)
          .environmentObject(ModelData())
      case .signUp:
        SignupView()
          .environmentObject(viewModel)
      }
    }
  }
}

struct AuthenticationView_Previews: PreviewProvider {
  static var previews: some View {
    AuthenticationView()
      .environmentObject(AuthenticationViewModel())
      .environmentObject(ModelData())
  }
}
