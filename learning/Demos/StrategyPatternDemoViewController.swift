
import Foundation
import UIKit

class StrategyPatternDemoViewController: UIViewController {

    private let priceTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "请输入总价（例如：1000）"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .decimalPad
        tf.font = .systemFont(ofSize: 18)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let strategies: [(title: String, strategy: Strategy)] = [
        ("8折优惠", PrecentageDiscountStrategy(discount: 0.8)),
        ("固定减免 ¥50", FixedDiscountStrategy(discount: 50)),
        ("满500减100", MinimumDiscountStrategy(minimumPrice: 500, discount: 100)),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "策略模式"
        view.backgroundColor = .systemBackground

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        let titleLabel = UILabel()
        titleLabel.text = "策略模式演示"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let descLabel = UILabel()
        descLabel.text = "输入总价后，点击下方按钮选择不同的折扣策略"
        descLabel.font = .systemFont(ofSize: 14)
        descLabel.textColor = .secondaryLabel
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0
        descLabel.translatesAutoresizingMaskIntoConstraints = false

        let buttonStack = UIStackView()
        buttonStack.axis = .vertical
        buttonStack.spacing = 16
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        for (index, item) in strategies.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(item.title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
            button.backgroundColor = .systemBlue
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 12
            button.tag = index
            button.addTarget(self, action: #selector(strategyButtonTapped(_:)), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 50).isActive = true
            buttonStack.addArrangedSubview(button)
        }

        view.addSubview(titleLabel)
        view.addSubview(descLabel)
        view.addSubview(priceTextField)
        view.addSubview(buttonStack)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -24),

            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 24),
            descLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -24),

            priceTextField.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 32),
            priceTextField.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 24),
            priceTextField.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -24),
            priceTextField.heightAnchor.constraint(equalToConstant: 48),

            buttonStack.topAnchor.constraint(equalTo: priceTextField.bottomAnchor, constant: 40),
            buttonStack.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 24),
            buttonStack.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -24),
        ])
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func strategyButtonTapped(_ sender: UIButton) {
        guard let text = priceTextField.text, let price = Double(text) else {
            let alert = UIAlertController(title: "提示", message: "请输入有效的价格", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "好的", style: .default))
            present(alert, animated: true)
            return
        }

        let item = strategies[sender.tag]
        let context = Context(strategy: item.strategy)
        let result = context.execute(price: price)

        let alert = UIAlertController(
            title: item.title,
            message: String(format: "原价：¥%.2f\n折后价：¥%.2f", price, result),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "好的", style: .default))
        present(alert, animated: true)
    }
}

// 策略模式
protocol Strategy {
    func discount(price: Double) -> Double
}

class PrecentageDiscountStrategy: Strategy {

    private var discount: Double

    init(discount: Double) {
        if discount < 0 || discount > 1 {
            self.discount = 0.8
            print("Discount must be between 0 and 1")
        } else {
            self.discount = discount
        }
    }

    func discount(price: Double) -> Double {
        return price * discount
    }

    func changeDiscount(discount: Double) {
        if discount < 0 || discount > 1 {
            print("Discount must be between 0 and 1")
        } else {
            self.discount = discount
        }
    }
}

// 如果您需要组合策略，可以使用装饰器模式，将策略组合起来，形成新的策略。注释代码为基本装饰
// class NoDiscountStrategy: Strategy {
//     func discount(price: Double) -> Double {
//         return price
//     }
// }

class FixedDiscountStrategy: Strategy {
    private var discount: Double

    init(discount: Double) {
        if discount < 0 {
            self.discount = 10
            print("Discount must be greater than 0")
        } else {
            self.discount = discount
        }
    }

    func discount(price: Double) -> Double {
        return max(0, price - discount)
    }

    func changeDiscount(discount: Double) {
        if discount < 0 {
            print("Discount must be greater than 0")
        } else {
            self.discount = discount
        }
    }
}

class MinimumDiscountStrategy: Strategy {
    private var minimumPrice: Double
    private var discount: Double

    init(minimumPrice: Double = 500,discount: Double = 100) {
        if minimumPrice > 0 && minimumPrice > discount {
            self.minimumPrice = 500
            self.discount = 100
            print("Minimum price must be greater than discount")
        } else {
            self.minimumPrice = minimumPrice
            self.discount = discount
        }
    }
    
    
    func discount(price: Double) -> Double {
        return max(0, price - discount)
    }

    func changeDiscount(discount: Double) {
        if discount < 0 {
            print("Discount must be greater than 0")
        } else {
            self.discount = discount
        }
    }
}


class Context {
    private var strategy: Strategy

    init(strategy: Strategy) {
        self.strategy = strategy
    }

    func execute(price: Double) -> Double {
        return strategy.discount(price: price)
    }
}
