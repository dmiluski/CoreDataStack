//
//  ContentView.swift
//  CoreDataStack
//
//  Created by loaner on 10/26/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Route.timestamp, ascending: true)],
        animation: .default)

    private var items: FetchedResults<Route>

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { route in
                    NavigationLink {
                        ContentDetailsView(
                            items: FetchRequest(
                                entity: Stop.entity(),
                                sortDescriptors: [
                                ],
                                predicate: NSPredicate(format: "parent == %@", route),
                                animation: .default
                            ),
                            route: route
                        )
                    } label: {
                        Text(route.timestamp!, formatter: itemFormatter)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private func addItem() {
        withAnimation {
            let newItem = Route(context: viewContext)
            newItem.timestamp = Date()
            trySave()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            trySave()
        }
    }

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

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
