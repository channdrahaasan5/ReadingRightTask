//
//  ViewController.swift
//  ReadingRightTask
//
//  Created by Chandra Hasan on 04/08/21.
//

import UIKit

class ViewController: UIViewController {
    var randomData: FoodListModel?
    var searchData: FoodListModel?
    var favData: Array<Any> = []
    var isRandomData: Bool!
    var isSearchData: Bool!
    var isFavData: Bool!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBarView: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        isRandomData = true
        isFavData = true
        self.tableView.register(UINib(nibName: "FoodCell", bundle: nil), forCellReuseIdentifier: "FoodCell")
        self.tableView.register(UINib(nibName: "EmptyViewCell", bundle: nil), forCellReuseIdentifier: "EmptyViewCell")
        favData = UserDefaults.standard.value(forKey: "favData") as? Array<Any> ?? []
        ANLoader.pulseAnimation = true //It will animate your Loading
        ANLoader.activityColor = .black
        ANLoader.activityBackgroundColor = .clear
        ANLoader.activityTextColor = .clear
        getRandomData()
    }
    
    // MARK: API call for get random data
    func getRandomData() {
        let url : String = "https://www.themealdb.com/api/json/v1/1/random.php"
        ANLoader.showLoading()
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(FoodListModel.self, from: data) {
                    DispatchQueue.main.async {
                        self.randomData = decodedResponse
                        self.tableView.reloadData()
                    }
                }
            }
            ANLoader.hide()
        })
        task.resume()
    }
    
    // MARK: API call for search text
    func getSearchData(searchStr: String) {
        let url : String = "https://www.themealdb.com/api/json/v1/1/search.php?s=" + searchStr
        ANLoader.showLoading()
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(FoodListModel.self, from: data) {
                    DispatchQueue.main.async {
                        self.searchData = decodedResponse
                        self.tableView.reloadData()
                    }
                }
            }
            ANLoader.hide()
        })
        task.resume()
    }
    
    // MARK: Get Fav Data
    func getFavAvailData(id: String)-> Bool {
        let userDef = UserDefaults.standard
        let favDatas =  (userDef.value(forKey: "favData") ?? []) as! Array<Any>
        if(favDatas.count > 0) {
            for i in 0...favDatas.count - 1 {
                let food = favDatas[i] as! Dictionary<String, Any>
                if((food["idMeal"] as! String) == id) {
                    return true
                }
            }
        }
        return false
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchBarView.endEditing(true)
        searchBarView.resignFirstResponder()
    }
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(isRandomData) {
            return 2
        } else if(isSearchData) {
            return 1
        } else if (isFavData) {
            return 2
        }
        return 0
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if(isRandomData) {
            if(section == 0) {
                return "Favorite list"
            } else {
                return "Random Data"
            }
        } else if(isSearchData) {
            return "Search Data"
        }
        return "List"
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var num: Int!
        if(section == 0) {
            if (isFavData) {
                num = favData.count
           } else if(isSearchData) {
                num = searchData?.meals?.count ?? 0
            }
        } else if (section == 1) {
             if(isRandomData) {
                 num = randomData?.meals!.count ?? 0
             }
        }
        
        if(num > 0) {
            return num
        }
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var meals: Meals?
        
        if(indexPath.section == 0) {
            if (isFavData) {
                if(favData.count > 0) {
                    let food = favData[indexPath.row] as! Dictionary<String, Any>
                    let cell = tableView.dequeueReusableCell(withIdentifier: "FoodCell") as! FoodCell
                    DispatchQueue.global(qos: .userInitiated).async {
                        DispatchQueue.main.async {
                            cell.thumbnailImg.setCustomImage(food["strMealThumb"] as? String)
                        }
                    }
                    cell.titleLabel.text = food["strMeal"] as? String
                    cell.categoryLabel.text = food["strCategory"] as? String
                    cell.areaLabel.text = food["strArea"] as? String
                    cell.favBtn.addTarget(self, action: #selector(removeFromFavBtn(sender:)), for: .touchUpInside)
                    cell.favBtn.layer.setValue(food["idMeal"], forKey: "idMeal")
                    cell.favBtn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyViewCell") as! EmptyViewCell
                    return cell
                }
            } else if(isSearchData) {
                meals = searchData?.meals?[indexPath.row]
            }
        } else if (indexPath.section == 1) {
            if(isRandomData) {
                meals = randomData?.meals![indexPath.row]
            }
        }
        if(meals == nil) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyViewCell") as! EmptyViewCell
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodCell") as! FoodCell
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                cell.thumbnailImg.setCustomImage(meals?.strMealThumb ?? "")
            }
        }
        cell.titleLabel.text = meals?.strMeal
        cell.categoryLabel.text = meals?.strCategory
        cell.areaLabel.text = meals?.strArea
        cell.favBtn.addTarget(self, action: #selector(addToFavData(sender:)), for: .touchUpInside)
        cell.favBtn.layer.setValue(meals, forKey: "meals")
        if(getFavAvailData(id: (meals?.idMeal)!)) {
            cell.favBtn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            cell.favBtn.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var meals: Meals?

        if(indexPath.section == 0) {
            if (isFavData) {
                let food = favData[indexPath.row] as! Dictionary<String, Any>
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController
                vc!.id = food["idMeal"] as! String
                self.present(vc!, animated: true, completion: nil)
            } else if(isSearchData) {
                meals = searchData?.meals![indexPath.row]
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController
                vc?.id = (meals?.idMeal)!
                self.present(vc!, animated: true, completion: nil)
            }
        } else if (indexPath.section == 1) {
            if(isRandomData) {
                meals = randomData?.meals![indexPath.row]
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController
                vc?.id = (meals?.idMeal)!
                self.present(vc!, animated: true, completion: nil)
            }
        }
    }
    
    @objc func addToFavData(sender: UIButton) {
        let tempData = sender.layer.value(forKey: "meals") as! Meals
        let favDatas = (UserDefaults.standard.array(forKey: "favData") ?? []) as Array
        if(favDatas.count > 0) {
            for i in 0...favDatas.count - 1 {
                let food = favDatas[i] as! Dictionary<String, Any>
                if((food["idMeal"] as! String) == tempData.idMeal) {
                    removeFromFav(id: tempData.idMeal!)
                    return
                }
            }
            addAsFav(meals: tempData)
        } else {
            addAsFav(meals: tempData)
        }
    }
    
    func addAsFav(meals: Meals ) {
        var food = (UserDefaults.standard.array(forKey: "favData") ?? []) as Array
        var tempDict = Dictionary<String, String>()
        tempDict["strMeal"] = meals.strMeal
        tempDict["strArea"] = meals.strArea
        tempDict["strMealThumb"] = meals.strMealThumb
        tempDict["strCategory"] = meals.strCategory
        tempDict["strCategory"] = meals.strCategory
        tempDict["idMeal"] = meals.idMeal
        food.append(tempDict)
        UserDefaults.standard.set(food, forKey: "favData")
        UserDefaults.standard.synchronize()
        favData = UserDefaults.standard.value(forKey: "favData") as? Array<Any> ?? []
        tableView.reloadData()
    }
    
    @objc func removeFromFavBtn(sender: UIButton) {
        let id = sender.layer.value(forKey: "idMeal")
        removeFromFav(id: id as! String)
    }
    func removeFromFav(id: String) {
        let userDef = UserDefaults.standard
        var favDatas =  (userDef.value(forKey: "favData") ?? []) as! Array<Any>
        if(favDatas.count > 0) {
            for i in 0...favDatas.count - 1 {
                let food = favDatas[i] as! Dictionary<String, Any>
                if((food["idMeal"] as! String) == id) {
                    favDatas.remove(at: i)
                    break
                }
            }
        }
        userDef.removeObject(forKey: "favData")
        userDef.setValue(favDatas, forKey: "favData")
        userDef.synchronize()
        favData = UserDefaults.standard.value(forKey: "favData") as? Array<Any> ?? []
        tableView.reloadData()
    }
}

extension UIImageView {

    func setCustomImage(_ imgURLString: String?) {
        guard let imageURLString = imgURLString else {
            self.image = UIImage(named: "default.png")
            return
        }
        DispatchQueue.global().async { [weak self] in
            let data = try? Data(contentsOf: URL(string: imageURLString)!)
            DispatchQueue.main.async {
                self?.image = data != nil ? UIImage(data: data!) : UIImage(named: "default.png")
            }
        }
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if(searchBar.text!.count < 1) {
            isRandomData = true
            isSearchData = false
            isFavData = true
            tableView.reloadData()
        } else {
            isRandomData = false
            isSearchData = true
            isFavData = false
            getSearchData(searchStr: searchBar.text!)
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isRandomData = true
        isSearchData = false
        isFavData = true
        tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.count < 1) {
            isRandomData = true
            isSearchData = false
            isFavData = true
            tableView.reloadData()
        }
    }
}
