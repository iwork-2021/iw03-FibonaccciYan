//
//  AboutViewController.swift
//  ITSC
//
//  Created by 严思远 on 2021/11/18.
//

import UIKit
import SwiftSoup

class AboutViewController: UIViewController {

    @IBOutlet weak var page1: UILabel!
    @IBOutlet weak var page2: UILabel!
    @IBOutlet weak var page3: UILabel!
    @IBOutlet weak var page4: UILabel!
    @IBOutlet weak var page5: UILabel!
    @IBOutlet weak var page6: UILabel!
    
    let defaultUrl: URL = URL(string: "https://itsc.nju.edu.cn/main.htm")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadDataFromUrl()
        // Do any additional setup after loading the view.
    }
    
    func loadDataFromUrl() {
        let task = URLSession.shared.dataTask(with: defaultUrl, completionHandler: {
            data, response, error in
            if let error = error {
                print("\(error.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("server error")
                return
            }
            if let mimeType = httpResponse.mimeType, mimeType == "text/html",
                        let data = data,
                        let string = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    do {
                        let file: Document = try SwiftSoup.parse(string)
                        let about: Element = try file.select("div.foot-center")[0]
                        let aboutHtml: String = try about.html()
                        let parseAboutHtml: Document = try SwiftSoup.parse(aboutHtml)
                        let aboutPages: Elements = try parseAboutHtml.select("div.news_box")
                        
                        self.page1.text! = try aboutPages.array()[0].text()
                        self.page2.text! = try aboutPages.array()[1].text()
                        self.page3.text! = try aboutPages.array()[2].text()
                        self.page4.text! = try aboutPages.array()[3].text()
                        self.page5.text! = try aboutPages.array()[4].text()
                        self.page6.text! = try aboutPages.array()[5].text()
                       
                    } catch Exception.Error(let type, let message) {
                        print(message)
                    } catch {
                        print("error")
                    }

                }
            }
        })
        task.resume()
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
