//
//  MemoListVCTableViewController.swift
//  MyMemory
//
//  Created by 3zin on 2018. 3. 10..
//  Copyright © 2018년 3zin. All rights reserved.
//

import UIKit

class MemoListVC: UITableViewController , UISearchBarDelegate{

    
    @IBOutlet var searchBar: UISearchBar!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    lazy var dao = MemoDAO()
    
    // 테이블 뷰의 셀 개수를 결정하는 메소드
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let count = self.appDelegate.memolist.count
        return count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 1. memolist 배열 데이터에서 주어진 행에 맞는 데이터를 꺼낸다.
        let row = self.appDelegate.memolist[indexPath.row]
        
        // 2. 이미지 속성이 비어 있을 경우 "memoCell", 아니면 "memoCellWithImage"
        
        let cellId:String
        if row.image == nil{
            cellId = "memoCell"
        }else{
            cellId = "memoCellWithImage"
        }
        
        // 3. 재사용 큐로부터 프로토타입 셀의 인스턴스를 전달받는다.
        let cell:MemoCell? = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? MemoCell

        // 4. memoCell의 내용을 구성한다
        cell?.subject?.text = row.title
        cell?.contents?.text = row.contents
        cell?.img?.image = row.image
        
        // 5. Date 타입의 날짜를 포맷에 맞게 변경
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        cell?.regdate?.text = formatter.string(from: row.regdate!)
        
        // 6. cell 객체 리턴
        
        if let cell = cell{
            return cell
        }else{
            // default set
            return MemoCell()
        }
    }
    
    
    override func viewDidLoad() {
        
        searchBar.enablesReturnKeyAutomatically = false
        
        // SWRevealViewController 라이브러리의 revealViewController 객체를 읽어온다
        
        if let revealVC = self.revealViewController(){ //revealVC의 typed은 SWRevealViewController. 결국 모든 작업을 종합적으로 처리할 main Container Controller에 대한 참조 주소 정보를 얻어오는 것이다. 얻어오는 이유는, target(target은 호출하는 action 메소드가 소속되어있는 객체 정보이다. 본 경우는 라이브러리 함수)값이 자기 자신이 아니라 SWRevealViewController이고, 직접적인 연관은 없으나 라이브러리 함수 참조를 위해 주소값이 필요하기 때문이다.
            
            let btn = UIBarButtonItem()
            btn.image = UIImage(named: "sidemenu.png")
            btn.target = revealVC // 메소드가 속해 있는 인스턴스 객체 (?)
            btn.action = #selector(revealVC.revealToggle(_:))
            
            self.navigationItem.leftBarButtonItem = btn
            
            self.view.addGestureRecognizer(revealVC.panGestureRecognizer()) // 이 제스처는 "TableViewController"인 MemoListVC에 추가하는 것이다. 이는 적당히 SWRevealViewController에 의해 view로 띄워져 반응하게 될 것이다.
            
            searchBar.delegate = self
           // self.tableView.delegate = self tableviewController를 상속했을 경우, 델리게이트와 데이터 소스는 자동으로 설정되어 있다
        }
    }
    
    // 디바이스 스크린에 뷰 컨트롤러가 나타날 때마다 호출되는 메소드
    // viewDidappear과는 시작시점의 차이가 존재한다. view controller appear 전후의 차이
    override func viewWillAppear(_ animated: Bool) {
        // 테이블 데이터를 다시 읽어들인다. 이에 따라 행을 구성하는 로직이 다시 실행될 것이다.
        self.appDelegate.memolist = self.dao.fetch()
        
        self.tableView.reloadData()
        
        let ud = UserDefaults.standard
        if ud.bool(forKey: UserInfoKey.tutorial) == false {
            let vc = self.instanceTutorialVC(name: "MasterVC")
            self.present(vc, animated: false)
            return
        }
        
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let data = self.appDelegate.memolist[indexPath.row]
        
        if dao.delete(data.objectID!){
            self.appDelegate.memolist.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "read_sg"{
            
            guard let destination = segue.destination as MemoReadVC, let selectedIndex = tableView.indexPathForSelectedRow?.row, let data = self.appDelegate?.memolist[selectedIndex] else{
                return
            }
            
            destination.param = data
        }
    }*/
    
    
    // segue를 사용하는 방법
    // preparesegue와 performsegue를 이용함. 공용 데이터 전달은 didselect내부 perform에서 담당.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "read_sg"{
            
            // destination optional binding
            guard let destination:MemoReadVC = segue.destination as? MemoReadVC else{return}
            // data 전달
            destination.param = sender as? MemoData
        }
    }
    
    // 임의의 시점에 performSegue 사용. sender을 통해 indexPath에 맞는 data 전달
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // memolist 는 옵셔널이 아니므로 바인딩 불필요. segue에 맞춰서 prepare가 이루어진 후 자동으로 이동하게 됨.
        performSegue(withIdentifier: "read_sg", sender: self.appDelegate.memolist[indexPath.row])

    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let keyword = searchBar.text
        
        self.appDelegate.memolist = self.dao.fetch(keyword: keyword)
        self.tableView.reloadData()
        
    }
    
    
    // segue를 사용하지 않은 방법
    /*override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
        // 1. memolist 배열에서 선택된 행에 맞는 데이터를 꺼낸다.
        let row = self.appDelegate.memolist[indexPath.row]
        
        // 2. 상세 화면의 인스턴스를 생성한다.
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "MemoRead") as? MemoReadVC else{
            return
        }
        
        // 3. 값을 전달한 다음, 상세 화면으로 이동한다.
        vc.param = row
        self.navigationController?.pushViewController(vc, animated: true)
    }*/

}
