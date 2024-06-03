//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Gabrielle Oliveira on 23/05/24.
//

import UIKit
import CoreData
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    var categories = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navBar = navigationController?.navigationBar {
     
            let defaultColor = UIColor.black
            navBar.barTintColor = defaultColor
            navBar.tintColor = ContrastColorOf(defaultColor, returnFlat: true)
            navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(defaultColor, returnFlat: true)]
            
            if #available(iOS 15.0, *) {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = defaultColor
                appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(defaultColor, returnFlat: true)]
                appearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(defaultColor, returnFlat: true)]
                navBar.standardAppearance = appearance
                navBar.scrollEdgeAppearance = appearance
            }
            
            title = "Todoey"
        }
    }
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
      
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let category = categories[indexPath.row]
        
        cell.textLabel?.text = category.name
        
        if let colorHex = category.color, let color = UIColor(hexString: colorHex){
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        } 
        else {
            let color = UIColor.randomFlat()
            category.color = color.hexValue()
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        }
        
        return cell
        
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories[indexPath.row]
        }
    }
    
    //MARK: - Data Manipulation Methods
    
    func saveCategories(){
        
        do {
            try context.save()
        } catch {
            print("Error saving Category \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadCategories() {
        
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error loading categories \(error)")
        }
        
        tableView.reloadData()
    }
    
    //MARK: - Delete Data from Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        
        self.context.delete(self.categories[indexPath.row])
        self.categories.remove(at: indexPath.row)
        
        do {
         try self.context.save()
        } catch {
         print("Error saving context after deletion \(error)")
        }
    }
    
    //MARK: - Add new Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) {(action) in
        
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat().hexValue()
            
            self.categories.append(newCategory)
            self.saveCategories()
        }
        
        alert.addAction(action)
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Add a new Category"
        }
        
        present(alert, animated: true, completion: nil)
    }
}
