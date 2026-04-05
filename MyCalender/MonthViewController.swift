import UIKit

class MonthViewController: UIViewController, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var fab: UIButton!
    
    let calenderDaysDataSource = CalenderDaysDataSource()
    
    private var didSetupLayout = false
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          if segue.identifier == "showEventDetail" {
              let dest = segue.destination as! EventDetailsViewController
              dest.currEvent = sender as? Holiday
              return
          }
        if segue.identifier == "showDayView",
           let dest = segue.destination as? DayViewViewController {
            dest.calendarDay = sender as? CalenderDay
        }
      }
    
  
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         let selectedDay = calenderDaysDataSource.calenderDays[indexPath.row]
         performSegue(withIdentifier: "showDayView", sender: selectedDay)
     }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(value(forKey: "storyboardSegueTemplates") ?? "no segues found")
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.estimatedItemSize = .zero
        layout.sectionInset = .zero
        collectionView.collectionViewLayout = layout
        
        fab.layer.shadowColor = UIColor.black.cgColor
        fab.layer.shadowOpacity = 0.3
        fab.layer.shadowOffset = CGSize(width: 0, height: 4)
        fab.layer.shadowRadius = 6
        fab.layer.cornerRadius = 28
        
        
        collectionView.delegate = self
        print("Delegate set to: \(String(describing: collectionView.delegate))")
        collectionView.dataSource = calenderDaysDataSource
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard !didSetupLayout else { return }
        didSetupLayout = true
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let width = floor(collectionView.bounds.width / 7)
            let height = floor(collectionView.bounds.height / 6)
            layout.itemSize = CGSize(width: width, height: height)  // ✅ set directly on layout
        }
        
        collectionView.reloadData()  // ✅ force full reload
    }
    
}
