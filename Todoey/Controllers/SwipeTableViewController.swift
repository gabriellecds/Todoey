import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // tableView.rowHeight = 70.0
    }
    
    // TableView Datasource Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        
        return cell
        
    }

    
    // Método que define as ações de swipe para a célula na posição indexPath
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // Handle action by updating model with deletion
            self.updateModel(at: indexPath)
        }

        // Customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")

        return [deleteAction]
    }
    
    // Define opções de swipe para a célula na posição indexPath
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        
        return options
    }
    
    // Método auxiliar para atualizar o modelo de dados após exclusão
    func updateModel(at indexPath: IndexPath) {
        // O codigo está em Category View Controller, substituindo o que
        // estaria aqui com o "override". 
    }
}
