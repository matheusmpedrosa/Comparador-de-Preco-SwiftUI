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
    
    public var id: String { rawValue }
}

struct ContentView: View {
    @State private var quantityA = String()
    @State private var priceA = String()
    @State private var unitA: MeasurementUnit = .miligram
    
    @State private var quantityB = String()
    @State private var priceB = String()
    @State private var unitB: MeasurementUnit = .miligram
    
    @State private var showAlert = false
    @State private var result: Alerts = .equal
    
    var body: some View {
        Text("Comparador de preços")
            .font(.title)
        VStack(alignment: .leading) {
            Text("Produto 1")
                .font(.headline)
            HStack(alignment: .top) {
                VStack {
                    TextField("mg, g, kg, mL, L", text: $quantityA)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                    Text("Quantidade")
                        .font(.caption)
                    Picker("Defina a unidade de medida", selection: $unitA) {
                        ForEach(MeasurementUnit.allCases) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
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
            HStack(alignment: .top) {
                VStack {
                    TextField("mg, g, kg, mL, L", text: $quantityB)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .font(.caption)
                    Text("Quantidade")
                    Picker("Defina a unidade de medida", selection: $unitB) {
                        ForEach(MeasurementUnit.allCases) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
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
            let priceA = changeComaToDotIn(priceA)
            let priceB = changeComaToDotIn(priceB)
            let quantityA = changeComaToDotIn(quantityA)
            let quantityB = changeComaToDotIn(quantityB)
            
            guard let doublePriceA = Double(priceA) else {
                result = .firstPriceError
                showAlert = true
                return
            }
            guard let doubleQuantityA = Double(quantityA) else {
                result = .firstQuantityError
                showAlert = true
                return
            }
            guard let doublePriceB = Double(priceB) else {
                result = .secondPriceError
                showAlert = true
                return
            }
            guard let doubleQuantityB = Double(quantityB) else {
                result = .secondQuantityError
                showAlert = true
                return
            }
            
            let productA = Product(measurement: Measurement(unit: unitA, quantity: doubleQuantityA), price: doublePriceA)
            let productB = Product(measurement: Measurement(unit: unitB, quantity: doubleQuantityB), price: doublePriceB)
            
            didTapCalculateButton(productA: productA, productB: productB)
            dismissKeyboard()
        }
        .buttonStyle(.borderedProminent)
        .alert(result.title, isPresented: $showAlert) {
            Button(result.buttonTitle, role: .cancel) {
            }
        }
        Button("Limpar") {
            quantityA = ""
            priceA = ""
            unitA = .miligram
            quantityB = ""
            priceB = ""
            unitB = .miligram
            dismissKeyboard()
        }
    }
    
    private func didTapCalculateButton(productA: Product, productB: Product) {
        switch measurementUnitsMatch(productA: productA, productB: productB) {
        case .success(_):
            let products = normalizeScale(productA: productA, productB: productB)
            result = calculateBestOption(productA: products.0, productB: products.1)
        case .failure(let alert):
            result = alert
        }
        showAlert = true
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func measurementUnitsMatch(productA: Product, productB: Product) -> Result<Bool, Alerts> {
        switch productA.measurement.unit {
        case .miligram, .gram, .kilogram:
            switch productB.measurement.unit {
            case .miligram, .gram, .kilogram:
                return .success(true)
            case .mililiter, .liter:
                return .failure(.firstMassSecondVolumeError)
            }
        case .mililiter, .liter:
            switch productB.measurement.unit {
            case .miligram, .gram, .kilogram:
                return .failure(.firstVolumeSecondMassError)
            case .mililiter, .liter:
                return .success(true)
            }
        }
    }
    
    private func normalizeScale(productA: Product, productB: Product) -> (Product, Product) {
        var productB = productB
        
        switch productA.measurement.unit {
        case .miligram:
            switch productB.measurement.unit {
            case .gram:
                productB.measurement.quantity = productB.measurement.quantity * 1000
            case .kilogram:
                productB.measurement.quantity = productB.measurement.quantity * 1000000
            case .miligram, .mililiter, .liter:
                break
            }
        case .gram:
            switch productB.measurement.unit {
            case .miligram:
                productB.measurement.quantity = productB.measurement.quantity / 1000
            case .kilogram:
                productB.measurement.quantity = productB.measurement.quantity / 1000000
            case .gram, .mililiter, .liter:
                break
            }
        case .kilogram:
            switch productB.measurement.unit {
            case .miligram:
                productB.measurement.quantity = productB.measurement.quantity / 1000000
            case .gram:
                productB.measurement.quantity = productB.measurement.quantity / 1000
            case .kilogram, .mililiter, .liter:
                break
            }
        case .mililiter:
            switch productB.measurement.unit {
            case .liter:
                productB.measurement.quantity = productB.measurement.quantity * 1000
            case .miligram, .gram, .kilogram, .mililiter:
                break
            }
        case .liter:
            switch productB.measurement.unit {
            case .mililiter:
                productB.measurement.quantity = productB.measurement.quantity / 1000
            case .miligram, .gram, .kilogram, .liter:
                break
            }
        }
        return (productA, productB)
    }
    
    private func calculateBestOption(productA: Product, productB: Product) -> Alerts {
        
        let pricePerUnit1 = productA.price / productA.measurement.quantity
        let pricePerUnit2 = productB.price / productB.measurement.quantity
        
        if pricePerUnit1 < pricePerUnit2 {
            return .firstHasAdvantage
        } else if pricePerUnit1 > pricePerUnit2 {
            return .secondHasAdvantage
        } else {
            return .equal
        }
    }
    
    private func changeComaToDotIn(_ string: String) -> String {
        return string.replacingOccurrences(of: ",", with: ".")
    }
}

#Preview {
    ContentView()
}
