//
//  ResetPassword.swift
//  TravelDiary
//
//  Created by Anvitha Lakshmisha on 4/26/24.
//

import SwiftUI
import CoreData

struct ResetPasswordView: View {
    @EnvironmentObject private var userAuth: UserAuth
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var oldPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    
    var body: some View {
        VStack {
            Text("PASSWORD RESET")
                .font(.title2)
                .fontWeight(.bold)
            SecureField("Old Password", text: $oldPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("New Password", text: $newPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Update Password") {
                updatePassword()
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10)
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func updatePassword() {
        guard !oldPassword.isEmpty else {
            showAlert(title: "Error", message: "Please enter your old password.")
            return
        }
        
        guard !newPassword.isEmpty else {
            showAlert(title: "Error", message: "Please enter a new password.")
            return
        }
        
        guard newPassword == confirmPassword else {
            showAlert(title: "Error", message: "New password and confirm password do not match.")
            return
        }
        
        guard let currentUser = userAuth.currentUser else {
            showAlert(title: "Error", message: "No user logged in.")
            return
        }
        
        guard validateOldPassword() else {
            showAlert(title: "Error", message: "Incorrect old password.")
            return
        }
        
        // Update password in CoreData
        currentUser.password = newPassword
        
        do {
            try viewContext.save()
            alertTitle = "Success"
            alertMessage = "Password updated successfully."
            showAlert = true
        } catch {
            showAlert(title: "Error", message: "Failed to update password.")
        }
    }
    
    private func validateOldPassword() -> Bool {
        guard let currentUser = userAuth.currentUser else {
            return false
        }
        
        return currentUser.password == oldPassword
    }
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}



struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView().environmentObject(UserAuth(context: PersistenceController.preview.container.viewContext))
    }
}
