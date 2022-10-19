//
//  RedeemVC.swift
//  rewards
//
//  Created by Kushal Vaghani on 17/10/22.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ItemModel: NSObject {
    
    var imageName: String
    var name: String
    var point: Int
    
    init(imageName: String, name: String, point: Int) {
        self.imageName = imageName
        self.name = name
        self.point = point
    }
}

class ItemCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Outlet
    @IBOutlet weak var imgViewItem: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPoint: UILabel!
    @IBOutlet weak var btnRedeem: UIButton!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK: - Configure Cell Method
    func configureCell(data: ItemModel) {
        self.backgroundColor = .white
        self.layer.cornerRadius = 10.0
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.gray.cgColor
        
        self.imgViewItem.image = UIImage(named: data.imageName)
        self.lblName.text = "\(data.name)"
        self.lblPoint.text = "\(data.point)"
    }
}

class RedeemVC: UIViewController {
    
    //MARK: - Outlet
    @IBOutlet weak var lblRewards: UILabel!
    @IBOutlet weak var collViewItem: UICollectionView!
    
    //MARK: - Class Varibale
    var employee: Employee!
    var itemArray = [ItemModel]()
    private var token: Any?
    
    //MARK: - DatabaseReference
    lazy var ref: DatabaseReference = Database.database().reference()
    var rewardRef: DatabaseReference!
    
    //MARK: - Custom Methodes
    func setUpView() {
        rewardRef = ref.child("rewards")
        lblRewards.text = "\(employee.point)"
        collViewItem.delegate = self
        collViewItem.dataSource = self
        collViewItem.contentInset = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 20.0, right: 20.0)
        
        setData()
        collViewItem.reloadData()
    }
    func setData() {
        itemArray.append(ItemModel(imageName: "workfromhome", name: "Work From Home - 1 day",
                                   point: 500))
        itemArray.append(ItemModel(imageName: "workfromhome", name: "WFH - 2 days",
                                  point: 1000))
        itemArray.append(ItemModel(imageName: "workfromhome", name: "WFH - 3 days",
                                   point: 1500))
        itemArray.append(ItemModel(imageName: "workfromhome", name: "WFH - 5 days",
                                   point: 2200))
    }
    //update rewards point when any changes on data base
    func updateRewardsPoint(point: Int) {
        lblRewards.text = "\(point)"
        self.collViewItem.reloadData()
    }
    
    //MARK: - Action Method
    @IBAction func btnRedeemRewards(_ sender: UIButton) {
        let item = itemArray[sender.tag]

        let id = UUID().uuidString
        var dicValue = [String: Any]()
        dicValue["id"] = id
        dicValue["name"] = employee.name
        dicValue["email"] = employee.email
        dicValue["point"] = item.point
        dicValue["is_reward"] = "redeem"

        //Set data on firesbase database for redeem
        self.rewardRef.child(id).setValue(dicValue)
        
        self.showAlertWithOKAction(title: "Successful", message: "\(item.point) points redeemed for \(item.name)")
    }
    
    //MARK: - Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Add NotificationCenter Observer for get changes on previous screen
        token = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("updateredeem"), object: nil, queue: nil
        ) { (notification) in
            if let user = notification.userInfo {
                let point = (user["point"] as! NSNumber).intValue
                self.updateRewardsPoint(point: point)
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        //Remove NotificationCenter Observer
        super.viewWillDisappear(animated)
        if token != nil {
            NotificationCenter.default.removeObserver(token!)
        }
    }
}

//MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension RedeemVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCollectionViewCell", for: indexPath) as! ItemCollectionViewCell
        let data = itemArray[indexPath.row]
        cell.configureCell(data: data)
        cell.btnRedeem.isEnabled = employee.point >= data.point
        cell.btnRedeem.tag = indexPath.row
        cell.btnRedeem.addTarget(self, action: #selector(self.btnRedeemRewards(_:)), for: .touchUpInside)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Calculate width for cell width onlt two cell show in row.
        let width = (collectionView.frame.width - 60)/2
        return CGSize(width: width, height: width + 95)
    }
}
