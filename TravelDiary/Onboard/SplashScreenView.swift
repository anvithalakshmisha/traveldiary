//
//  SplashScreenView.swift
//  TravelDiary
//
//  Created by Bhavesh Raja on 11/04/24.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            WelcomeScreenView() // Your login view goes here
        } else {
            ZStack {
                Color(hue: 0.709, saturation: 1.0, brightness: 1.0)
                    .ignoresSafeArea()
                VStack {
                    Image("TravelLogoWhite")//
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.white)
                        .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                        .frame(width: 140, height: 140)
                    Text("Travel Diary")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                }
            }
            .ignoresSafeArea()
            .background(Color(hue: 0.709, saturation: 1.0, brightness: 1.0))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}


#Preview {
    SplashScreenView()
}
