//
//  DetailViewController.swift
//  ReadingRightTask
//
//  Created by Chandra Hasan on 05/08/21.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var imgView: UIImageView!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var areaLbl: UILabel!
    @IBOutlet var catLbl: UILabel!
    @IBOutlet var ingrediantsLbl: UILabel!
    @IBOutlet var procedureLbl: UILabel!
    var itemData: FoodListModel?
    var id: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        ANLoader.pulseAnimation = true //It will animate your Loading
        ANLoader.activityColor = .black
        ANLoader.activityBackgroundColor = .clear
        ANLoader.activityTextColor = .clear
        // Do any additional setup after loading the view.
        getItemData()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: API call USing item id
    func getItemData() {
        let url : String = "https://www.themealdb.com/api/json/v1/1/lookup.php?i=" + id
        ANLoader.showLoading()
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(FoodListModel.self, from: data) {
                    DispatchQueue.main.async {
                        self.itemData = decodedResponse
                        self.setUpView()
                    }
                }
            }
            ANLoader.hide()
        })
        task.resume()
    }
    
    func setUpView() {
        
        imgView.setCustomImage(itemData?.meals![0].strMealThumb ?? "")
        titleLbl.text = itemData?.meals![0].strMeal
        catLbl.text = itemData?.meals![0].strCategory
        areaLbl.text = itemData?.meals![0].strArea
        procedureLbl.text = itemData?.meals![0].strInstructions
        ingrediantsLbl.text = "\(itemData?.meals![0].strIngredient1 ?? "") - \(itemData?.meals![0].strMeasure1 ?? "") , \(itemData?.meals![0].strIngredient2 ?? "") - \(itemData?.meals![0].strMeasure2 ?? "") , \(itemData?.meals![0].strIngredient3 ?? "") - \(itemData?.meals![0].strMeasure3 ?? "") , \(itemData?.meals![0].strIngredient4 ?? "") - \(itemData?.meals![0].strMeasure4 ?? "") , \(itemData?.meals![0].strIngredient5 ?? "") - \(itemData?.meals![0].strMeasure5 ?? "") , \(itemData?.meals![0].strIngredient6 ?? "") - \(itemData?.meals![0].strMeasure6 ?? "") , \(itemData?.meals![0].strIngredient7 ?? "") - \(itemData?.meals![0].strMeasure7 ?? "") , \(itemData?.meals![0].strIngredient8 ?? "") - \(itemData?.meals![0].strMeasure8 ?? "") , \(itemData?.meals![0].strIngredient9 ?? "") - \(itemData?.meals![0].strMeasure9 ?? "") , \(itemData?.meals![0].strIngredient10 ?? "") - \(itemData?.meals![0].strMeasure10 ?? "") , \(itemData?.meals![0].strIngredient11 ?? "") - \(itemData?.meals![0].strMeasure11 ?? "") , \(itemData?.meals![0].strIngredient12 ?? "") - \(itemData?.meals![0].strMeasure12 ?? "") , \(itemData?.meals![0].strIngredient13 ?? "") - \(itemData?.meals![0].strMeasure13 ?? ""), \(itemData?.meals![0].strIngredient14 ?? "") - \(itemData?.meals![0].strMeasure14 ?? "")"
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sourceBtnAction(_ sender: Any) {
        if let url = URL(string: (itemData?.meals![0].strSource)!) {
            UIApplication.shared.open(url)
        }
    }
    
    
}
