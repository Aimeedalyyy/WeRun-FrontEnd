//
//  logInView.swift
//  WeRun
//
//  Created by Aimee Daly on 15/01/2026.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = loginViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Login")
                .font(.largeTitle)
                .bold()
            
            TextField("Username", text: $viewModel.username)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .autocapitalization(.none)
            
            SecureField("Password", text: $viewModel.password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            if viewModel.isLoading {
                ProgressView()
            }
            
            Button(action: {
                Task {
                    await viewModel.login()
                }
            }) {
                Text("Login")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            
            if let token = viewModel.token {
                Text("Logged in! Token: \(token)")
                    .foregroundColor(.green)
                    .padding()
            }
            
            if let error = viewModel.error {
                Text("Error")
                    .foregroundColor(.red)
                    .padding()
            }
            
            Spacer()
        }
        .padding()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
