//
//  UpNextScreen.swift
//  What's Next
//
//  Created by Hundter Biede on 6/17/21.
//

import SwiftUI

struct UpNextScreen: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.recommendationDate, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    @State private var currentItem: Item?
    @State private var selectedType: Type = .movie

    @Environment(\.colorScheme) var colorScheme

    @ViewBuilder
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    Picker("Type", selection: $selectedType) {
                        ForEach(Type.allCases) {
                            Text($0.description).tag($0)
                        }
                    }
                        #if os(iOS)
                        .frame(width: UIScreen.main.bounds.size.width * 0.8)
                        #else
                        .frame(width: .infinity)
                        .padding([.horizontal], 20)
                        #endif
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        .onChange(of: selectedType) { newType in
                            // Update current item based on newly selected type
                            currentItem = items.filter { $0.type == newType.description }.randomElement()
                        }
                    .onAppear {
                        // Set `currentItem` for initial frame
                        currentItem = items.filter { $0.type == selectedType.description }.randomElement()
                    }

                    if currentItem != nil {
                        Text(currentItem!.name!)
                            .font(.title)
                            .accessibilityHint("Recommendation Title")
                        if currentItem?.type == "Book" {
                            HStack {
                                Text("Author").font(.title3).fontWeight(.light)
                                Spacer()
                                Text(currentItem!.author!)
                                    .font(.title3)
                                    .accessibilityHint("Author")
                            }
                                .padding()
                        }
                        HStack {
                            Text("Recommended by").font(.title3).fontWeight(.light)
                            Spacer()
                            Text(currentItem!.recommender!)
                                .font(.title2)
                                .accessibilityHint("Recommended by")
                        }
                            .padding()
                        HStack {
                            Text("Recommended on").font(.title3).fontWeight(.light)
                            Spacer()
                            Text(currentItem!.recommendationDate!, formatter: itemFormatter)
                                .font(.title3)
                                .accessibilityLabel(
                                    "\(currentItem!.recommendationDate!, formatter: spokenItemFormatter)"
                                )
                                .accessibilityHint("Recommended on")
                        }
                            .padding()
                    } else if selectedType == .movie {
                        Text("No movie records found")
                            .padding()
                    } else if selectedType == .book {
                        Text("No book records found")
                            .padding()
                    } else {
                        Text("No TV show records found")
                            .padding()
                    }
                }
                    #if os(iOS)
                    .frame(width: UIScreen.main.bounds.size.width * 0.9)
                    .navigationBarHidden(true)
                    #else
                    .frame(width: .infinity)
                    .padding([.horizontal], 20)
                    #endif
                    .background(colorScheme == .dark ? Color.black : Color.white)
                    .cornerRadius(8)
                    .padding()
                Spacer()
            }
                #if os(iOS)
                .navigationBarHidden(true)
                #endif
                .frame(width: .infinity)
                .background(Color.accentColor)
                .ignoresSafeArea(edges: [.bottom, .horizontal])
        }
            .navigationTitle("Up Next")
            #if os(iOS)
            .navigationViewStyle(StackNavigationViewStyle())
            #endif
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter
}()

private let spokenItemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    return formatter
}()

struct UpNextScreen_Previews: PreviewProvider {
    static var previews: some View {
        UpNextScreen()
    }
}
