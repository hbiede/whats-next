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
    @State private var selectedType: Type = .Movie

    @Environment(\.colorScheme) var colorScheme

    @ViewBuilder
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    Picker("Type", selection: $selectedType) {
                        Text("Movie").tag(Type.Movie)
                        Text("TV Show").tag(Type.TVShow)
                        Text("Book").tag(Type.Book)
                    }
                        .frame(width: UIScreen.main.bounds.size.width * 0.8)
                        .pickerStyle(SegmentedPickerStyle())
                        .background(Color.white)
                        .padding()
                        .onChange(of: selectedType){ newType in
                            // Update current item based on newly selected type
                            if newType == .Movie {
                                currentItem = items.filter{ $0.type == "Movie" }.randomElement()
                            } else if newType == .Book {
                                currentItem = items.filter{ $0.type == "Book" }.randomElement()
                            } else {
                                currentItem = items.filter{ $0.type == "TV Show" }.randomElement()
                            }
                        }
                    .onAppear(){
                        // Set `currentItem` for initial frame
                        if selectedType == .Movie {
                            currentItem = items.filter{ $0.type == "Movie" }.randomElement()
                        } else if selectedType == .Book {
                            currentItem = items.filter{ $0.type == "Book" }.randomElement()
                        } else {
                            currentItem = items.filter{ $0.type == "TV Show" }.randomElement()
                        }
                    }

                    if currentItem != nil {
                        Text(currentItem!.name!)
                            .font(.title)
                        if currentItem?.type == "Book" {
                            HStack {
                                Text("Author").font(.title3).fontWeight(.light)
                                Spacer()
                                Text(currentItem!.author!).font(.title3)
                            }
                                .padding()
                        }
                        HStack {
                            Text("Recommended by").font(.title3).fontWeight(.light)
                            Spacer()
                            Text(currentItem!.recommender!).font(.title2)
                        }
                            .padding()
                        HStack {
                            Text("Recommended on").font(.title3).fontWeight(.light)
                            Spacer()
                            Text(currentItem!.recommendationDate!, formatter: itemFormatter).font(.title3)
                        }
                            .padding()
                    } else if selectedType == .Movie {
                        Text("No movie records found")
                            .padding()
                    } else if selectedType == .Book {
                        Text("No book records found")
                            .padding()
                    } else {
                        Text("No TV show records found")
                            .padding()
                    }
                }
                    .frame(width: UIScreen.main.bounds.size.width * 0.9)
                    .background(colorScheme == .dark ? Color.black : Color.white)
                    .cornerRadius(8)
                    .navigationBarHidden(true)
                    .padding()
                Spacer()
            }
                .navigationBarHidden(true)
                .frame(width: UIScreen.main.bounds.size.width)
                .background(Color.init(red: 0.56862745, green: 0.07058824, blue: 0.94901961))
                .ignoresSafeArea(edges: [.bottom, .horizontal])
        }
            .navigationTitle("Up Next")
            .navigationViewStyle(StackNavigationViewStyle())
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter
}()

struct UpNextScreen_Previews: PreviewProvider {
    static var previews: some View {
        UpNextScreen()
    }
}
