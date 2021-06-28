//
//  AddRecScreen.swift
//  What's Next
//
//  Created by Hundter Biede on 6/17/21.
//

import SwiftUI

struct AddRecScreen: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var selectedType: RecType = .movie
    @State private var name: String = ""
    @State private var author: String = ""
    @State private var recommender: String = ""
    @State private var recDate: Date = Date()
    @State private var notes: String = ""

    @State private var didSave = false
    @State private var saveError = false

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
                itemFormatter.string(from: Date()) == itemFormatter.string(from: recDate) &&
                notes == "" {
                Section {
                    Text("success-saved-message", comment: "Message for when an entry is successfully added")
                }
                    .listRowBackground(Color.green.opacity(0.3))
            } else if saveError &&
                        name == "" &&
                        author == "" &&
                        recommender == "" &&
                        (Date(), formatter: itemFormatter) == (recDate, formatter: itemFormatter) &&
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
                        (selectedType == .book && author.trimmingCharacters(in: .whitespacesAndNewlines) == "") ||
                        recommender.trimmingCharacters(in: .whitespacesAndNewlines) == "")
        }
        .navigationTitle("add-rec-screen-title")
    }

    private func confirm() {
        saveError = false
        didSave = false
        let newItem = Item(context: viewContext)
        newItem.id = UUID()
        newItem.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        newItem.author = author.trimmingCharacters(in: .whitespacesAndNewlines)
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
            saveError = true
        }
    }

    #if DEBUG
    private func onRecommenderChange(_ recommender: String) {
        switch recommender {
        case "Keiko":
            recDate = ISO8601DateFormatter().date(from: "2021-06-24T10:00:00+0000")!
        case "Adam":
            recDate = ISO8601DateFormatter().date(from: "2019-09-14T10:00:00+0000")!
        case "Elijah":
            recDate = ISO8601DateFormatter().date(from: "2020-05-29T10:00:00+0000")!
        case "Alex":
            recDate = ISO8601DateFormatter().date(from: "2020-10-17T10:00:00+0000")!
        default:
            break
        }
    }
    #endif
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter
}()

struct AddRecScreen_Previews: PreviewProvider {
    static var previews: some View {
        AddRecScreen()
    }
}
