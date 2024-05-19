//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Mark Balikoti on 19.05.2024.
//

import Foundation
import UIKit

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)    
}
