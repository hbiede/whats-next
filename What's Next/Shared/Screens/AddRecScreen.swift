//
//  AddRecScreen.swift
//  What's Next
//
//  Created by Hundter Biede on 6/17/21.
//

import CoreData
import SwiftUI

struct AddRecScreen: View {
    @Environment(\.managedObjectContext) private var viewContext

    /// The type to start on, e.g. books after a tap on an empty books widget
    let requestedType: RecType

    @State private var selectedType: RecType
    @State private var name: String = ""
    @State private var author: String = ""
    @State private var recommender: String = ""
    @State private var recDate: Date = Date()
    @State private var notes: String = ""

    @State private var didSave = false
    @State private var saveError = false

    init(requestedType: RecType = .movie) {
        self.requestedType = requestedType
        _selectedType = State(initialValue: requestedType)
    }

    // MARK: View
    var body: some View {
        let recommenderBinding = Binding<String>(get: {
                    self.recommender
                }, set: {
                    self.recommender = $0
                    #if DEBUG
                    onRecommenderChange($0)
                    #endif
                })

        return Form {
            if didSave &&
                name == "" &&
                author == "" &&
                recommender == "" &&
                Calendar.current.isDateInToday(recDate) &&
                notes == "" {
                Section {
                    Text("success-saved-message", comment: "Message for when an entry is successfully added")
                }
                    .listRowBackground(Color.green.opacity(0.3))
            } else if saveError &&
                        name == "" &&
                        author == "" &&
                        recommender == "" &&
                        Calendar.current.isDateInToday(recDate) &&
                        notes == "" {
                Section {
                    Text("failed-save-message", comment: "Message for when an entry failed to be added")
                }
                    .listRowBackground(Color.red.opacity(0.3))
            }
            Section {
                Picker(NSLocalizedString("rec-type-label", comment: "Type selector label"), selection: $selectedType) {
                    ForEach(RecType.allCases) {
                        Text(
                            NSLocalizedString($0.description, comment: "Convert the type to a title cased string")
                        ).tag($0)
                    }
                }
                    .pickerStyle(SegmentedPickerStyle())
                if selectedType == .movie {
                    TextField(
                        NSLocalizedString("movie-name-field-label", comment: "Movie name edit field label"),
                        text: $name
                    )
                } else if selectedType == .book {
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
                    text: recommenderBinding
                )
                #if os(iOS)
                    .textContentType(.nickname)
                #endif
                DatePicker(
                    NSLocalizedString("rec-date-field-label", comment: "Recommendation date edit field label"),
                    selection: $recDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                TextField(
                    NSLocalizedString("notes-field-label", comment: "Notes edit field label"),
                    text: $notes
                )
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
            }
            Button("confirm-addition-button-label", action: confirm)
                .disabled(
                    name.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
                        (selectedType == .book && author.trimmingCharacters(in: .whitespacesAndNewlines) == "")
                    )
        }
        .navigationTitle("add-rec-screen-title")
        .onChange(of: requestedType) { _, newType in
            // A widget for another type was tapped while this screen was open
            selectedType = newType
        }
    }

    // MARK: Confirm
    private func confirm() {
        saveError = false
        didSave = false
        let newItem = Item(context: viewContext)
        newItem.id = UUID()
        newItem.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        // The author field is hidden for other types, but keeps whatever was typed while a book was selected
        newItem.author = selectedType == .book ? author.trimmingCharacters(in: .whitespacesAndNewlines) : ""
        newItem.recommender = recommender.trimmingCharacters(in: .whitespacesAndNewlines)
        newItem.recommendationDate = recDate
        newItem.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)

        newItem.type = selectedType.description
        do {
            try viewContext.save()
            didSave = true
            name = ""
            author = ""
            recommender = ""
            recDate = Date()
            notes = ""
        } catch {
            print("Failed to save context to CoreData on \(Date())")
            viewContext.rollback()
            saveError = true
        }
    }

    #if DEBUG
    /**
     * Used for creating varying screenshots
     */
    private func onRecommenderChange(_ recommender: String) {
        switch recommender {
        case NSLocalizedString("toy-story-recommender", comment: "Who recommender Toy Story"):
            recDate = daysAgo(21)
        case NSLocalizedString("breaking-bad-recommender", comment: "Who recommender Breaking Bad"):
            recDate = daysAgo(243)
        case NSLocalizedString("star-trek-recommender", comment: "Who recommender Star Trek"):
            recDate = daysAgo(139)
        case NSLocalizedString("parks-and-rec-recommender", comment: "Who recommender Parks and Rec"):
            recDate = daysAgo(90)
        default:
            break
        }
    }

    private func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: Date())!
    }
    #endif
}

#Preview {
    AddRecScreen()
}
