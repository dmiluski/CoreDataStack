//
//  StopCellView.swift
//  CoreDataStack
//
//  Created by loaner on 10/26/21.
//

import SwiftUI

struct StopCellView: View {

    @ObservedObject
    var stop: Stop

    var body: some View {
        HStack {
            Text("\(stop.index).")
                .frame(width: 24)
                .animation(nil)

            VStack(alignment: .leading) {
                Text(stop.street?.prefix(10) ?? "")

                Text(stop.city?.prefix(10) ?? "")
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
    }
}
