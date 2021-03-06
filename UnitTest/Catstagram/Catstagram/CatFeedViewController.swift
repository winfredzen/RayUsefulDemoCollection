//
//  ViewController.swift
//  Catstagram-Starter
//
//  Created by Luke Parham on 2/9/17.
//  Copyright © 2017 Luke Parham. All rights reserved.
//

import UIKit
import CoreMotion
import CoreLocation

class CatFeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    private let kCatCellIdentifier = "CatCell"
    private let screensFromBottomToLoadMoreCats: CGFloat = 2.5
    
    private var photoFeed: PhotoFeedModel?
    private let tableView = UITableView(frame: CGRect.zero, style: .plain)
    private let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private let lastY = 0.0
    
    private let motionManager = CMMotionManager()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = "Catstagram"
        
        tableView.autoresizingMask = UIViewAutoresizing.flexibleWidth;
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoFeed = PhotoFeedModel(imageSize: imageSizeForScreenWidth())
        view.backgroundColor = UIColor.white

        refreshFeed()

        view.addSubview(tableView)
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.register(CatPhotoTableViewCell.classForCoder(), forCellReuseIdentifier: kCatCellIdentifier)
        
        tableView.addSubview(activityIndicatorView)
        
        motionManager.startDeviceMotionUpdates(to: .main, withHandler:{ deviceMotion, error in
            guard let deviceMotion = deviceMotion else { return }
            guard abs(self.lastY - deviceMotion.rotationRate.y) > 0.1 else { return }
            
            let xRotationRate = CGFloat(deviceMotion.rotationRate.x)
            let yRotationRate = CGFloat(deviceMotion.rotationRate.y)
            let zRotationRate = CGFloat(deviceMotion.rotationRate.z)
            
            print("y \(yRotationRate) and x \(xRotationRate) and z\(zRotationRate)")
            
            if abs(yRotationRate) > (abs(xRotationRate) + abs(zRotationRate)) {
                for cell in self.tableView.visibleCells as! [CatPhotoTableViewCell] {
                    cell.panImage(with: yRotationRate)
                }
            }
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        activityIndicatorView.center = CGPoint(x: view.bounds.size.width/2.0, y: view.bounds.size.height/2.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func refreshFeed() {
        guard let photoFeed = photoFeed else { return }
        
        activityIndicatorView.startAnimating()
        photoFeed.refreshFeed(with: 4) { (photoModels) in
            self.activityIndicatorView.stopAnimating()
            self.insert(newRows: photoModels)
            self.loadPage()
        }
    }
    
    func loadPage() {
        guard let photoFeed = photoFeed else { return }

        photoFeed.requestPage(with: 20) { (photoModels) in
            self.insert(newRows: photoModels)
        }
    }
    
    func insert(newRows photoModels: [PhotoModel]) {
        guard let photoFeed = photoFeed else { return }

        var indexPaths = [IndexPath]()
        
        let newTotal = photoFeed.numberOfItemsInFeed()
        for i in (newTotal - photoModels.count)..<newTotal {
            indexPaths.append(IndexPath(row: i, section: 0))
        }
        tableView.insertRows(at: indexPaths, with: .none)
    }
    
    //MARK: Table View Delegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCatCellIdentifier, for: indexPath) as! CatPhotoTableViewCell
        cell.layer.cornerRadius = 40.0
        cell.clipsToBounds = true
        
        cell.updateCell(with: photoFeed?.object(at: indexPath.row))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let photoModel = photoFeed?.object(at: indexPath.row) {
            return CatPhotoTableViewCell.height(forPhoto: photoModel, with: view.bounds.size.width)
        }
        return 0
    }
    
    //MARK: Table View DataSource
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoFeed?.numberOfItemsInFeed() ?? 0
    }

    //MARK: Scroll View Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let screensFromBottom = (scrollView.contentSize.height - scrollView.contentOffset.y)/UIScreen.main.bounds.size.height;
        
        if screensFromBottom < screensFromBottomToLoadMoreCats {
            loadPage()
        }
    }
    
    //MARK: Helpers
    func imageSizeForScreenWidth() -> CGSize {
        let screenRect = UIScreen.main.bounds
        let scale = UIScreen.main.scale
        
        return CGSize(width: screenRect.width * scale, height: screenRect.width * scale)
    }
    
    func resetAllData() {
        photoFeed?.clearFeed()
        tableView.reloadData()
        refreshFeed()
    }
}

extension CatFeedViewController {
    func sendLogs() {
        let headers = [
            "cookie": "foo=bar; bar=baz",
            "accept": "application/json",
            "content-type": "application/x-www-form-urlencoded"
        ]
        
        var postData = "foo=bar".data(using: String.Encoding.utf8)!
        postData.append("&bar=baz".data(using: String.Encoding.utf8)!)
        
        var request = URLRequest(
            url: URL(string: "https://mockbin.org/bin/d7fc711e-dc00-4a53-93e2-870a35163685?foo=bar&foo=baz")!,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: .main)
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
            }
            if let response = response {
                print(response)
            }
        }
        dataTask.resume()
    }
}

extension CatFeedViewController: URLSessionDelegate {
    
}
