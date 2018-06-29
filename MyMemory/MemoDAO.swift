//
//  MemoDAO.swift
//  MyMemory
//
//  Created by 3zin on 2018. 6. 27..
//  Copyright © 2018년 3zin. All rights reserved.
//

import UIKit
import CoreData

class MemoDAO {
 
    // context 객체
    lazy var context : NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    func fetch(keyword text: String? = nil) -> [MemoData] {
        var memolist = [MemoData]()
        
        let fetchRequest : NSFetchRequest<MemoMO> = MemoMO.fetchRequest()
        
        let regdateDesc = NSSortDescriptor(key: "regdate", ascending: false)
        fetchRequest.sortDescriptors = [regdateDesc]
        
        if let t = text, t.isEmpty == false {
            fetchRequest.predicate = NSPredicate(format: "contents CONTAINS[c] %@", t)
        }
        
        do{
            let resultset = try self.context.fetch(fetchRequest)
            
            for record in resultset {
                let data = MemoData()
                data.title = record.title
                data.contents = record.contents
                data.regdate = record.regdate
                data.objectID = record.objectID
                
                if let image = record.image as Data? {
                    data.image = UIImage(data: image) // UIImage 타입을 Data 타임으로 변환?
                }
                
                memolist.append(data)
            }
        } catch let e as NSError {
            NSLog("An error has occured : %s", e.localizedDescription)
        }
        return memolist
    }
    
    func insert(_ data: MemoData) {
        
        let object = NSEntityDescription.insertNewObject(forEntityName: "Memo", into: self.context) as! MemoMO
        
        object.title = data.title
        object.contents = data.contents
        object.regdate = data.regdate!
        
        if let image = data.image {
            object.image = UIImagePNGRepresentation(image)
            
        }
        
        do {
            try self.context.save()
            
            let tk = TokenUtils()
            if tk.getAuthorizationHeader() != nil {
                DispatchQueue.global(qos: .background).async {
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                    
                    let sync = DataSync()
                    sync.uploadDatum(object){
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                }
            }
            
            } catch let e as NSError {
                NSLog("An error has occured : %s", e.localizedDescription)
        }
    }
    
    
    func delete(_ objectID: NSManagedObjectID) -> Bool {
        
        let object = self.context.object(with: objectID)
        self.context.delete(object)
        
        do {
            try self.context.save()
            return true
        } catch let e as NSError {
            NSLog("An error has occured : %s", e.localizedDescription)
            return false
        }
    }
}

