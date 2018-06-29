//
//  DataSync.swift
//  MyMemory
//
//  Created by 3zin on 2018. 6. 29..
//  Copyright © 2018년 3zin. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class DataSync {
    
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    func downloadBackupData() {
        
        let ud = UserDefaults.standard
        guard ud.value(forKey: "firstLogin") == nil else { return }
        
        let tk = TokenUtils()
        let header = tk.getAuthorizationHeader()
        
        let url = "http://swiftapi.rubypaper.co.kr:2029/memo/search"
        let get = Alamofire.request(url, method: .post, encoding: JSONEncoding.default, headers: header)
        
        get.responseJSON { res in
            
            guard let jsonObject = res.result.value as? NSDictionary else { return }
            guard let list = jsonObject["list"] as? NSArray else { return }
            
            for item in list {
                guard let record = item as? NSDictionary else { return }
                
                let object = NSEntityDescription.insertNewObject(forEntityName: "Memo", into: self.context) as! MemoMO
                object.title = (record["title"] as! String)
                object.contents = (record["contents"] as! String)
                object.regdate = self.stringToDate(record["create_date"] as! String)
                object.sync = true
                
                if let imagePath = record["image_path"] as? String {
                    let url = URL(string: imagePath)!
                    object.image = try! Data(contentsOf: url)
                }
            }
            
            
            do {
                try self.context.save()
            } catch let e as NSError {
                self.context.rollback()
                print(e.localizedDescription)
            }
            
            ud.setValue(true, forKey: "firstLogin")
 
        }
    }
    
    func uploadData() {
        
        let fetchRequest : NSFetchRequest<MemoMO> = MemoMO.fetchRequest()
        let regdateDesc = NSSortDescriptor(key: "regdate", ascending: false)
        fetchRequest.sortDescriptors = [regdateDesc]
        fetchRequest.predicate = NSPredicate(format: "sync == false")
        
        do {
            let resultset = try self.context.fetch(fetchRequest)
            
            for record in resultset {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                print("upload data==\(record.title!)")
                self.uploadDatum(record) {
                    if record == resultset.last{
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                }
            }
        } catch let error as NSError {
                print(error.localizedDescription)
        }
    }
    
    func uploadDatum(_ item: MemoMO, complete: (()->Void)? = nil) {
        
        let tk = TokenUtils()
        guard let header = tk.getAuthorizationHeader() else {
            print("fuck")
            return
        }
        
        var param: Parameters = [
        
            "title": item.title!,
            "contents" : item.contents!,
            "create_date" : self.dateToString(item.regdate!)
            
        ]
        
        if let imageData = item.image as Data? {
            param["image"] = imageData.base64EncodedString()
        }
        
        let url = "http://swiftapi.rubypaper.co.kr:2029/memo/save"
        let upload = Alamofire.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: header)
    
        upload.responseJSON{ res in
            guard let jsonObject = res.result.value as? NSDictionary else {
                print("fuckfcuk")
                return
            }
            
            let resultCode = jsonObject["result_code"] as! Int
            if resultCode == 0 {
                print("ok")
                
                do {
                    item.sync = true
                    try self.context.save()
                } catch let e as NSError {
                    self.context.rollback()
                    print("error")
                }
                
            } else {
                print(jsonObject["error_msg"] as! String)
            }
            
            complete?()
            
        }
    
    }
}

extension DataSync {
    func stringToDate(_ value: String) -> Date {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df.date(from: value)!
    }
    
    func dateToString(_ value: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df.string(from: value as Date)
        
    }
}
