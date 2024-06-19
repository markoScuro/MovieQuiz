//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Mark Balikoti on 19.05.2024.
//

import UIKit

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer() // сообщение об успешной загрузке
    func didFailToLoadData(with error: Error) // сообщение об ошибке загрузки
}
