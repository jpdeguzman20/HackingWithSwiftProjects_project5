//
//  ViewController.swift
//  Project5
//
//  Created by Jonathan Deguzman on 11/22/16.
//  Copyright © 2016 Jonathan Deguzman. All rights reserved.
//

import GameplayKit
import UIKit

class ViewController: UITableViewController {

    var allWords = [String]()
    var usedWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Unwrap and find the path to a txt file named start using a built-in method of Bundle called path(forResource:)
        if let startWordsPath = Bundle.main.path(forResource: "start", ofType: "txt") {
            // Unwrap and create a string instance from the contents of a file at a particular path. If the code doesn't work, it will return a nil.
            if let startWords = try? String(contentsOfFile: startWordsPath) {
                // Split our single string into an array of strings based on wherever we find a line break
                allWords = startWords.components(separatedBy: "\n")
            }
        } else {
            allWords = ["silkworm"]
        }
        
        startGame()
    }
    
    func startGame() {
        // Shuffle the words array. However, this looks inefficient because we're randomizing an array of thousands of words and picking the first in the array. Might be better to just pick a word at a random position from the array.
        allWords = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: allWords) as! [String]
        title = allWords[0]
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    // Overriding these tableView methods help handle the table view data: numberOfRowsInSection and cellForRowAt
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

