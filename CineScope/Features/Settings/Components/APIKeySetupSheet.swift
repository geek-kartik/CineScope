//
//  APIKeySetupSheet.swift
//  CineScope
//

import SwiftUI

public struct APIKeySetupSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var inputKey: String = ""
    @State private var isValidating: Bool = false
    @State private var validationSuccess: Bool = false
    @State private var errorMessage: String? = nil

    public var onSaved: (() -> Void)? = nil

    public init(onSaved: (() -> Void)? = nil) {
        self.onSaved = onSaved
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: CineSpacing.xl) {
                    // Header card
                    VStack(alignment: .leading, spacing: CineSpacing.s) {
                        HStack(spacing: CineSpacing.m) {
                            ZStack {
                                RoundedRectangle(cornerRadius: CineRadius.m)
                                    .fill(CineColors.crimson.opacity(0.15))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "key.fill")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(CineColors.crimson)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("TMDB API Key Required")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(CineColors.textPrimary)
                                Text("Power CineScope with live movie data")
                                    .font(.system(size: 13))
                                    .foregroundStyle(CineColors.textSecondary)
                            }
                        }

                        Text("CineScope uses The Movie Database (TMDB) API to deliver real-time trending movies, high-definition backdrops, cast credits, and trailers.")
                            .font(.system(size: 14))
                            .foregroundStyle(CineColors.textSecondary)
                            .padding(.top, CineSpacing.xs)
                    }
                    .padding(CineSpacing.l)
                    .background(
                        RoundedRectangle(cornerRadius: CineRadius.l)
                            .fill(CineColors.backgroundElevated)
                            .overlay(
                                RoundedRectangle(cornerRadius: CineRadius.l)
                                    .stroke(CineColors.surfaceBorder, lineWidth: 1)
                            )
                    )

                    // Input section
                    VStack(alignment: .leading, spacing: CineSpacing.m) {
                        Text("Enter API Key or Access Token")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(CineColors.textPrimary)

                        HStack {
                            Image(systemName: "lock.shield.fill")
                                .foregroundStyle(CineColors.textTertiary)

                            TextField("Paste TMDB API Key or Bearer Token", text: $inputKey)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .foregroundStyle(CineColors.textPrimary)

                            if !inputKey.isEmpty {
                                Button {
                                    inputKey = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(CineColors.textTertiary)
                                }
                            }
                        }
                        .padding(CineSpacing.m)
                        .background(
                            RoundedRectangle(cornerRadius: CineRadius.m)
                                .fill(CineColors.backgroundSecondary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: CineRadius.m)
                                        .stroke(errorMessage != nil ? Color.red : CineColors.surfaceBorder, lineWidth: 1)
                                )
                        )

                        if let errorMessage = errorMessage {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.red)
                                Text(errorMessage)
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.red)
                            }
                        }

                        if validationSuccess {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(CineColors.emerald)
                                Text("Credentials validated successfully!")
                                    .font(.system(size: 13))
                                    .foregroundStyle(CineColors.emerald)
                            }
                        }

                        Button {
                            Task {
                                await testAndSave()
                            }
                        } label: {
                            HStack {
                                Spacer()
                                if isValidating {
                                    ProgressView()
                                        .tint(Color.white)
                                } else {
                                    Text("Verify & Save Key")
                                        .font(.system(size: 15, weight: .bold))
                                }
                                Spacer()
                            }
                            .padding(.vertical, 14)
                            .foregroundStyle(Color.white)
                            .background(CineColors.crimsonGradient)
                            .clipShape(RoundedRectangle(cornerRadius: CineRadius.m))
                        }
                        .disabled(inputKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isValidating)
                        .opacity(inputKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
                    }

                    // How to get key instructions
                    VStack(alignment: .leading, spacing: CineSpacing.m) {
                        Text("How to get a free TMDB API key:")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(CineColors.textPrimary)

                        VStack(alignment: .leading, spacing: CineSpacing.s) {
                            stepRow(number: "1", text: "Create a free account at themoviedb.org")
                            stepRow(number: "2", text: "Go to Account Settings → API")
                            stepRow(number: "3", text: "Request an API Key (Developer option is free)")
                            stepRow(number: "4", text: "Copy your API Key (v3 auth) or Read Access Token (v4 auth)")
                        }
                    }
                    .padding(CineSpacing.l)
                    .background(
                        RoundedRectangle(cornerRadius: CineRadius.l)
                            .fill(CineColors.backgroundSecondary.opacity(0.6))
                    )
                }
                .padding(CineSpacing.l)
            }
            .background(CineColors.backgroundPrimary.ignoresSafeArea())
            .navigationTitle("API Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(CineColors.crimson)
                }
            }
        }
        .onAppear {
            if let current = APIConfig.shared.apiKeyOrToken {
                inputKey = current
            }
        }
    }

    private func stepRow(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: CineSpacing.m) {
            ZStack {
                Circle()
                    .fill(CineColors.backgroundElevated)
                    .frame(width: 24, height: 24)
                Text(number)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(CineColors.crimson)
            }
            Text(text)
                .font(.system(size: 14))
                .foregroundStyle(CineColors.textSecondary)
        }
    }

    private func testAndSave() async {
        let trimmed = inputKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        isValidating = true
        errorMessage = nil
        validationSuccess = false

        // Temporarily set
        APIConfig.shared.setCredential(trimmed)

        do {
            let isValid = try await URLSessionAPIClient.shared.validateCredentials()
            isValidating = false
            if isValid {
                validationSuccess = true
                onSaved?()
                try? await Task.sleep(nanoseconds: 700_000_000)
                dismiss()
            } else {
                errorMessage = "Invalid credentials. Please verify your TMDB key or token."
            }
        } catch {
            isValidating = false
            errorMessage = error.localizedDescription
        }
    }
}
