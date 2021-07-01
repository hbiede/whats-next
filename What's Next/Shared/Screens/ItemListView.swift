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
        List {
            ForEach(
                sortItems(items: items.filter { _ in true }, sortMethod: "type").sorted{ $0.key < $1.key },
                id: \.key
            ) { (sectionKey, sectionItems) in
                Section(header: Text(NSLocalizedString(sectionKey, comment: "The name of the type"))) {
                    ForEach(sectionItems) { item in
                        if item.id != nil && item.name != nil {
                            NavigationLink(destination: ItemDetailView(item: item)) {
                                ItemListEntry(item: item)
                            }
                            #if os(iOS)
                                .isDetailLink(true)
                            #endif
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
        }
        #if os(iOS)
        .listStyle(.insetGrouped)
        .navigationViewStyle(StackNavigationViewStyle())
        .toolbar {
            NavigationLink(destination: AddRecScreen()) {
                AnyView(
                    Button(action: {}, label: {
                        Image(systemName: "plus")
                    })
                )
            }
        }
        #endif
        .navigationTitle("recommendation-list-page-title")
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
                viewContext.reset()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ItemListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

struct ItemListEntry: View {
    let item: Item
    
    @ViewBuilder
    var body: some View {
        VStack {
            HStack {
                Text(item.name ?? "")
                    .fontWeight(.bold)
                    .frame(alignment: .leading)
                Text(NSLocalizedString(item.type ?? "", comment: "The name of the type"))
                    .fontWeight(.light)
                    .italic()
                    .frame(alignment: .leading)
                    .padding([.leading], 8)
            }
                .frame(maxWidth: .infinity, alignment: .leading)
            if item.author != nil && item.author != "" {
                Text(
                    "author-listing \(item.author ?? "")",
                    comment: "The author of the book recommendation"
                )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 0.5)
            }
            Text(
                "recommender-listing \(item.recommender ?? "")",
                comment: "The person who recommended this entry"
            )
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 1)
            Text(
                "recommendation-date-listing \(getRecDateString(item))",
                comment: "The recommendation date"
            )
                .accessibilityLabel(getRecDateString(item))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 1)
        }
    }
    
    private func getRecDateString(_ item: Item) -> String {
        spokenItemFormatter.string(from: item.recommendationDate ?? Date())
    }
}

private let spokenItemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    return formatter
}()
