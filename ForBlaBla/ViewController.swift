//
//  ViewController.swift
//  ForBlaBla
//
//  Created by Bing on 2019/10/24.
//  Copyright © 2019 Bing. All rights reserved.
//
import Foundation
import UIKit
import Apollo

typealias IssueEdge = RepositorsQuery.Data.Repository.Issue.Edge
class ViewController: UIViewController {
    var session: URLSession {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Authorization": "Bearer a9f8e04a0074f05bae3f496de12a727d3439cd9b"]
        return URLSession(configuration: config)
    }
    lazy var networkTransport = HTTPNetworkTransport(
      url: URL(string: "https://api.github.com/graphql")!,
      session: self.session
      )
    lazy var apollo = ApolloClient(networkTransport: self.networkTransport)
    
    var sourceArray:[IssueEdge]!
    var dataArray:[IssueEdge]! {
        didSet {
            tableView.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "CELL")
        tableView.register(UINib(nibName: "BlaTableViewCell", bundle: .main), forCellReuseIdentifier: "BlaTableViewCell")
        tableView.rowHeight = 90
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        loadIssues(isFresh: true)
        self.segControl.selectedSegmentIndex = 0
    }
    var watcher: GraphQLQueryWatcher<RepositorsQuery>?
    
    func loadIssues(isFresh: Bool) {
        watcher = apollo.watch(query: RepositorsQuery(owner: "octocat", name: "Hello-World")) { result in
            switch result {
            case .success(let graphQLResult):
                //          self.posts = graphQLResult.data?.posts
//                print(graphQLResult.data?.repository?.issues.edges)
                self.sourceArray = graphQLResult.data?.repository?.issues.edges as? [IssueEdge]

                if isFresh {
                    self.dataArray = self.sourceArray
                }
            case .failure(let error):
                NSLog("Error while fetching query: \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func segSelected(_ sender: UISegmentedControl) {
                
        switch sender.selectedSegmentIndex {
        case 0:
            loadIssues(isFresh: true)
        case 1:
            filteIssueTitles()
        case 2:
            filteIssueOwner()
        case 3:
            mostIssues()
        default:
            print("")
        }
    }
    
    // title 去重
    func filteIssueTitles() {
        if self.dataArray == nil || self.dataArray.count == 0 { return }
        var result = [IssueEdge]()
        for edge in self.dataArray {
            var contained = false
            for result_edge in result {
                if edge.node?.fragments.issueDetails.title == result_edge.node?.fragments.issueDetails.title {
                    contained = true
                    break
                }
            }
            if !contained {
                result.append(edge)
            }
        }
        
        self.dataArray = result
    }
    
    // owner 去重
    func filteIssueOwner() {
        if self.dataArray == nil || self.dataArray.count == 0 { return }
        var result = [IssueEdge]()
        for edge in self.dataArray {
            var contained = false
            for result_edge in result {
                if edge.node?.fragments.issueDetails.author?.login == result_edge.node?.fragments.issueDetails.author?.login {
                    contained = true
                    break
                }
            }
            if !contained {
                result.append(edge)
            }
        }
        
        self.dataArray = result

    }
    
    // 最多
    func mostIssues() {
        if self.dataArray == nil || self.dataArray.count == 0 { return }
        
        var countDic = [String:Int]()
        for edge in self.dataArray {
            let owner = edge.node?.fragments.issueDetails.author?.login
            if owner != nil {
                let currentCount = countDic[owner!] ?? 0
                countDic[owner!] = currentCount+1
            }
        }
        
        var owner = countDic.first
        for kv in countDic {
            if kv.value > owner?.value ?? 0 {
                owner = kv
            }
        }
        
        var result = [IssueEdge]()
        for edge in self.dataArray {
            if edge.node?.fragments.issueDetails.author?.login == owner?.key {
                result.append(edge)
            }
        }
        
        self.dataArray = result

    }
    
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  dataArray?.count ?? 0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: BlaTableViewCell = tableView.dequeueReusableCell(withIdentifier: "BlaTableViewCell", for: indexPath) as! BlaTableViewCell
        let edge = dataArray?[indexPath.row]
        cell.issueTitleLabel.text = edge?.node?.fragments.issueDetails.title
        cell.loginLabel.text = edge?.node?.fragments.issueDetails.author?.login
        
        return cell
    }

}
