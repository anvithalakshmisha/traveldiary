//
//  ContentView.swift
//  TravelDiary
//
//  Created by Bhavesh Raja on 12/04/24.
//

import SwiftUI

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userAuth: UserAuth
    
    var body: some View {
        // Check if the user is logged in
        if userAuth.isLoggedIn {
            MainView()
        } else {
            SplashScreenView()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

