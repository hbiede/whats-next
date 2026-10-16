//
//  MainScreenView.swift
//  What's Next
//
//  Created by Hundter Biede on 6/17/21.
//

import CoreData
import SwiftUI

struct MainScreenView: View {
    @Environment(\.scenePhase) private var phase
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(QuickActionSettings.self) var quickActionSettings: QuickActionSettings

    @FetchRequest(sortDescriptors: [])
    private var items: FetchedResults<Item>

    @State private var showGetRec = false
    @State private var showAddRec = false
    @State private var showList = false
    @State private var openedItem: Item?
    /// The type Up Next and Add Recommendation start on
    @State private var requestedType: RecType = .movie

    func handleQuickAction(_ newAction: QuickActionSettings.ShortcutAction?) {
        guard let newAction else { return }
        let type = quickActionSettings.requestedType
        // Clear it so asking for the same screen again still triggers `onChange`
        quickActionSettings.quickAction = nil
        quickActionSettings.requestedType = nil
        show(newAction, type: type)
    }

    func show(_ action: QuickActionSettings.ShortcutAction, type: RecType?) {
        requestedType = type ?? .movie
        switch action {
        case .ADD_REC:
            showAddRec = true
        case .GET_REC:
            showGetRec = true
        case .SHOW_LIST:
            showList = true
        }
    }

    func openRecommendation(_ id: UUID?) {
        guard let id else { return }
        quickActionSettings.recommendationToOpen = nil
        let request = Item.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        openedItem = try? viewContext.fetch(request).first
    }

    // MARK: Body
    var body: some View {
        NavigationStack {
            ZStack {
                Background()

                VStack {
                    Spacer()
                    Text("app-title", comment: "Main app screen title")
                        .accessibilityElement()
                        .foregroundStyle(.white)
                        .font(.system(size: 500).bold().lowercaseSmallCaps())
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                    Spacer()
                    Spacer()
                    // The labels stay part of their buttons, so VoiceOver and UI tests find them by name
                    Button {
                        show(.GET_REC, type: nil)
                    } label: {
                        Text("whats-next-menu-button", comment: "Button to get to the Up Next page")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.black)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 10)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.white)
                    .padding(.bottom, 10)
                    .opacity(items.isEmpty ? 0.4 : 1)
                    .disabled(items.isEmpty)
                    Button {
                        show(.ADD_REC, type: nil)
                    } label: {
                        Text("add-menu-button", comment: "Button to get to the Add Recommendation page")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 20)
                    }
                    .buttonStyle(.glass)
                    .padding(.bottom, 10)
                    Button {
                        showList = true
                    } label: {
                        Text("see-list-menu-button", comment: "Button to get to the See List page")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 20)
                    }
                    .buttonStyle(.glass)
                    .opacity(items.isEmpty ? 0.4 : 1)
                    .disabled(items.isEmpty)
                    Spacer()
                }
            }
            .navigationDestination(isPresented: $showGetRec) {
                UpNextScreen(requestedType: requestedType).environment(\.managedObjectContext, viewContext)
            }
            .navigationDestination(isPresented: $showAddRec) {
                AddRecScreen(requestedType: requestedType)
            }
            .navigationDestination(isPresented: $showList) {
                ItemListView().environment(\.managedObjectContext, viewContext)
            }
            .navigationDestination(item: $openedItem) { item in
                ItemDetailView(item: item)
            }
        }
        .onAppear {
            handleQuickAction(quickActionSettings.quickAction)
            openRecommendation(quickActionSettings.recommendationToOpen)
        }
        .onChange(of: phase) { _, newPhase in
            if newPhase == .background || newPhase == .inactive {
                addQuickActions()
            }
        }
        .onChange(of: quickActionSettings.quickAction) { _, newAction in
            handleQuickAction(newAction)
        }
        .onChange(of: quickActionSettings.recommendationToOpen) { _, id in
            openRecommendation(id)
        }
        .onOpenURL { url in
            quickActionSettings.handle(url)
        }
    }

    // MARK: Quick Actions
    func addQuickActions() {
        #if os(iOS)
        var shortcutItems: [UIApplicationShortcutItem] = [
            UIApplicationShortcutItem(
                type: QuickActionSettings.ShortcutAction.ADD_REC.rawValue,
                localizedTitle: NSLocalizedString(
                    "add-rec-title",
                    comment: "Add a recommendation from the home screen"
                ),
                localizedSubtitle: nil,
                icon: UIApplicationShortcutIcon(systemImageName: "plus.square.on.square")
            )
        ]
        if items.count > 0 {
            shortcutItems.append(
                UIApplicationShortcutItem(
                    type: QuickActionSettings.ShortcutAction.SHOW_LIST.rawValue,
                    localizedTitle: NSLocalizedString(
                        "show-list-title",
                        comment: "Show all recommendations from the home screen"
                    ),
                    localizedSubtitle: nil,
                    icon: UIApplicationShortcutIcon(systemImageName: "list.star")
                )
            )
            shortcutItems.append(
                UIApplicationShortcutItem(
                    type: QuickActionSettings.ShortcutAction.GET_REC.rawValue,
                    localizedTitle: NSLocalizedString(
                        "get-rec-title",
                        comment: "Get a random recommendation from the home screen"
                    ),
                    localizedSubtitle: nil,
                    icon: UIApplicationShortcutIcon(systemImageName: "lightbulb.fill")
                )
            )
        }
        UIApplication.shared.shortcutItems = shortcutItems
        #endif
    }
}

// MARK: Gradient Background
struct Background: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    @State var rotation = Double(Int.random(in: 0...360))

    let colors = [
        .accentColor,
        Color.init(red: 0.75862745, green: 0.27058824, blue: 1),
        Color.blue,
        Color.init(red: 0.56862745, green: 0.07058824, blue: 0.94901961)
    ]

    var body: some View {
        AngularGradient(
            colors: colors,
            center: UnitPoint(x: 4, y: 0),
            angle: .degrees(rotation)
        )
            .ignoresSafeArea()
            #if !DEBUG
            .task(id: reduceMotion) {
                // Hold still for people who've asked for less motion
                guard !reduceMotion else { return }
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(6))
                    withAnimation(.linear(duration: 6)) {
                        rotation += 120
                    }
                }
            }
            #endif
    }
}

#Preview {
    MainScreenView()
        .environment(QuickActionSettings())
}
