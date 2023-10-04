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

    @State private var showGetRec = false
    @State private var showAddRec = false
    @State private var showList = false

    func handleQuickAction (_ newAction: QuickActionSettings.ShortcutAction?) {
        if let newAction = newAction {
            switch newAction {
            case .ADD_REC:
                showAddRec = true
            case .GET_REC:
                showGetRec = true
            case .SHOW_LIST:
                showList = true
            }
        }
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
                        .foregroundColor(.white)
                        .font(.system(size: 500).bold().lowercaseSmallCaps())
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                    Spacer()
                    Spacer()
                    Button {
                        showGetRec = true
                    } label: {
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
                    Button {
                        showAddRec = true
                    } label: {
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
                    Button {
                        showList = true
                    } label: {
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
            .navigationDestination(isPresented: $showGetRec) {
                UpNextScreen().environment(\.managedObjectContext, viewContext)
            }
            .navigationDestination(isPresented: $showAddRec) {
                AddRecScreen()
            }
            .navigationDestination(isPresented: $showList) {
                ItemListView().environment(\.managedObjectContext, viewContext)
            }
        }
        .onAppear() {
            handleQuickAction(quickActionSettings.quickAction)
        }
        .onChange(of: phase) { newPhase in
            if newPhase == .background || newPhase == .inactive {
                addQuickActions()
            }
        }
        .onChange(of: quickActionSettings.quickAction, perform: handleQuickAction)
        .onOpenURL { url in
            quickActionSettings.quickAction =
            url.absoluteString == QuickActionSettings.ShortcutAction.ADD_REC.rawValue
                ? .ADD_REC
                : .GET_REC
        }
    }
    
    // MARK: Quick Actions
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

// MARK: Gradient Background
struct Background: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    #if !DEBUG
    var timer = Timer.publish(every: 6, on: .current, in: .default).autoconnect()
    #endif
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
            .onReceive(timer) { [self] _ in
                withAnimation(.linear(duration: 6)) {
                    self.rotation += 120
                }
            }
            #endif
    }
}

struct MainScreenView_Previews: PreviewProvider {
    static var previews: some View {
        MainScreenView()
            .environmentObject(QuickActionSettings())
    }
}
