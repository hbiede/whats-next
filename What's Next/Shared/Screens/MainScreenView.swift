//
//  MainScreenView.swift
//  What's Next
//
//  Created by Hundter Biede on 6/17/21.
//

import SwiftUI

struct MainScreenView: View {
    @Environment(\.scenePhase) private var phase
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var quickActionSettings: QuickActionSettings

    @FetchRequest(sortDescriptors: [])
    private var items: FetchedResults<Item>

    @State var startPoint = UnitPoint(x: 0, y: 0)
    @State var endPoint = UnitPoint(x: 0, y: 2)

    var body: some View {
        NavigationView {
            ZStack {
                Background()
                
                VStack {
                    Spacer()
                    Text("app-title", comment: "Main app screen title")
                        .accessibilityElement()
                        .foregroundColor(.white)
                        .font(.largeTitle.bold().lowercaseSmallCaps())
                        .multilineTextAlignment(.center)
                    Spacer()
                    Spacer()
                    NavigationLink(
                        destination: UpNextScreen().environment(\.managedObjectContext, viewContext),
                        tag: QuickActionSettings.ShortcutAction.GET_REC,
                        selection: $quickActionSettings.quickAction
                    ) {
                        Text("whats-next-menu-button", comment: "Button to get to the Up Next page")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .accessibilityElement()
                            .padding()
                            .padding(.horizontal, 10)
                            .background(Color.white)
                        
                    }
                    .clipShape(Capsule())
                    .padding(.bottom, 10)
                    .opacity(items.isEmpty ? 0.4 : 1)
                    .disabled(items.isEmpty)
                    NavigationLink(
                        destination: AddRecScreen(),
                        tag: QuickActionSettings.ShortcutAction.ADD_REC,
                        selection: $quickActionSettings.quickAction
                    ) {
                        Text("add-menu-button", comment: "Button to get to the Add Recommendation page")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .accessibilityElement()
                            .padding()
                            .padding(.horizontal, 20)
                            .background(Color.white)
                        
                    }
                    .clipShape(Capsule())
                    .padding(.bottom, 10)
                    NavigationLink(
                        destination: ItemListView().environment(\.managedObjectContext, viewContext),
                        tag: QuickActionSettings.ShortcutAction.SHOW_LIST,
                        selection: $quickActionSettings.quickAction
                    ) {
                        Text("see-list-menu-button", comment: "Button to get to the See List page")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .accessibilityElement()
                            .padding()
                            .padding(.horizontal, 20)
                            .background(Color.white)
                        
                    }
                    .clipShape(Capsule())
                    .opacity(items.isEmpty ? 0.4 : 1)
                    .disabled(items.isEmpty)
                    Spacer()
                }
            }
        }
        #if os(iOS)
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
        .onChange(of: phase) { newPhase in
            switch newPhase {
            case .active:
                print("skipping active")
            case .inactive, .background:
                print("inactive")
                addQuickActions()
            @unknown default:
                print(newPhase)
            }
        }
    }
    
    func addQuickActions() {
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
    }
}

struct Background: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion

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
            angle: .degrees(Double.random(in: 0...360))
        )
            .ignoresSafeArea()
    }
}

struct MainScreenView_Previews: PreviewProvider {
    static var previews: some View {
        MainScreenView()
            .environmentObject(QuickActionSettings())
    }
}
