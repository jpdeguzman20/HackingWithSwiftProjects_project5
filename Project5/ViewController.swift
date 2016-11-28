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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
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
    
    func promptForAnswer() {
        // Create a UIAlertController instance to prompt user for an answer
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        
        // Add an editable text input field (unlike UILabel, which cannot be edited) to the UIAlertController
        ac.addTextField()
        
        // This is a trailing closure. Everything before 'in' describes the closure and everything after it is the closure, thus the closure accepts one parameter of type UIAlertAction. '[unowned self, ac]' prevents creating a strong reference cycle because the closure does not own self and ac.
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned self, ac] (action: UIAlertAction!) in
            // Force unwrap array of text fields
            let answer = ac.textFields![0]
            // passes the contents of the text field and sends it to our submit method
            self.submit(answer: answer.text!)
        }
        
        // Adds the UIAlertAction, submitAction, to the UIAlertController
        ac.addAction(submitAction)
        
        present(ac, animated: true)
    }
    
    func submit(answer: String) {
        // Remember that Strings are case-sensitive, so it's best to make the whole thing lower-case first
        let lowerAnswer = answer.lowercased()
        
        let errorTitle: String
        let errorMessage: String
        
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    // If the word passes all the tests, insert it into the beginning of the usedWords array
                    usedWords.insert(answer, at: 0)
                    
                    // Update the table view
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                } else {
                    errorTitle = "Word not recognized"
                    errorMessage = "You cna't just make them up, y'know!"
                }
            } else {
                errorTitle = "Word used already"
                errorMessage = "Be more original!"
            }
        } else {
            errorTitle = "Word not possible"
            errorMessage = "You can't spell that word from '\(title!.lowercased())'!"
        }
        
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    // Method to check if the word can actually be made out of the original word
    func isPossible(word: String) -> Bool {
        // Have a variable to store the original word
        var tempWord = title!.lowercased()
        
        for letter in word.characters {
            // range(of:) returns an optional (can return nil if not found) position for where the item was found. In this case, we look for the letter from the word we just made and compare it to the letters in the original word. If the original word contains the specified letter, we remove it so that it can't be used again.
            if let pos = tempWord.range(of: String(letter)) {
                tempWord.remove(at: pos.lowerBound)
            } else {
                return false
            }
        }
        
        return true
    }
    
    // Method to check if the word has already been used
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        // Create an instance of UITextChecker, which is an iOS class for spotting spelling errors. Helpful for knowing if a word we've entered is an actual (and correctly spelled) word.
        let checker = UITextChecker()
        // Used to examine the entire string
        let range = NSMakeRange(0, word.utf16.count)
        // Scans the entire word in English and returns the amount of misspelled positions
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
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

