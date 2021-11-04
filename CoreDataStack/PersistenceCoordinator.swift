//
//  PersistenceCoordinator.swift
//  CoreDataStack
//
//  Created by loaner on 11/3/21.
//

import Foundation
import CoreData
import Combine

// Observes ChildContext Saves to persist changes to disk
class PersistenceCoordinator {

    let persistenceController: PersistenceController
    let notificationCenter: NotificationCenter
    private var cancellable: AnyCancellable?


    init(
        persistenceController: PersistenceController = PersistenceController.shared,
        notificationCenter: NotificationCenter = NotificationCenter.default
    ) {
        self.persistenceController = persistenceController
        self.notificationCenter = notificationCenter

        // Setup DidSave Observation
        cancellable = notificationCenter
            .publisher(for: .NSManagedObjectContextDidSave, object: nil)
            .sink { [weak self] notification in
                self?.onManagedObjectSave(notification: notification)
            }

    }

    /// Observe Background Changes merged with Main Context that need to be saved to disk
    private func onManagedObjectSave(notification: Notification) {

        // Extract Context
        guard let context = notification.object as? NSManagedObjectContext else {
            return
        }

        // If save was triggered by a child of this context
        if context.parent == persistenceController.container.viewContext {
            try? persistenceController.container.viewContext.save()
        }
    }
}
