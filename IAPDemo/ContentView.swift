//
//  ContentView.swift
//  IAPDemo
//
//  Created by Ahmad Qureshi on 05/05/23.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject private var vm = ViewModel()
    var body: some View {
        ZStack {
            VStack {
                Text("Demo In-App purchase Paywall")
                    .foregroundColor(.blue)
                    .font(.largeTitle)
                Spacer()
                Button {
                    vm.purchaseProduct()
                } label: {
                    if let product = vm.products.first {
                        Text("\(product.title ?? product.productIdentifier) only at \(product.localizedCurrencyPrice)")
                            .foregroundColor(.white)
                            .padding(.all, 16)
                            .background( .blue)
                            .cornerRadius(10)
                            .padding(.bottom, 10)
                    }
                }
                
                Button {
                    vm.restorePurhcase()
                } label: {
                    Text("Restore purhcase")
                        .foregroundColor(.blue)
                }

            }
        }
        .onAppear {
            vm.fetchProducts()
            vm.handleAlerts()
        }
        .alert(vm.alertMessage, isPresented: $vm.showSuccessAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
