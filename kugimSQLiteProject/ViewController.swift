
import UIKit
import SQLite


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    // Step 1
    var database: Connection!
    
    // Step 3
    let contactTable = Table("contacts")
    let id = Expression<Int64>("id")
    let name = Expression<String>("name")
    let email = Expression<String>("email")
    
    
    // Step 4
    func createTable() {
        let createTable = self.contactTable.create {
            (table) in
            table.column(self.id, primaryKey: true)
            table.column(name)
            table.column(email)
        }
        
        do {
            try self.database.run(createTable)
            print("Contact Table Created")
        } catch {
            print(error)
        }
        
    }
    
    // Step 7 -> List Contacts
    func listContacts() {
        do {
            let contacts = try self.database.prepare(self.contactTable)
            contactListArray = [Contact]()
            
            for cnt in contacts {
                contactListArray.append(
                    Contact(
                        id: cnt[self.id],
                        name: cnt[self.name],
                        email: cnt[self.email]
                    )
                )
            }
            print(contactListArray)
            contactTableOutlet.reloadData()
            print("Contacts Listed")
        } catch {
            print(error)
        }
    }
    
    var contactListArray = [Contact]()
    var contactID: Int64 = 0
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellItem = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cellItem.textLabel!.text = contactListArray[indexPath.row].name
        return cellItem
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        contactID = contactListArray[indexPath.row].id
        nameFieldOutlet.text = contactListArray[indexPath.row].name
        emailFieldOutlet.text = contactListArray[indexPath.row].email
    }
    
    @IBOutlet weak var nameFieldOutlet: UITextField!
    @IBOutlet weak var emailFieldOutlet: UITextField!
    @IBOutlet weak var contactTableOutlet: UITableView!
    
    @IBAction func insertButtonAction(_ sender: UIButton) {
        
        // Step 6
        let nameField = nameFieldOutlet.text
        let emailField = emailFieldOutlet.text
        
        let insertContact = self.contactTable.insert(
            name <- nameField!,
            email <- emailField!
        )
        
        do {
            try self.database.run(insertContact)
            print("contact added")
        } catch {
            print(error)
        }
        
        listContacts()
        
        print("Insert Islemi Yapildi")
    }
    
    @IBAction func updateButtonAction(_ sender: UIButton) {
        if contactID > 0 {
            let contact = self.contactTable.filter(self.id == contactID)
            
            let nameField = nameFieldOutlet.text
            let emailField = emailFieldOutlet.text
            
            let updateContact = contact.update(
                self.name <- nameField!,
                self.email <- emailField!
            )
            
            do {
                try self.database.run(updateContact)
                print("contact updated")
            } catch {
                print(error)
            }
            
        }
        
        print("Update Islemi Yapildi")
    }
    
    
    @IBAction func deleteActionButton(_ sender: UIButton) {
        if contactID > 0 {
            let contact = self.contactTable.filter(self.id == contactID)

            
            do {
                try self.database.run(contact.delete())
                listContacts()
                
                print("contact delete")
            } catch {
                print(error)
            }
            
        }
        
        print("Delete Islemi Yapildi")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Step 2 -> Create DB
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("contact").appendingPathExtension("sqlite3")
            let db = try Connection(fileUrl.path)
            self.database = db
        } catch {
            print(error)
        }
        
        // Step 5 -> Create Table
        createTable()
        
        listContacts()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
