import UIKit
import CoreData
import SwiftUI

class StopCollectionViewController: UIViewController {

    // MARK: - Properties

    let managedObjectContext: NSManagedObjectContext
    let route: Route

    // MARK: - UI

    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createLayout()
        )

        let longPressGesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(self.handleLongGesture(gesture:))
        )
        collectionView.addGestureRecognizer(longPressGesture)
        self.longPressGesture = longPressGesture


        return collectionView
    }()

    fileprivate var longPressGesture: UILongPressGestureRecognizer?

    // MARK: - DataSources

    /// Diffable DataSource directing dequing/configuration of cells
    ///

    func makeCellRegistration() -> UICollectionView.CellRegistration<StopCell, Stop> {
        UICollectionView.CellRegistration<StopCell, Stop> { [unowned self] cell, indexPath, stop in

            // Configure Cell
            cell.configure(stop: stop, parent: self)

            // Enable Reorder/Delete Accessories
            cell.accessories = [
                .reorder(),
                .delete(),
            ]
        }
    }

    lazy var diffableDataSource: UICollectionViewDiffableDataSource<Int, NSManagedObjectID> = {

        let cellRegistration = makeCellRegistration()

        var dataSource = UICollectionViewDiffableDataSource<Int, NSManagedObjectID>(
            collectionView: collectionView
        ) { [unowned self] collectionView, indexPath, objectID -> UICollectionViewCell? in


            guard let stop = managedObjectContext.object(with: objectID) as? Stop else {
                return nil
            }

            return collectionView.dequeueConfiguredReusableCell(
                using:  cellRegistration,
                for: indexPath,
                item: stop
            )
        }

        dataSource.reorderingHandlers.canReorderItem = { item in
            return true
        }

        // Connect BackingStore Updates
        dataSource.reorderingHandlers.didReorder = { [weak self] transaction in
            self?.handleReorder(transaction)
        }
        
        // TODO: - Additional Configurations
        return dataSource
    }()

    func handleReorder(_ transaction: (NSDiffableDataSourceTransaction<Int, NSManagedObjectID>)) {

        // Recalculate Indices on background Context
        DispatchQueue
            .global(qos: .userInitiated)
            .async { [managedObjectContext] in
                let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                context.parent = managedObjectContext
                context.automaticallyMergesChangesFromParent = true
                context.perform {
                    transaction
                        .finalSnapshot
                        .itemIdentifiers
                        .compactMap { objectID in
                            context.object(with: objectID) as? Stop
                        }
                        .enumerated()
                        .forEach { (index, stop) in
                            stop.index = Int64(index)
                        }

                    // Merge with parent
                    try? context.save()
            }
        }
    }

    lazy var fetchedResultController: NSFetchedResultsController<Stop>  = {


        let fetchRequest: NSFetchRequest<Stop> = Stop.fetchRequest()

        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Stop.index, ascending: true)
        ]

        fetchRequest.predicate = NSPredicate(format: "parent == %@", route)

        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self

        return controller
    }()

    // MARK: - View Lifecycle

    init(_ managedObjectContext: NSManagedObjectContext, route: Route) {
        self.managedObjectContext = managedObjectContext
        self.route = route
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.embed(view: collectionView)
        collectionView.delegate = self
        collectionView.dataSource = diffableDataSource

        let add = UIBarButtonItem(
            title: "Add",
            image: UIImage(systemName: "plus"),
            primaryAction: UIAction { [unowned self] action in
                self.addItem()
            }
        )

        self.navigationItem.rightBarButtonItems = [editButtonItem, add]
        
        do {
            try fetchedResultController.performFetch()
        } catch {
            print("Error: \(error)")
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        collectionView.isEditing = editing
    }
}

// MARK: - Types

extension StopCollectionViewController {
    enum Section {
        case main
    }
}

// MARK: - UICollectionViewDelegate

extension StopCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

// MARK: - FetchResultsControllerDelegate

extension StopCollectionViewController: NSFetchedResultsControllerDelegate {
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference
    ) {
        let diffableSnapshot = snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>
        diffableDataSource.apply(diffableSnapshot)
    }
}

// MARK: - UI Factory Methods

extension StopCollectionViewController {

    /// Composed Layout Factory
    ///
    /// Provides a composition of Start/Waypoint/End Section Layouts and their respective configurations
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider =
        { [unowned self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            NSCollectionLayoutSection.list(
                using: self.makeWaypointSectionListConfiguration(),
                layoutEnvironment: layoutEnvironment
            )
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }

    /// Waypoint SectionConfiguration Factory
    ///
    /// Provides section configuration handlers for cell separators and swipe action handling
    func makeWaypointSectionListConfiguration() -> UICollectionLayoutListConfiguration {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)

        config.trailingSwipeActionsConfigurationProvider = { [unowned self] indexPath in

            let deleteAction = UIContextualAction(
                style: .destructive,
                title: NSLocalizedString("Dekete", comment: ""),
                handler: { _, _, completion in

                    defer { completion(true) }

                    guard let identifier = diffableDataSource.itemIdentifier(for: indexPath),
                          let route = managedObjectContext.object(with: identifier) as? Stop else {
                              return
                          }

                    self.managedObjectContext.delete(route)
                    self.trySave()
                }
            )

            return UISwipeActionsConfiguration(actions: [
                deleteAction,
            ])
        }

        // TODO: Configure Swipe Actions Here
        return config
    }
}

// MARK: - IBActions

extension StopCollectionViewController {

    private func trySave() {
        do {
            try managedObjectContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    /// Long Gesture Handler
    ///
    /// Detects long press gestures allowing for direct movement of cells and animations vs putting the collection in edit mode
    @objc
    func handleLongGesture(gesture: UILongPressGestureRecognizer) {

        // Confirm View Exists
        guard let gestureView = gesture.view else { return }

        // Forward message to appropriate CollectionView Handler
        switch gesture.state {

        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView))
            else {
                break
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gestureView))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }

    }

    private func addItem() {

        // Construct Object
        let newItem = Stop(context: managedObjectContext)
        newItem.street = UUID().uuidString
        newItem.city = UUID().uuidString
        newItem.updatedAt = Date()
        newItem.createdAt = Date()

        // Assume Append at end
        let index: Int = route.stops?.count ?? 0
        newItem.index = Int64(index)

        route.addToStops(newItem)

        trySave()
    }


}

// MARK: - SwiftUI Representable

struct StopCollectionViewControllerRepresentable: UIViewControllerRepresentable {
    @Environment(\.managedObjectContext) private var viewContext
    let route: Route

    func makeUIViewController(context: StopCollectionViewControllerRepresentable.Context) -> StopCollectionViewController {
        StopCollectionViewController(viewContext, route: route)
    }

    func updateUIViewController(_ uiViewController: StopCollectionViewController, context: Context) {}
}
