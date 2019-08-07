import UIKit
class InventoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var inventoryLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var brandNameLabel: UILabel!
    @IBOutlet weak var myImage: UIImageView!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    func toggleSelected()
    {
        if (isSelected){
            backgroundColor = UIColor.green
        }else {
            backgroundColor = UIColor.gray
        }
    }
}
