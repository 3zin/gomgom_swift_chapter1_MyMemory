//
//  UserInfoManager.swift
//  MyMemory
//
//  Created by 3zin on 2018. 5. 25..
//  Copyright © 2018년 3zin. All rights reserved.
//

import UIKit

struct UserInfoKey {
    
    // 저장에 사용할 키
    static let loginId = "LOGINID"
    static let account = "ACCOUNT"
    static let name = "NAME"
    static let profile = "PROFILE"
    
}

// 계정 및 사용자 정보를 저장 관리하는 클래스
class UserInfoManager{
    
    // 연산 프로퍼티 for loginID(int)
    var loginId: Int {
        get{
            return UserDefaults.standard.integer(forKey: UserInfoKey.loginId)
        }
        set(v){
            let ud = UserDefaults.standard
            ud.set(v, forKey: UserInfoKey.loginId)
            ud.synchronize()
        }
    }
    
    // 연산 프로퍼티 for account
    var account: String? { // Optional, 비로그인 상태일때 이 값을 nil로 설정하기 위함.
        get{
            return UserDefaults.standard.string(forKey: UserInfoKey.account)
        }
        set(v){
            let ud = UserDefaults.standard
            ud.set(v, forKey: UserInfoKey.account)
            ud.synchronize()
        }
    }
    
    // 연산 프로퍼티 for name
    var name: String? {
        get{
            return UserDefaults.standard.string(forKey: UserInfoKey.name)
        }
        set(v){
            let ud = UserDefaults.standard
            ud.set(v, forKey: UserInfoKey.name)
            ud.synchronize()
        }
    }
    
    // 연산 프로퍼티 for profile image
    var profile: UIImage? {
        get{
            let ud = UserDefaults.standard
            
            if let _profile = ud.data(forKey: UserInfoKey.profile){
                return UIImage(data: _profile)
            }else{
                return UIImage(named: "account.jpg") // 이미지가 없다면 기본 이미지로
            }
            
        }
        set(v){
            if v != nil{
                let ud = UserDefaults.standard
                ud.set(UIImagePNGRepresentation(v!), forKey: UserInfoKey.profile)
                ud.synchronize()
            }// nil일 경우 아무것도 하지 않음
        }
    }
    
    // 로그인 상태를 판별해주는 연산 프로퍼티
    var isLogin: Bool {
        // 로그인 아이디가 0이거나 계정이 비어 있으면
        if self.loginId == 0 || self.account == nil{
            return false
        }else{
            return true
        }
    }
    
    
    func login(account: String, passwd: String) -> Bool {
        // 후에 서버와 연동할 예정
        if account.elementsEqual("sqlpro@naver.com") && passwd.elementsEqual("1234"){
            let ud = UserDefaults.standard
            ud.set(100, forKey: UserInfoKey.loginId)
            ud.set(account, forKey: UserInfoKey.account)
            ud.set("재은 씨", forKey: UserInfoKey.name)
            ud.synchronize()
            return true
        } else {
            return false
        }
    }
    
    func logout() -> Bool{
        let ud = UserDefaults.standard
        ud.removeObject(forKey: UserInfoKey.loginId)
        ud.removeObject(forKey: UserInfoKey.account)
        ud.removeObject(forKey: UserInfoKey.name)
        ud.removeObject(forKey: UserInfoKey.profile)
        ud.synchronize()
        return true
    }
    
}









