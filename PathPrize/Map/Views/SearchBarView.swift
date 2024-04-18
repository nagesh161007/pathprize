//
//  SearchBarView.swift
//  PathPrize
//
//  Created by Babuaravind Gururaj on 4/23/24.
//

import SwiftUI

struct SearchBarView: View {
    
    @Binding var search: String
    @Binding var isSearching: Bool
    
    var body: some View {
        VStack(spacing: -10) {
            TextField("Search", text: $search)
                .textFieldStyle(.roundedBorder)
                .padding()
                .onSubmit {
                    isSearching = true
                }
            SearchOptionsView { searchOption in
                search = searchOption
                isSearching = true
            }
            .padding([.leading], 10)
            .padding([.bottom], 20)
        }
    }
}

#Preview {
    SearchBarView(search: .constant("Coffee"), isSearching: .constant(true))
}
