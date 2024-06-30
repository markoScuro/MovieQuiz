//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Mark Balikoti on 25.06.2024.
//

import Foundation
protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showNetworkError(message: String, errorCompletion: @escaping () -> Void)
    func setUIElementsHidden(_ hidden: Bool)
}
