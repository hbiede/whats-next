//
//  ContentView.swift
//  Shared
//
//  Created by Hundter Biede on 6/17/21.
//

import SwiftUI
import CoreData

struct ItemListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.recommendationDate, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    @ViewBuilder
    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    VStack {
                        Text(item.name!)
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if item.author != nil && item.author != "" {
                            Text("By \(item.author!)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 0.5)
                        }
                        Text("Recommender: \(item.recommender!)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 1)
                        Text("Recommended on: \(item.recommendationDate!, formatter: itemFormatter)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 1)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationBarHidden(true)
        }
        .navigationTitle("Recommendations List")
        .navigationBarTitleDisplayMode(.inline)
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ItemListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
