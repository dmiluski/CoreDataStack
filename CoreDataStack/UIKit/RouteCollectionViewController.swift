import UIKit
import CoreData
import SwiftUI

class RouteCollectionViewController: UIViewController {

    // MARK: - Properties

    let managedObjectContext: NSManagedObjectContext

    // MARK: - UI

    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createLayout()
        )
        return collectionView
    }()


    // MARK: - DataSources

    /// Diffable DataSource directing dequing/configuration of cells
    ///

    func makeCellRegistration() -> UICollectionView.CellRegistration<RouteCell, Route> {

        UICollectionView.CellRegistration<RouteCell, Route> { [unowned self] cell, indexPath, value in
            cell.configure(with: value, parent: self)
            cell.accessories = [
                .delete(),
            ]
        }
    }

    lazy var diffableDataSource: UICollectionViewDiffableDataSource<Int, NSManagedObjectID> = {

        let cellRegistration = makeCellRegistration()

        var dataSource = UICollectionViewDiffableDataSource<Int, NSManagedObjectID>(
            collectionView: collectionView
        ) { collectionView, indexPath, objectID -> UICollectionViewCell? in

            guard let object = try? self.managedObjectContext.existingObject(with: objectID) as? Route else {
                return nil
            }

            return collectionView.dequeueConfiguredReusableCell(
                using:  cellRegistration,
                for: indexPath,
                item: object
                )
        }
        
        // TODO: - Additional Configurations
        return dataSource
    }()

    lazy var fetchedResultController: NSFetchedResultsController<Route>  = {


        let fetchRequest: NSFetchRequest<Route> = Route.fetchRequest()

        // Sort Routes by Timestamp
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Route.timestamp, ascending: true),
        ]

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

    init(_ managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        super.init(nibName: nil, bundle: nil)
        self.title = "UIKit Routes"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.embed(view: collectionView)
        collectionView.delegate = self
        collectionView.dataSource = diffableDataSource


        let delete = UIBarButtonItem(
            systemItem: .trash,
            primaryAction: UIAction { [unowned self] action in
                self.deleteAll()
            }
        )

        let add = UIBarButtonItem(
            title: "Add",
            image: UIImage(systemName: "plus"),
            primaryAction: UIAction { [unowned self] action in
                self.addItem()
            }
        )

        self.navigationItem.rightBarButtonItems = [
            editButtonItem,
            add,
            delete,
        ]

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

extension RouteCollectionViewController {
    enum Section {
        case main
    }
}

// MARK: - UICollectionViewDelegate

extension RouteCollectionViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        guard let items = fetchedResultController.fetchedObjects,
              items.indices.contains(indexPath.row) else {
                  return
              }

        let route = items[indexPath.row]
        let vc = StopCollectionViewController(managedObjectContext, route: route)
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - FetchResultsControllerDelegate

extension RouteCollectionViewController: NSFetchedResultsControllerDelegate {
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference
    ) {
        let diffableSnapshot = snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>
        diffableDataSource.apply(diffableSnapshot)
    }
}

// MARK: - UI Factory Methods

extension RouteCollectionViewController {

    /// Composed Layout Factory
    ///
    /// Provides a composition of Start/Waypoint/End Section Layouts and their respective configurations
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider =
        { [unowned self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            NSCollectionLayoutSection.list(
                using: self.makeStopSectionListConfiguration(),
                layoutEnvironment: layoutEnvironment
            )
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }

    /// Waypoint SectionConfiguration Factory
    ///
    /// Provides section configuration handlers for cell separators and swipe action handling
    func makeStopSectionListConfiguration() -> UICollectionLayoutListConfiguration {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)

        config.trailingSwipeActionsConfigurationProvider = { [unowned self] indexPath in

            let deleteAction = UIContextualAction(
                style: .destructive,
                title: NSLocalizedString("Delete", comment: ""),
                handler: { _, _, completion in

                    defer { completion(true) }

                    guard let identifier = diffableDataSource.itemIdentifier(for: indexPath),
                          let route = managedObjectContext.object(with: identifier) as? Route else {
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

struct RouteCollectiVewControllerRepresentable: UIViewControllerRepresentable {
    @Environment(\.managedObjectContext) private var viewContext

    func makeUIViewController(context: RouteCollectiVewControllerRepresentable.Context) -> RouteCollectionViewController {
        RouteCollectionViewController(viewContext)
    }

    func updateUIViewController(_ uiViewController: RouteCollectionViewController, context: Context) {}
}

// MARK: - IBActions

extension RouteCollectionViewController {

    private func addItem() {
        let newItem = Route(context: managedObjectContext)
        newItem.timestamp = Date()
        newItem.displayableName = String(UUID().uuidString.prefix(5))
        trySave()
    }

    private func deleteAll() {
        let request = Route.fetchRequest()
        let result = try? managedObjectContext.fetch(request)
        result?.forEach { managedObjectContext.delete($0) }
        trySave()
    }

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

}
