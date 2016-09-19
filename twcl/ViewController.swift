//
//  ViewController.swift
//  twcl
//
//  Created by 武内駿 on 2016/09/19.
//  Copyright © 2016年 Syun Takeuchi. All rights reserved.
//  twitterタイムライン表示アプリ
//  現状、ツイート内容とユーザー名のみ表示
//  表示スタイル等は後ほど。ユーザー画像はswiftの仕様変更によりimageviewがnilを許容しないため後回し
//  ツイートが長いと省略されるのも修正予定
//  ツイート長さに合わせて行切り替えとテーブルセルの長さ切り替え
//  もっさり挙動も直す事
//  リロードボタンの機能実装する事
//  現状iPad2のみのレイアウトなのでautolayoutも設定すること

import UIKit
import Accounts
import Social

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self
        
        //アカウント取得
        getAccounts(){(account: [ACAccount]) -> Void in
            //アカウント振り分け処理は追って実装（とりあえず1番目のアカウント指定）
            self.twitterAccount=account[0]
            //タイムライン取得
            self.getTimeline(){(timeLine: NSMutableArray) -> Void in
                //書出
                self.tweetslist = timeLine[0] as! NSArray
                
                for tweets in self.tweetslist{
                    //ユーザー名
                    self.tweetuser.append((tweets["user"] as! NSDictionary)["name"]! as! String )
                    
                    //プロファイル画像
                    self.tweetuserimage.append((tweets["user"] as! NSDictionary)["profile_image_url_https"]! as! String )
                    
                    //ツイート内容
                    self.tweettext.append(tweets["text"] as! String)
                    
                    // print(tweets["user"] as! NSDictionary)
                    
                }
            }
        }
        sleep(2)
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var reLoad: UIBarButtonItem!
    
    //行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetslist.count
    }
    
    //セルの内容
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: TableViewCell = tableView.dequeueReusableCellWithIdentifier("cellType") as! TableViewCell
        //ツイート取得済みなら以下処理
        if self.tweetslist.count != 0{
            cell.setUsername(tweetuser[indexPath.row])
            cell.setUserprofileimage(tweetuserimage[indexPath.row])
            cell.setTweetText(tweettext[indexPath.row])
        }
        return cell
    }
    @IBAction func pushReload(sender: AnyObject) {
        //とりあえず全部再取得してるけど後でID使って差分で取得するようにする事
        self.tweetslist = []
        self.tweetuserimage = []
        self.tweetuser = []
        self.tweettext = []
        
        self.tableView.reloadData()
        
        //タイムライン取得
        self.getTimeline(){(timeline: NSMutableArray) -> Void in
            //書出
            self.tweetslist = timeline[0] as! NSArray
            
            for tweets in self.tweetslist{
                //ユーザー名
                self.tweetuser.append((tweets["user"] as! NSDictionary)["name"]! as! String )
                
                //プロファイル画像
                self.tweetuserimage.append((tweets["user"] as! NSDictionary)["profile_image_url_https"]! as! String )
                
                //ツイート内容
                self.tweettext.append(tweets["text"] as! String)
            }
        }
        sleep(2)
        self.tableView.reloadData()
    }
    
    //ツイッターアカウント変数
    var accountstore = ACAccountStore()
    var  twitterAccount : ACAccount?
    //情報本体
    var tweetslist = []
    //ツイートしたユーザー
    var tweetuser:[String] = []
    //ユーザーイメージアドレス
    var tweetuserimage:[String] = []
    //ツイート内容
    var tweettext: [String] = []
    //ツイッターアカウント取得
    func getAccounts(callback: [ACAccount] -> Void) {
        //アカウントタイプ設定
        let accountType:ACAccountType = accountstore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        //本体のツイッターアカウント情報を問い合わせる
        //複数ある場合を想定して配列で返す
        accountstore.requestAccessToAccountsWithType(accountType, options: nil) { (granted: Bool, error: NSError?) -> Void in
            if error != nil {
                //何かしらのエラー
                print("error! \(error)")
                return
            }
            if !granted {
                //アカウント利用不許可
                print("error! Twitterアカウントの利用が許可されていません")
                return
            }
            //利用許可で配列に収納
            let accounts = self.accountstore.accountsWithAccountType(accountType) as! [ACAccount]
            //配列が空っぽ＝アカウント登録なし
            if accounts.count == 0 {
                print("error! 設定画面からアカウントを設定してください")
                return
            }
            print("アカウント取得完了")
            //アカウント配列を返す
            callback(accounts)
        }
    }
    
    //リクエスト作成
    func sendRequest(url: NSURL, requestMethod: SLRequestMethod, params: AnyObject?, responseHandler: (responseData: NSData!, urlResponse: NSHTTPURLResponse!) -> Void) {
        let request:SLRequest = SLRequest(
            forServiceType: SLServiceTypeTwitter,
            requestMethod: requestMethod,
            URL: url,
            parameters: params as? [NSObject : AnyObject]
        )
        //アカウント情報移植
        request.account = twitterAccount
        //リクエストを投げる
        request.performRequestWithHandler { (responseData: NSData!, urlResponse: NSHTTPURLResponse!, error: NSError!) -> Void in
            if error != nil {
                print("error is \(error)")
            } else {
                responseHandler(responseData: responseData, urlResponse: urlResponse)
            }
        }
    }
    
    //タイムライン取得
    func getTimeline(callbabk: NSMutableArray -> Void) {
        //リクエストの宛先（今回はtwitter
        let url:NSURL = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")!
        //リクエスト実行
        sendRequest(url, requestMethod: .GET, params: ["count": "200"]) { (responseData, urlResponse) -> Void in
            do {
                let result:NSMutableArray = [try NSJSONSerialization.JSONObjectWithData(responseData, options: .AllowFragments)]
                //無事処理完了でコールバックする
                callbabk(result)
            } catch {
                print("エラーが発生しました")
            }
        }
    }
    
}

