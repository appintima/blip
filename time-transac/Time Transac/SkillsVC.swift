//
//  SkillsVC.swift
//  Time Transac
//
//  Created by Gbenga Ayobami on 2017-07-13.
//  Copyright © 2017 Gbenga Ayobami. All rights reserved.
//

import UIKit

class SkillsVC: UIViewController{
    
    @IBOutlet weak var skillsTableView: UITableView!
    
    
    var cell : CustomTableViewCell!
    var all_Cells: Array<CustomTableViewCell>!
    var all_Cells_Dict: Dictionary<Int, Bool> = [Int:Bool]()
    var all_Category_Dict: Dictionary<String, Int> = [String:Int]()
    
    var newUser: User!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib.init(nibName: "CustomTableViewCell", bundle: nil)
        self .skillsTableView.register(nib, forCellReuseIdentifier: "cell")
        // Do any additional setup after loading the view.
        
        all_Cells = Array()
        
        for i in 0..<miniDataBase.AllJobs_data.getAllCategories().count{
            all_Cells_Dict[i] = false
        }
        
        for name in miniDataBase.AllJobs_data.getAllCategories(){
            all_Category_Dict[name] = 0
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        if all_Cells.isEmpty{
            ERR_User_Did_not_Add_Skill()
            return
        }
        for skill_cell in all_Cells{
            if !(skill_cell.xpLevelTF.text?.isEmpty)!{
            newUser.addSkill(skill: Skill(skillName: skill_cell.skillNameLabel.text!, experienceLevel: skill_cell.xpLevelTF.text!))
            }else{
                ERR_User_Did_not_Add_XP()
                return
            }
        }
        if miniDataBase.addUser_to_DataBase(user: newUser) == nil{
            performSegue(withIdentifier: "goToAddSkillFromSignUp", sender: nil)
        }
    }
    
    
    
    
    
    
    
    
    
    func ERR_User_Did_not_Add_Skill(){
        
        let alert = UIAlertController(title: "Add Skills", message: "You Must Add At Least A Skill", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func ERR_User_Did_not_Add_XP(){
        
        let alert = UIAlertController(title: "Add Experience Level", message: "You Did Not Add Experience Level On One Or More Of Your Skill Categories", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    

}






extension SkillsVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = skillsTableView.cellForRow(at: indexPath) as! CustomTableViewCell
        all_Category_Dict[selectedCell.skillNameLabel.text!]!+=1
        if all_Category_Dict[selectedCell.skillNameLabel.text!]! % 2 != 0{
            selectedCell.xpLevelTF.isHidden = false
            selectedCell.accessoryType = UITableViewCellAccessoryType.checkmark
            all_Cells.append(selectedCell)
            
        }else{
            selectedCell.xpLevelTF.isHidden = true
            selectedCell.xpLevelTF.text = ""
            selectedCell.accessoryType = UITableViewCellAccessoryType.none
            all_Cells.remove(at: all_Cells.index(of: selectedCell)!)
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return miniDataBase.AllJobs_data.getAllCategories().count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell = skillsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        let item = miniDataBase.AllJobs_data.getAllCategories()[indexPath.row]
        
        cell.skillNameLabel.text = item
        
        return cell
    }
    

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
}
