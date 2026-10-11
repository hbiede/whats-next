//
//  ContentView.swift
//  Shared
//
//  Created by Hundter Biede on 6/17/21.
//

import AppIntents
import SwiftUI
import CoreData

struct ItemListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.recommendationDate, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    // MARK: Body
    @ViewBuilder
    var body: some View {
        List {
            ForEach(
                sortItems(items: items.filter { _ in true }, sortMethod: "type").sorted { $0.key < $1.key },
                id: \.key
            ) { (sectionKey, sectionItems) in
                Section(header: Text(NSLocalizedString(sectionKey, comment: "The name of the type"))) {
                    ForEach(sectionItems) { item in
                        if let id = item.id, item.name != nil {
                            NavigationLink(destination: ItemDetailView(item: item)) {
                                ItemListEntry(item: item)
                            }
                            .appEntityIdentifier(RecommendationEntity.identifier(for: id))
                        }
                    }
                    // Offsets count within this section, not within all of `items`
                    .onDelete { offsets in
                        deleteItems(offsets.map { sectionItems[$0] })
                    }
                }
            }
        }
        #if os(iOS)
        .listStyle(.insetGrouped)
        .toolbar {
            NavigationLink(destination: AddRecScreen()) {
                Image(systemName: "plus")
            }
        }
        #endif
        .navigationTitle("recommendation-list-page-title")
    }

    // MARK: Delete
    private func deleteItems(_ itemsToDelete: [Item]) {
        withAnimation {
            let isDeletingEverything = itemsToDelete.count == items.count
            itemsToDelete.forEach(viewContext.delete)

            do {
                try viewContext.save()
                if isDeletingEverything {
                    // Go back if list is empty
                    self.dismiss()
                }
            } catch {
                print("Failed to delete: \(error)")
                viewContext.rollback()
            }
        }
    }
}

#if DEBUG
#Preview {
    ItemListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
#endif

struct ItemListEntry: View {
    let item: Item

    // MARK: ListEntry
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
