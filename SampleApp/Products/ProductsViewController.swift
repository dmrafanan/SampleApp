//
//  ViewController.swift
//  SampleApp
//
//  Created by Daniel Marco Rafanan on 8/24/22.
//

import UIKit

class ProductsViewController: UIViewController {
    
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    @IBOutlet private weak var bottomActionView: UIView!
    @IBOutlet private weak var bottomActionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var moveButton: UIButton!
    
    
    
    private var folders = ["Wants", "Needs"]
    
    private var products: [Product] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews(){
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editProducts))
        
        let layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        collectionView.collectionViewLayout = listLayout
        
        collectionView.allowsSelection = false
        
        collectionView.allowsMultipleSelectionDuringEditing = true
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
        NetworkManager.shared.fetchProducts { [weak self] result in
            
            switch result{
            case .success(let products):
                
                self?.products = products
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()

                }
                
            case .failure(let networkError):
                
                let errorMessage:String
                switch networkError{
                case .errorFetching:
                    errorMessage = "Error Fetching"
                case .cantParseData:
                    errorMessage = "Can't parse data"
                case .wrongUrl:
                    errorMessage = "Wrong Url"
                case .networkError(let description):
                    errorMessage = description
                }
                let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                self?.present(alert, animated: true)
            }
        }
        
        bottomActionViewHeightConstraint.constant = 0
        
//        layer.shadowColor = UIColor.black.cgColor
        bottomActionView.layer.shadowOpacity = 0.3
        bottomActionView.layer.shadowOffset = .zero
        bottomActionView.layer.shadowRadius = 5
    }
    
    
    @objc private func editProducts(){
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Select", style: .default, handler: { [weak self] _ in
            
            self?.collectionView.isEditing = true
            self?.collectionView.allowsSelection = true
            self?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self?.finishEditingProducts))
            
            self?.bottomActionViewHeightConstraint.constant = 80
            UIView.animate(withDuration: 0.3) {
                self?.view.layoutIfNeeded()
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @IBAction private func moveButton(_ sender: Any) {
        
        collectionView.indexPathsForSelectedItems?.filter({$0.section == 1}).sorted().reversed().forEach({ indexPathWithSectionOne in
            products.remove(at: indexPathWithSectionOne.row)
        })
        self.collectionView.performBatchUpdates({
            self.collectionView.deleteItems(at: collectionView.indexPathsForSelectedItems ?? [])
            }, completion:nil)
        
        let alert = UIAlertController(title: nil, message: "Selected topic has been moved", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true)
        
        collectionView.reloadData()
        moveButton.isEnabled = false
        
    }
    
    @objc private func finishEditingProducts(){
        finishedEditing()
    }
    
    private func finishedEditing(){
        collectionView.isEditing = false
        moveButton.isEnabled = false
        collectionView.allowsSelection = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editProducts))
        
        bottomActionViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }

}

extension ProductsViewController: UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch section{
        case 0:
            return folders.count
        case 1:
            return products.count
        default:
            return 0
        }
    }
}

extension ProductsViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productReuseIdentifier", for: indexPath) as? UICollectionViewListCell else {
            return UICollectionViewCell()
        }
        var content = cell.defaultContentConfiguration()
        
        switch indexPath.section{
        case 0:
            content.text = folders[indexPath.row]
//            content.secondaryText = products[indexPath.row].productDescription

//            cell.accessories = [.multiselect(displayed: .whenEditing, options: .init())]
            
            cell.contentConfiguration = content
        case 1:
            content.text = products[indexPath.row].title
            content.secondaryText = products[indexPath.row].productDescription
            content.prefersSideBySideTextAndSecondaryText = false
            content.secondaryTextProperties.font = UIFont.preferredFont(forTextStyle: .subheadline)

            cell.accessories = [.multiselect(displayed: .whenEditing, options: .init())]
            
            cell.contentConfiguration = content
//            return products.count
        default:
            return UICollectionViewCell()
        }
        

        return cell
    }
    func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
        switch indexPath.section{
        case 0:
            return false
        case 1:
            return true
        default:
            return false
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didselect")
        switch indexPath.section{
        case 0:
            collectionView.deselectItem(at: indexPath, animated: true)
        default:
            moveButton.isEnabled = true
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("diddeselect")
        if collectionView.indexPathsForSelectedItems?.contains(where: {$0.section == 1}) == true{
            moveButton.isEnabled = true
        }else{
            moveButton.isEnabled = false
        }
    }
    
}



