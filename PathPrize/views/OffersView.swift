//
//  OffersView.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/26/24.
//

import Foundation
import SwiftUI

struct OffersView: View {
    @State private var offers: [OfferModel] = []
    @State private var searchText: String = ""

    var body: some View {
        NavigationView {
            List(filteredOffers, id: \.id) { offer in
                VStack(alignment: .leading) {
                    Text(offer.name ?? "No Name")
                        .font(.headline)
                    Text(offer.address)
                        .font(.subheadline)
                    if let count = offer.count {
                        Text("Count: \(count)")
                            .foregroundColor(.secondary)
                            .font(.title3)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search Offers")
            .navigationTitle("Offers")
            .task {
                loadOffers()
            }
        }
    }

    private var filteredOffers: [OfferModel] {
        if searchText.isEmpty {
            return offers
        } else {
            return offers.filter { offer in
                (offer.name?.lowercased().contains(searchText.lowercased()) ?? false) ||
                offer.address.lowercased().contains(searchText.lowercased())
            }
        }
    }

    private func loadOffers() {
        print("Loading Offers")
        Task {
            do {
                self.offers = try await OfferService.getOffersByUser()
            } catch {
                print("Error fetching offers: \(error)")
            }
        }
    }
}

