//
//  ContentView.swift
//  Comparador de Preco-SwiftUI
//
//  Created by Matheus Malcher Pedrosa on 02/01/25.
//

import SwiftUI

struct Product {
    var quantity: String
    var price: String
}

struct ContentView: View {
    @State private var quantityA = String()
    @State private var priceA = String()
    @State private var quantityB = String()
    @State private var priceB = String()
    
    @State private var showAlert = false
    @State private var result = String()
    
//    private var tf = TextField("mg, g, kg, mL, L", text: $quantityA)
    
    var body: some View {
        Text("Comparador de preços")
            .font(.title)
        VStack(alignment: .leading) {
            Text("Produto 1")
                .font(.headline)
            HStack {
                VStack {
                    TextField("mg, g, kg, mL, L", text: $quantityA)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                    Text("Quantidade")
                        .font(.caption)
                }
                VStack {
                    TextField("R$", text: $priceA)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                    Text("Preço")
                        .font(.caption)
                }
            }
            Text("Produto 2")
                .font(.headline)
            HStack {
                VStack {
                    TextField("mg, g, kg, mL, L", text: $quantityB)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                    Text("Quantidade")
                        .font(.caption)
                }
                VStack {
                    TextField("R$", text: $priceB)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                    Text("Preço")
                        .font(.caption)
                }
            }
        }
        .padding()
        Button("Calcular") {
            result = calculateBestOption(product1: Product(quantity: quantityA, price: priceA), product2: Product(quantity: quantityB, price: priceB))
            showAlert = true
        }
        .buttonStyle(.borderedProminent)
        .alert(result, isPresented: $showAlert) {
            Button("Fechar", role: .cancel) { }
        }
        Button("Limpar") {
            quantityA = ""
            priceA = ""
            quantityB = ""
            priceB = ""
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    func calculateBestOption(product1: Product, product2: Product) -> String {
        let price1 = product1.price.replacingOccurrences(of: ",", with: ".")
        let price2 = product2.price.replacingOccurrences(of: ",", with: ".")
        
        guard let doublePrice1 = Double(price1) else {
            return "Existe algum problema com o preço do produto 1."
        }
        guard let doubleQuantity1 = Double(product1.quantity) else {
            return "Existe algum problema com a quantidade do produto 1."
        }
        guard let doublePrice2 = Double(price2) else {
            return "Existe algum problema com o preço do produto 2."
        }
        guard let doubleQuantity2 = Double(product2.quantity) else {
            return "Existe algum problema com a quantidade do produto 2."
        }
        let pricePerUnit1 = doublePrice1 / doubleQuantity1
        let pricePerUnit2 = doublePrice2 / doubleQuantity2
        
        if pricePerUnit1 < pricePerUnit2 {
            return "O produto 1 é mais vantajoso."
        } else if pricePerUnit1 > pricePerUnit2 {
            return "O produto 2 é mais vantajoso."
        } else {
            return "Não existe vantagem de um sobre o outro. Escolha o que faz mais sentido para você!"
        }
    }
}

#Preview {
    ContentView()
}
