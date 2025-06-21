//
//  ProfileCardCarousel.swift
//  FocusTap
//
//  Created by Trevor Walker on 6/9/25.
//

import FamilyControls
import SwiftUI

struct ProfileCardCarousel: View {
  let profiles: [Profile]
  let isBlocking: Bool
  let activeSessionProfileId: UUID?
  let elapsedTime: TimeInterval

  var onManageTapped: () -> Void

  // State for tracking current profile index and drag gesture
  @State private var currentIndex: Int = 0
  @State private var dragOffset: CGFloat = 0
  @State private var animatingOffset: CGFloat = 0

  // Constants for the carousel
  private let cardSpacing: CGFloat = 12
  private let dragThreshold: CGFloat = 50

  private var cardHeight: CGFloat = 160

  private var titleMessage: String {
    return isBlocking ? "Active Profile" : "Profile"
  }

  init(
    profiles: [Profile],
    isBlocking: Bool,
    activeSessionProfileId: UUID?,
    elapsedTime: TimeInterval,
    onManageTapped: @escaping () -> Void
  ) {
    self.profiles = profiles
    self.isBlocking = isBlocking
    self.activeSessionProfileId = activeSessionProfileId
    self.elapsedTime = elapsedTime
    self.onManageTapped = onManageTapped
  }

  // Initialize current index based on active profile
  private func initialSetup() {
    if let activeId = activeSessionProfileId,
       let index = profiles.firstIndex(where: { $0.id == activeId })
    {
    currentIndex = index
    return
    }

    if profiles.first != nil {
      currentIndex = 0
      return
    }
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {

      SectionTitle(
        titleMessage,
        buttonText: "Manage",
        buttonAction: {
          onManageTapped()
        },
        buttonIcon: "person.crop.circle"
      )
      .padding(.horizontal, 16)

      VStack(spacing: 16) {
        // Card carousel
        ZStack {
          // Carousel container
          GeometryReader { geometry in
            let cardWidth = geometry.size.width * 0.88

            HStack(spacing: cardSpacing) {
              ForEach(profiles.indices, id: \.self) { index in
                LargeProfileCard(
                  profile: profiles[index]
                )
                .frame(width: cardWidth)
              }
            }
            .offset(
              x: calculateOffset(
                geometry: geometry,
                cardWidth: cardWidth
              )
            )
            .animation(
              .spring(response: 0.4, dampingFraction: 0.8),
              value: currentIndex
            )
            .animation(
              .spring(response: 0.4, dampingFraction: 0.8),
              value: dragOffset
            )
            .gesture(
              DragGesture()
                .onChanged { value in
                  if !isBlocking {  // Only allow dragging when not blocking
                    dragOffset = value.translation.width
                  }
                }
                .onEnded { value in
                  if !isBlocking {  // Only allow dragging when not blocking
                    let offsetAmount = value.translation
                      .width
                    let swipedRight =
                    offsetAmount > dragThreshold
                    let swipedLeft =
                    offsetAmount < -dragThreshold

                    if swipedLeft
                        && currentIndex < profiles.count - 1
                    {
                    currentIndex += 1
                    } else if swipedRight
                                && currentIndex > 0
                    {
                    currentIndex -= 1
                    }

                    dragOffset = 0
                  }
                }
            )
          }
        }
        .frame(height: cardHeight)
        .padding(.bottom, 10)

        // Page indicator dots
        HStack(spacing: 8) {
          if !isBlocking && profiles.count > 1 {
            ForEach(0..<profiles.count, id: \.self) { index in
              Circle()
                .fill(
                  index == currentIndex
                  ? Color.primary
                  : Color.secondary.opacity(0.3)
                )
                .frame(width: 8, height: 8)
                .animation(.easeInOut, value: currentIndex)
            }
          }
        }
        .frame(height: 8)
        .opacity(!isBlocking && profiles.count > 1 ? 1 : 0)
        .animation(.easeInOut, value: isBlocking)
      }
    }
    .onAppear {
      initialSetup()
    }
    .onChange(of: activeSessionProfileId) { _, _ in
      initialSetup()
    }
    .onChange(of: profiles) { _, _ in
      initialSetup()
    }
  }

  // Calculate the offset based on current index and drag
  private func calculateOffset(geometry: GeometryProxy, cardWidth: CGFloat)
  -> CGFloat
  {
  let totalWidth = cardWidth + cardSpacing
  let baseOffset = CGFloat(currentIndex) * -totalWidth
  let leadingPadding = (geometry.size.width - cardWidth) / 2
  return baseOffset + dragOffset + leadingPadding
  }
}

// Active preview
#Preview {
  let activeId = UUID()

  ZStack {
    Color(.systemGroupedBackground).ignoresSafeArea()

    ProfileCardCarousel(
      profiles: [
        Profile(id: activeId,
                name: "Work",
                selection: FamilyActivitySelection(),
                interactionId: NFCInteraction.id,
                enableLiveActivity: true),
        Profile(name: "Focus Mode",
                selection: FamilyActivitySelection(),
                interactionId: ManualInteraction.id,
                timed: true)
      ],
      isBlocking: true,
      activeSessionProfileId: activeId,
      elapsedTime: 1234,
      onManageTapped: {}
    )
  }
}

#Preview {
  ZStack {
    Color(.systemGroupedBackground).ignoresSafeArea()

    ProfileCardCarousel(
      profiles: [
        Profile(name: "Work",
                selection: FamilyActivitySelection(),
                interactionId: NFCInteraction.id,
                enableLiveActivity: true),
        Profile(name: "Focus",
                selection: FamilyActivitySelection(),
                interactionId: ManualInteraction.id,
                enableLiveActivity: true),
        Profile(name: "Test",
                selection: FamilyActivitySelection(),
                interactionId: NFCInteraction.id,
                enableLiveActivity: true),
        Profile(name: "Work",
                selection: FamilyActivitySelection(),
                interactionId: NFCInteraction.id,
                enableLiveActivity: true)
      ],
      isBlocking: false,
      activeSessionProfileId: nil,
      elapsedTime: 1234,
      onManageTapped: {}
    )
  }
}

