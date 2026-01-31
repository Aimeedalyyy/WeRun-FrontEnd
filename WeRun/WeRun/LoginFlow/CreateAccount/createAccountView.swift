//
//  RegisterView.swift
//  WeRun
//
//  Created by Aimee Daly on 15/01/2026.
//


import SwiftUI

struct CreateAccountView: View {
  @StateObject private var viewModel = createAccountViewModel()

  
  var body: some View {
      VStack(spacing: 20) {
        TextField("Username", text: $viewModel.username)
          .textFieldStyle(.roundedBorder)
          .autocapitalization(.none)
        
        SecureField("Password", text: $viewModel.password)
          .textFieldStyle(.roundedBorder)
        
        Button(action: {
          print("Button press")
          Task {
            await viewModel.createAccount()
          }
        }) {
          Text("Create Account")
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
      }
      
      
      // Error message
      if let error = viewModel.error {
        Text(error.localizedDescription)
          .foregroundColor(.red)
          .multilineTextAlignment(.center)
          .padding()
      }
      
      Spacer()
    .padding()
    .navigationTitle("Register")
  }
}

#Preview {
  CreateAccountView()
}
