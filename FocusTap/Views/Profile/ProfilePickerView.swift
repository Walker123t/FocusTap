//
//  ProfilePicker.swift
//  Broke
//
//  Created by Oz Tamir on 23/08/2024.
//

import SwiftUI
import FamilyControls

struct ProfilesPickerView: View {
  @ObservedObject var profileManager: ProfileManager
  @State private var showAddProfileView = false
  @State private var editingProfile: Profile?

  var body: some View {
    VStack {
      Text(.title)
        .font(.headline)
        .padding(.horizontal)
        .padding(.top)

      ScrollView {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 10)], spacing: 10) {
          ForEach(profileManager.profiles) { profile in
            ProfileCell(profile: profile, isSelected: profile.id == profileManager.currentProfileId)
              .onTapGesture {
                profileManager.setCurrentProfile(id: profile.id)
              }
              .onLongPressGesture {
                editingProfile = profile
              }
          }

          ProfileCellBase(
            name: .profilePicker(.newProfile),
            icon: "plus",
            appsBlocked: nil,
            categoriesBlocked: nil,
            isSelected: false,
            isDashed: true,
            hasDivider: false
          )
          .onTapGesture {
            showAddProfileView = true
          }
        }
        .padding(.horizontal, 10)
      }

      Spacer()

      Text(.editHint)
        .font(.caption2)
        .foregroundColor(.secondary.opacity(0.7))
        .padding(.bottom, 8)
    }
    .background(
      Color("ProfileSectionBackground")
        .clipShape(
          .rect(
            topLeadingRadius: 20,
            topTrailingRadius: 20
          )
        )
        .ignoresSafeArea(edges: .bottom)
    )
    .sheet(item: $editingProfile) { profile in
      ProfileFormView(profile: profile, profileManager: profileManager) {
        editingProfile = nil
      }
    }
    .sheet(isPresented: $showAddProfileView) {
      ProfileFormView(profileManager: profileManager) {
        showAddProfileView = false
      }
    }
  }
}

struct ProfileCellBase: View {
  let name: String
  let icon: String
  let appsBlocked: Int?
  let categoriesBlocked: Int?
  let isSelected: Bool
  var isDashed: Bool = false
  var hasDivider: Bool = true

  var body: some View {
    VStack(spacing: 4) {
      Image(systemName: icon)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 30, height: 30)
      if hasDivider {
        Divider().padding(2)
      }
      Text(verbatim: name)
        .font(.caption)
        .fontWeight(.medium)
        .lineLimit(1)

      if let apps = appsBlocked, let categories = categoriesBlocked {
        Text(verbatim: String(format: .profilePicker(.statsFormat), apps, categories))
          .font(.system(size: 10))
      }
    }
    .frame(width: 90, height: 90)
    .padding(2)
    .background(isSelected ? Color.blue.opacity(0.3) : Color.secondary.opacity(0.2))
    .cornerRadius(8)
    .overlay(
      RoundedRectangle(cornerRadius: 8)
        .stroke(
          isSelected ? Color.blue : (isDashed ? Color.secondary : Color.clear),
          style: StrokeStyle(lineWidth: 2, dash: isDashed ? [5] : [])
        )
    )
  }

  private var borderOverlay: some View {
    RoundedRectangle(cornerRadius: 8)
      .stroke(
        isSelected ? Color.blue : (isDashed ? Color.secondary : Color.clear),
        style: StrokeStyle(lineWidth: 2, dash: isDashed ? [5] : [])
      )
  }
}

struct ProfileCell: View {
  let profile: Profile
  let isSelected: Bool

  var body: some View {
    ProfileCellBase(
      name: profile.name,
      icon: profile.icon,
      appsBlocked: profile.appTokens.count,
      categoriesBlocked: profile.categoryTokens.count,
      isSelected: isSelected
    )
    .padding(.top, 3)
  }
}
