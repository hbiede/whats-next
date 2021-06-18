//
//  AddRecScreen.swift
//  What's Next
//
//  Created by Hundter Biede on 6/17/21.
//

import SwiftUI

struct AddRecScreen: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var selectedType: Type = .movie
    @State private var name: String = ""
    @State private var author: String = ""
    @State private var recommender: String = ""
    @State private var recDate: Date = Date()
    @State private var saveError = false

    @ViewBuilder
    var body: some View {
        Form {
            if saveError {
                Section {
                    Text("Failed to save")
                }
                    .listRowBackground(Color.red.opacity(0.3))
            }
            Section {
                Picker("Type", selection: $selectedType) {
                    ForEach(Type.allCases) {
                        Text($0.description).tag($0)
                    }
                }
                    .pickerStyle(SegmentedPickerStyle())
                if selectedType == .movie {
                    TextField("Movie name", text: $name)
                } else if selectedType == .book {
                    TextField("Book name", text: $name)
                    TextField("Author", text: $author)
                } else {
                    TextField("TV show name", text: $name)
                }
                TextField("Recommended by", text: $recommender)
                DatePicker(
                    "Recommended on",
                    selection: $recDate,
                    displayedComponents: [.date]
                )
            }
            Button("Add", action: confirm)
                .disabled(
                    name.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
                        (selectedType == .book && author.trimmingCharacters(in: .whitespacesAndNewlines) == "") ||
                        recommender.trimmingCharacters(in: .whitespacesAndNewlines) == "")
        }
        .navigationTitle("Add Recommendation")
    }

    func confirm() {
        saveError = false
        let newItem = Item(context: viewContext)
        newItem.name = name
        newItem.author = author
        newItem.recommender = recommender
        newItem.recommendationDate = recDate

        if selectedType == .movie {
            newItem.type = "Movie"
        } else if selectedType == .book {
            newItem.type = "Book"
        } else {
            newItem.type = "TV Show"
        }
        do {
            try viewContext.save()
            name = ""
            author = ""
            recommender = ""
            recDate = Date()
        } catch {
            print("Failed to save context to CoreData on \(Date())")
            saveError = true
        }
    }
}

struct AddRecScreen_Previews: PreviewProvider {
    static var previews: some View {
        AddRecScreen()
    }
}
