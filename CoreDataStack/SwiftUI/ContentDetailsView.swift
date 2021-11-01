//
//  ContentDetailsView.swift
//  CoreDataStack
//
//  Created by loaner on 10/26/21.
//

import SwiftUI
import CoreData


extension ContentDetailsView {
    init(route: Route) {
        self.route = route
        _items = FetchRequest(
            entity: Stop.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Stop.index, ascending: true),
            ],
            predicate: NSPredicate(format: "parent == %@", route),
            animation: .default
        )
    }
}

struct ContentDetailsView: View {

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest
    var items: FetchedResults<Stop>

    @ObservedObject
    var route: Route

    var body: some View {

        VStack {

            // Use Stops which provides ordering
            List {
                ForEach(items, id: \.self) { stop in
                    StopCellView(stop: stop)
                }
                .onMove(perform: moveItems)
                .onDelete(perform: deleteItems)
            }
            .listStyle(PlainListStyle())
        }

        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: loadRemoteRoutes) {
                    Image(systemName: "arrow.clockwise")
                }
            }
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
            newItem.updatedAt = Date()
            newItem.createdAt = Date()

            let index: Int = items.count
            newItem.index = Int64(index)

            // Set Ordered Relationship (NSOrderedSet takes care of appended ordering)
            route.addToStops(newItem)

            trySave()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {

            let stops = items.map { $0 }
            offsets
                .compactMap { stops[$0] }
                .forEach(viewContext.delete)

            trySave()
        }
    }

    private func moveItems(source: IndexSet, to destination: Int) {

        var stops = items.map { $0 }
        stops.move(fromOffsets: source, toOffset: destination)
        stops.enumerated().forEach { (index, stop) in
            stop.index = Int64(index)
        }
        trySave()
    }

    private func loadRemoteRoutes() {

        // TODO: - Perform Async Remote Loading
        DispatchQueue.global().async {


            // Remove existing stops, replace with updated values
            let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            context.parent = viewContext

            guard let route = context.object(with: route.objectID) as? Route else {
                return
            }

            // Mock Handle a chanced application of either prefixing street number or removing to show
            // animated handling

            route.stops?
                .compactMap { $0 as? Stop }
                .forEach { stop in

                    // Randomize handling
                    if Bool.random() {
                        stop.street = "1" + (stop.street ?? "")
                    } else {
                        context.delete(stop)
                    }
                }

            do {
                try context.save()

                // Sync to disk
                DispatchQueue.main.async { trySave() }
            } catch {
                print("Dane - error \(error)")
            }
        }
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
