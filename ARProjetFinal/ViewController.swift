//=====================================
import UIKit
//=====================================
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {


    @IBOutlet weak var tableV: UITableView!
    @IBOutlet weak var newElement: UITextField!
    
    var viewContent: [String] = []
    var viewContent2: [Bool] = []
    var aDict: [String: Bool] = [:]
    var defaults = UserDefaults.standard
    var valuesToSend : [String] = []

    
    //-------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableV.allowsMultipleSelection = true
        Singleton.instancePartage.unArray.removeAll()
        Singleton.instancePartage.unArray2.removeAll()
        getInfo()
        loadData()
    }
    //-------------------------
    func loadData() {
        viewContent = []
        for a in Singleton.instancePartage.unArray{
            viewContent.append(a)
        }
        for b in Singleton.instancePartage.unArray2{
            viewContent2.append(b)
        }
    }
    //-------------------------
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getInfo() {
        
        let urlString = "http://localhost/dashboard/robitaille/check_list_php/data.json"
        
        do {
            if let url = URL(string: urlString) {
                let data = try Data(contentsOf: url)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [String : String] {
                    print(object)
                    
                    for (a,b) in object {
                        let status: Bool
                        Singleton.instancePartage.unArray.append(a)
                        if b == "true"{ status = true}
                        else { status = false}
                        Singleton.instancePartage.unArray2.append(status)
                    }
                    
                } else {
                    print("JSON INVALID")
                }
            } else{
                print("no file")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //---Bouton ajouter
    @IBAction func Ajouter(_ sender: UIButton) {
        
        //*** AJOUTER UNE ALERTE POUR LA SAUVEGARDE ***
        if(newElement.text?.isEmpty)!{
            let alerte = UIAlertController(title: "Champ vide", message:"Veuillez entrer une tâche pour l'ajouter à la liste", preferredStyle: UIAlertControllerStyle.alert)
            alerte.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            self.present(alerte,animated: true, completion: nil)
        }
        else{
            self.view.endEditing(true)
            Singleton.instancePartage.unArray.append(newElement.text!)
            Singleton.instancePartage.unArray2.append(false)
            loadData()
            tableV.reloadData()
        }
        newElement.text = ""
    }
    //---Bouton Sauvegarder
    //sauvegarder toutes les infos sur le serveur
    @IBAction func Sauvegarder(_ sender: UIButton) {
        
        var dictionary: [String : Bool] = [:]
        
        for a in 0..<Singleton.instancePartage.unArray.count{
            dictionary[Singleton.instancePartage.unArray[a]] = Singleton.instancePartage.unArray2[a]
        }
        
        var urlToSend = "http://localhost/dashboard/robitaille/check_list_php/add.php?json=["
        var counter = 0
        let total = dictionary.count
        for (a, b) in dictionary {
            let noSpaces = replaceChars(originalStr: a, what: " ", byWhat: "_")
            counter += 1
            if counter < total {
                urlToSend += "/\(noSpaces)/,/\(b)/!"
            } else {
                urlToSend += "/\(noSpaces)/,/\(b)/"
            }
        }
        urlToSend += "]"
        
        print(urlToSend)
        
        let session = URLSession.shared
        let urlString = urlToSend
        let url = NSURL(string: urlString)
        let request = NSURLRequest(url: url! as URL)
        let dataTask = session.dataTask(with: request as URLRequest) {
            (data:Data?, response:URLResponse?, error:Error?) -> Void in
        }
        dataTask.resume()
        
    }
    
    //---Methode pour remplace les caractères pour le php
    func replaceChars(originalStr: String, what: String, byWhat: String) -> String {
        return originalStr.replacingOccurrences(of: what, with: byWhat)
    }
    
    //---Bouton réinitialiser
    //déselectionner toutes les taches sélectionnés
    @IBAction func Reinitialiser(_ sender: UIButton) {
        tableV.reloadData()
    }
   
    //---Bouton charger
    //va chercher les informations sauvegarder sur le serveur et update la liste
    @IBAction func Charger(_ sender: UIButton) {
        
        Singleton.instancePartage.unArray.removeAll()
        Singleton.instancePartage.unArray2.removeAll()
        getInfo()
        loadData()
        tableV.reloadData()
    }
    
    //---Bouton Voir Liste
    //Prend les elements sélectionné et les envoies dans la liste
    @IBAction func VoirListe(_ sender: UIButton) {
        valuesToSend.removeAll()
        let selected_indexPaths = tableV.indexPathsForSelectedRows
        for indexPath in selected_indexPaths! {
            let cell = tableV.cellForRow(at: indexPath)
            valuesToSend.append((cell?.textLabel?.text)!)
        }
        print(valuesToSend)
        
    }
    
    //---Methode faire le segue avec les éléments sélectionnées
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "liste" {
            let secondVC = segue.destination as! SecondViewController
            secondVC.values2 = valuesToSend
        }
    }
    
    //----Methodes pour table view-----------------
    //----Nombre de cellules
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.backgroundColor = UIColor.clear
        return viewContent.count
    }
    
    //---------------------
    //----Texte dans les cellules
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell(style:UITableViewCellStyle.default, reuseIdentifier:"proto")
        cell.textLabel!.text = viewContent[indexPath.row]
        cell.textLabel?.textColor = UIColor.white
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    //---------------------
    //----Selection des cellules
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath as IndexPath)!
        selectedCell.contentView.backgroundColor = UIColor.darkGray
        
        if Singleton.instancePartage.unArray2[indexPath.row] == false {
          Singleton.instancePartage.unArray2[indexPath.row] = true
        }
        else {
            Singleton.instancePartage.unArray2[indexPath.row] = false
        }
    }
    
    
    //---------------------
    //----Éliminer les cellules
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            viewContent.remove(at: indexPath.row)
            viewContent2.remove(at: indexPath.row)
            Singleton.instancePartage.unArray.remove(at: indexPath.row)
            Singleton.instancePartage.unArray2.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
        }
    }
    //---------------------
    
}

