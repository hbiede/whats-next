//
//  ItemDetailView.swift
//  What's Next
//
//  Created by Hundter Biede on 6/23/21.
//  Copyright © 2021 com.hbiede. All rights reserved.
//

import SwiftUI

struct ItemDetailView: View {
    let item: Item

    init(item: Item) {
        self.item = item
    }

    @Environment(\.managedObjectContext) private var viewContext

    @State private var name: String = ""
    @State private var author: String = ""
    @State private var recommender: String = ""
    @State private var recDate: Date = Date()
    @State private var notes: String = ""

    @State private var didSave = false

    @ViewBuilder
    var body: some View {
        Form {
            if didSave &&
                name == item.name &&
                author == item.author &&
                recommender == item.recommender &&
                (
                    item.recommendationDate == nil ||
                    itemFormatter.string(from: item.recommendationDate!) == itemFormatter.string(from: recDate)
                ) &&
                notes == item.notes {
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
                } else if item.type == "Book" {
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
                    displayedComponents: [.date]
                )
                TextField(
                    NSLocalizedString("notes-field-label", comment: "Notes edit field label"),
                    text: $notes
                )
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
            }
                .onAppear {
                    name = item.name ?? ""
                    author = item.author ?? ""
                    recommender = item.recommender ?? ""
                    recDate = item.recommendationDate ?? Date()
                    notes = item.notes ?? ""
                }
            if #available(iOS 15.0, macOS 12.0, *) {
                Button("delete-recommnedation-button", role: .destructive, action: delete)
            } else {
                Button("delete-recommnedation-button", action: delete)
            }
            if
                item.name != name ||
                    item.author != author ||
                    item.recommender != recommender ||
                    item.notes != notes ||
                    item.recommendationDate == nil ||
                    itemFormatter.string(from: recDate) != itemFormatter.string(from: item.recommendationDate!)
            {
                Button("save-change-button", action: confirm)
                    .disabled(
                        name.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
                        recommender.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
                        (
                            item.type == RecType.book.description &&
                            author.trimmingCharacters(in: .whitespacesAndNewlines) == ""
                        )
                    )
                if #available(iOS 15.0, macOS 12.0, *) {
                    Button("undo-change-button", role: .cancel, action: undo)
                } else {
                    Button("undo-change-button", action: undo)
                }
            }
        }
        .navigationTitle("edit-recommendation-page-title")
    }

    func confirm() {
        didSave = false
        if name.trimmingCharacters(in: .whitespacesAndNewlines) != item.name {
            item.setValue(name.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "name")
            didSave = true
        }

        if author.trimmingCharacters(in: .whitespacesAndNewlines) != item.author {
            item.setValue(author.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "author")
            didSave = true
        }

        if recommender.trimmingCharacters(in: .whitespacesAndNewlines) != item.recommender {
            item.setValue(recommender.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "recommender")
            didSave = true
        }

        if
            item.recommendationDate == nil ||
            itemFormatter.string(from: item.recommendationDate!) != itemFormatter.string(from: recDate)
        {
            item.setValue(recDate, forKey: "recommendationDate")
            didSave = true
        }

        if notes.trimmingCharacters(in: .whitespacesAndNewlines) != item.notes {
            item.setValue(notes.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "notes")
            didSave = true
        }

        if didSave {
            do {
                try viewContext.save()
            } catch {}
            viewContext.reset()
        }
    }

    func delete() {
        viewContext.delete(item)
        do {
            try viewContext.save()
        } catch {}
        viewContext.reset()
    }

    func undo() {
        name = item.name ?? ""
        author = item.author ?? ""
        recommender = item.recommender ?? ""
        recDate = item.recommendationDate ?? Date()
        notes = item.notes ?? ""
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter
}()
