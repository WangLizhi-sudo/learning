//
//  ViewController.swift
//  learning
//
//  Created by wanglizhi on 2026/3/13.
//

import UIKit

class ViewController: UIViewController {

    private let cellIdentifier = "DemoCell"

    private let demos: [DemoItem] = [
        DemoItem(
            title: "示例 Demo",
            subtitle: "一个简单的示例页面",
            viewControllerProvider: { SampleDemoViewController() }
        ),
        DemoItem(title: "策略模式",
                 subtitle: "策略模式是一种行为型设计模式，它定义了算法家族，分别封装起来，让它们之间可以相互替换，此模式让算法的变化，不会影响到使用算法的客户。",
                 viewControllerProvider: { StrategyPatternDemoViewController() }
                 ),
        // 在这里添加更多 demo...
    ]

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.dataSource = self
        tv.delegate = self
        tv.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Learning Demos"
        view.backgroundColor = .systemBackground

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        demos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let demo = demos[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = demo.title
        content.secondaryText = demo.subtitle
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let demo = demos[indexPath.row]
        let vc = demo.viewControllerProvider()
        navigationController?.pushViewController(vc, animated: true)
    }
}

