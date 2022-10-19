//
//  Reward.swift
//  rewards
//
//  Created by Kushal Vaghani on 11/10/22.
//

import Foundation

class Reward: NSObject {
    
  var email: String
  var id: String
  var isReward: String
  var name: String
  var point: Int

    init(email: String, id: String, isReward: String, name: String, point: Int) {
        self.email = email
        self.id = id
        self.isReward = isReward
        self.name = name
        self.point = point
    }

    init?(data: [String : Any]) {
      
    guard let email = data["email"] as? String else { return nil }
    guard let id = data["id"] as? String else { return nil }
    guard let isReward = data["is_reward"] as? String else { return nil }
    guard let name = data["name"] as? String else { return nil }
    guard let point = data["point"] as? Int else { return nil }

    self.email = email
    self.id = id
    self.isReward = isReward
    self.name = name
    self.point = point
  }

  override convenience init() {
    self.init(email: "", id: "", isReward: "", name: "", point: 0)
  }
}
