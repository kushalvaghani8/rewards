//
//  ManagerDashboardVC.swift
//  rewards
//
//  Created by Kushal Vaghani on 05/10/22.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase


class ManagerTableViewCell: UITableViewCell {
    
    //MARK: - Outlet cell for employee
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblRewards: UILabel!
    @IBOutlet weak var btnSend: UIButton!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK: - Configuring Cell Method
    func configureCell(data: Employee, rewardArray: [Reward]) {
        selectionStyle = .none
        lblName.text = data.name
        lblEmail.text = data.email
        lblRewards.text = "0"
        if rewardArray.count != 0 {
            // filter reward by email id
            let getByEmail = rewardArray.filter{ $0.email == data.email } //filtering for specific email
            // filter reward by Get and redeem
            let getPoint = getByEmail.filter{$0.isReward == "get"}.compactMap{ $0.point }.reduce(0, +) //.reduce is same as for loop to get a total of "get" points, 0 is the initial value
            let redeemPoint = getByEmail.filter{$0.isReward == "redeem"}.compactMap{ $0.point }.reduce(0, +)
            //Calculate total reward points
            lblRewards.text = "\(getPoint - redeemPoint)"
        }
    }
}


class ManagerDashboardVC: UIViewController {
    
    //MARK: - Outlet configuring slider, and other labels
    @IBOutlet weak var lblRewards: UILabel!
    @IBOutlet weak var sliderRewards: UISlider!
    @IBOutlet weak var tblView: UITableView!
    
    //MARK: - DatabaseReference, handler
    lazy var ref: DatabaseReference = Database.database().reference()
    var rewardRef: DatabaseReference!
    var refHandle: DatabaseHandle?
    
    //MARK: - Class Varibale
    var rewardArray = [Reward]() //rewards array from database
    let step: Float = 10
    var sendReward:Float = 10.0 //initial reward
    var employeeArray = [Employee]() //showing all employee
    
    //MARK: - Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblView.rowHeight = UITableView.automaticDimension //table configuration
        tblView.estimatedRowHeight = 100.0
        tblView.tableFooterView = UIView(frame: .zero)
        
        rewardRef = ref.child("rewards") //main from firebase URL referencing to "rewards"
        
        employeeArray.append(Employee(email: "employee1@test.com", name: "Employee 1")) //adding all employee to an array
        employeeArray.append(Employee(email: "employee2@test.com", name: "Employee 2"))
        employeeArray.append(Employee(email: "employee3@test.com", name: "Employee 3"))
        employeeArray.append(Employee(email: "employee4@test.com", name: "Employee 4"))
        employeeArray.append(Employee(email: "employee5@test.com", name: "Employee 5"))
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Add observe to get and subcribe data changes realtime database
        refHandle = rewardRef.observe(DataEventType.value, with: { snapshot in
            //Get value from snapshot - firesbase
            guard let rewards = snapshot.value as? [String: [String: Any]] else { return }
            let values = rewards.values
            //Conver value to model object
            self.rewardArray = values.map{ Reward(data: $0)!} //mapping data to our rewards model from firebase dictionary
            //Reload table after get reward data from firebase
            DispatchQueue.main.async {
                self.tblView.reloadData()
            }
        })
    }
    
    //MARK: - Action Method for slider
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        self.sendReward = round(sender.value / step) * step //setting the slider value
        self.lblRewards.text = "\(Int(self.sendReward))"
    }
    @IBAction func btnLogOutTapped(_ sender: Any) {
        self.showAlertWithYESNOAction(title: "Logout",
                                      message: "Are you sure you want to logout?",
                                      yescompletionBlock: { ok in
            
            do {
                try Auth.auth().signOut() //logging out from firebase
                let nav = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC")
                AppDelegate.shared.window?.rootViewController = nav
                AppDelegate.shared.window?.makeKeyAndVisible()
            } catch let error {
                print(error.localizedDescription)
            }
        }, nocompletionBlock: nil)
    }
    @IBAction func btnSendRewards(_ sender: UIButton) {
    
        let data = employeeArray[sender.tag] //sending it to specific employee using tag.
        
        let id = UUID().uuidString
        var dicValue = [String: Any]()
        dicValue["id"] = id
        dicValue["name"] = data.name
        dicValue["email"] = data.email
        dicValue["point"] = Int(self.sendReward)
        dicValue["is_reward"] = "get" //when sent the points are set as "get" i.e. employee gets point
        
        //Set data on database
        self.rewardRef.child(id).setValue(dicValue) //setting all values into the firebase
        
    }
}

//MARK: - UITableViewDataSource, UITableViewDelegate
extension ManagerDashboardVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employeeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ManagerTableViewCell") as! ManagerTableViewCell
        cell.configureCell(data: employeeArray[indexPath.row], rewardArray: self.rewardArray)
        cell.btnSend.tag = indexPath.row //tag for sending reward to specific employee
        cell.btnSend.addTarget(self, action: #selector(self.btnSendRewards(_:)), for: .touchUpInside) //calling btnsendrewards above
        return cell
    }
}

