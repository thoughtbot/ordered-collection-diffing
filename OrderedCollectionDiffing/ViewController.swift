import UIKit

final class ViewController: UIViewController {
  // MARK: - Properties
  private(set) var data = [1, 2, 3, 4, 5]
  private lazy var  refreshControl: UIRefreshControl = {
    let control = UIRefreshControl()
    control.addTarget(self, action: #selector(fetchNewData), for: .valueChanged)
    return control
  }()
  private lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
    tableView.dataSource = self
    tableView.refreshControl = self.refreshControl
    return tableView
  }()

  // MARK: - View Controller Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }

  // MARK: - View Setup
  private func setupView() {
    view.addSubview(tableView)

    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }

  // Mock a network request returning new data
  private func mockedNewData() -> [Int] {
    let length = Int.random(in: 5...10)
    return (1...length).map { _ in Int.random(in: 0...10) }
  }

  // MARK: - Actions
  @objc private func fetchNewData() {
    // Mock a two second long network request
    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 2) {
      if #available(iOS 9999, *) {
        DispatchQueue.main.async { [weak self] in
          guard let self = self else { return }
          var deletedIndexPaths = [IndexPath]()
          var insertedIndexPaths = [IndexPath]()
          let newData = self.mockedNewData()
          let diff = newData.difference(from: self.data)

          // Gather the row
          for change in diff {
            switch change {
            case let .remove(offset, _, _):
              deletedIndexPaths.append(IndexPath(row: offset, section: 0))
            case let .insert(offset, _, _):
              insertedIndexPaths.append(IndexPath(row: offset, section: 0))
            }
          }

          self.data = newData

          self.tableView.performBatchUpdates({ [weak self] in
            guard let self = self else { return }
            self.tableView.deleteRows(at: deletedIndexPaths, with: .fade)
            self.tableView.insertRows(at: insertedIndexPaths, with: .right)
          }) { _ in
            self.refreshControl.endRefreshing()
            print("All done updating!")
          }
        }
      }
    }
  }
}

// MARK: UITableViewDataSource
extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return data.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
    let value = data[indexPath.row]
    print(value)
    cell.textLabel?.text = "\(value)"
    return cell
  }
}
