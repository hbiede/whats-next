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

    var body: some View {
        NavigationView {
            ZStack {
                Color.init(red: 0.56862745, green: 0.07058824, blue: 0.94901961).ignoresSafeArea()
                VStack {
                    Spacer()
                    Text("What's Next?")
                        .foregroundColor(.white)
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                    Spacer()
                    Spacer()
                    NavigationLink(destination: UpNextScreen().environment(\.managedObjectContext, viewContext)) {
                        Text("See What's Next")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding()
                            .padding(.horizontal, 10)
                            .background(Color.white)
                            
                    }
                        .clipShape(Capsule())
                        .padding(.bottom, 10)
                        .opacity(items.count == 0 ? 0.4 : 1)
                        .disabled(items.count == 0)
                    NavigationLink(destination: AddRecScreen()) {
                        Text("    Add    ")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .padding()
                            .padding(.horizontal, 40)
                            .background(Color.white)
                            
                    }
                        .clipShape(Capsule())
                        .padding(.bottom, 10)
                    NavigationLink(destination: ItemListView().environment(\.managedObjectContext, viewContext)) {
                        Text("See List")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .padding()
                            .padding(.horizontal, 40)
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

struct MainScreenView_Previews: PreviewProvider {
    static var previews: some View {
        MainScreenView()
    }
}
