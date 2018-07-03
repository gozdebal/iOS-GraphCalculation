//
//  CalcViewController.swift
//  MealDesigner
//
//  Created by gozdebal on 15/01/2017.
//  Copyright © 2017 Gozde Bal. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import MessageUI
import Charts
import GoogleMobileAds
import UserNotifications
import CoreLocation

class MealCalculatorViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, GADBannerViewDelegate, UITextFieldDelegate, UITextViewDelegate, CLLocationManagerDelegate { //UIPickerViewDelegate, UIPickerViewDataSource,
    
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var bannerView72: GADBannerView!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var carbLabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var totalView: UIView!
    @IBOutlet weak var pieView: UIView!
    @IBOutlet weak var calculatorView: UIView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var pieView2: PieChartView!
    @IBOutlet weak var totalCaloryTextField: UITextField!
    @IBOutlet weak var orderButton: UIButton!
    @IBOutlet weak var ingredientTableView: UITableView!
    @IBOutlet weak var text4: UITextField!
    @IBOutlet weak var text2: UITextField!
    var selectedCells = Set<Int>()
    var ingredients = [Ingredient]()
    var selectedcompany : String?
    var selectedemail: String?
    var selectedcategory: String?
    var companyid = 0
    private var selectedItems = [String]()
    var totalIngredientArray = [String] ()
    var nameArray = [String] ()
    var caloryStoreArray = [Double] ()
    var firstCaloriesArray = [AnyObject] ()
    var numberStoreArray = [String] ()
    var totalCaloryArray = [Double] ()
    var totalcalories = 0
    var totalingredients = [String]()
    var t1 = [Int] ()
    var t2 = [String] ()
    var refreshControl = UIRefreshControl()
    var tableViewController = UITableViewController (style: .plain)
    let userEmail = FIRAuth.auth()?.currentUser?.email
    let userDisplayName = FIRAuth.auth()?.currentUser?.displayName
    var sum1 = 0.0
    var sum2 = 0.0
    var sum3 = 0.0
    var sum4 = 0.0
    var sum = 0.0
    var values: [PieChartDataEntry] = []
    var cellcalory1 = 0
    var nutrition = [Int] ()
    var firstnutrition = [Int] ()
    var firstnutr1 = [AnyObject] ()
    var firstnutr2 = [AnyObject] ()
    var firstnutr3 = [AnyObject] ()
    var fatArray = [Double] ()
    var carbArray = [Double] ()
    var proteinArray = [Double] ()
    var newNutrition = [Int] ()
    var new1 = 0
    var ingID = 0
    var firstNumberItemQArray = [AnyObject] ()
    var userlist = [Users] ()
    var ref: FIRDatabaseReference!
    var refHandle: UInt!
    var key = [String] ()
    var locationArray = ["I'm at the Store","I'm not in the Store"]
    let locationPicker = UIPickerView()
    let savedmeal1 = [SavedMeal] ()
    var locationManager:CLLocationManager!
    var latitude:Double?
    var longtitude:Double?
    var comp1 = 1
    var uLatitude:Double?
    var uLongitude:Double?
    var oType: Int64?
    var uPhone: Int64?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setLeftBarButton( (UIBarButtonItem(title:"< Back", style: .plain, target:self, action:#selector(MealCalculatorViewController.backTapped(_:)))), animated: false)
        
        //view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        UINavigationBar.appearance().barTintColor = UIColor(red: 11.0/255.0, green: 164.0/255.0, blue: 118.0/255.0, alpha: 100.0/100.0)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        UINavigationBar.appearance().tintColor = UIColor.white
        calculatorView.layer.cornerRadius = 3.0
        calculatorView.layer.masksToBounds = false
        calculatorView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        calculatorView.layer.shadowOffset = CGSize(width: 0, height: 0)
        calculatorView.layer.shadowOpacity = 0.8
        pieView.layer.cornerRadius = 3.0
        pieView.layer.masksToBounds = false
        pieView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        pieView.layer.shadowOffset = CGSize(width: 0, height: 0)
        pieView.layer.shadowOpacity = 0.8
        totalView.layer.cornerRadius = 3.0
        totalView.layer.masksToBounds = false
        totalView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        totalView.layer.shadowOffset = CGSize(width: 0, height: 0)
        totalView.layer.shadowOpacity = 0.8
        shareButton.layer.cornerRadius = 4
        orderButton.layer.cornerRadius = 4
        /*locationPicker.delegate = self
        locationPicker.dataSource = self
        locationTextField.inputView = locationPicker*/
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneClicked))
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        notesTextView.inputAccessoryView = toolbar
        phoneTextField.inputAccessoryView = toolbar
        
        if (oType == 2) {
            phoneTextField.alpha = 1.0
            phoneLabel.alpha = 1.0
        }
        else {
            phoneTextField.alpha = 0.0
            phoneLabel.alpha = 0.0
        }
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func doneClicked () {
        view.endEditing(true)
    }
    
    /*func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return locationArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return locationArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        locationTextField.text = locationArray[row]
        //self.view.endEditing(false)
    }*/

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = ingredientTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! IngredientTableViewCell
        cell.ingredientNameTextField.text = ingredients [indexPath.row].ingredientName
        cell.ingredientNameTextField?.font = UIFont(name:"Helvetica", size:15)
        let numberitem = ingredients [indexPath.row].ingredientQuantity
        cell.numberofItem.text = String (describing: numberitem)
        cell.numberofItem?.font = UIFont(name:"Helvetica", size:15)
        
        let numberitem1 = Int(numberitem)
        firstNumberItemQArray.append((numberitem1 as AnyObject))
        cell.quantity.font = UIFont(name:"Helvetica", size:15)
        
        let cellcalory = ingredients [indexPath.row].ingredientCalory
        cell.itemTotalCalory.text = String (describing: cellcalory)
        let cellcalory1 = Int(cellcalory)
        firstCaloriesArray.append((cellcalory1 as AnyObject))
    
        let var1 = ingredients [indexPath.row].ingredientFat
        let var2 = ingredients [indexPath.row].ingredientCarbs
        let var3 = ingredients [indexPath.row].ingredientProtein
        firstnutr1.append(var1 as AnyObject)
        firstnutr2.append(var2 as AnyObject)
        firstnutr3.append(var3 as AnyObject)
        
        let weight = ingredients [indexPath.row].ingredientWeight
        
        if (weight == 1) {
            cell.quantity.alpha = 1.0
            cell.quantity.text = "gr"
        }
        else {
            cell.quantity.alpha = 1.0
            cell.quantity.text = "nbr"
        }

        cell.minusButton.tag = indexPath.row
        cell.minusButton.addTarget(self, action:#selector(minusAction), for: .touchUpInside)
     
        let ingFat = ingredients [indexPath.row].ingredientFat
        fatArray.append(ingFat)
        sum2 = fatArray.reduce(0,+)
        let ingCarb = ingredients [indexPath.row].ingredientCarbs
        carbArray.append(ingCarb)
        sum3 = carbArray.reduce(0,+)
        let ingProtein = ingredients [indexPath.row].ingredientProtein
        proteinArray.append(ingProtein)
        sum4 = proteinArray.reduce(0,+)
        
        firstnutrition.removeAll()
        firstnutrition.append(Int(sum2))
        firstnutrition.append(Int(sum3))
        firstnutrition.append(Int(sum4))
        //print(firstnutrition)
 
        let caloryStore = ingredients [indexPath.row].ingredientCalory
        caloryStoreArray.removeAll()
        caloryStoreArray.append(caloryStore)
        totalCaloryArray.append(contentsOf:caloryStoreArray)
        //print(totalCaloryArray)
        
        let gr = " grams "
        let numberStore = ingredients [indexPath.row].ingredientQuantity
        let numberStore2 = String(numberStore)
        let numberStore1 = numberStore2 + gr
        let ingredientStore1 = ingredients [indexPath.row].ingredientName
        let ingredientStore2 = ingredientStore1?.trimmingCharacters(in: .whitespaces)
        let ingredientStore = numberStore1 + ingredientStore2! //+ ","
        totalIngredientArray.append(ingredientStore)

        
        values.removeAll()
        
        /* For future use
         
         for caloryStore in totalCaloryArray {
            
            let dataEntry1 = PieChartDataEntry(value: Double(caloryStore), label: "")
            values.append(dataEntry1)
            let pieChartDataSet1 = PieChartDataSet(values: values, label: "Calory Graphic")
            pieChartDataSet1.sliceSpace = 1
            pieChartDataSet1.colors = [UIColor.red, UIColor.yellow, UIColor.blue]
            self.pieView.data = PieChartData(dataSet: pieChartDataSet1)
        }*/
        
        values.removeAll()
        
        let dataEntry2 = PieChartDataEntry(value: Double(sum2),label: "Fat")
        let dataEntry3 = PieChartDataEntry(value: Double(sum3),label: "Carb")
        let dataEntry4 = PieChartDataEntry(value: Double(sum4),label: "Protein")
        values.append(dataEntry2)
        values.append(dataEntry3)
        values.append(dataEntry4)
        let pieChartDataSet2 = PieChartDataSet(values: values, label: "")
        pieChartDataSet2.sliceSpace = 1
        pieChartDataSet2.valueFont = UIFont(name:"Helvetica", size:8)!
        pieChartDataSet2.colors = [UIColor.red, UIColor.purple, UIColor.blue]
        self.pieView2.data = PieChartData(dataSet: pieChartDataSet2)
        
        let fat = "Fat: " + String(sum2)
        let carb = "Carb: " + String(sum3)
        let protein = "Protein: " + String(sum4)
        proteinLabel.text = protein
        carbLabel.text = carb
        fatLabel.text = fat
        
        sum1 = totalCaloryArray.reduce(0,+)
        totalCaloryTextField.text = String(sum1)
        order(totalIngredientArray: totalIngredientArray, sum2: sum1)

        return cell
    }
    
    @IBAction func minusAction(sender: UIButton) {
   
        let buttonRow = sender.tag
        let cell = ingredientTableView.dequeueReusableCell(withIdentifier: "cell")  as! IngredientTableViewCell
        
        let oldTextValue = firstNumberItemQArray[buttonRow]
        let oldTextValue1 = Int64(oldTextValue as! NSNumber)
        let textValue1 = ingredients [buttonRow].ingredientQuantity
        var textValue = Int64(textValue1)
        let textValue2 = textValue - oldTextValue1
        
        if (textValue2 == 0 ) {
            
            cell.minusButton.isEnabled = false
            let noitem: Int64 = 0
            cell.numberofItem.text = String(noitem)
            ingredients [buttonRow].ingredientQuantity = 0
            
            ingredients [buttonRow].ingredientQuantity = Int64(textValue)
            
            cell.numberofItem.text = String(describing: textValue)
            ingredients [buttonRow].ingredientQuantity = Int64(textValue)
            let oldTextValue = firstNumberItemQArray[buttonRow]
            let oldTextValue1 = Int64(oldTextValue as! NSNumber)
            let textValue1 = ingredients [buttonRow].ingredientQuantity
            var textValue = Int64(textValue1)
            textValue = 0 //textValue - oldTextValue1
            cell.numberofItem.text = String(describing: textValue)
            ingredients [buttonRow].ingredientQuantity = Int64(textValue)
            
            let oldcalory = ingredients [buttonRow].ingredientCalory
            let fcCalory1 = firstCaloriesArray[buttonRow]
            let fcCalory = Int64(fcCalory1 as! NSNumber)
            
            cell.itemTotalCalory.text = String((Int64(oldcalory) - fcCalory ))
            let newcalory = cell.itemTotalCalory.text
            ingredients [buttonRow].ingredientCalory = Double(newcalory!)!
            totalCaloryArray.removeAll()
            totalIngredientArray.removeAll()
            
            let name = ingredients [buttonRow].ingredientName
            var nameArray1 = [String] ()
            nameArray1.append(name!)
            var numberArray1 = [Double] ()
            let newcalory1 = Double(newcalory!)
            numberArray1.append(newcalory1!)
            
            let fatFirstNutrition = firstnutr1[buttonRow]
            let carbsFirstNutrition = firstnutr2[buttonRow]
            let proteinFirstNutrition = firstnutr3[buttonRow]
            
            let oldFat = ingredients [buttonRow].ingredientFat
            let oldCarbs = ingredients [buttonRow].ingredientCarbs
            let oldProtein = ingredients [buttonRow].ingredientProtein
            
            let newFat = Double(oldFat) - Double(fatFirstNutrition as! NSNumber)
            let newCarbs = Double(oldCarbs) - Double(carbsFirstNutrition as! NSNumber)
            let newProtein = Double(oldProtein) - Double(proteinFirstNutrition as! NSNumber)
            
            newNutrition.append(Int(newFat))
            newNutrition.append(Int(newCarbs))
            newNutrition.append(Int(newProtein))
            firstnutrition.removeAll()
            fatArray.removeAll()
            carbArray.removeAll()
            proteinArray.removeAll()
            
            ingredients [buttonRow].ingredientFat = newFat
            ingredients [buttonRow].ingredientCarbs = newCarbs
            ingredients [buttonRow].ingredientProtein = newProtein
        }
            
        else if (textValue2 < 0) {
            
            cell.minusButton.isEnabled = false
            let noitem: Int64 = 0
            cell.numberofItem.text = String(noitem)
            ingredients [buttonRow].ingredientQuantity = 0
        }
            
        else  if (textValue2 > 0) {
            
            ingredients [buttonRow].ingredientQuantity = Int64(textValue)
            cell.numberofItem.text = String(describing: textValue)
            ingredients [buttonRow].ingredientQuantity = Int64(textValue)
            let oldTextValue = firstNumberItemQArray[buttonRow]
            let oldTextValue1 = Int64(oldTextValue as! NSNumber)
            let textValue1 = ingredients [buttonRow].ingredientQuantity
            var textValue = Int64(textValue1)
            textValue = textValue - oldTextValue1
            cell.numberofItem.text = String(describing: textValue)
            ingredients [buttonRow].ingredientQuantity = Int64(textValue)
            
            let oldcalory = ingredients [buttonRow].ingredientCalory
            let fcCalory1 = firstCaloriesArray[buttonRow]
            let fcCalory = Int64(fcCalory1 as! NSNumber)
            
            cell.itemTotalCalory.text = String((Int64(oldcalory) - fcCalory ))
            let newcalory = cell.itemTotalCalory.text
            ingredients [buttonRow].ingredientCalory = Double(newcalory!)!
            totalCaloryArray.removeAll()
            totalIngredientArray.removeAll()
            
            let name = ingredients [buttonRow].ingredientName
            var nameArray1 = [String] ()
            nameArray1.append(name!)
            var numberArray1 = [Double] ()
            let newcalory1 = Double(newcalory!)
            numberArray1.append(newcalory1!)
            
            let fatFirstNutrition = firstnutr1[buttonRow]
            let carbsFirstNutrition = firstnutr2[buttonRow]
            let proteinFirstNutrition = firstnutr3[buttonRow]
            
            let oldFat = ingredients [buttonRow].ingredientFat
            let oldCarbs = ingredients [buttonRow].ingredientCarbs
            let oldProtein = ingredients [buttonRow].ingredientProtein
            
            let newFat = Double(oldFat) - Double(fatFirstNutrition as! NSNumber)
            let newCarbs = Double(oldCarbs) - Double(carbsFirstNutrition as! NSNumber)
            let newProtein = Double(oldProtein) - Double(proteinFirstNutrition as! NSNumber)
            
            newNutrition.append(Int(newFat))
            newNutrition.append(Int(newCarbs))
            newNutrition.append(Int(newProtein))
            firstnutrition.removeAll()
            fatArray.removeAll()
            carbArray.removeAll()
            proteinArray.removeAll()
            
            ingredients [buttonRow].ingredientFat = newFat
            ingredients [buttonRow].ingredientCarbs = newCarbs
            ingredients [buttonRow].ingredientProtein = newProtein
        }
        
        refresh();
    }
    
    func refresh() {
        DispatchQueue.main.async {
            self.ingredientTableView.reloadData()
        }
        self.refreshControl.endRefreshing()
    }
    
    func order(totalIngredientArray: [String], sum2: Double) -> ([String],Double) {
        
        sum = sum2
        totalingredients.removeAll()
        t2.removeAll()
        t2 = totalIngredientArray
        totalingredients.append(contentsOf: t2)
        
        return (totalingredients, sum)
    }
    
    @IBAction func orderAction(_ sender: Any) {
        
        //I'm at the Store - Geo location Check
        

        //I'm not in the Store - Check
        /*ref.child("SavedMeal").queryOrdered(byChild: "OrderCompanyID").queryEqual(toValue: selectedCompany).observe(.childAdded, with: {(snapshot) in
            
            if let dictionary1 = snapshot.value as? [String:AnyObject] {
                let smeal = SavedMeal ()
                smeal.setValuesForKeys(dictionary1)
                self.savedmeal1.removeAll()
                self.savedmeal1.append(smeal)
            }
            
            for IngredientID in self.savedmeal1 {
                
                let selectedIngredient = IngredientID.IngredientID
                self.refHandle = self.ref.child("Ingredient").queryOrdered(byChild: "IngredientID").queryEqual(toValue: selectedIngredient).observe(.childAdded, with: { (snapshot) in
                    
                    if let dictionary = snapshot.value as? [String:AnyObject] {
                        let ingredient = Ingredient()
                        ingredient.setValuesForKeys(dictionary)
                        let active = ingredient.ingredientActive
                        if (active == 1) {
                            self.ingredientList.append(ingredient)
                        }
                        DispatchQueue.main.async {
                            self.ingredientTableView.reloadData()
                        }
                    }
                })
            }
        })
        */
        
        let date =  Date().toString()
        let orderId = arc4random()
        let t4 = totalingredients
        let mealactive = 1
        let mealingredientname = String(describing: t4)
        let orderstatus = 1
        let useremail = userEmail
        let companyName = selectedcompany
        let companyEmail = selectedemail
        let companyCategory = selectedcategory
        let companyID = Int64(companyid)
        let fat = sum2
        let carbs = sum3
        let protein = sum4
        let mealnotes = notesTextView.text
        let feedback = ""
        let feedback1 = ""
        let orderlocation = ""
        
        if (self.latitude == nil || self.longtitude == nil) {
            self.uLatitude = 0
            self.uLongitude = 0
        } else {
            self.uLatitude = self.latitude
            self.uLongitude = self.longtitude
        }
        
        if (phoneTextField.alpha == 1.0) {
            
            let phone = phoneTextField.text;
            
            if ((phone?.isEmpty)!) {
                displayMyAlertMessage(userMessage: "Phone field is required.");
                return;
            }
           uPhone = Int64(phoneTextField.text!)
        }
        else {
            uPhone = 0
        }
        
        let meals : [String : AnyObject] = ["CompanyCancelFeedback":feedback1 as AnyObject,
                                            "CompanyOrderFeedback":feedback as AnyObject,
                                            "MealActive":mealactive as AnyObject,
                                            "OrderCompanyName": companyName as AnyObject,
                                            "OrderCompanyCategory": companyCategory as AnyObject,
                                            "OrderCompanyID": companyID as AnyObject,
                                            "OrderCompanyEmail":companyEmail as AnyObject,
                                            "MealIngredientName":mealingredientname as AnyObject,
                                            "MealTotalCalory":sum as AnyObject,
                                            "MealTotalFat":fat as AnyObject,
                                            "MealTotalCarbs":carbs as AnyObject,
                                            "MealTotalProtein":protein as AnyObject,
                                            "OrderDateTime":date as AnyObject,
                                            "OrderID" : orderId as AnyObject,
                                            "OrderLocation": orderlocation as AnyObject,
                                            "OrderNotes": mealnotes as AnyObject,
                                            "OrderStatus":orderstatus as AnyObject,
                                            "OrderType":oType as AnyObject,
                                            "UserEmail": useremail! as AnyObject,
                                            "UserLocationLatitude":self.uLatitude as AnyObject,
                                            "UserLocationLongtitude":self.uLongitude as AnyObject,
                                            "UserPhone":uPhone as AnyObject]
        
        let databaseRef = FIRDatabase.database().reference()
        databaseRef.child("SavedMeal").childByAutoId().setValue(meals)
        
        ref = FIRDatabase.database().reference()
        ref.child("Users").queryOrdered(byChild: "UserEmail").queryEqual(toValue: userEmail).observe(.childAdded, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {
                let user = Users()
                user.setValuesForKeys(dictionary)
                self.key.removeAll()
                self.userlist.append(user)
                self.key.append(snapshot.key)
            }
        
        let tdate =  Date().toString()
        let tid = arc4random()
        let tactive = 1
        let tfee = 1
        let tuemail = self.userEmail
        let tcompany = self.selectedcompany
        let tcompanyemail = self.selectedemail
        let tcompanycategory = self.selectedcategory
        let tcompanyid = Int64(self.companyid)
        let date = NSDate()
        let calender = NSCalendar.current
        let ttime1 = calender.dateComponents([.hour, .minute], from: date as Date)
        let hour1 = ttime1.hour
        let hour =  ("\(hour1!)")
        let minutes1 = ttime1.minute
        let minutes = ("\(minutes1!)")
        let ttime = hour + ":" + minutes
        let tuser = self.userlist[0].Name! + " " + self.userlist[0].Surname!
        let torderid = orderId
        
        let income : [String : AnyObject] = ["TransactionActive":tactive as AnyObject,
                                             "TransactionCompany":tcompany as AnyObject,
                                             "TransactionCompanyCategory":tcompanycategory as AnyObject,
                                             "TransactionCompanyEmail":tcompanyemail as AnyObject,
                                             "TransactionCompanyID":tcompanyid as AnyObject,
                                             "TransactionDate":tdate as AnyObject,
                                             "TransactionFee": tfee as AnyObject,
                                             "TransactionID": tid as AnyObject,
                                             "TransactionOrderID": torderid as AnyObject,
                                             "TransactionTime": ttime as AnyObject,
                                             "TransactionUser":tuser as AnyObject,
                                             "TransactionUserEmail":tuemail as AnyObject]
        
        let databaseRef1 = FIRDatabase.database().reference()
        databaseRef1.child("Transaction").childByAutoId().setValue(income)
        
        })
        
        /*if MFMailComposeViewController.canSendMail() {
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self
            mailComposerVC.setToRecipients([userEmail!,companyEmail!])
            mailComposerVC.setSubject("Meal Designer Order")
            mailComposerVC.setMessageBody("Setting up a body message!", isHTML: false)
            
            self.present(mailComposerVC, animated: true, completion: {() -> Void in })
        }*/
        orderButton.isEnabled = false
        displayMyAlertMessage(userMessage: "Order is sent.");
    }
    
    func displayMyAlertMessage (userMessage:String) {
        
        let myAlert = UIAlertController (title:"Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.alert);
        let okAction = UIAlertAction(title:"Ok", style:UIAlertActionStyle.default, handler:nil);
        myAlert.addAction(okAction);
        self.present(myAlert, animated:true,completion:nil);
    }
    
    func performSegueToReturnBack()  {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func backTapped(_ sender: Any) {

        performSegueToReturnBack()
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Swift.Error?){
        //controller.dismiss(animated: true, completion: nil)
        controller.dismiss(animated: true) { () -> Void in }
    }
    
    func removeSpecialCharsFromString(text: String) -> String {
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-*=(),.:!_".characters)
        return String(text.characters.filter {okayChars.contains($0) })
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
    
        let t4 = totalingredients
        let firstIngredientStyle =  ("\(t4)")
        let lastIngredientStyle = self.removeSpecialCharsFromString(text: firstIngredientStyle)
        let stringredientcontain = lastIngredientStyle
        let companyName = selectedcompany
        let calory = String(sum)
        let fat = String(sum2)
        let carbs = String(sum3)
        let protein = String(sum4)
        let strlist1 = "I'm eating " + stringredientcontain + " at " + companyName!
        let strlist = ". Calory :" + calory + ". Fat: " + fat
        let strlist2 = ". Carbs: " + carbs + ". Protein: " + protein + " @MoveNic App"
        let str = strlist1 + strlist + strlist2
        
        let vc = UIActivityViewController(activityItems: [str], applicationActivities: nil)
        self.present(vc,animated:true,completion:nil)
        
    }
}


/*func configuredMailComposeViewController() -> MFMailComposeViewController {
 
 let mailComposerVC = MFMailComposeViewController()
 mailComposerVC.mailComposeDelegate = self
 mailComposerVC.setToRecipients(["gozdebal@gmail.com"])
 mailComposerVC.setSubject("Sending you an in-app e-mail...")
 mailComposerVC.setMessageBody("Sending e-mail in-app is not so bad!", isHTML: false)
 //present(mailComposerVC, animated: true, completion: nil)
 
 return mailComposerVC
 }
 
 func showSendMailErrorAlert() {
 let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
 sendMailErrorAlert.show()
 }*/
