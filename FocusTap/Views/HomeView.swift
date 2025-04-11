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

  // MARK: - Alert Type
  private enum AlertType: Identifiable {
    case wrongTag
    case notFocusTag
    case createTag
    case tagCreationResult(success: Bool)

    var id: Int {
      switch self {
      case .wrongTag: return 0
      case .notFocusTag: return 1
      case .createTag: return 2
      case .tagCreationResult: return 3
      }
    }
  }

  // MARK: - Computed Properties
  private var isBlocking: Bool {
    get {
      return appBlocker.isBlocking
    }
  }

  // MARK: - View Body
  var body: some View {
    NavigationView {
      GeometryReader { geometry in
        mainContent(geometry: geometry)
      }
      .navigationBarItems(trailing: createTagButton)
      .alert(item: $alertType, content: alertContent)
    }
    .animation(.spring(), value: isBlocking)
    .onOpenURL { url in
      print(url.absoluteString)
      handleBlockingTag(payload: url.absoluteString, currentProfile: profileManager.currentProfile)
    }
  }

  // MARK: - Main Layout Views
  private func mainContent(geometry: GeometryProxy) -> some View {
    ZStack {
      VStack(spacing: 0) {
        blockOrUnblockButton(geometry: geometry)

        if !isBlocking {
          Divider()
          profilesList(geometry: geometry)
        }
      }
      .background(backgroundColor)
    }
  }

  private func profilesList(geometry: GeometryProxy) -> some View {
    ProfilesPickerView(profileManager: profileManager)
      .frame(height: geometry.size.height / 2)
      .transition(.move(edge: .bottom))
  }

  // MARK: - UI Components
  private func blockOrUnblockButton(geometry: GeometryProxy) -> some View {
    VStack(spacing: 8) {
      Text(isBlocking ? "Tap to unblock" : "Tap to block")
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
        title: Text(verbatim: .alerts(.wrongTagTitle)),
        message: Text(verbatim: .alerts(.wrongTagMessage)),
        dismissButton: .default(Text(verbatim: .common(.ok)))
      )
    case .notFocusTag:
      return Alert(
        title: Text(verbatim: .alerts(.notFocusTagTitle)),
        message: Text(verbatim: .alerts(.notFocusTagMessage)),
        dismissButton: .default(Text(verbatim: .common(.ok)))
      )
    case .createTag:
      return Alert(
        title: Text(verbatim: .alerts(.createTagTitle)),
        message: Text(verbatim: .alerts(.createTagMessage)),
        primaryButton: .default(Text(verbatim: .common(.create))) { createFocusTag() },
        secondaryButton: .cancel(Text(verbatim: .common(.cancel)))
      )
    case .tagCreationResult(let success):
      return Alert(
        title: Text(verbatim: .alerts(.tagCreationTitle)),
        message: Text(verbatim: success ?
          .alerts(.tagCreationSuccess) :
            .alerts(.tagCreationFailure)
        ),
        dismissButton: .default(Text(verbatim: .common(.ok)))
      )
    }
  }

  // MARK: - NFC Tag Handling
  private func scanTag() {
    nfcReader.scan { payload in
      let currentProfile = profileManager.currentProfile

      if isBlocking {
        handleUnblockingTag(payload: payload, currentProfile: currentProfile)
      } else {
        handleBlockingTag(payload: payload, currentProfile: currentProfile)
      }
    }
  }

  private func handleUnblockingTag(payload: String, currentProfile: Profile) {
    if currentProfile.requireMatchingTag {
      if payload == currentProfile.tagPhrase {
        NSLog(.logs(.matchingTag))
        appBlocker.toggleBlocking(for: currentProfile)
      } else if String(payload.prefix(11)) == "focusTap://" {
        alertType = .wrongTag
        NSLog(.logs(.wrongTag), payload)
      } else {
        alertType = .notFocusTag
        NSLog(.logs(.nonBrokeTag), payload)
      }
    } else {
      NSLog(.logs(.noMatchRequired))
      appBlocker.toggleBlocking(for: currentProfile)
    }
  }

  private func handleBlockingTag(payload: String, currentProfile: Profile) {
    if let matchingProfile = profileManager.profiles.first(where: { $0.tagPhrase == payload }) {
      profileManager.setCurrentProfile(id: matchingProfile.id)
      NSLog(.logs(.switchingProfile), matchingProfile.name)
      appBlocker.toggleBlocking(for: matchingProfile)
    } else {
      alertType = .notFocusTag
    }
  }

  private func createFocusTag() {
    nfcReader.write(profileManager.currentProfile.tagPhrase) { success in
      alertType = .tagCreationResult(success: success)
    }
  }
}
