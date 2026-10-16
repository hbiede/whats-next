//
//  UpNextScreen.swift
//  What's Next
//
//  Created by Hundter Biede on 6/17/21.
//

import AppIntents
import CoreData
import SwiftUI

struct UpNextScreen: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.recommendationDate, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    /// The type to show, e.g. books after a tap on a books widget
    let requestedType: RecType

    @State private var currentItem: Item?
    @State private var selectedType: RecType

    init(requestedType: RecType = .movie) {
        self.requestedType = requestedType
        _selectedType = State(initialValue: requestedType)
    }

    @ViewBuilder
    var body: some View {
        Form {
            VStack {
                Picker(
                    NSLocalizedString("rec-type-label", comment: "Type selector label"),
                    selection: $selectedType
                ) {
                    ForEach(RecType.allCases) {
                        Text(
                            NSLocalizedString(
                                $0.description,
                                comment: "Convert the type to a title cased string"
                            )
                        ).tag($0)
                    }
                }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: selectedType) { _, newType in
                        // Update current item based on newly selected type
                        currentItem = randomItem(of: newType)
                    }
                .onAppear {
                    // Set `currentItem` for initial frame
                    currentItem = randomItem(of: selectedType)
                }
                .onChange(of: requestedType) { _, newType in
                    // A widget for another type was tapped while this screen was open
                    selectedType = newType
                }
                .onChange(of: items.map(\.objectID)) {
                    // Pick again if the one on screen was deleted (e.g. by asking Siri to delete it), or if the
                    // first recommendations have only just synced in
                    if currentItem.map({ $0.isDeleted || $0.managedObjectContext == nil }) ?? true {
                        currentItem = randomItem(of: selectedType)
                    }
                }

                if let currentItem, let name = currentItem.name {
                    Text(name)
                        .font(.title)
                        .accessibilityHint("name-field")
                        .padding([.vertical], 16)
                    if currentItem.type == RecType.book.description {
                        HStack {
                            Text("author-label").font(.title3).fontWeight(.light)
                            Spacer()
                            Text(currentItem.author ?? "")
                                .font(.title3)
                                .accessibilityHint("author-label")
                        }
                        .padding([.vertical], 4)
                    }
                    HStack {
                        Text(
                            "rec-by-field-label",
                            comment: "The label for the recommender for the recommendation"
                        )
                            .font(.title3)
                            .fontWeight(.light)
                        Spacer()
                        Text(currentItem.recommender ?? "")
                            .font(.title2)
                            .accessibilityHint("rec-by-field-label")
                    }
                        .padding([.vertical], 4)
                    if let recommendationDate = currentItem.recommendationDate {
                        HStack {
                            Text(
                                "rec-date-field-label",
                                comment: "The label for the recommender for the recommendation"
                            )
                                .font(.title3)
                                .fontWeight(.light)
                            Spacer()
                            Text(recommendationDate, formatter: itemFormatter)
                                .font(.title3)
                                .accessibilityLabel(
                                    "\(recommendationDate, formatter: spokenItemFormatter)"
                                )
                                .accessibilityHint("rec-date-field-label")
                        }
                            .padding([.vertical], 4)
                    }
                } else if selectedType == .movie {
                    Text("no-movie-records-text")
                        .padding([.vertical], 16)
                        .multilineTextAlignment(.center)
                } else if selectedType == .book {
                    Text("no-book-records-text")
                        .padding([.vertical], 16)
                        .multilineTextAlignment(.center)
                } else {
                    Text("no-tv-records-text")
                        .padding([.vertical], 16)
                        .multilineTextAlignment(.center)
                }
            }
                .padding()
                .appEntityIdentifier(currentItem?.id.map(RecommendationEntity.identifier(for:)))

            if items.filter({ $0.type == selectedType.description }).count > 1 {
                Section {
                    Button("refresh-button-label", action: {
                        // Get new `currentItem`
                        currentItem = randomItem(of: selectedType, excluding: currentItem)
                    })
                }
            }
        }
            .navigationTitle("up-next-page-title")
    }

    /// Avoids `current` where there's another to choose, so refreshing always shows something new
    private func randomItem(of type: RecType, excluding current: Item? = nil) -> Item? {
        let candidates = items.filter { $0.type == type.description && $0.name != nil }
        let others = candidates.filter { $0 != current }
        return (others.isEmpty ? candidates : others).randomElement()
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

#if DEBUG
#Preview {
    NavigationStack {
        UpNextScreen()
            .environment(
                \.managedObjectContext,
                 PersistenceController.preview.container.viewContext
            )
    }
}
#endif
