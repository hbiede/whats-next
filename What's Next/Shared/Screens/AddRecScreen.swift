//
//  AddRecScreen.swift
//  What's Next
//
//  Created by Hundter Biede on 6/17/21.
//

import SwiftUI

struct AddRecScreen: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var selectedType: Type = .Movie
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
                }.listRowBackground(Color.red.opacity(0.3))
            }
            Section {
                Picker("Type", selection: $selectedType) {
                    Text("Movie").tag(Type.Movie)
                    Text("TV Show").tag(Type.TVShow)
                    Text("Book").tag(Type.Book)
                }
                    .pickerStyle(SegmentedPickerStyle())
                if selectedType == .Movie {
                    TextField("Movie name", text: $name)
                } else if selectedType == .Book {
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
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines) == "" || (selectedType == .Book && author.trimmingCharacters(in: .whitespacesAndNewlines) == "") || recommender.trimmingCharacters(in: .whitespacesAndNewlines) == "")
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

        if selectedType == .Movie {
            newItem.type = "Movie"
        } else if selectedType == .Book {
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
