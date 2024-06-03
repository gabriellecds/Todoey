//
//  ViewController.swift
//  Todoey
//
//  Created by Gabrielle Oliveira on 21/05/24.
//

import UIKit
import CoreData
import SwipeCellKit
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
    
    var itemArray = [Item]()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }

    let context = (UIApplication.shared.delegate as!AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            if let colorHex = selectedCategory?.color, let navBar = navigationController?.navigationBar {
                
                guard let navBarColor = UIColor(hexString: colorHex) else { fatalError("Invalid color hex string.") }
                
                // Update the navigation bar color
                navBar.barTintColor = navBarColor
                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
                
                if #available(iOS 15.0, *) {
                    let appearance = UINavigationBarAppearance()
                    appearance.configureWithOpaqueBackground()
                    appearance.backgroundColor = navBarColor
                    appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
                    appearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
                    navBar.standardAppearance = appearance
                    navBar.scrollEdgeAppearance = appearance
                }
                
                title = selectedCategory?.name
                searchBar.barTintColor = navBarColor
                
                if let textField = searchBar.value(forKey: "searchField") as? UITextField {
                    textField.backgroundColor = UIColor.white  // Cor de fundo do campo de texto
                    textField.textColor = UIColor.black  // Cor do texto
                    textField.tintColor = UIColor.black  // Cor do cursor
                    textField.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])  // Cor do placeholder
                }
            }
        }
    
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // herdando a celula da super classe (.super) para que seja uma celula swipe
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        
        if let colour = UIColor(hexString: selectedCategory!.color!)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(itemArray.count)){
            cell.backgroundColor = colour
            
            cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
        }
   
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        self.saveItems()

        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .cancel) { (action) in
            
            let newItem = Item(context: self.context)
            newItem.done = false
            newItem.title = textField.text!
            newItem.dateCreated = Date()
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
                
            self.saveItems()
                
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manipulation Methods
    
    func saveItems() {
        
        DispatchQueue.global(qos: .background).async {
            
            do {
                try self.context.save()
            }
            catch {
                print("Error saving context \(error)")
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil){
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let aditionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, aditionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        }
        catch {
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
    }
    //MARK: - Delete Data from Swipe

        override func updateModel(at indexPath: IndexPath) {
            
            context.delete(itemArray[indexPath.row])
            itemArray.remove(at: indexPath.row)
            
            saveItems()
            
        }
    }


//MARK: - Search Bar Methods

extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async{
                searchBar.resignFirstResponder()
            }
        }
    }
}





