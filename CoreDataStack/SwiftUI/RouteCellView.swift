//
//  RouteCellView.swift
//  CoreDataStack
//
//  Created by loaner on 10/27/21.
//

import SwiftUI

struct RouteCellView: View {

    let route: Route

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                if let name = route.name {
                    Text(name)
                }

                Text(route.timestamp!, formatter: itemFormatter)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
