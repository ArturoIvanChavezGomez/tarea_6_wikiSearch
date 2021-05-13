//
//  ViewController.swift
//  WikiSearch
//
//  Created by Arturo Iván Chávez Gómez on 12/05/21.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var wikiWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlWikipedia = URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/Wikipedia-logo-v2-es.svg/1200px-Wikipedia-logo-v2-es.svg.png")
        
        wikiWebView.load(URLRequest(url: urlWikipedia!))
    }
    
    @IBAction func searchWordButton(_ sender: UIButton) {
        searchTextField.resignFirstResponder()
        guard let searchedWord = searchTextField.text else {
            return
        }
        if searchedWord == "" {
            searchTextField.placeholder = "Type here"
            wikiWebView.loadHTMLString("<h1>Type something ... </h1>", baseURL: nil)
        } else {
            searchWikipedia(words: searchedWord)
        }
    }
    
    func searchWikipedia(words: String) {
        if let urlAPI = URL(string: "https://es.wikipedia.org/w/api.php?action=query&prop=extracts&format=json&titles=\(words.replacingOccurrences(of: " ", with: "%20"))") {
            
            let request = URLRequest(url: urlAPI)
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                if error != nil {
                    print(error?.localizedDescription ?? "")
                } else {
                    do {
                        let objJson = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        
                        let querySubJson = objJson["query"] as! [String: Any]
                        
                        let pagesSubJson = querySubJson["pages"] as! [String: Any]
                        
                        let pageID = pagesSubJson.keys
                        
                        if pageID.first == "-1" {
                            DispatchQueue.main.async {
                                self.wikiWebView.loadHTMLString("<h1>Word doesn't exist. :/ </h1>", baseURL: nil)
                            }
                        } else {
                            let keyExtract = pageID.first!
                            
                            let idSubJson = pagesSubJson[keyExtract] as! [String: Any]
                            
                            let extract = idSubJson["extract"] as? String
                            
                            DispatchQueue.main.async {
                                self.wikiWebView.loadHTMLString(extract ?? "<h1>Results not found. :c</h1>", baseURL: nil)
                            }
                        }
                    } catch {
                        print("Error al procesar JSON: \(error.localizedDescription)")
                    }
                }
            }
            task.resume()
        }
    }

}

