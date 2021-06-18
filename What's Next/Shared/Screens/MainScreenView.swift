//
//  MainScreenView.swift
//  What's Next
//
//  Created by Hundter Biede on 6/17/21.
//

import SwiftUI

struct MainScreenView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(sortDescriptors: [])
    private var items: FetchedResults<Item>

    @State var startPoint = UnitPoint(x: 0, y: 0)
    @State var endPoint = UnitPoint(x: 0, y: 2)

    var body: some View {
        NavigationView {
            ZStack {
                AnimatedBackground().edgesIgnoringSafeArea(.all)

                VStack {
                    Spacer()
                    Text("What's Next?")
                        .accessibilityElement()
                        .foregroundColor(.white)
                        .font(.largeTitle.bold().lowercaseSmallCaps())
                        .multilineTextAlignment(.center)
                    Spacer()
                    Spacer()
                    NavigationLink(destination: UpNextScreen().environment(\.managedObjectContext, viewContext)) {
                        Text("See What's Next")
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
                        .opacity(items.count == 0 ? 0.4 : 1)
                        .disabled(items.count == 0)
                    NavigationLink(destination: AddRecScreen()) {
                        Text("Add")
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
                    NavigationLink(destination: ItemListView().environment(\.managedObjectContext, viewContext)) {
                        Text("See List")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .accessibilityElement()
                            .padding()
                            .padding(.horizontal, 20)
                            .background(Color.white)

                    }
                        .clipShape(Capsule())
                        .opacity(items.count == 0 ? 0.4 : 1)
                        .disabled(items.count == 0)
                    Spacer()
                }
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct AnimatedBackground: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    @State var rotation = 0.0

    let timer = Timer.publish(every: 0.1, on: .main, in: .default).autoconnect()
    let colors = [
        Color.init(red: 0.56862745, green: 0.07058824, blue: 0.94901961),
        Color.init(red: 0.75862745, green: 0.27058824, blue: 1),
        Color.blue,
        Color.init(red: 0.56862745, green: 0.07058824, blue: 0.94901961)
    ]

    var body: some View {
        AngularGradient(colors: colors, center: UnitPoint(x: 4, y: 0), angle: .degrees(self.rotation))
            .onReceive(timer, perform: { _ in
                self.rotation = (self.rotation + (reduceMotion ? 0.2 : 2)).truncatingRemainder(dividingBy: 360)
            })
            .ignoresSafeArea()
    }
}

struct MainScreenView_Previews: PreviewProvider {
    static var previews: some View {
        MainScreenView()
    }
}
