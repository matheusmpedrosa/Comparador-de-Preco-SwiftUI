//
//  Alerts.swift
//  Comparador de Preco-SwiftUI
//
//  Created by Matheus Malcher Pedrosa on 03/01/25.
//

import Foundation

protocol Alert {
    var title: String { get }
//    var message: String? { get }
    var buttonTitle: String { get }
}

enum Alerts: Alert, Error {
    //success
    case equal
    case firstHasAdvantage
    case secondHasAdvantage
    
    //error
    case invalidInput
    case unitMismatch

    var title: String {
        switch self {
        case .equal:
            return "Não existe vantagem de um sobre o outro. Escolha o que faz mais sentido para você!"
        case .firstHasAdvantage:
            return "O produto 1 é mais vantajoso."
        case .secondHasAdvantage:
            return "O produto 2 é mais vantajoso."
        case .invalidInput:
            return "Existe algum problema com os valores inseridos."
        case .unitMismatch:
            return "As unidades de medida não são do mesmo tipo."
        }
    }
    
    var buttonTitle: String {
        return "Fechar"
    }
}
