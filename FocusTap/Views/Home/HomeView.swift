//
//  BrockerView.swift
//  Broke
//
//  Created by Oz Tamir on 22/08/2024.
//

import SwiftUI
import CoreNFC
import SFSymbolsPicker
import FamilyControls
import ManagedSettings

struct HomeView: View {
  // MARK: - Environment
  @EnvironmentObject private var appBlocker: AppBlocker
  @EnvironmentObject private var profileManager: ProfileManager

  // MARK: - State
  @StateObject private var nfcReader = NFCReader()
  @State private var alertType: AlertType?
  @State private var showAboutPage: Bool = false
  @State private var showWhatsNewPage: Bool = false


  // MARK: - Alert Type
  private enum AlertType: Identifiable {
    case wrongTag
    case notFocusTag
    case createTag

    var id: Int {
      switch self {
      case .wrongTag: return 0
      case .notFocusTag: return 1
      case .createTag: return 2
      }
    }
  }

  // MARK: - Computed Properties
  private var isBlocking: Bool { appBlocker.isBlocking }

  // MARK: - View Body
  var body: some View {
    NavigationView {
      GeometryReader { geometry in
        mainContent(geometry: geometry)
      }
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          aboutButton
        }

        if !isBlocking {
          ToolbarItem(placement: .topBarTrailing) {
            createTagButton
          }
        }
      }
      .alert(item: $alertType, content: alertContent)
    }
    .animation(.spring(), value: isBlocking)
    .onOpenURL { url in
      switch isBlocking {
      case true:
        handleUnblockingTag(payload: url.absoluteString, currentProfile: profileManager.currentProfile)
      case false:
        handleBlockingTag(payload: url.absoluteString, currentProfile: profileManager.currentProfile)
      }
    }
    .sheet(isPresented: $showAboutPage) { AboutView() }
    .sheet(isPresented: $showWhatsNewPage) { WhatsNewView() }
  }

  // MARK: - Main Layout Views
  private func mainContent(geometry: GeometryProxy) -> some View {
    ZStack {
      VStack(spacing: 0) {
        ProfileCardCarousel(profiles: profileManager.profiles,
                            isBlocking: appBlocker.isBlocking,
                            activeSessionProfileId: nil,
                            elapsedTime: 60) {
          print("Tapped")
        }
      }
    }
    .onAppear {
      let currentAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
      let previousAppVersion = UserDefaults.standard.string(forKey: "appVersion") ?? "NAN"

      if currentAppVersion != previousAppVersion {
        UserDefaults.standard.set(currentAppVersion, forKey: "appVersion")
        showWhatsNewPage = true
      } else {
        showWhatsNewPage = false
      }
    }
  }

  private func profilesList(geometry: GeometryProxy) -> some View {
//    ProfilesPickerView(profileManager: profileManager)
//      .frame(height: geometry.size.height / 2)
//      .offset(y: isBlocking ? UIScreen.main.bounds.height : 0)
//      .animation(.easeOut(duration: 1), value: isBlocking)
    Text("Hello World")
  }

  // MARK: - UI Components
  private func blockOrUnblockButton(geometry: GeometryProxy) -> some View {
    VStack(spacing: 8) {
      Text(isBlocking ? HomeStrings.tapToUnblock : HomeStrings.tapToBlock)
        .font(.caption)
        .opacity(0.75)
        .transition(.scale)

      Button(action: {
        withAnimation(.spring()) {
          scanTag()
        }
      }) {
        Image(isBlocking ? "RedIcon" : "GreenIcon")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(height: geometry.size.height / 3)
      }
      .transition(.scale)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .frame(height: isBlocking ? geometry.size.height : geometry.size.height / 2)
    .animation(.spring(), value: isBlocking)
  }

  private var aboutButton: some View {
    Button(action: {
      showAboutPage.toggle()
    }) {
      Image(systemName: "questionmark.circle.fill")
    }
  }

  private var createTagButton: some View {
    Button(action: {
      alertType = .createTag
    }) {
      Image(systemName: "plus")
    }
    .disabled(!NFCNDEFReaderSession.readingAvailable)
  }

  private var backgroundColor: Color {
    isBlocking ? Color("BlockingBackground") : Color("NonBlockingBackground")
  }

  // MARK: - Alert Handling
  private func alertContent(for type: AlertType) -> Alert {
    switch type {
    case .wrongTag:
      return Alert(
        title: Text(.wrongTag(.title)),
        message: Text(.wrongTag(.message)),
        dismissButton: .default(Text(.ok))
      )
    case .notFocusTag:
      return Alert(
        title: Text(.notFocusTag(.title)),
        message: Text(.notFocusTag(.message)),
        dismissButton: .default(Text(.ok))
      )
    case .createTag:
      return Alert(
        title: Text(.createTag(.title)),
        message: Text(.createTag(.message)),
        primaryButton: .default(Text(.create)) { createFocusTag() },
        secondaryButton: .cancel(Text(.cancel))
      )
    }
  }

  // MARK: - NFC Tag Handling
  private func scanTag() {
//    if !isBlocking &&
//       !profileManager.currentProfile.requireTagToBlock {
//      handleBlockingTag(payload: "", currentProfile: profileManager.currentProfile)
//      return
//    }
//
//    nfcReader.scan { payload in
//      let currentProfile = profileManager.currentProfile
//
//      if isBlocking {
//        handleUnblockingTag(payload: payload, currentProfile: currentProfile)
//      } else {
//        handleBlockingTag(payload: payload, currentProfile: currentProfile)
//      }
//    }
  }

  private func handleUnblockingTag(payload: String, currentProfile: Profile) {
//    if currentProfile.requireMatchingTag {
//      if payload == currentProfile.tagPhrase {
//        NSLog(.logs(.matchingTag))
//        appBlocker.toggleBlocking(for: currentProfile)
//      } else if String(payload.prefix(11)) == "focusTap://" {
//        alertType = .wrongTag
//        NSLog(.logs(.wrongTag), payload)
//      } else {
//        alertType = .notFocusTag
//        NSLog(.logs(.nonBrokeTag), payload)
//      }
//    } else {
//      NSLog(.logs(.noMatchRequired))
//      appBlocker.toggleBlocking(for: currentProfile)
//    }
  }

  private func handleBlockingTag(payload: String, currentProfile: Profile) {
//    if let matchingProfile = profileManager.profiles.first(where: { $0.tagPhrase == payload }) {
//      profileManager.setCurrentProfile(id: matchingProfile.id)
//      NSLog(.logs(.switchingProfile), matchingProfile.name)
//      appBlocker.toggleBlocking(for: matchingProfile)
//    } else if !currentProfile.requireTagToBlock {
//      appBlocker.toggleBlocking(for: currentProfile)
//    } else {
//      alertType = .notFocusTag
//    }
  }

  private func createFocusTag() {
//    nfcReader.write(profileManager.currentProfile.tagPhrase)
  }
}
