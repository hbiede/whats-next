//
//  ItemDetailView.swift
//  What's Next
//
//  Created by Hundter Biede on 6/23/21.
//  Copyright © 2021 com.hbiede. All rights reserved.
//

import AppIntents
import CoreData
import SwiftUI

struct ItemDetailView: View {
    let item: Item

    init(item: Item) {
        self.item = item
    }

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    @State private var name: String = ""
    @State private var author: String = ""
    @State private var recommender: String = ""
    @State private var recDate: Date = Date()
    @State private var notes: String = ""

    @State private var didSave = false

    // MARK: Body
    @ViewBuilder
    var body: some View {
        Form {
            if didSave && !hasChanges {
                Section {
                    Text("success-saved-message", comment: "Message for when an entry is successfully added")
                }
                    .listRowBackground(Color.green.opacity(0.3))
            }
            Section {
                if item.type == RecType.movie.description {
                    TextField(
                        NSLocalizedString("movie-name-field-label", comment: "Movie name edit field label"),
                        text: $name
                    )
                } else if item.type == RecType.book.description {
                    TextField(
                        NSLocalizedString("book-name-field-label", comment: "Book title edit field label"),
                        text: $name
                    )
                    TextField(
                        NSLocalizedString("author-field-label", comment: "Author edit field label"),
                        text: $author
                    )
                } else {
                    TextField(
                        NSLocalizedString("tv-show-name-field-label", comment: "TV Show name edit field label"),
                        text: $name
                    )
                }
                TextField(
                    NSLocalizedString("rec-by-field-label", comment: "Recommended by edit field label"),
                    text: $recommender
                )
                DatePicker(
                    "rec-date-field-label",
                    selection: $recDate,
                    in: ...Date(),
                    displayedComponents: [.date]
                )
                TextField(
                    NSLocalizedString("notes-field-label", comment: "Notes edit field label"),
                    text: $notes
                )
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
            }
                .onAppear(perform: loadSavedValues)
            Button("delete-recommnedation-button", role: .destructive, action: delete)
            if hasChanges {
                // Recommended by is optional, as it is when adding
                Button("save-change-button", action: confirm)
                    .disabled(
                        trimmed(name).isEmpty ||
                        (item.type == RecType.book.description && trimmed(author).isEmpty)
                    )
                Button("undo-change-button", role: .cancel, action: loadSavedValues)
            }
        }
        .navigationTitle("edit-recommendation-page-title")
        .appEntityIdentifier(item.id.map(RecommendationEntity.identifier(for:)))
    }

    /// Compares what will be saved, so whitespace that saving trims off (like the space after a QuickType
    /// suggestion) doesn't count as a change, and a missing value matches an empty field
    private var hasChanges: Bool {
        trimmed(name) != (item.name ?? "") ||
            trimmed(author) != (item.author ?? "") ||
            trimmed(recommender) != (item.recommender ?? "") ||
            trimmed(notes) != (item.notes ?? "") ||
            !(item.recommendationDate.map { Calendar.current.isDate($0, inSameDayAs: recDate) } ?? false)
    }

    private func trimmed(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: Confirm
    func confirm() {
        didSave = false
        if trimmed(name) != (item.name ?? "") {
            item.name = trimmed(name)
        }
        if trimmed(author) != (item.author ?? "") {
            item.author = trimmed(author)
        }
        if trimmed(recommender) != (item.recommender ?? "") {
            item.recommender = trimmed(recommender)
        }
        if !(item.recommendationDate.map { Calendar.current.isDate($0, inSameDayAs: recDate) } ?? false) {
            item.recommendationDate = recDate
        }
        if trimmed(notes) != (item.notes ?? "") {
            item.notes = trimmed(notes)
        }

        guard viewContext.hasChanges else { return }
        do {
            try viewContext.save()
            didSave = true
            // Show what was saved, without the trimmed whitespace
            loadSavedValues()
        } catch {
            print("Failed to save changes: \(error)")
            viewContext.rollback()
        }
    }

    // MARK: Delete
    func delete() {
        viewContext.delete(item)
        do {
            try viewContext.save()
        } catch {
            print("Failed to delete: \(error)")
            viewContext.rollback()
            return
        }
        self.dismiss()
    }

    // MARK: Undo
    func loadSavedValues() {
        name = item.name ?? ""
        author = item.author ?? ""
        recommender = item.recommender ?? ""
        recDate = item.recommendationDate ?? Date()
        notes = item.notes ?? ""
    }
}
