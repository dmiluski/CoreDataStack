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

    /// Modal Presentation of UIKit variation of interacting with this data
    @State
    var isPresenting: Bool = false

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { route in
                    NavigationLink {
                        ContentDetailsView(route: route)
                    } label: {
                        RouteCellView(route: route)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .listStyle(PlainListStyle())
            .navigationTitle(Text("Routes"))
            .toolbar {

                // Nav Bar
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: loadRemoteRoutes) {
                        Image(systemName: "arrow.clockwise")
                    }
                }

                ToolbarItemGroup(placement: .navigationBarTrailing) {

                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                    EditButton()
                }

                // Bottom Toolbar
                ToolbarItemGroup(placement: .bottomBar) {

                    Button(action: {
                        withAnimation {
                            items.forEach(viewContext.delete(_:))
                        }
                    }){
                        Image(systemName: "trash")
                    }

                    Spacer()

                    Button(action: {
                        isPresenting.toggle()
                    }) {
                        Label("Present UIKit Variant", systemImage: "square.and.arrow.up")
                    }
                }
                ToolbarItem(placement: .bottomBar) {

                }
            }
            .sheet(isPresented: $isPresenting) {
                NavigationViewControllerRepresentable(rootViewController: RouteCollectionViewController(viewContext))
                    .environment(\.managedObjectContext, viewContext)
                    .ignoresSafeArea()
            }
        }
    }

    // MARK: - Actions

    private func loadRemoteRoutes() {

        // TODO: - Perform Async Remote Loading
        DispatchQueue
            .global()
            .asyncAfter(deadline: .now() + 2) {

                let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                context.parent = viewContext

                guard let lastRoute = items.last else {
                    return
                }

                let route = context.object(with: lastRoute.objectID)

                context.delete(route)

                do {
                    try context.save()

                    // Save to disk
                    DispatchQueue.main.async(execute: trySave)
                } catch {
                    print("Dane - error: \(error)")
                }

            }
    }

    private func addItem() {
        withAnimation {
            let newItem = Route(context: viewContext)
            newItem.timestamp = Date()
            newItem.displayableName = String(UUID().uuidString.prefix(5))
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
