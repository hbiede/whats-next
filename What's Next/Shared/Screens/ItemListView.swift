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
                ForEach(items) {
                    VStack {
                        Text($0.name!)
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if $0.author != nil && $0.author != "" {
                            Text("By \($0.author!)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 0.5)
                        }
                        Text("Recommender: \($0.recommender!)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 1)
                        Text("Recommended on: \($0.recommendationDate!, formatter: itemFormatter)")
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
