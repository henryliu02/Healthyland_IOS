/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view that hosts the profile viewer and editor.
*/


//struct ProfileHost: View {
//    @Environment(\.editMode) var editMode
//    @EnvironmentObject var modelData: ModelData
//    @State private var draftProfile = Profile.default
//
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 20) {
//            HStack {
//                if editMode?.wrappedValue == .active {
//                    Button("Cancel", role: .cancel) {
//                        draftProfile = modelData.profile
//                        editMode?.animation().wrappedValue = .inactive
//                    }
//                }
//                Spacer()
//                EditButton()
//            }
//
//            if editMode?.wrappedValue == .inactive {
//                ProfileSummary(profile: modelData.profile)
//            } else {
//                ProfileEditor(profile: $draftProfile)
//                    .onAppear {
//                        draftProfile = modelData.profile
//                    }
//                    .onDisappear {
//                        modelData.profile = draftProfile
//                    }
//            }
//        }
//        .padding()
//    }
//}
//
//struct ProfileHost_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileHost()
//            .environmentObject(ModelData())
//    }
//}

import SwiftUI
import FirebaseAnalyticsSwift

struct ProfileHost: View {
    @Environment(\.editMode) var editMode
    @EnvironmentObject var modelData: ModelData
    @State private var draftProfile = Profile.default
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    @State var presentingConfirmationDialog = false
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                if editMode?.wrappedValue == .active {
                    Button("Cancel", role: .cancel) {
                        draftProfile = modelData.profile
                        editMode?.animation().wrappedValue = .inactive
                    }
                }
                Spacer()
                EditButton()
            }
            
            if editMode?.wrappedValue == .inactive {
                ProfileSummary(profile: modelData.profile)
            } else {
                ProfileEditor(profile: $draftProfile)
                    .onAppear {
                        draftProfile = modelData.profile
                    }
                    .onDisappear {
                        modelData.profile = draftProfile
                    }
            }
        }
        .padding()
    }
}

struct ProfileHost_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      ProfileHost()
        .environmentObject(AuthenticationViewModel())
        .environmentObject(ModelData())
    }
  }
}
