//
//  SettingsView.swift
//  CineScope
//

import SwiftUI

public struct SettingsView: View {
    @State private var viewModel: SettingsViewModel
    @State private var showKeySetup: Bool = false

    public init(userMovieRepository: UserMovieRepositoryProtocol) {
        _viewModel = State(initialValue: SettingsViewModel(userMovieRepository: userMovieRepository))
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                CineColors.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: CineSpacing.xl) {
                        // API Configuration Card
                        apiConfigSection

                        // Cache and Storage Management
                        storageSection

                        // TMDB Legal Attribution
                        TMDBAttributionCard()

                        // About CineScope
                        aboutSection

                        Spacer(minLength: CineSpacing.xxl)
                    }
                    .padding(CineSpacing.l)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showKeySetup) {
                APIKeySetupSheet {
                    viewModel.refreshState()
                }
            }
            .alert("Clear All Saved Movie Data?", isPresented: $viewModel.showClearDataAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete All", role: .destructive) {
                    viewModel.clearAllUserData()
                }
            } message: {
                Text("This will permanently remove all movies from your Watchlist, Favorites, Watched history, and your personal reviews.")
            }
            .onAppear {
                viewModel.refreshState()
            }
        }
    }

    // MARK: - Subviews

    private var apiConfigSection: some View {
        VStack(alignment: .leading, spacing: CineSpacing.m) {
            Text("API Integration")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(CineColors.textPrimary)

            VStack(spacing: CineSpacing.m) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("TMDB API Connection")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(CineColors.textPrimary)
                        Text(viewModel.hasCredentials ? "Active API key configured" : "API credentials required")
                            .font(.system(size: 12))
                            .foregroundStyle(CineColors.textSecondary)
                    }

                    Spacer()

                    HStack(spacing: 5) {
                        Circle()
                            .fill(viewModel.hasCredentials ? CineColors.emerald : CineColors.gold)
                            .frame(width: 8, height: 8)
                        Text(viewModel.hasCredentials ? "Connected" : "Not Set")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(viewModel.hasCredentials ? CineColors.emerald : CineColors.gold)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill((viewModel.hasCredentials ? CineColors.emerald : CineColors.gold).opacity(0.12))
                    )
                }

                HStack(spacing: CineSpacing.m) {
                    Button {
                        showKeySetup = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "key.fill")
                                .font(.system(size: 12))
                            Text(viewModel.hasCredentials ? "Update Key" : "Configure Key")
                                .font(.system(size: 13, weight: .bold))
                        }
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(CineColors.crimson)
                        .clipShape(RoundedRectangle(cornerRadius: CineRadius.s))
                    }

                    if viewModel.hasCredentials {
                        Button {
                            viewModel.removeCredentials()
                        } label: {
                            Text("Remove")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.red)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(CineColors.backgroundSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: CineRadius.s))
                                .overlay(RoundedRectangle(cornerRadius: CineRadius.s).stroke(Color.red.opacity(0.4), lineWidth: 1))
                        }
                    }
                }
            }
            .padding(CineSpacing.l)
            .background(
                RoundedRectangle(cornerRadius: CineRadius.l)
                    .fill(CineColors.backgroundElevated)
                    .overlay(RoundedRectangle(cornerRadius: CineRadius.l).stroke(CineColors.surfaceBorder, lineWidth: 1))
            )
        }
    }

    private var storageSection: some View {
        VStack(alignment: .leading, spacing: CineSpacing.m) {
            Text("Storage & Cache")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(CineColors.textPrimary)

            VStack(spacing: CineSpacing.m) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Cached Posters & Responses")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(CineColors.textPrimary)
                        Text("Disk cache for offline browsing")
                            .font(.system(size: 12))
                            .foregroundStyle(CineColors.textSecondary)
                    }

                    Spacer()

                    Text(viewModel.cacheSize)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(CineColors.textSecondary)
                }

                Button {
                    viewModel.clearImageCache()
                } label: {
                    HStack {
                        Spacer()
                        if viewModel.cacheClearedFeedback {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                            Text("Cache Cleared!")
                                .font(.system(size: 13, weight: .bold))
                        } else {
                            Text("Clear Cached Media")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        Spacer()
                    }
                    .foregroundStyle(viewModel.cacheClearedFeedback ? CineColors.emerald : CineColors.textPrimary)
                    .padding(.vertical, 10)
                    .background(CineColors.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: CineRadius.s))
                    .overlay(RoundedRectangle(cornerRadius: CineRadius.s).stroke(CineColors.surfaceBorder, lineWidth: 1))
                }

                Divider()
                    .background(CineColors.surfaceBorder)

                Button {
                    viewModel.showClearDataAlert = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                            .font(.system(size: 13))
                        Text("Reset All Saved Movie Collections")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(Color.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
            }
            .padding(CineSpacing.l)
            .background(
                RoundedRectangle(cornerRadius: CineRadius.l)
                    .fill(CineColors.backgroundElevated)
                    .overlay(RoundedRectangle(cornerRadius: CineRadius.l).stroke(CineColors.surfaceBorder, lineWidth: 1))
            )
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: CineSpacing.m) {
            Text("About CineScope")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(CineColors.textPrimary)

            VStack(alignment: .leading, spacing: CineSpacing.s) {
                infoRow(label: "Application", value: "CineScope")
                infoRow(label: "Version", value: "1.0.0")
                infoRow(label: "Platform", value: "Native iOS (SwiftUI & SwiftData)")
                infoRow(label: "Architecture", value: "MVVM with Swift Concurrency")
            }
            .padding(CineSpacing.l)
            .background(
                RoundedRectangle(cornerRadius: CineRadius.l)
                    .fill(CineColors.backgroundElevated)
                    .overlay(RoundedRectangle(cornerRadius: CineRadius.l).stroke(CineColors.surfaceBorder, lineWidth: 1))
            )
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(CineColors.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(CineColors.textPrimary)
        }
    }
}
