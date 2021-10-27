//
//  ContentDetailsView.swift
//  CoreDataStack
//
//  Created by loaner on 10/26/21.
//

import SwiftUI
import CoreData


struct ContentDetailsView: View {

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest
    var items: FetchedResults<Stop>

    @ObservedObject
    var route: Route

    /// Ordered Stops
    var stops: [Stop] {
        let stops = route.stops?.array as? [Stop] ?? []
        return stops
    }

    var body: some View {

        List {
            ForEach(Array(stops.enumerated()), id: \.element.self) { offset, item in
                StopCellView(viewModel: StopCellView.ViewModel(index: offset, stop: item))
            }
            .onMove(perform: moveItems)
            .onDelete(perform: deleteItems)
        }
        .toolbar {
            ToolbarItem {
                Button(action: addItem) {
                    Label("Add Item", systemImage: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
    }

    // MARK: - IBActions

    private func addItem() {
        withAnimation {

            // Construct Object
            let newItem = Stop(context: viewContext)
            newItem.street = UUID().uuidString
            newItem.city = UUID().uuidString

            // Set Ordered Relationship (NSOrderedSet takes care of appended ordering)
            route.addToStops(newItem)

            trySave()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {

            offsets
                .compactMap { route.stops?.array[$0] as? Stop }
                .forEach(viewContext.delete)

            trySave()
        }
    }

    private func moveItems(source: IndexSet, to destination: Int) {

        guard var stops = route.stops?.array else {
            return
        }

        // Apply Move
        stops.move(fromOffsets: source, toOffset: destination)

        // Update
        route.stops = NSOrderedSet(array: stops)

        trySave()

    }

    // MARK: - Peristence

    private func trySave() {
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
