//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Mark Balikoti on 19.05.2024.
//

import Foundation
import UIKit
final class AlertPresenter {
    
    func present(view controller: UIViewController, alert model: AlertModel, alertIdentifier: String) {
        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText, style: .default, handler: model.completion)
        alert.addAction(action)
        alert.view.accessibilityIdentifier = "myAlertID"
        controller.present(alert, animated: true, completion: nil)
    }
}
