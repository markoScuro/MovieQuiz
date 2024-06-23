import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate{
    
    // MARK: - IB Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    // MARK: - Private Properties
    
    private var questionFactory: QuestionFactoryProtocol!
    private var statisticService: StatisticService  = StatisticServiceImplementation()
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    
    private let questionsAmount: Int = 10
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var errorAlert = AlertPresenter()
    
    // MARK: - Overrides Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImplementation()
        
        showLoadingIndicator()
        setUIElementsHidden(true)
        activityIndicator.hidesWhenStopped = true
        questionFactory.loadData()
    }
    
    
    // MARK: - Public Methods
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
            self?.setUIElementsHidden(false)
            self?.hideLoadingIndicator()
        }
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        //        showNetworkError(message: error.localizedDescription, errorCompletion: <#() -> Void#>)
        let completion = {[weak self] in
            guard let self else { return }
            self.currentQuestionIndex = 1
            self.correctAnswers = 0
            self.activityIndicator.startAnimating()
            self.questionFactory?.loadData()
        }
        guard let error = error as? NetworkClient.NetworkErrors else {
            return showNetworkError(
                message: error.localizedDescription,
                errorCompletion: completion)
        }
        switch error {
        case .codeError:
            showNetworkError(
                message: error.localizedDescription,
                errorCompletion: completion)
        case .invalidURLError(_):
            showNetworkError(
                message: error.localizedDescription,
                errorCompletion: completion)
        case .loadImageError(_):
            showNetworkError(
                message: error.localizedDescription)
            {[weak self] in self?.questionFactory?.requestNextQuestion()}
        }
    }
    
    func didFailToLoadNextQuestion(with error: Error) {
        
        showImageLoadError(text: error.localizedDescription)
        
    }
    // MARK: - Private Methods
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        yesButton.isEnabled = !self.yesButton.isEnabled
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            yesButton.isEnabled = !self.yesButton.isEnabled
        }
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        noButton.isEnabled = !self.noButton.isEnabled
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            noButton.isEnabled = !self.noButton.isEnabled
        }
    }
    
    private func changeStateButton(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    
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
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        let action = UIAlertAction(
            title: result.buttonText, style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory.requestNextQuestion()
            }
        alert.addAction(action)
        self.present(alert, animated: true, completion: {[weak self] in
            self?.questionFactory.loadData()})
    }
    
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let currentRecord = "\(statisticService.bestGame.correct)/\(statisticService.bestGame.total)"
            let totalCount = "\(statisticService.gamesCount)"
            let recordTime = statisticService.bestGame.date.dateTimeString
            let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
            let text = """
Ваш результат: \(correctAnswers)/\(questionsAmount)
Количество сыгранных квизов: \(totalCount)
Рекорд: \(currentRecord) (\(recordTime))
Средняя точность: \(accuracy)%
"""
            
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть ещё раз") { [weak self] in
                    guard let self = self else { return }
                    self.showLoadingIndicator()
                    self.currentQuestionIndex = 0
                    self.correctAnswers = 0
                    self.questionFactory.requestNextQuestion()
                }
            let alertPresenter = AlertPresenter()
            alertPresenter.delegate = self
            self.alertPresenter = alertPresenter
            alertPresenter.show(quiz: alertModel)
        } else {
            showLoadingIndicator()
            currentQuestionIndex += 1
            questionFactory.loadData()
        }
    }
    private func setUIElementsHidden(_ hidden: Bool) {
        imageView.isHidden = hidden
        counterLabel.isHidden = hidden
        imageView.isHidden = hidden
        textLabel.isHidden = hidden
        yesButton.isHidden = hidden
        questionTitleLabel.isHidden = hidden
        noButton.isHidden = hidden
    }
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        activityIndicator.color = UIColor.white
        activityIndicator.style = .large
        
    }
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String, errorCompletion: @escaping () -> Void) {
        hideLoadingIndicator()
        
        let model = AlertModel(
            title: "Ошибка сети",
            message: message,
            buttonText: "Попробовать еще раз", completion: errorCompletion)
        let errorAlert = AlertPresenter()
        errorAlert.delegate = self
        self.errorAlert = errorAlert
        errorAlert.show(quiz: model)
    }
    
    
    private func showImageLoadError(text: String) {
        let model = AlertModel(title: "Ошибка загрузки изображения",
                               message: text,
                               buttonText: "Попробовать еще раз") { [weak self]
            in guard let self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory.loadData()
        }
        
        let errorAlert = AlertPresenter()
        errorAlert.delegate = self
        self.errorAlert = errorAlert
        errorAlert.show(quiz: model)
    }
}
