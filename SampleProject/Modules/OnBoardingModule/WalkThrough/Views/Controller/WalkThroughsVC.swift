//
//  IntroSliderVC.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 04/01/24.
//  Copyright © 2019 NimbleAppGenie. All rights reserved.
//

import UIKit
import SDWebImage

class WalkThroughsVC: BaseNavigationController{
    
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var nextBtnOtl: UIButton!
    @IBOutlet weak var skipBtnOtl: UIButton!
    @IBOutlet weak var getStartedBtnOtl: UIButton!

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var viewModel: WalkThroughViewModelProtocol
    
    init(viewModel: WalkThroughViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        Log.error("init(coder:) has not been implemented")
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Log.info("== \(self) ==")
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        
        initView()
      
        initaPageControl()
        self.stateObserver()
    }
    
    func initView() {
        collectionView.register(UINib(nibName: "IntroSliderCell", bundle: nil), forCellWithReuseIdentifier: "IntroSliderCell")
    }
    
    func initaPageControl(){
        updatePageControl(currentPage: 0)
//        pageControl.transform = CGAffineTransform(scaleX: 1, y: 1)
    }
    
    
    private func updatePageControl(currentPage: Int) {

        let numberOfPages = viewModel.getNumberOfRows()

        pageControl.numberOfPages = numberOfPages
        pageControl.currentPage = currentPage

        let selectedImage = createCircleImage(
            size: CGSize(width: 10, height: 10),
            fillColor: .appGreen,
            borderColor: .appGreen,
            borderWidth: 1
        )

        let unselectedImage = createCircleImage(
            size: CGSize(width: 10, height: 10),
            fillColor: .clear,
            borderColor: ._696969,
            borderWidth: 1
        )

        for index in 0..<numberOfPages {
            pageControl.setIndicatorImage(
                index == currentPage ? selectedImage : unselectedImage,
                forPage: index
            )
        }
    }
    
    private func createCircleImage(
        size: CGSize,
        fillColor: UIColor,
        borderColor: UIColor,
        borderWidth: CGFloat
    ) -> UIImage? {

        let renderer = UIGraphicsImageRenderer(
            size: size,
            format: {
                let format = UIGraphicsImageRendererFormat()
                format.scale = UIScreen.main.scale
                format.opaque = false
                return format
            }()
        )

        return renderer.image { context in

            let rect = CGRect(
                x: borderWidth / 2,
                y: borderWidth / 2,
                width: size.width - borderWidth,
                height: size.height - borderWidth
            )

            let path = UIBezierPath(ovalIn: rect)

            fillColor.setFill()
            path.fill()

            borderColor.setStroke()
            path.lineWidth = borderWidth
            path.stroke()
        }
    }
    
    private func stateObserver() {
        viewModel.stateSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.collectionView.reloadData()
                }
            } receiveValue: { [weak self] state in
                switch state {
                case .reloadView:
                    self?.collectionView.reloadData()
                    self?.pageControl.numberOfPages = self?.viewModel.getNumberOfRows() ?? 0
                case .error(let message):
                    Log.error(message)
                    ProgressHudWrapper.failed(message: message)

                }
            }
            .store(in: &viewModel.cancellable)
    }
    
    @IBAction func skipBtnAction(_ sender: ResponsiveButton){
        goToLoginScreen()
    }
    
    @IBAction func nextBtnACtion(_ sender: ResponsiveButton) {
        guard let currentIndexPath = collectionView.indexPathsForVisibleItems.first
        else {
            return
        }
        
        let nextIndexPath = IndexPath(row: currentIndexPath.row + 1, section: currentIndexPath.section)
        if nextIndexPath.row < viewModel.getNumberOfRows() {
            collectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
            //pageControl.currentPage = nextIndexPath.row
            updatePageControl(currentPage: nextIndexPath.row)
            titleLabel.text = "\(nextIndexPath.row+1)/\(viewModel.getNumberOfRows())"
        }
        else{
            goToLoginScreen()
        }
        
        if nextIndexPath.row == 2{
            skipBtnOtl.isHidden = true
            skipBtnOtl.isUserInteractionEnabled = false
            
            getStartedBtnOtl.isHidden = false
            getStartedBtnOtl.isUserInteractionEnabled = true
        }
        else{
            skipBtnOtl.isHidden = false
            skipBtnOtl.isUserInteractionEnabled = true
            
            getStartedBtnOtl.isHidden = true
            getStartedBtnOtl.isUserInteractionEnabled = false
        }
    }
    
    func goToLoginScreen(){
        AppUserDefaults.shared.UDSave(true, forKey: .alreadyShowWalkThroughScreen)
        
        let vc = LoginVC(viewModel: RegisterViewModel())
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension WalkThroughsVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getNumberOfRows()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IntroSliderCell", for: indexPath) as! IntroSliderCell
     
            cell.configureCell(item: viewModel.getNumberOfItem(At: indexPath))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        var visibleRect = CGRect()
        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        guard let indexPath = collectionView.indexPathForItem(at: visiblePoint) else{ return }
//        print(indexPath.row)
        updatePageControl(currentPage: indexPath.row)
        titleLabel.text = "\(indexPath.row+1)/\( viewModel.getNumberOfRows())"

        if indexPath.row ==  viewModel.getNumberOfRows() - 1{
            skipBtnOtl.isHidden = true
            skipBtnOtl.isUserInteractionEnabled = false

            getStartedBtnOtl.isHidden = false
            getStartedBtnOtl.isUserInteractionEnabled = true
            
            //nextBtnOtl.setTitle("LET'S GO", for: .normal)
        }
        else{
            skipBtnOtl.isHidden = false
            skipBtnOtl.isUserInteractionEnabled = true

            getStartedBtnOtl.isHidden = true
            getStartedBtnOtl.isUserInteractionEnabled = false
           // nextBtnOtl.setTitle("NEXT", for: .normal)
        }
    }
}
