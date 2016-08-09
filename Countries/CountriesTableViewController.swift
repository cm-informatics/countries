//
//  CountriesTableViewController.swift
//  Countries
//
//  Created by Christian Mansch on 17.07.16.
//  Copyright © 2016 Christian Mansch. All rights reserved.
//

import UIKit

class CountriesTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {

    var countries: NSArray = []
    var filteredCountries: NSArray = []
    var shouldShowSearchResults = false
    
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureSearchController()
        getCountries()
        
        
        navigationItem.prompt = "Countries"
        
    }
    override func viewWillAppear(animated: Bool) {
        searchController.searchBar.hidden = false
    }
    
    func getCountries() {
        
        let JSONFile = NSBundle.mainBundle().pathForResource("countries", ofType: "json")
        let data = NSData(contentsOfFile: JSONFile!)!
    
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: [])
             countries =  NSArray(array: json as! [AnyObject])
            
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
        }
        
    }
    
    func configureSearchController()
    {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search here..."
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.hidesNavigationBarDuringPresentation = false
        //self.tableView.tableHeaderView = searchController.searchBar
        navigationItem.titleView = searchController.searchBar
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        /*shouldShowSearchResults = true
        tableView.reloadData()*/
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        
        // To still display the search results when the search button is tapped, not the whole list
        if searchBar.text != "" {
            shouldShowSearchResults = true
        }
        else{
            shouldShowSearchResults = false
        }
        
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            tableView.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        shouldShowSearchResults = false
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        
        if searchString != ""{
            shouldShowSearchResults = true
        }
        else{
            shouldShowSearchResults = false
        }
        
        // Filter the data array and get only those countries that match the search text.
        filteredCountries = countries.filter({ (country) -> Bool in
            let countryText: NSString = country.objectForKey("cn_short_en") as! NSString
            
            return (countryText.rangeOfString(searchString!, options: NSStringCompareOptions.CaseInsensitiveSearch).location) != NSNotFound
        })
        
        // Reload the tableview.
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResults{
            return filteredCountries.count
        }
        else{
            return countries.count
        }
        
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)

        if shouldShowSearchResults{
            if filteredCountries[indexPath.row].valueForKey("states")!.count != 0{
                cell.accessoryType = .DisclosureIndicator
            }
            else{
                cell.accessoryType = .None
            }
        
            cell.textLabel?.text = String(filteredCountries[indexPath.row].valueForKey("cn_short_en")!)
            
        }
        else{
            if countries[indexPath.row].valueForKey("states")!.count != 0{
                cell.accessoryType = .DisclosureIndicator
            }
            else{
                cell.accessoryType = .None
            }
            
            cell.textLabel?.text = String(countries[indexPath.row].valueForKey("cn_short_en")!)
        }
        return cell
    }

    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if tableView.cellForRowAtIndexPath(indexPath)?.accessoryType == .DisclosureIndicator
        {
            // Hide search bar and keyboard when presenting a detail view
            searchController.searchBar.hidden = true
            searchController.searchBar.resignFirstResponder()
            
            if !shouldShowSearchResults
            {
                if let states = countries[indexPath.row].valueForKey("states")
                {
                    let nameOftheStates = states.valueForKey("zn_name_local")
        
                    let stvc: StatesTableViewController = StatesTableViewController()
                    stvc.initWithStates(nameOftheStates as! NSArray, numberOfStates: (countries[indexPath.row].valueForKey("states")?.count)!)
        
                    self.navigationController?.pushViewController(stvc, animated: true)
                }
            }
            else
            {
                if let states = filteredCountries[indexPath.row].valueForKey("states")
                {
                    let nameOftheStates = states.valueForKey("zn_name_local")
                    
                    let stvc: StatesTableViewController = StatesTableViewController()
                    stvc.initWithStates(nameOftheStates as! NSArray, numberOfStates: (filteredCountries[indexPath.row].valueForKey("states")?.count)!)
                    
                    self.navigationController?.pushViewController(stvc, animated: true)
                }

            }
        }
        
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
