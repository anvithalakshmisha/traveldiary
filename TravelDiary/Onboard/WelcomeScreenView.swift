//
//  WelcomeScreen.swift
//  TravelDiary
//
//  Created by Bhavesh Raja on 11/04/24.
//

import SwiftUI

struct WelcomeScreenView: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Image("welcome")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                //.frame(width: 300, height: 400)
                    .cornerRadius(8)
                    .padding()
                
                
                Text("Discover and capture your travel experiences at one place")
                    .font(.title2)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
                
                NavigationLink(destination: LogInView()) {
                    Text("Login")
                        .fontWeight(.semibold)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color(hue: 0.709, saturation: 1.0, brightness: 1.0))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                NavigationLink(destination: SignUpView()) {
                    Text("Sign Up")
                        .fontWeight(.semibold)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke((Color(hue: 0.709, saturation: 1.0, brightness: 1.0)), lineWidth: 2)
                        )
                        .foregroundColor(Color(hue: 0.709, saturation: 1.0, brightness: 1.0))
                        .padding(.horizontal)
                }
            }
        }
    }
}


#Preview {
    WelcomeScreenView()
}
