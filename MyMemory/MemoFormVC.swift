//
//  MemoFormVC.swift
//  MyMemory
//
//  Created by 3zin on 2018. 3. 10..
//  Copyright © 2018년 3zin. All rights reserved.
//

import UIKit

class MemoFormVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    // 잘라내서 저장할 제목
    var subject:String!
    

    @IBOutlet var contents: UITextView!
    @IBOutlet var preview: UIImageView!
    @IBAction func save(_ sender: Any) {
        // 1. 내용을 입력하지 않았을 경우, 경고
        guard self.contents.text?.isEmpty == false else{
            let alert = UIAlertController(title:nil, message: "내용을 입력해주세요", preferredStyle:.alert)
            alert.addAction(UIAlertAction(title:"OK", style: .default, handler:nil)) // closure 생략
            self.present(alert, animated:true)
            return
        }
        
        // 2. MemoData 객체를 생성하고, 데이터를 담는다
        let data = MemoData()
        
        data.title = self.subject
        data.contents = self.contents.text
        data.image = self.preview.image
        data.regdate = Date()
        
        // 3. 앱 델리게이트 객체를 읽어온 다음, memolist 배열에 MemoData 객체를 추가한다
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memolist.append(data)
        
        // 4. 작성폼 화면을 종료하고, 이전 화면으로 되돌아간다.
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    // 카메라 버튼을 클릭했을 때 호출되는 메소드
    ////////////////////////////////////////
    // 틀린 부분 -> imagepicker method를 아예 따로 만들어서 반복되는 부분을 없게 했어야지!! 
    /////////////////////////////////////////
    @IBAction func pick(_ sender: Any) {
        
        let alert = UIAlertController(title: "이미지를 가져올 곳을 선택해주세요", message: nil, preferredStyle: .actionSheet)
        
        // 카메라 실행(시뮬레이터에서는 불가능)
        alert.addAction(UIAlertAction(title:"카메라", style: .default){ (alert:UIAlertAction!) -> Void in
            
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.allowsEditing = true
            
            self.present(picker, animated:false, completion: nil)
            
        })
        
        // 저장 앨범 실행(시뮬레이터에서는 불가능)
        alert.addAction(UIAlertAction(title:"저장 앨범", style: .default){ (alert:UIAlertAction!) -> Void in
            
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
            picker.allowsEditing = true
            
            self.present(picker, animated:false, completion: nil)
            
        })
        
        
        // 사진 라이브러리 실행
        alert.addAction(UIAlertAction(title:"사진 라이브러리", style: .default){ (alert:UIAlertAction!) -> Void in
            
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            picker.allowsEditing = true
            
            self.present(picker, animated:false, completion: nil)
        })
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel,handler : nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    // 이미지 선택을 완료했을 때 호출되는 메소드
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // 선택된 이미지를 미리보기에 표시한다
        self.preview.image = info[UIImagePickerControllerEditedImage] as? UIImage
        // 이미지 피커 컨트롤러를 닫는다
        picker.dismiss(animated:false)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated:false)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // 내용의 최대 15자리까지 읽어 subject 변수에 저장한다.
        let contents = textView.text as NSString
        let length = ((contents.length > 15) ? 15 : contents.length)
        self.subject = contents.substring(with:NSRange(location:0, length:length))
        
        // 내비게이션 타이틀에 표시한다.
        self.navigationItem.title = subject
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.contents.delegate = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
