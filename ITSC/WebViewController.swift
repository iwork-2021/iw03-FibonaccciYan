//
//  WebViewController.swift
//  ITSC
//
//  Created by 严思远 on 2021/11/18.
//

import UIKit
import WebKit
import SwiftSoup

class WebViewController: UIViewController {
    
    var webView = WKWebView()
    var defaultUrl: URL = URL(string: "https://apple.com")!
    let baseUrl = URL(string: "https://itsc.nju.edu.cn")
    let header = """
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=YES" />
                <style>
                    body {
                        font-family: "Avenir";
                        font-size: 14px;
                    }
                    img{
                        max-width:360px !important;
                    }
                </style>
            </head>
            """

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = webView
        self.loadWeb()
        // Do any additional setup after loading the view.
    }
    
    func loadWeb(){
        let task = URLSession.shared.dataTask(with: defaultUrl, completionHandler: {
            data, response, error in
            if let error = error {
                print("\(error.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("server error")
                return
            }
            if let mimeType = httpResponse.mimeType, mimeType == "text/html",
               let data = data,
               let string = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async { [self] in
                        do {
                            var content = "<html>\r\n<meta charset=\"utf-8\">\r\n<base href=\"https://itsc.nju.edu.cn\"/>\r\n"
                            content += self.header
                            content += self.body(string: string)
                            content += "<html/>"
                            print(content)

                            self.webView.loadHTMLString(content, baseURL: nil)
                        }
                }
            }
        })
        task.resume()
        task.priority = 1
    }

    
    func body(string: String) -> String {
        let lines = string.split(separator: "\r\n")
        var body: String = ""
        var start: Bool = false
        for line in lines {
            if line == "<!--Start||content-->" {
                start = true
            }
            else if line == "<!--End||content-->" {
                start = false
            }
            if start {
                body = body + line + "\r\n"
            }
        }
        return body
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
