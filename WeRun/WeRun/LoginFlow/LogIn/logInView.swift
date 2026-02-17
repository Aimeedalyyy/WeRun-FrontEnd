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
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {

                // MARK: Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("Welcome back")
                        .font(.title.bold())
                        .foregroundColor(.accentPurple)

                    Text("Log in to continue tracking your performance.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // MARK: Fields
                VStack(spacing: 16) {
                    TextField("Username", text: $viewModel.username)
                        .padding()
                        .background(Color.backgroundGrey.opacity(0.2))
                        .cornerRadius(12)
                        .autocapitalization(.none)

                    SecureField("Password", text: $viewModel.password)
                        .padding()
                        .background(Color.backgroundGrey.opacity(0.2))
                        .cornerRadius(12)
                }

                // MARK: Loading
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                }


                // MARK: Error
                if let error = viewModel.error {
                    Text(error.localizedDescription)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }

                Spacer(minLength: 20)
            }
            .padding(24)
        }
        .navigationTitle("Log In")
    }
}



struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
