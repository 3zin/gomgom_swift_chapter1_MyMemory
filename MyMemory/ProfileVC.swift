//
//  ProfileVC.swift
//  MyMemory
//
//  Created by 3zin on 2018. 5. 19..
//  Copyright © 2018년 3zin. All rights reserved.
//

import UIKit
import Alamofire
import LocalAuthentication

class ProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let uinfo = UserInfoManager()
    
    var isCalling = false
    
    let profileImage = UIImageView()
    let tv = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "프로필"
        
        let backBtn = UIBarButtonItem(title: "닫기", style: .plain, target: self, action: #selector(close))
        self.navigationItem.leftBarButtonItem = backBtn
        
        // 배경 이미지 설정
        let bg = UIImage(named: "profile-bg")
        let bgImg = UIImageView(image: bg)
        
        bgImg.frame.size = CGSize(width: bgImg.frame.size.width, height: bgImg.frame.size.height)
        bgImg.center = CGPoint(x: self.view.frame.width/2, y: 40)
        
        bgImg.layer.cornerRadius = bgImg.frame.size.width/2
        bgImg.layer.borderWidth = 0
        bgImg.layer.masksToBounds = true
        self.view.addSubview(bgImg)
        
        // 프로필 사진에 들어갈 기본 이미지
        let image = self.uinfo.profile
        self.profileImage.image = image
        self.profileImage.frame.size = CGSize(width: 100, height: 100)
        self.profileImage.center = CGPoint(x: self.view.frame.width/2, y: 130)
        
        // 프로필 이미지 둥글게 만들기
        self.profileImage.layer.cornerRadius = self.profileImage.frame.width/2
        self.profileImage.layer.borderWidth = 0
        self.profileImage.layer.masksToBounds = true
        self.profileImage.center = CGPoint(x: self.view.frame.width/2, y: 270)
        
        self.view.addSubview(self.profileImage)
        
        // 테이블 뷰
        self.tv.frame = CGRect(x: 0, y: self.profileImage.frame.origin.y + self.profileImage.frame.size.height + 20, width: self.view.frame.width, height: 100)
        self.tv.dataSource = self
        self.tv.delegate = self
        self.view.addSubview(self.tv)
        
        // 이미지 어울림 설정
        self.view.bringSubview(toFront: self.tv)
        self.view.bringSubview(toFront: self.profileImage)
        
        self.navigationController?.navigationBar.isHidden = true
        
        self.drawBtn() // 최초화면 로딩 시 로그인 상태에 따라 적절히 로그인/로그아웃 버튼을 출력한다.
        
        // 프로필 이미지 뷰 객체에 탭 제스처를 등록하고, 이를 profile 메소드와 연결한다
        let tap = UITapGestureRecognizer(target:self, action: #selector(profile))
        self.profileImage.addGestureRecognizer(tap)
        self.profileImage.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tokenValidate()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
        cell.accessoryType = .disclosureIndicator
        
        switch indexPath.row{
        case 0:
            cell.textLabel?.text = "이름"
            cell.detailTextLabel?.text = self.uinfo.name ?? "Login please" // 연산 프로퍼티에 의해 값을 받아올 것
        case 1:
            cell.textLabel?.text = "계정"
            cell.detailTextLabel?.text = self.uinfo.account ?? "Login please"
        default:
            ()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.uinfo.isLogin == false{
            self.doLogin(self) // self.tv의 의미는??
        }
    }
    
    // 버튼을 만든다
    func drawBtn(){
        // 버튼을 감쌀 뷰를 정의한다
        let v = UIView()
        v.frame.size.width = self.view.frame.width
        v.frame.size.height = 40
        v.frame.origin.x = 0
        v.frame.origin.y = self.tv.frame.origin.y + self.tv.frame.height
        v.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
        
        self.view.addSubview(v)
        
        // 버튼을 정의한다
        let btn = UIButton(type: .system)
        btn.frame.size.width = 100
        btn.frame.size.height = 30
        
        btn.center.x = v.frame.size.width / 2
        btn.center.y = v.frame.size.height / 2
        
        // 로그인 상태일 때는 로그아웃 버튼을, 로그아웃 상태일 때는 로그인 버튼을 만들어 준다.
        if self.uinfo.isLogin == true {
            btn.setTitle("로그아웃", for: .normal)
            btn.addTarget(self, action: #selector(doLogout(_:)), for: .touchUpInside)
        } else {
            btn.setTitle("로그인", for: .normal)
            btn.addTarget(self, action: #selector(doLogin(_:)), for: .touchUpInside)
        }
        v.addSubview(btn)
    }
    
    // 이미지 피커 컨트롤러를 실행하는 커스텀 메소드
    func imgPicker(_ source: UIImagePickerControllerSourceType){
        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker, animated:true)
    }
    
    
    @objc func close(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @objc func doLogin(_ sender: Any) {
        
        if self.isCalling == true {
            self.alert("응답을 기다리는 중입니다. \n잠시만 기다려 주세여.")
            return
        }else {
            self.isCalling = true
        }
        
        let loginAlert = UIAlertController(title: "LOGIN", message: nil, preferredStyle: .alert)
        
        // 알림창에 들어갈 입력폼
        loginAlert.addTextField() { (tx) in
            tx.placeholder = "Your Account"
        }
        loginAlert.addTextField() { (tx) in
            tx.placeholder = "Password"
            tx.isSecureTextEntry = true
        }
        
        // 알림창 버튼 추가
        loginAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel) {(al) in
            self.isCalling = true
        })
        loginAlert.addAction(UIAlertAction(title: "Login", style: .destructive){ (al) in
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            let account = loginAlert.textFields?[0].text ?? "" // 첫 번째 필드 : 계정
            let passwd = loginAlert.textFields?[1].text ?? ""  // 두 번째 필드 : 비밀번호
            
            self.uinfo.login(account: account, passwd: passwd, success: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isCalling = false
                
                self.tv.reloadData()
                self.profileImage.image = self.uinfo.profile
                self.drawBtn()
                
                let sync = DataSync()
                DispatchQueue.global(qos: .background).async {
                    sync.downloadBackupData()
                }
                
                DispatchQueue.global(qos: .background).async {
                    sync.uploadData()
                }
                
                
            }, fail: { msg in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isCalling = false
                
                self.alert(msg)
            })
        })
        self.present(loginAlert, animated: false)
    }
    
    @objc func doLogout(_ sender: Any){
        let msg = "로그아웃하시겠습니까?"
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "확인", style: .destructive){ (al) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            self.uinfo.logout(){
                // 로그아웃 성공
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.tv.reloadData() // 테이블 뷰를 갱신한다
                self.profileImage.image = self.uinfo.profile // 이미지 프로필을 갱신한다
                self.drawBtn() // 로그인 상태에 따라 적절히 로그인/로그아웃 버튼을 출력한다.
            }
        })
        self.present(alert, animated: false)
    }
    
    // 프로필 사진의 소스 타입을 선택하는 액션 메소드
    @objc func profile(_ sender: Any) {
        // 로그인되어 있지 않을 경우에는 프로필 이미지 등록을 막고 대신 로그인 창을 띄워 준다.
        guard self.uinfo.account != nil else{
            self.doLogin(self) // not self.tv? 어차피 그냥 sender...
            return
        }
        
        let alert = UIAlertController(title: nil, message: "사진을 가져올 곳을 선택해주세요", preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            alert.addAction(UIAlertAction(title: "카메라", style: .default){ (al) in
                self.imgPicker(.camera)
            })
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            alert.addAction(UIAlertAction(title: "저장된 앨범", style: .default){ (al) in
                self.imgPicker(.savedPhotosAlbum)
            })
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            alert.addAction(UIAlertAction(title: "포토 라이브러리", style: .default){ (al) in
                self.imgPicker(.photoLibrary)
            })
        }
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        // 액션 시트 창 실행
        self.present(alert, animated: true)
    }
    
    // 이미지를 선택하면 이 메소드가 자동으로 호출된다
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        if let img = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.uinfo.newProfile(img, success: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.profileImage.image = img
                
            }, fail: { msg in

                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.alert(msg)
            })
        }
        
        picker.dismiss(animated: true)
    }
    
    @IBAction func backProfileVC(_ segue: UIStoryboardSegue){
        
    }
}

extension ProfileVC {
    
    func tokenValidate(){
        
        URLCache.shared.removeAllCachedResponses()
        
        let tk = TokenUtils()
        guard let header = tk.getAuthorizationHeader() else {
            return
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/tokenValidate"
        let validate = Alamofire.request(url, method: .post, encoding: JSONEncoding.default, headers: header)
        
        validate.responseJSON { res in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            print(res.result.value!)
            guard let jsonObject = res.result.value as? NSDictionary else {
                self.alert("잘못된 응답입니다.")
                return
            }
            
            let resultCode = jsonObject["result_code"] as! Int
            if resultCode != 0 {
                self.touchID()
            }
        }
    }
    
    func touchID(){
        
        let context = LAContext()
        var error: NSError?
        let msg = "인증이 필요합니다"
        let deviceAuth = LAPolicy.deviceOwnerAuthenticationWithBiometrics
        
        if context.canEvaluatePolicy(deviceAuth, error: &error){
            
            context.evaluatePolicy(deviceAuth, localizedReason: msg) { (success, e) in
                
                if success {
                    self.refresh()
                } else {
                    
                    print(e?.localizedDescription)
                    
                    switch(e!._code) {
                    case LAError.systemCancel.rawValue:
                        self.alert("시스템에 의해 인증이 취소되었습니다.")
                    case LAError.userCancel.rawValue:
                        self.alert("사용자에 의해 인증이 취소되었습니다."){
                            self.commonLogout(true)
                        }
                    case LAError.userFallback.rawValue:
                        OperationQueue.main.addOperation {
                            self.commonLogout(true)
                        }
                    default:
                        OperationQueue.main.addOperation {
                            self.commonLogout(true)
                        }
                        
                    }
                }
            }
        } else {
            print(error!.localizedDescription)
            switch(error!.code) {
            case LAError.touchIDNotEnrolled.rawValue:
                print("터치 아이디가 등록되어 있지 않습니다.")
            case LAError.passcodeNotSet.rawValue:
                print("패스 코드가 설정되어 있지 않습니다.")
            default:
                print("터치 아이디를 사용할 수 없습니다.")
            }
            
            OperationQueue.main.addOperation {
                self.commonLogout(true)
            }
        }
    }
    
    
    func refresh(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let tk = TokenUtils()
        let header = tk.getAuthorizationHeader()
        
        let refreshToken = tk.load("kr.co.rubypaper.MyMrmory", account: "refreshToken")
        let param: Parameters = ["refresh_token" : refreshToken!]
        
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount.refresh"
        let refresh = Alamofire.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: header)
        
        refresh.responseJSON{ res in
        
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            guard let jsonObject = res.result.value as? NSDictionary else {
                self.alert("잘못된 응답입니다.")
                return
            }
            
            let resultCode = jsonObject["result_code"] as! Int
            if resultCode == 0 {
                let accessToken = jsonObject["access_token"] as! String
                tk.save("kr.co.rubypaper.MyMemory", account: "accessToken", value: accessToken)
                
            } else {
                self.alert("인증이 만료되었으므로 다시 로그인해야 합니다"){
                    OperationQueue.main.addOperation {
                        self.commonLogout(true)
                    }
                }
            }
        }
    }
    
    func commonLogout(_ isLogin: Bool = false) {
        
        let userInfo = UserInfoManager()
        userInfo.localLogout()
        
        self.tv.reloadData()
        self.profileImage.image = userInfo.profile
        self.drawBtn()
        
        if isLogin{
            self.doLogin(self)
        }
    }
}








