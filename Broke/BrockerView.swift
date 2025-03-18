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

struct BrokerView: View {
  @EnvironmentObject private var appBlocker: AppBlocker
  @EnvironmentObject private var profileManager: ProfileManager
  @StateObject private var nfcReader = NFCReader()

  @State private var alertType: AlertType?

  private enum AlertType: Identifiable {
    case wrongTag
    case notBrokerTag
    case createTag
    case tagCreationResult(success: Bool)

    var id: Int {
      switch self {
      case .wrongTag: return 0
      case .notBrokerTag: return 1
      case .createTag: return 2
      case .tagCreationResult: return 3
      }
    }
  }

  private var isBlocking : Bool {
    get {
      return appBlocker.isBlocking
    }
  }

  var body: some View {
    NavigationView {
      GeometryReader { geometry in
        ZStack {
          VStack(spacing: 0) {
            blockOrUnblockButton(geometry: geometry)

            if !isBlocking {
              Divider()

              ProfilesPicker(profileManager: profileManager)
                .frame(height: geometry.size.height / 2)
                .transition(.move(edge: .bottom))
            }
          }
          .background(isBlocking ? Color("BlockingBackground") : Color("NonBlockingBackground"))
        }
      }
      .navigationBarItems(trailing: createTagButton)
      .alert(item: $alertType) { type in
        switch type {
        case .wrongTag:
          Alert(
            title: Text("Wrong Tag Scanned!"),
            message: Text("The current profile requires you scan its corresponding tag to unlock it."),
            dismissButton: .default(Text("OK"))
          )
        case .notBrokerTag:
          Alert(
            title: Text("Not a Broker Tag"),
            message: Text("You can create a new Broker tag using the + button"),
            dismissButton: .default(Text("OK"))
          )
        case .createTag:
          Alert(
            title: Text("Create Broker Tag"),
            message: Text("Do you want to create a new Broker tag?"),
            primaryButton: .default(Text("Create")) { createBrokerTag() },
            secondaryButton: .cancel()
          )
        case .tagCreationResult(let success):
          Alert(
            title: Text("Tag Creation"),
            message: Text(success ? "Broker tag created successfully!" : "Failed to create Broker tag. Please try again."),
            dismissButton: .default(Text("OK"))
          )
        }
      }
    }
    .animation(.spring(), value: isBlocking)
  }

  @ViewBuilder
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

  private func scanTag() {
    nfcReader.scan { payload in
      let currentProfile = profileManager.currentProfile

      if isBlocking {
        if currentProfile.requireMatchingTag {
          if payload == currentProfile.tagPhrase {
            NSLog("Matching tag, unblocking")
            appBlocker.toggleBlocking(for: currentProfile)
          } else if String(payload.prefix(6)) != "BROKE-" {
            alertType = .notBrokerTag
            NSLog("A Non Broke tag was scanned!\nPayload: \(payload)")
          } else {
            alertType = .wrongTag
            NSLog("Wrong Tag for unblocking!\nPayload: \(payload)")
          }
        } else {
          NSLog("Tag matching not required, unblocking")
          appBlocker.toggleBlocking(for: currentProfile)
        }
      } else {
        if let matchingProfile = profileManager.profiles.first(where: { $0.tagPhrase == payload }) {
          profileManager.setCurrentProfile(id: matchingProfile.id)
          NSLog("Switching to profile: \(matchingProfile.name)")
          appBlocker.toggleBlocking(for: matchingProfile)
        } else {
          NSLog("No matching profile, using current")
          appBlocker.toggleBlocking(for: currentProfile)
        }
      }
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

  private func createBrokerTag() {
    nfcReader.write(profileManager.currentProfile.tagPhrase) { success in
      alertType = .tagCreationResult(success: success)
    }
  }
}
