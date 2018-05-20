//
//  SideBarVC.swift
//  MyMemory
//
//  Created by 3zin on 2018. 5. 19..
//  Copyright © 2018년 3zin. All rights reserved.
//

import UIKit

class SideBarVC: UITableViewController {
    

    let titles = ["새 글 작성하기", "친구 새 글", "달력으로 보기", "공지사항", "통계", "계정 관리" ]
    let icons = [UIImage(named:"icon01.png"),UIImage(named:"icon02.png"),UIImage(named:"icon03.png"),
                 UIImage(named:"icon04.png"),UIImage(named:"icon05.png"),UIImage(named:"icon06.png")]
    
    let nameLabel = UILabel()
    let emailLabel = UILabel()
    let profileImage = UIImageView()
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let id = "menucell"
        let cell = tableView.dequeueReusableCell(withIdentifier: id) ?? UITableViewCell(style: .default, reuseIdentifier: id)
        
        cell.textLabel?.text = self.titles[indexPath.row]
        cell.imageView?.image = self.icons[indexPath.row]
        
        cell.textLabel?.font = UIFont.systemFont(ofSize:14)
        return cell
    }
    
    // 이와 같은 방식의 화면 전환은 실제 버튼을 클릭해서 navigation controller를 순회하는 것과 어떤 차이가 있는가?
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 { //새 글 작성
            let uv = self.storyboard?.instantiateViewController(withIdentifier: "MemoForm")
            let target = self.revealViewController().frontViewController as! UINavigationController
            target.pushViewController(uv!, animated: true)
            self.revealViewController().revealToggle(self)//self는 곧 UITableViewController
            
        }else if indexPath.row == 5 {
            let uv = self.storyboard?.instantiateViewController(withIdentifier: "_Profile")
            self.present(uv!, animated: true){
                self.revealViewController().revealToggle(self)
            }
        }
    }
    
    
    
    
    override func viewDidLoad() {
        // 테이블 뷰의 헤더 역할을 할 뷰
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 70))
        headerView.backgroundColor = UIColor.darkGray
        self.tableView.tableHeaderView = headerView
        
        // 추가 레이블들
        self.nameLabel.frame = CGRect(x: 70, y: 15, width: 100, height: 30)
        self.nameLabel.text = "3zin"
        self.nameLabel.textColor = UIColor.white
        self.nameLabel.font = UIFont.boldSystemFont(ofSize: 15)
        self.nameLabel.backgroundColor = UIColor.clear
        headerView.addSubview(self.nameLabel)
        
        self.emailLabel.frame = CGRect(x: 70, y: 30, width: 100, height: 30)
        self.emailLabel.text = "3zin@naver.com"
        self.emailLabel.textColor = UIColor.white
        self.emailLabel.font = UIFont.boldSystemFont(ofSize: 11)
        self.emailLabel.backgroundColor = UIColor.clear
        headerView.addSubview(self.emailLabel)
        
        let defaultProfile = UIImage(named: "account.jpg")
        self.profileImage.image = defaultProfile
        self.profileImage.frame = CGRect(x: 10, y: 10, width: 50, height: 50)
        
        // 프로필 이미지 둥글게 만들기
        self.profileImage.layer.cornerRadius = (self.profileImage.frame.width/2)
        self.profileImage.layer.borderWidth = 0
        self.profileImage.layer.masksToBounds = true
        headerView.addSubview(self.profileImage)
    }
}






