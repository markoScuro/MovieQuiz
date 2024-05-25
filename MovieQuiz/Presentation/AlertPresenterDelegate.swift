//
//  AlertPresenterDelegate.swift
//  MovieQuiz
//
//  Created by Mark Balikoti on 24.05.2024.
//

import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
}

