//
//  API.swift
//  yohelper2
//
//  Created by to0r on 6/11/14.
//  Copyright (c) 2014 yozaii. All rights reserved.
//

import UIKit

//@objc protocol APIProtocol {
//    @optional func didReceiveAPIResponse(data: NSDictionary)
//    @optional func didReceiveAPIError(errno: Int)
//    @optional func didReceiveAPIResponseOf(api: API, data: NSDictionary)
//    @optional func didReceiveAPIErrorOf(api: API, errno: Int)
//}
protocol APIProtocol {
    func didReceiveAPIResponseOf(api: API, data: NSDictionary)
    func didReceiveAPIErrorOf(api: API, errno: Int)
}


class API: NSObject {
    
    var response: NSMutableData = NSMutableData()
    var delegate: APIProtocol?
    let host = "http://121.41.98.147:8080/anydo/api/"/*"http://115.29.166.167:8080/yozaii2/api/"*/
    let hostBase = "http://121.41.98.147:8080/"/*"http://115.29.166.167:8080/"*/
    let imageHost = String()
    var tag = 0

    var source: AnyObject?
//    class var user = " "
    struct userInfo{
        
        static var token = ""
        static var tokenValid = false
        static var id = -1
        static var username = ""
        static var nickname = ""
        static var phone = ""
        static var gender = ""
        static var profilePhoto = UIImage(named: "DefaultAvatar")
        static var profilePhotoUrl = ""
        static var profilePhotoPath = ""
        static var rmb = 0
        static var acceptNote = true
        static var signature = ""
        static var wxID = "Jolin_H"
        static let host = "http://121.41.98.147:8080/anydo/api/"//"http://218.244.141.224:8080/yozaii2/api/"//
        static let imageHost = "http://121.41.98.147:8080/"//"http://218.244.141.224:8080"//
        static var imageCache = Dictionary<String, UIImage>()
    }
    override init(){
//        imageHost = hostBase
    }
    init(delegate del: APIProtocol?) {
        self.delegate = del
    }
//    func fillUserInfo() {
//        
//    }
    
    //Huanxin related
    func getUsernameForHuanxin(uid: Int) {
        get(host + "getIndividual.action?uid=\(uid)")
    }

    //Tutors
    func getEvidencesFromMid(mid: Int) {
        get(host + "getEvidencesFromMid.action?token=\(API.userInfo.token)&mid=\(mid)&start=0&limit=100")
    }
    func getMissionCommentsAndMissionLikes(mid: Int) {
        get(host + "getMissionCommentsAndMissionLikes.action?token=\(API.userInfo.token)&mid=\(mid)&start=0&limit=100")
    }
    
    func getTutorsListByFilter(lang: Int?, discount: Int?, iffree: Int?, start: Int?, limit: Int?) {
        var url: String = host + "getTeachers.action?"
        if lang != nil {
            url += "lang=\(lang!)"
        }
        if discount != nil {
            url += "&ifdiscount=\(discount!)"
        }
        if iffree != nil {
            url += "&iffree=\(iffree!)"
        }
        if start != nil {
            url += "&start=\(start!)"
        }
        if limit != nil {
            url += "&limit=\(limit!)"
        }
        get(url)
    }
    
    func getTutorDetails(tid id: Int) {
        get(host + "getTeacher.action?tid=\(id)")
    }
    func getCoursesOfTutor(tid id: Int) {
        get(host + "getTopics.action?tid=\(id)")
    }
    func getCommentsOfTutor(tid id: Int) {
        get(host + "getTeacherEvaluations.action?tid=\(id)")
    }
    func getCoursesList(skip: Int?, lang: Int) {
        if skip != nil {
            get(host + "getTopicTypes.action?start=\(skip!)&lang=\(lang)")
        }
        else {
            get(host + "getTopicTypes.action?lang=\(lang)")
        }
    }
    func getCourseDetails(topic t: String, skip: Int, limit: Int) {
        let d = ["title": t, "start": String(skip), "limit": String(limit)]
//        get(host + "getTeachersInTopic.action?content=\(t)&start=\(skip)")
        sendURLEncodedForm(action: "getTeachersInTopic.action", data: d, image: nil)
    }
    func getCourseDetailsOfTutor(tid: Int, topic: String, skip: Int, limit: Int) {
        let d = ["title": topic, "tid": String(tid), "start": String(skip), "limit": String(limit)]
        sendURLEncodedForm(action: "getStuffsInTeacher.action", data: d, image: nil)
//        get(host + "getStuffsInTeacher.action?tid=\(tid)&start=\(skip)&limit=\(limit)")
    }
    
    // Auth
    func checkToken(token: String) {
        let tokenData = ["token": token]
        sendURLEncodedForm(action: "getStatus.action", data: tokenData, image: nil)
    }
    
    func login(username user: String, password pass: String){
       
        let authInfo = ["username": user, "password": pass]
        sendURLEncodedForm(action: "auth.action", data: authInfo, image: nil)
    }
    func register(username: String, phone p: String, password pass: String, authCode code: String) {
        let d = ["nickname": username, "phone": p, "password": pass, "type": "0", "identification": "0", "code": code, "gender": "M"]
        sendURLEncodedForm(action: "register.action", data: d, image: nil)
    }
    func sendAuthCode(phoneNumber num: String) {
        let data = ["phone": num]
        sendURLEncodedForm(action: "sendAuthcode.action", data: data, image: nil)
    }
    func checkAuthCode(phoneNumber num: String, authCode code: String) {
        let data = ["phone": num, "auth_code": code]
        sendURLEncodedForm(action: "checkAuthcode.action", data: data, image: nil)
    }
    func findPassword(phone: String) {
        get(host + "findPassword.action?phone=" + phone)
    }
    //Me
    func setNotePreference(accept: Bool) {
        if accept {
            get(host + "setIfmessage.action?token=\(API.userInfo.token)&ifmessage=1")
        }
        else {
            get(host + "setIfmessage.action?token=\(API.userInfo.token)&ifmessage=0")
        }
    }
    
    func addCollection(id: Int) {
        get(host + "addCollection.action?token=\(API.userInfo.token)&id=\(id)")
    }
    func addFriend(username: String) {
        get(host + "addFriend.action?token=\(API.userInfo.token)&username=\(username)")
    }
    func deleteFriend(username: String) {
        get(host + "deleteFriend.action?token=\(API.userInfo.token)&username=\(username)")
    }
    func getMyInfo() {
        let tokenData = ["token": API.userInfo.token]
        get(host + "getMyInfo.action?token=" + API.userInfo.token)
    }
    func setNickname(name: String) {
        let d = ["token": API.userInfo.token, "nickname": name]
        sendURLEncodedForm(action: "setNickname.action", data: d, image: nil)
    }
    func setAddress(addr: String) {
        let d = ["token": API.userInfo.token, "address": addr]
        sendURLEncodedForm(action: "setAddress.action", data: d, image: nil)
    }
    func setGender(g: String) {
        let d = ["token": API.userInfo.token, "gender": g]
        sendURLEncodedForm(action: "setGender.action", data: d, image: nil)
    }
    func setSignature(g: String) {
        let d = ["token": API.userInfo.token, "sign": g]
        sendURLEncodedForm(action: "setSign.action", data: d, image: nil)
    }
    func setPhone(p: String) {
        let d = ["token": API.userInfo.token, "phone": p]
        sendURLEncodedForm(action: "setPhone.action", data: d, image: nil)
    }

    func setPassword(newPass p: String, oldPass o: String ) {
        let d = ["token": API.userInfo.token, "newPassword": p, "oldPassword": o]
        sendURLEncodedForm(action: "setPassword.action", data: d, image: nil)
    }
    func getUserInfo(g: String) {
        let d = ["token": API.userInfo.token, "username": g]
        sendURLEncodedForm(action: "getIndividual.action", data: d, image: nil)
    }
    func getFinance() {
        get(host + "getGoldRMB.action?token=" + API.userInfo.token)
    }
    func checkDeal(tid: Int, rmb: Int, price: Int, coupon: Int, tag: String) {
        let d = ["token": API.userInfo.token, "rmb": String(rmb), "money": String(price), "coupon": String(coupon), "WIDid": tag]
        get(host + "checkMission.action?token=\(API.userInfo.token)&tid=\(tid)&rmb=\(rmb)&money=\(price)&coupon=\(coupon)&WIDid=\(tag)")
    }
    func spendMoney(tid: Int, rmb: Int, coupon: Int) {
        get(host + "addMission.action?token=\(API.userInfo.token)&tid=\(tid)&rmb=\(rmb)&coupon=\(coupon)")
    }
    func spendFreeCourseMoney(tid: Int) {
        get(host + "addFreeMission.action?token=\(API.userInfo.token)&tid=\(tid)")
    }
    func setAvatar() {
        let d = ["token": API.userInfo.token]
        sendURLEncodedForm(action: "setAvatar.action", data: d, image: API.userInfo.profilePhoto)
    }
    func uploadPic(pic: UIImage) {
        let d = ["token": API.userInfo.token]
        sendURLEncodedForm(action: "uploadPicture.action", data: d, image: pic)
    }
    func searchFriend(str: String) {
        let d = ["token": API.userInfo.token, "usernameorphone": str]
        sendURLEncodedForm(action: "getInfoFromUsernameOrPhone.action", data: d, image: nil)
    }
    func deleteCollection(id: Int) {
        get(host + "deleteCollection.action?token=\(API.userInfo.token)&id=\(id)")
    }
    func addMission(missionTemplateID: Int, title: String, content: String, supervisor: String, slogan: String, pics: String, picTimes: String, location: String, rmb: Int) {
        let data = ["token": API.userInfo.token, "missionTemplateID": "\(missionTemplateID)", "title": title, "content": content, "supervisor": supervisor, "slogan": slogan, "pics": pics, "picTimes": picTimes, "location": location, "rmb": "\(rmb)"]
        sendURLEncodedForm(action: "addMission.action", data: data, image: nil)
    }
    func setSchool(school: Int) {
        let data = ["token": API.userInfo.token, "school": "\(school)"]
        sendURLEncodedForm(action: "setSchool.action", data: data, image: nil)
        //get(host + "setSchool.action?token=\(API.userInfo.token)&school=\(school)")
    }
    
    //Learnings
    func takeNextMission(mid: Int) {
//        let d = ["token": API.userInfo.token, "id": String(mid)]
//        sendURLEncodedForm(action: host + "nextMission2.action", data: d, image: nil)
        get(host + "nextMission2.action?token=" + API.userInfo.token + "&id=\(mid)")
    }
    func getStudentEvaluations() {
        let d = ["token": API.userInfo.token]
        sendURLEncodedForm(action: "getStudentEvaluations.action", data: d, image: nil )
    }
    func getMyMissions(skip: Int) {
        get(host + "getMyMissions.action?token=" + API.userInfo.token + "&start=\(skip)&limit=100")
    }
    func getMissionsAndEvidences(skip: Int) {
        get(host + "getMissionsAndEvidences.action?token=" + API.userInfo.token + "&start=\(skip)&limit=5")
    }
    func deleteMission(id: Int) {
        get(host + "deleteMission.action?token=" + API.userInfo.token + "&id=\(id)")
    }
    func getTransactionHistory(skip: Int) {
        get(host + "getPersonRMBHistory.action?token=\(API.userInfo.token)&limit=10&start=\(skip)")
    }
    
    func getRankingList() {
        get(host + "getRmbRank.action?token=" + API.userInfo.token)
    }
    
    func getCollections() {
        get(host + "getCollection.action?token=" + API.userInfo.token)
    }
    
    func getMoments(uid: Int) {
        get(host + "getMissions.action?token=" + API.userInfo.token + "&uid=\(uid)&start=0&limit=100")
    }
    func getMissionFromID(mid: Int) {
        get(host + "getMissionFromID.action?token=" + API.userInfo.token + "&id=\(mid)")
    }
    func getCourses() {
        get(host + "getTopicTypes.action?token=" + API.userInfo.token)
    }
    
    func rateTutor(mid id: Int, score scr: Int) {
        let d = ["token": API.userInfo.token, "mid": String(id), "score": String(scr)]
        sendURLEncodedForm(action: "setScore.action", data: d, image: nil)
    }
    
    func evaluateTutor(mid id: Int, comment cmnt: String, score scr: Int) {
        let d = ["token": API.userInfo.token, "mid": String(id), "content": cmnt, "score": String(scr)]
//        var request = host + "evaluateTeacher.action?token=" + API.userInfo.token + "&"
//        request += "mid=" + String(id) + "&"
//        request += "content=" + cmnt + "&"
//        request += "score=" + String(scr)
//
//        get(request)
        sendURLEncodedForm(action: "evaluateTeacher.action", data: d, image: nil)
    }
    func sendMultipartForm(action act: String, data d: Dictionary<String, String>, image img: UIImage?) {
        
        let urlString = host + act
        let url = NSURL(string: urlString)
        let boundary = "unique-consistent-string"
        var body: NSMutableData = NSMutableData()
        var request = NSMutableURLRequest(URL: url!)

        for (key, value) in d {
            
            body.appendData(("--" + boundary + "\r\n").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
            body.appendData(("Content-Disposition: form-data; name=" + key + "\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
            body.appendData((value + "\r\n").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
            
        }
        
        if img != nil {
//            println("have img")
            var imgData = UIImageJPEGRepresentation(img, 1.0)
            var base64Img = imgData.base64EncodedDataWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
            body.appendData(("--" + boundary + "\r\n").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
            body.appendData(("Content-Disposition: form-data; name=Base64Files; filename=imageName.jpg\r\n").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
            body.appendData(("Content-Type: image/jpeg\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
            body.appendData(base64Img)
            body.appendData(("\r\n").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
        }
        
        body.appendData(("--" + boundary + "--").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)

        request.HTTPMethod = "POST"
        request.setValue("multipart/form-data; boundary=" + boundary, forHTTPHeaderField: "Content-Type")
        request.setValue("en-US,en;q=0.8,zh-CN;q=0.6,zh;q=0.4", forHTTPHeaderField: "Accept-Language")
        //        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(data, options: nil, error: nil)
        request.HTTPBody = body
        NSURLConnection(request: request, delegate: self)!.start()
    }
    func sendURLEncodedForm(action act: String, data d: Dictionary<String, String>, image img: UIImage?) {
        let urlString = host + act
        let url = NSURL(string: urlString)
        var body: NSMutableData = NSMutableData()
        var request = NSMutableURLRequest(URL: url!)
        for (key, value) in d {
            
//            body.appendData((key + "=" + value + "&").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false))
            var encode = ((key + "=" + value + "&") as NSString).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            body.appendData(encode.dataUsingEncoding(NSUTF8StringEncoding , allowLossyConversion: false)!)
            
        }
        if img != nil {
            var imgData = UIImageJPEGRepresentation(img, 1.0)
            var base64Img = imgData.base64EncodedDataWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
//            var encode = (("base64Files=data:image/jpeg;base64,") as NSString).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
//            body.appendData(encode.dataUsingEncoding(NSUTF8StringEncoding , allowLossyConversion: false))
            var stringImg = NSString(data: base64Img, encoding: NSUTF8StringEncoding)!
//            stringImg = stringImg.stringByReplacingOccurrencesOfString("/", withString: "%2F")
            stringImg = stringImg.stringByReplacingOccurrencesOfString("+", withString: "%2B")
            body.appendData(("Base64File=data:image/jpeg;base64,").dataUsingEncoding(NSUTF8StringEncoding , allowLossyConversion: false)!)
            body.appendData(stringImg.dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        request.HTTPMethod = "POST"
        request.setValue("application/x-www-form-urlencoded;charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("en-US,en;q=0.8,zh-CN;q=0.6,zh;q=0.4", forHTTPHeaderField: "Accept-Language")
        request.HTTPBody = body
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        NSURLConnection(request: request, delegate: self)!.start()
    }
    
    func get(path: String) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
//        println(path)
        let url = NSURL(string: path)
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfiguration.timeoutIntervalForRequest = 10
        sessionConfiguration.timeoutIntervalForResource = 20
        let session = NSURLSession(configuration: sessionConfiguration)
//        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            if(error != nil) {
                // If there is an error in the web request, print it to the console
//                println(error.localizedDescription)
                self.delegate?.didReceiveAPIErrorOf(self, errno: -1)
//                NSLog("b")
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false

            }
            else {
                var err: NSError? = nil
                NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err)// as NSDictionary
                
                if err == nil {
                    var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as! NSDictionary
                    
                    // Now send the JSON result to our delegate object
//                    println(jsonResult)
                    if jsonResult.count > 0 {
                        if (jsonResult["errno"] != nil) {
                            var errno = jsonResult["errno"] as! Int
                            if errno == 0{
                                self.delegate?.didReceiveAPIResponseOf(self, data: jsonResult)
                            }
                            else {
                                self.delegate?.didReceiveAPIErrorOf(self, errno: errno)
                            }
                        }
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false

                    }
                    else {
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    }
                }
                else {
                    self.delegate?.didReceiveAPIErrorOf(self, errno: -2)
//                    println("JSON Error \(err!)")

                }
            }
        })
        
        task.resume()
    }

    
    
    func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {
//        println("Connection failed.\(error.localizedDescription)")
        self.delegate?.didReceiveAPIErrorOf(self, errno: -3)

        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    
    func connection(didReceiveResponse: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        // Recieved a new request, clear out the data object
        self.response = NSMutableData()
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        // Append the recieved chunk of data to our data object
        //NSLog("\(data)")
        self.response.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        // Request complete, self.data should now hold the resulting info
        // Convert the retrieved data in to an object through JSON deserialization
        var err: NSError? = nil
        
        NSJSONSerialization.JSONObjectWithData(response, options: NSJSONReadingOptions.MutableContainers, error: &err)
        if err == nil {
            var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(response, options: NSJSONReadingOptions.AllowFragments, error: &err) as! NSDictionary
            // Now send the JSON result to our delegate object
//            println(jsonResult)
            if jsonResult.count > 0 {
                if jsonResult["errno"] != nil {
                    var errno = Int(jsonResult["errno"] as! NSNumber)
                    if errno == 0{
                        self.delegate?.didReceiveAPIResponseOf(self, data: jsonResult)

                    }
                    else {
                        self.delegate?.didReceiveAPIErrorOf(self, errno: errno)

                    }
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                }
            }
            else {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
        }
        else {
//            NSLog(String(contentsOfFile: response, encoding: NSUTF8StringEncoding)!)
            self.delegate?.didReceiveAPIErrorOf(self, errno: -4)
        }
        
    }
}
