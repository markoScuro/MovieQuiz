//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Mark Balikoti on 19.05.2024.
//


import UIKit
import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    var completion: ((UIAlertAction) -> Void)?
}
