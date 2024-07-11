//
//  ProfileView.swift
//  TravelDiary
//
//  Created by Anvitha Lakshmisha on 4/23/24.
//

import SwiftUI
import CoreData

struct ProfileView: View {
    @EnvironmentObject var userAuth: UserAuth
    @State private var showLogoutConfirmation = false
    @State private var showResetPassword = false
    @State private var stats = UserStats(trips: 0, moments: 0, photos: 0, totalMiles: 0.0)
    @State private var showingEditProfile = false // State to control the presentation of the EditProfileView
    
    var profileImage: UIImage? {
        if let imageData = userAuth.currentUser?.profileImageData {
            return UIImage(data: imageData)
        }
        return nil
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let user = userAuth.currentUser {
                        ProfileHeaderView(
                            fullName: user.fullname ?? "",
                            username: user.username ?? "",
                            email: user.email ?? "",
                            profileImage: profileImage ?? UIImage(systemName: "person.crop.circle.fill") // Use the computed property here
                        )
                        
                        // Stats section
                        StatsScrollView(stats: stats)
                        
                        // User details list
                        DetailsSectionView(user: user)
                        
                        Button("Reset password") {
                            showResetPassword = true
                        }
                        .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                        // Logout button
                        Button("Logout") {
                            showLogoutConfirmation = true
                        }
                        .foregroundColor(.red)
                    } else {
                        Text("No user logged in")
                    }
                }
                .padding()
                .sheet(isPresented: $showResetPassword) {
                    ResetPasswordView()
                }

                .alert(isPresented: $showLogoutConfirmation) {
                    Alert(
                        title: Text("Confirm Logout"),
                        message: Text("Are you sure you want to log out?"),
                        primaryButton: .destructive(Text("Logout")) {
                            userAuth.logout()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                // Edit button in the navigation bar
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.showingEditProfile = true
                    }) {
                        Image(systemName: "pencil")
                    }
                }
            }
            .sheet(isPresented: $showingEditProfile, onDismiss: {
                // Refresh the current user
                
                // Optionally refresh user stats if they could have changed
                userAuth.fetchUserStats { fetchedStats in
                    self.stats = fetchedStats
                }
            }) {
                if let user = userAuth.currentUser {
                    EditProfileView(user: user)
                }
            }
        }
        .onAppear {
            userAuth.fetchUserStats { fetchedStats in
                self.stats = fetchedStats
            }
        }
    }
}


// ProfileHeaderView with added image parameter
struct ProfileHeaderView: View {
    var fullName: String
    var username: String
    var email: String
    var profileImage: UIImage?
    
    var body: some View {
        VStack {
            // Safely unwrap the optional profileImage
            if let image = profileImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .shadow(radius: 10)
                    .overlay(Circle().stroke(Color.white, lineWidth: 3))
            } else {
                // Provide a default image if profileImage is nil
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .shadow(radius: 10)
                    .overlay(Circle().stroke(Color.white, lineWidth: 3))
            }
            
            Text(fullName)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(email)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top)
    }
}


// A list section for more detailed user information
struct DetailsSectionView: View {
    var user: User
    
    var body: some View {
        Section(header: Text("Profile Information")) {
            VStack(alignment: .leading, spacing: 10) {
                DetailRow(label: "Username", detail: user.username ?? "")
                DetailRow(label: "Email", detail: user.email ?? "")
                // Include other details as needed
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
        }
    }
}

struct DetailRow: View {
    var label: String
    var detail: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
            Spacer()
            Text(detail)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

struct StatsScrollView: View {
    var stats: UserStats
    var formattedTotalMiles: String {
        String(format: "%.2f", stats.totalMiles)
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                StatView(label: "Trips", value: "\(stats.trips)")
                StatView(label: "Moments", value: "\(stats.moments)")
                StatView(label: "Photos", value: "\(stats.photos)")
                StatView(label: "Total miles", value: formattedTotalMiles)
            }
            .padding()
        }
    }
}

struct StatView: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(Color.accentColor) // Using a custom accent color
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2) // Soft shadow
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView().environmentObject(UserAuth(context: PersistenceController.preview.container.viewContext))
    }
}
