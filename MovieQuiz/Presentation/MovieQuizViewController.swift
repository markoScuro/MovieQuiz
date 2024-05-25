import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    // инициализируем делегаты и статистику
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var statisticService: StatisticService  = StatisticServiceImplementation()
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    
    private let questionsAmount: Int = 10
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
        
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
   
// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let questionFactory = QuestionFactory()
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory
        questionFactory.requestNextQuestion()
       
    }
        
// MARK: - QuestionFactoryDelegate

    // показываем статус-бар
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // указываем кнопки
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        self.yesButton.isEnabled = !self.yesButton.isEnabled
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.yesButton.isEnabled = !self.yesButton.isEnabled
        }
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        self.noButton.isEnabled = !self.noButton.isEnabled
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.noButton.isEnabled = !self.noButton.isEnabled
        }
    }
    
    // конвертируем данные вопросов в модель
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    // окрашиваем рамку при фиксации ответов
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            showNextQuestionOrResults()
        }
        
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(title: result.title,
                                      message: result.text,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory.requestNextQuestion()
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    // показать результаты игры со статистикой
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let currentRecord = "\(statisticService.bestGame.correct)/\(statisticService.bestGame.total)"
            let totalCount = "\(statisticService.gamesCount)"
            let recordTime = statisticService.bestGame.date.dateTimeString
            let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
            
            let text = "Ваш результат: \(correctAnswers)/\(questionsAmount)\nКоличество сыгранных квизов: \(totalCount)\nРекорд: \(currentRecord) (\(recordTime))\nСредняя точность: \(accuracy)%"
            
            let alertModel = AlertModel(title: "Этот раунд окончен!",
                                        message: text,
                                        buttonText: "Сыграть ещё раз") { [weak self] in
                guard let self = self else { return }
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory.requestNextQuestion()
            }
            let alertPresenter = AlertPresenter()
            alertPresenter.delegate = self
            self.alertPresenter = alertPresenter
            alertPresenter.show(quiz: alertModel)
        } else {
            currentQuestionIndex += 1
            questionFactory.requestNextQuestion()
        }
        
    }

}
