import UIKit
import CoreData
import SwiftUI

class RouteCollectionViewController: UIViewController {

    // MARK: - Properties

    let managedObjectContext: NSManagedObjectContext

    // MARK: - UI

    let collectionView: UICollectionView = {
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
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.embed(view: collectionView)
        collectionView.delegate = self
        collectionView.dataSource = diffableDataSource

        do {
            try fetchedResultController.performFetch()
        } catch {
            print("Error: \(error)")
        }
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

        guard let identifier = diffableDataSource.itemIdentifier(for: indexPath),
            let route = managedObjectContext.object(with: identifier) as? Route else {
            return
        }

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
        guard let dataSource = collectionView.dataSource as? UICollectionViewDiffableDataSource<Int, NSManagedObjectID> else {
            assertionFailure("The data source has not implemented snapshot support while it should")
            return
        }

        var snapshot = snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>
        let currentSnapshot = dataSource.snapshot() as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>

        let reloadIdentifiers: [NSManagedObjectID] = snapshot.itemIdentifiers.compactMap { itemIdentifier in
            guard let currentIndex = currentSnapshot.indexOfItem(itemIdentifier), let index = snapshot.indexOfItem(itemIdentifier), index == currentIndex else {
                return nil
            }
            guard let existingObject = try? controller.managedObjectContext.existingObject(with: itemIdentifier), existingObject.isUpdated else { return nil }
            return itemIdentifier
        }
        snapshot.reloadItems(reloadIdentifiers)

        dataSource.apply(snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>, animatingDifferences: true)
        

    }
}

// MARK: - UI Factory Methods

extension RouteCollectionViewController {

    /// Composed Layout Factory
    ///
    /// Provides a composition of Start/Waypoint/End Section Layouts and their respective configurations
    static func createLayout() -> UICollectionViewLayout {
        let sectionProvider =
        {(sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            NSCollectionLayoutSection.list(
                using: makeWaypointSectionListConfiguration(),
                layoutEnvironment: layoutEnvironment
            )
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }

    /// Waypoint SectionConfiguration Factory
    ///
    /// Provides section configuration handlers for cell separators and swipe action handling
    static func makeWaypointSectionListConfiguration() -> UICollectionLayoutListConfiguration {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)

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
