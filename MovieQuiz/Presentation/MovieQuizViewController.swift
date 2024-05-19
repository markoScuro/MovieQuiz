import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
   
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    
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
        
        self.questionFactory.requestNextQuestion()
    }
        


// MARK: - QuestionFactoryDelegate




override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
}


    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    
    private var alertPresenter: AlertPresenter?
    
    
    
    
    

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

//    private func show(quiz result: QuizResultsViewModel) {
//        let alert = UIAlertController(
//            title: result.title,
//            message: result.text,
//            preferredStyle: .alert)
//        
//        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
//            guard let self = self else { return }
//            self.currentQuestionIndex = 0
//            self.correctAnswers = 0
//            
//            questionFactory.requestNextQuestion()
//        }
//        
//        alert.addAction(action)
//        self.present(alert, animated: true, completion: nil)
//    }

    func show(quiz result: QuizResultsViewModel) {
        let alertViewModel = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText, completion: { [weak self] _ in
            guard self != nil else { return }

        } )

        let alert = AlertPresenter()
        alert.present(view: self, alert: alertViewModel, alertIdentifier: "myAlertID")
        
    }
    
private func showNextQuestionOrResults() {
    
    if currentQuestionIndex == questionsAmount - 1 {
        let text = correctAnswers == questionsAmount ?
        "Поздравляем, вы ответили на 10 из 10!" :
        "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
        let viewModel = QuizResultsViewModel(
            title: "Этот раунд окончен!",
            text: text,
            buttonText: "Сыграть ещё раз")
        show(quiz: viewModel)
    } else {
        self.questionFactory.requestNextQuestion()
    }
}
}
