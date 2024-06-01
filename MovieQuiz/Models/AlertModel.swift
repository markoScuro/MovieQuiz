//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Mark Balikoti on 19.05.2024.
//

import UIKit

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: (() -> Void)
}
