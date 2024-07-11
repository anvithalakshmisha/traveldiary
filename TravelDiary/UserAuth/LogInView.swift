//
//  LogInView.swift
//  TravelDiary
//
//  Created by Bhavesh Raja on 11/04/24.
//

import SwiftUI

struct LogInView: View {
    @EnvironmentObject var userAuth: UserAuth
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var alertMessage: String = ""
    @State private var showingAlert = false

    var body: some View {
        VStack {
            Text("WELCOME BACK TO TRAVEL DIARY!")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center) // Centers the multiline Text
                .padding(.bottom, 30)

            TextField("Username", text: $username)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .padding(.bottom, 15)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.bottom, 20)
            
            Button(action: login) {
                Text("Log In")
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity) // Ensures the button label is centered within the available width
            }
            .padding()
            .background(Color(hue: 0.709, saturation: 1.0, brightness: 1.0))
            .cornerRadius(10)
        }
        .padding()
        .frame(maxWidth: .infinity) // Use this to center the VStack in its container
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Login Failed"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func login() {
        userAuth.login(username: username, password: password) { success, message in
            if !success {
                self.alertMessage = message
                self.showingAlert = true
            }
        }
    }
}

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView().environmentObject(UserAuth(context: PersistenceController.preview.container.viewContext))
    }
}
