import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate, MovieQuizViewControllerProtocol {
    
    // MARK: - IB Outlets
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    // MARK: - Private Properties
    
    private var alertPresenter: AlertPresenterProtocol?
    private var presenter: MovieQuizPresenter?
    private var errorAlert = AlertPresenter()
    
    // MARK: - Overrides Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        showLoadingIndicator()
        setUIElementsHidden(true)
        activityIndicator.hidesWhenStopped = true
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    // MARK: - Public Methods
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    func show(quiz result: QuizResultsViewModel) {
        _ = self.presenter?.makeResultsMessage()
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(
            title: result.buttonText, style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.presenter?.restartGame()
            }
        alert.addAction(action)
        alert.view.accessibilityIdentifier = "Game results"
        self.present(alert, animated: true, completion: nil)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func setUIElementsHidden(_ hidden: Bool) {
        imageView.isHidden = hidden
        counterLabel.isHidden = hidden
        imageView.isHidden = hidden
        textLabel.isHidden = hidden
        yesButton.isHidden = hidden
        questionTitleLabel.isHidden = hidden
        noButton.isHidden = hidden
    }
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        activityIndicator.color = UIColor.white
        activityIndicator.style = .large
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String, errorCompletion: @escaping () -> Void) {
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
    
    func showImageLoadError(text: String) {
        let model = AlertModel(title: "Ошибка загрузки изображения",
                               message: text,
                               buttonText: "Попробовать еще раз") { [weak self]
            in guard let self else { return }
            
            self.presenter?.restartGame()
        }
        
        let errorAlert = AlertPresenter()
        errorAlert.delegate = self
        self.errorAlert = errorAlert
        errorAlert.show(quiz: model)
    }
    
    // MARK: - Private Methods
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter?.yesButtonClicked()
        yesButton.isEnabled = !self.yesButton.isEnabled
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            yesButton.isEnabled = !self.yesButton.isEnabled
        }
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter?.noButtonClicked()
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
}
