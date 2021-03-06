//
//  UserInfoManager.swift
//  MyMemory
//
//  Created by 3zin on 2018. 5. 25..
//  Copyright © 2018년 3zin. All rights reserved.
//

import UIKit
import Alamofire

struct UserInfoKey {
    
    // 저장에 사용할 키
    static let loginId = "LOGINID"
    static let account = "ACCOUNT"
    static let name = "NAME"
    static let profile = "PROFILE"
    static let tutorial = "TUTORIAL"
    
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
    
    
    func login(account: String, passwd: String, success:(()->Void)? = nil, fail:((String)->Void)? = nil) {
        
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/login"
        let param: Parameters = [
        "account": account,
        "passwd" : passwd
        ]
        
        let call = Alamofire.request(url, method: .post, parameters: param, encoding: JSONEncoding.default)
        
        call.responseJSON { res in
        
            guard let jsonObject = res.result.value as? NSDictionary else {
                fail?("잘못된 응답 형식입니다:\(res.result.value!)")
                return
            }
            
            let resultCode = jsonObject["result_code"] as! Int
            if resultCode == 0 {
                
                let user = jsonObject["user_info"] as! NSDictionary
                
                self.loginId = user["user_id"] as! Int
                self.account = user["account"] as? String
                self.name = user["name"] as? String
                
                if let path = user["profile_path"] as? String {
                    if let imageData = try? Data(contentsOf: URL(string: path)!) {
                        self.profile = UIImage(data: imageData)
                    }
                }
                
                // 토큰 정보 추출
                let accessToken = jsonObject["access_token"] as! String
                let refreshToken = jsonObject["refresh_token"] as! String
                
                let tk = TokenUtils()
                tk.save("kr.co.rubypaper.MyMemory", account: "accessToken", value: accessToken)
                tk.save("kr.co.rubypaper.MyMemory", account: "refreshToken", value: refreshToken)
                success?()
                
            }else{
                let msg = (jsonObject["error_msg"] as? String) ?? "로그인이 실패했습니다."
                fail?(msg)
            }
        
        }
        
    }
    
    func logout(completion:(()->Void)? = nil) {
        
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/logout"
        
        let tokenUtils = TokenUtils()
        let header = tokenUtils.getAuthorizationHeader()
        
        let call = Alamofire.request(url, method: .post, encoding: JSONEncoding.default, headers: header)
        
        call.responseJSON { _ in
            self.localLogout()
            completion?()
        }
    }
    
    func localLogout(){
        
        // 기본 저장소에 저장된 값을 모두 삭제
        let ud = UserDefaults.standard
        ud.removeObject(forKey: UserInfoKey.loginId)
        ud.removeObject(forKey: UserInfoKey.account)
        ud.removeObject(forKey: UserInfoKey.name)
        ud.removeObject(forKey: UserInfoKey.profile)
        ud.synchronize()
        
        // 키 체인에 저장된 값을 모두 삭제
        let tokenUtils = TokenUtils()
        tokenUtils.delete("kr.co.rubypaper.MyMemory", account: "refreshToken")
        tokenUtils.delete("kr.co.rubypaper.MyMemory", account: "accessToken")
        
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
    
    func newProfile(_ profile: UIImage?, success:(()->Void)? = nil, fail:((String)->Void)? = nil) {
        
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/profile"
        
        let tk = TokenUtils()
        let header = tk.getAuthorizationHeader()
        
        let profileData = UIImagePNGRepresentation(profile!)?.base64EncodedString()
        let param: Parameters = ["profile_image" : profileData!]

        
        let call = Alamofire.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers:header)
        
        call.responseJSON { res in
            
            guard let jsonObject = res.result.value as? NSDictionary else {
                fail?("잘못된 응답 형식입니다:\(res.result.value!)")
                return
            }
            
            let resultCode = jsonObject["result_code"] as! Int
            if resultCode == 0 {
                self.profile = profile
                success?()
                
            }else{
                let msg = (jsonObject["error_msg"] as? String) ?? "이미지 프로필 변경이 실패했습니다."
                fail?(msg)
            }
        }
    }
}









