//
//  XWDTTableViewController.swift
//  ITSC
//
//  Created by 严思远 on 2021/11/17.
//

import UIKit
import SwiftSoup

class XwdtTableViewController: UITableViewController {

    var items:[ListItem] = []
    var num: Int = 1
    let defaultUrl = URL(string: "https://itsc.nju.edu.cn/xwdt/list.htm")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadDataFromUrl()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    func loadDataFromUrl(){
        var url: URL
        if num == 1 {
            url = defaultUrl!
        } else {
            url = URL(string: "https://itsc.nju.edu.cn/xwdt/list\(num).htm")!
        }
        let task = URLSession.shared.dataTask(with: url, completionHandler: {
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
                            let file: Document = try SwiftSoup.parse(string)
                            let title: Elements = try file.select("span.news_title")
                            let meta: Elements = try file.select("span.news_meta")
                            let elementsNum = title.array().count
                            if elementsNum == 0 {
                                return
                            }
                            
                            for i in 0...elementsNum - 1 {
                                let linkTitle: Element = title.array()[i]
                                let linkMeta: Element = meta.array()[i]
                                
                                let newTitle: String = try linkTitle.text()
                                let newDate: String = try linkMeta.text()
                                let titleHtml: String = try linkTitle.html()
                                
                                let parseTitleHtml: Document = try SwiftSoup.parse(titleHtml)
                                let urlRefer: Element = try parseTitleHtml.select("a").first()!
                                let urlAdd: String = try urlRefer.attr("href")
                                
                                let newUrl = URL(string: ("https://itsc.nju.edu.cn" + urlAdd).dropLast(4) + ".htm")
                                //print(("https://itsc.nju.edu.cn" + urlAdd).dropLast(4) + ".htm")
                                let newItem = ListItem(title: newTitle, date: newDate, link: newUrl!)
                                self.items.append(newItem)
                            }
                        } catch Exception.Error(let type, let message) {
                            print(message)
                        } catch {
                            print("error")
                        }
                
                self.num += 1
                self.loadDataFromUrl()
                self.tableView.reloadData()
                }
            }
        })
        task.resume()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "xwdtCell", for: indexPath) as! ListTableViewCell
        let item = items[indexPath.row]
        
        // Configure the cell...
        cell.title.text! = item.title
        cell.date.text! = item.date
        
        return cell
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let dest = segue.destination as! WebViewController
        let cell = sender as! ListTableViewCell
        let index = tableView.indexPath(for: cell)!.row
        let url:URL = items[index].link
        dest.defaultUrl = url
    }

}
