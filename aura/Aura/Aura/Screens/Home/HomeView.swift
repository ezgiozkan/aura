//
//  HomeView.swift
//  Aura
//
//  Created by Ezgi Özkan on 8.01.2026.
//

import SwiftUI
import PhotosUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var manager = RevenueCatManager.shared
    @State private var isLanguageSheetPresented = false
    @State private var isSettingsSheetPresented = false
    @State private var shouldOpenLanguageAfterSettingsDismiss = false
    @State private var languageSearchText = ""
    @State private var showPaywall = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.homeGradient
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Image("iconAura")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 90)
                        .padding(.top, -10)

                    Spacer()

                    VStack(spacing: 0) {
                        Image("iconHome")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 1000)
                            .offset(y: -40)

                        VStack(spacing: 8) {
                            Text("For accurate analysis, you can upload screenshots directly from WhatsApp, Instagram DMs, Telegram, iMessage, and more.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .offset(y: -70)
                                .padding(.horizontal, 32)

                            Button {
                                if manager.isSubscribed {
                                } else {
                                    showPaywall = true
                                }
                            } label: {
                                ZStack(alignment: .topTrailing) {
                                    PrimaryButton(
                                        titleKey: "Upload Message Screenshot",
                                        background: .darkPurple,
                                        foreground: .white
                                    ) {}
                                    .allowsHitTesting(false)
                                    
                                    if !manager.isSubscribed {
                                        HStack(spacing: 4) {
                                            Image(systemName: "lock.fill")
                                                .font(.system(size: 10, weight: .semibold))
                                            Text("Aura Pro")
                                                .font(.system(size: 11, weight: .bold))
                                        }
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(
                                            Capsule()
                                                .fill(Color.black.opacity(0.6))
                                        )
                                        .offset(x: -10, y: -8)
                                    }
                                }
                            }
                            .overlay {
                                if manager.isSubscribed {
                                    PhotosPicker(
                                        selection: $viewModel.messagePhotoItem,
                                        matching: .images
                                    ) {
                                        Color.clear
                                    }
                                }
                            }
                            .onChange(of: viewModel.messagePhotoItem) { _, newItem in
                                Task {
                                    await viewModel.loadMessageImage(from: newItem)
                                }
                            }
                            .padding(.horizontal, 54)
                            .offset(y: 40)
                            Button {
                                if manager.isSubscribed {
                                } else {
                                    showPaywall = true
                                }
                            } label: {
                                ZStack(alignment: .topTrailing) {
                                    PrimaryButton(
                                        titleKey: "Upload Instagram Story",
                                        background: .white,
                                        foreground: .darkPurple
                                    ) {}
                                    .allowsHitTesting(false)
                                    
                                    if !manager.isSubscribed {
                                        HStack(spacing: 4) {
                                            Image(systemName: "lock.fill")
                                                .font(.system(size: 10, weight: .semibold))
                                            Text("Aura Pro")
                                                .font(.system(size: 11, weight: .bold))
                                        }
                                        .foregroundStyle(.darkPurple)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(
                                            Capsule()
                                                .fill(Color.darkPurple.opacity(0.15))
                                        )
                                        .offset(x: -10, y: -8)
                                    }
                                }
                            }
                            .overlay {
                                if manager.isSubscribed {
                                    PhotosPicker(
                                        selection: $viewModel.storyPhotoItem,
                                        matching: .images
                                    ) {
                                        Color.clear
                                    }
                                }
                            }
                            .onChange(of: viewModel.storyPhotoItem) { _, newItem in
                                Task {
                                    await viewModel.loadStoryImage(from: newItem)
                                }
                            }
                            .padding(.horizontal, 54)
                            .offset(y: 40)
                        }
                    }

                    Spacer()
                    Spacer()
                }
                VStack {
                    HStack {
                        Spacer()

                        Button {
                            isSettingsSheetPresented = true
                        } label: {
                            Image(systemName: "line.3.horizontal")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(.darkPurple)
                                .frame(width: 40, height: 40)
                        }
                        .buttonStyle(.plain)
                        .padding(.trailing, 16)
                        .padding(.top, 14)
                    }
                    Spacer()
                }
            }
            .onAppear {
                languageManager.syncWithDeviceIfNeeded()
            }
            .fullScreenCover(isPresented: $showPaywall) {
                PaywallView()
            }
            .fullScreenCover(item: $viewModel.selectedStoryImage) { identifiableImage in
                GenerateRizzView(selectedImage: identifiableImage.image)
            }
            .fullScreenCover(item: $viewModel.selectedMessageImage) { identifiableImage in
                GenerateChatReplyView(selectedImage: identifiableImage.image)
            }
            .sheet(isPresented: $isSettingsSheetPresented, onDismiss: {
                if shouldOpenLanguageAfterSettingsDismiss {
                    shouldOpenLanguageAfterSettingsDismiss = false
                    isLanguageSheetPresented = true
                }
            }) {
                SettingsSheetView(
                    isPresented: $isSettingsSheetPresented,
                    shouldOpenLanguageAfterDismiss: $shouldOpenLanguageAfterSettingsDismiss,
                    languageName: languageManager.effectiveLanguageName,
                    languageFlag: languageManager.flagEmoji(for: languageManager.effectiveLanguageCode)
                )
            }
            .sheet(isPresented: $isLanguageSheetPresented) {
                NavigationStack {
                    List {
                        Section {
                            HStack {
                                Text("Automatic")
                                    .foregroundStyle(.primary)
                                Spacer()
                                if !languageManager.userSelected {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.primary)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                languageManager.setAutomatic()
                                isLanguageSheetPresented = false
                            }
                            ForEach(languageManager.filteredLanguages(query: languageSearchText)) { lang in
                                HStack {
                                    Text(lang.name)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    if lang.code == languageManager.effectiveLanguageCode {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.primary)
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    languageManager.setLanguage(code: lang.code)
                                    isLanguageSheetPresented = false
                                }
                            }
                        }
                    }
                    .navigationTitle("Language")
                    .navigationBarTitleDisplayMode(.inline)
                    .searchable(text: $languageSearchText, placement: .navigationBarDrawer(displayMode: .always))
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") {
                                isLanguageSheetPresented = false
                            }
                        }
                    }
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
    }
}

#Preview {
    HomeView()
}
