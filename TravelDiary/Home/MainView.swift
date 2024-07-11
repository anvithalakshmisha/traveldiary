//
//  MainView.swift
//  TravelDiary
//
//  Created by Bhavesh Raja on 12/04/24.
//

import SwiftUI

struct MainView: View {
    @State private var selectedTab = "home"
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag("home")
            
            TripsView()
                .tabItem {
                    Label("Trips", systemImage: "airplane")
                }
                .tag("trips")
            
            GalleryView()
                .tabItem {
                    Label("Gallery", systemImage: "photo.on.rectangle")
                }
                .tag("gallery")
            
            MapView()
                .tabItem {
                    Label("Maps", systemImage: "map")
                }
                .tag("maps")
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag("profile")
        }
    }
}

#Preview {
    MainView()
}
