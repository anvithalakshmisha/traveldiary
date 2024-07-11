//
//  TravelDiaryApp.swift
//  TravelDiary
//
//  Created by Bhavesh Raja on 11/04/24.
//

import SwiftUI

@main
struct TravelDiaryApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject var userAuth = UserAuth(context: PersistenceController.shared.container.viewContext)  // Added UserAuth as a StateObject
    @Environment(\.scenePhase) var scenePhase
    
    init() {
        ValueTransformer.setValueTransformer(ImageTransformer(), forName: NSValueTransformerName("ImageTransformer"))
        // Register your custom value transformer here

    }
    
    var body: some Scene {
        WindowGroup {
            // Use UserAuth.isLoggedIn to control the flow
            if userAuth.isLoggedIn {
                MainView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(userAuth)  // Ensure that UserAuth is available in the environment
            } else {
                SplashScreenView()  // Assume you want the login view if not logged in
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(userAuth)
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background {
                print("App is moving to the background. Attempting to save context.")
                persistenceController.saveContext()
            }
        }
    }
}
