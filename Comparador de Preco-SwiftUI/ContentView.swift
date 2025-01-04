//
//  ContentView.swift
//  Comparador de Preco-SwiftUI
//
//  Created by Matheus Malcher Pedrosa on 02/01/25.
//

import SwiftUI

struct Product {
    var measurement: Measurement
    var price: Double
}

struct Measurement {
    var unit: MeasurementUnit
    var quantity: Double
}

enum MeasurementUnit: String, CaseIterable, Identifiable {
    case miligram = "mg"
    case gram = "g"
    case kilogram = "kg"
    case mililiter = "mL"
    case liter = "L"
    
    var id: String { rawValue }
    
    var conversionFactor: Double {
        switch self {
        case .miligram: return 0.001
        case .gram: return 1.0
        case .kilogram: return 1000.0
        case .mililiter: return 1.0
        case .liter: return 1000.0
        }
    }
    
    var isMass: Bool {
        self == .miligram || self == .gram || self == .kilogram
    }
    
    var isVolume: Bool {
        self == .mililiter || self == .liter
    }
}

struct ContentView: View {
    @State private var quantityA = ""
    @State private var priceA = ""
    @State private var unitA: MeasurementUnit = .miligram
    
    @State private var quantityB = ""
    @State private var priceB = ""
    @State private var unitB: MeasurementUnit = .miligram
    
    @State private var showAlert = false
    @State private var result: Alerts = .equal
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Comparador de preços")
                .font(.title)
            
            productInputView(title: "Produto 1", quantity: $quantityA, price: $priceA, unit: $unitA)
            productInputView(title: "Produto 2", quantity: $quantityB, price: $priceB, unit: $unitB)
            
            Button("Calcular") {
                calculate()
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .alert(result.title, isPresented: $showAlert) {
                Button(result.buttonTitle, role: .cancel) {}
            }
            
            Button("Limpar") {
                clearFields()
            }
        }
        .padding()
        .onTapGesture { dismissKeyboard() }
    }
    
    @ViewBuilder
    private func productInputView(title: String,
                                  quantity: Binding<String>,
                                  price: Binding<String>,
                                  unit: Binding<MeasurementUnit>) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            HStack(alignment: .top) {
                VStack {
                    TextField("Quantidade", text: quantity)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                    Picker("Unidade", selection: unit) {
                        ForEach(MeasurementUnit.allCases) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                VStack {
                    TextField("Preço (R$)", text: price)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                }
            }
        }
    }
    
    private func calculate() {
        guard
            let quantity1 = Double(quantityA.replacingOccurrences(of: ",", with: ".")),
            let price1 = Double(priceA.replacingOccurrences(of: ",", with: ".")),
            let quantity2 = Double(quantityB.replacingOccurrences(of: ",", with: ".")),
            let price2 = Double(priceB.replacingOccurrences(of: ",", with: "."))
        else {
            result = .invalidInput
            showAlert = true
            return
        }
        
        let productA = Product(measurement: Measurement(unit: unitA, quantity: quantity1), price: price1)
        let productB = Product(measurement: Measurement(unit: unitB, quantity: quantity2), price: price2)
        
        guard unitA.isMass == unitB.isMass || unitA.isVolume == unitB.isVolume else {
            result = .unitMismatch
            showAlert = true
            return
        }
        
        let normalizedA = normalize(product: productA)
        let normalizedB = normalize(product: productB)
        
        result = compareProducts(productA: normalizedA, productB: normalizedB)
        showAlert = true
    }
    
    private func normalize(product: Product) -> Product {
        let baseQuantity = product.measurement.quantity * product.measurement.unit.conversionFactor
        return Product(measurement: Measurement(unit: product.measurement.unit, quantity: baseQuantity), price: product.price)
    }
    
    private func compareProducts(productA: Product, productB: Product) -> Alerts {
        let pricePerUnitA = productA.price / productA.measurement.quantity
        let pricePerUnitB = productB.price / productB.measurement.quantity
        
        if pricePerUnitA < pricePerUnitB {
            return .firstHasAdvantage
        } else if pricePerUnitA > pricePerUnitB {
            return .secondHasAdvantage
        } else {
            return .equal
        }
    }
    
    private func clearFields() {
        quantityA = ""
        priceA = ""
        unitA = .miligram
        quantityB = ""
        priceB = ""
        unitB = .miligram
        dismissKeyboard()
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    ContentView()
}
