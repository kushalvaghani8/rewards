//
//  EmployeeDashboardVC.swift
//  rewards
//
//  Created by Kushal Vaghani on 05/10/22.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class EmployeeTableViewCell: UITableViewCell {
    
    //MARK: - Outlet
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblRewards: UILabel!
    @IBOutlet weak var btnRedeem: UIButton!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK: - Configure Cell Method
    func configureCell(data: Employee) {
        selectionStyle = .none
        lblName.text = data.name
        lblEmail.text = data.email
        lblRewards.text = "\(data.point)"
        self.btnRedeem.isHidden = true
        if let user = Auth.auth().currentUser {
            guard let email = user.email else { return }
            if data.email == email {
                self.btnRedeem.isHidden = false
            }
        }
    }
}

class EmployeeDashboardVC: UIViewController {
    
    //MARK: - Outlet
    @IBOutlet weak var tblView: UITableView!
    
    //MARK: - DatabaseReference
    lazy var ref: DatabaseReference = Database.database().reference()
    var rewardRef: DatabaseReference!
    var refHandle: DatabaseHandle?
    
    //MARK: - Class Varibale
    var employeeArray = [Employee]()

    //MARK: - Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.rowHeight = UITableView.automaticDimension
        tblView.estimatedRowHeight = 100.0
        tblView.tableFooterView = UIView(frame: .zero)
        rewardRef = ref.child("rewards")
    
        //to input employee data for using realtime database, there was no entry into the database for the user
        employeeArray.append(Employee(email: "employee1@test.com", name: "Employee 1"))
        employeeArray.append(Employee(email: "employee2@test.com", name: "Employee 2"))
        employeeArray.append(Employee(email: "employee3@test.com", name: "Employee 3"))
        employeeArray.append(Employee(email: "employee4@test.com", name: "Employee 4"))
        employeeArray.append(Employee(email: "employee5@test.com", name: "Employee 5"))
      
        //for naviation title of employee who's logged in
        if let user = Auth.auth().currentUser {
            guard let email = user.email else { return }
            let filterarray = self.employeeArray.filter{ $0.email == email }
            if filterarray.count != 0 {
                let data = filterarray[0]
                
                self.title = data.name
            }
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Add observe to get and subcribe data changes realtime database
        refHandle = rewardRef.observe(DataEventType.value, with: { snapshot in
            //Get value from snapshot
            guard let rewards = snapshot.value as? [String: [String: Any]] else { return }
            let values = rewards.values
            //Conver value to model object
            let rewardArray = values.map{ Reward(data: $0)!}
    
            //Add Reward Point on Model object
            if rewardArray.count != 0 {
                for employee in self.employeeArray {
                    let getByEmail = rewardArray.filter{ $0.email == employee.email }
                    let getPoint = getByEmail.filter{$0.isReward == "get"}.compactMap{ $0.point }.reduce(0, +)
                    let redeemPoint = getByEmail.filter{$0.isReward == "redeem"}.compactMap{ $0.point }.reduce(0, +)
                    employee.point = getPoint - redeemPoint
                }
            }
            
            //Sort employee list base on rewards Point
            self.employeeArray.sort { $0.point > $1.point }
            
            // Post Notification when any changes on rewards point in data base like get and redeen rewards
            if let user = Auth.auth().currentUser {
                guard let email = user.email else { return }
                let filterarray = self.employeeArray.filter{ $0.email == email }
                
                if filterarray.count != 0 {
                    let data = filterarray[0]
                    //broadcasting the points object to change into different screen who ever is subscribed
                    NotificationCenter.default.post(name: NSNotification.Name("updateredeem"), object: nil, userInfo: ["point":data.point])
                }
            }
            
            //Reload table after get reward data from firebase
            DispatchQueue.main.async {
                self.tblView.reloadData()
            }
        })
    }
    
    //MARK: - Action Method
    @IBAction func btnLogoutTapped(_ sender: Any) {
        self.showAlertWithYESNOAction(title: "Logout",
                                      message: "Are you sure you want to logout?",
                                      yescompletionBlock: { ok in
            
            do {
                try Auth.auth().signOut()
                let nav = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC")
                AppDelegate.shared.window?.rootViewController = nav
                AppDelegate.shared.window?.makeKeyAndVisible()
            } catch let error {
                print(error.localizedDescription)
            }
        }, nocompletionBlock: nil)
    }
    @IBAction func btnRedeemRewards(_ sender: UIButton) {
        let redeemVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RedeemVC") as! RedeemVC
        redeemVC.title = "Redeem"
        redeemVC.employee = employeeArray[sender.tag]
        self.navigationController?.pushViewController(redeemVC, animated: true)
    }
}

//MARK: - UITableViewDataSource, UITableViewDelegate
extension EmployeeDashboardVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employeeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeTableViewCell") as! EmployeeTableViewCell
        cell.configureCell(data: employeeArray[indexPath.row])
        cell.btnRedeem.tag = indexPath.row
        cell.btnRedeem.addTarget(self, action: #selector(self.btnRedeemRewards(_:)), for: .touchUpInside)
        return cell
    }
}

