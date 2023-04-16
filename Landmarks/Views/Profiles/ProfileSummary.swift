/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view that summarizes a profile.
*/

import SwiftUI

struct ProfileSummary: View {
    @EnvironmentObject var modelData: ModelData
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    @State var presentingConfirmationDialog = false
    var profile: Profile

    private func deleteAccount() {
        Task {
            if await viewModel.deleteAccount() == true {
                dismiss()
            }
        }
    }
    
    private func signOut() {
        viewModel.signOut()
    }
    
    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                if viewModel.isSignedInAsGuest{
                    Text("Guest Mode")
                        .bold()
                        .font(.title)
                    
                }else{
                    Text(viewModel.displayName)
                        .bold()
                        .font(.title)
                }
                
                Text("Notifications: \(profile.prefersNotifications ? "On": "Off" )")
                Text("Seasonal Photos: \(profile.seasonalPhoto.rawValue)")
                Text("Goal Date: ") + Text(profile.goalDate, style: .date)
                
                Divider()
                
                VStack(alignment: .leading) {
                    Text("Completed Badges")
                        .font(.headline)
                    
                    ScrollView(.horizontal) {
                        HStack {
                            HikeBadge(name: "First Hike")
                            HikeBadge(name: "Earth Day")
                                .hueRotation(Angle(degrees: 90))
                            HikeBadge(name: "Tenth Hike")
                                .grayscale(0.5)
                                .hueRotation(Angle(degrees: 45))
                        }
                        .padding(.bottom)
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading) {
                    Text("Recent Hikes")
                        .font(.headline)
                    
                    HikeView(hike: modelData.hikes[0])
                }
                .padding(.bottom, 30)
                
                if !viewModel.isSignedInAsGuest{
                    
                    VStack(alignment: .leading) {
                        Section {
                            Button(role: .cancel, action: signOut) {
                                HStack {
                                    Spacer()
                                    Text("Sign out")
                                    Spacer()
                                }
                            }
                        }
                        .padding(.bottom, 20)
                        Section {
                            Button(role: .destructive, action: { presentingConfirmationDialog.toggle() }) {
                                HStack {
                                    Spacer()
                                    Text("Dactivate Account")
                                    Spacer()
                                }
                            }
                        }
                    }
                    .navigationTitle("Profile")
                    .navigationBarTitleDisplayMode(.inline)
                    .analyticsScreen(name: "\(Self.self)")
                    .confirmationDialog("Deactivating your account is permanent. Do you want to proceed?",
                                        isPresented: $presentingConfirmationDialog, titleVisibility: .visible) {
                        Button("Deactivate Account", role: .destructive, action: deleteAccount)
                        Button("Cancel", role: .cancel, action: { })
                    }
                }else{
                    VStack(alignment: .leading) {
                        Section {
                            Button(role: .cancel, action: signOut) {
                                HStack {
                                    Spacer()
                                    Text("Sign in")
                                    Spacer()
                                }
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
            .padding()
        }
    }
}

struct ProfileSummary_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSummary(profile: Profile.default)
            .environmentObject(ModelData())
            .environmentObject(AuthenticationViewModel())
    }
}
