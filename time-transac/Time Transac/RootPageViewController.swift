//
//  RootPageViewController.swift
//  Time Transac
//
//  Created by Srikanth Srinivas on 7/29/17.
//  Copyright © 2017 Gbenga Ayobami. All rights reserved.
//

import UIKit

class RootPageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    lazy var vcList:[UIViewController] = {
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc1 = sb.instantiateViewController(withIdentifier: "welcomepage")
        let vc2 = sb.instantiateViewController(withIdentifier: "buypage")
        let vc3 = sb.instantiateViewController(withIdentifier: "sellpage")
        let vc4 = sb.instantiateViewController(withIdentifier: "lgsupage")
        
        return [vc1, vc2, vc3, vc4]
    
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        
        if let firstvc = vcList.first{
            self.setViewControllers([firstvc], direction: .forward, animated: true, completion: nil )
        }

    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 4
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let scrollView = view.subviews.filter({ $0 is UIScrollView }).first,
            let pageControl = view.subviews.filter({ $0 is UIPageControl }).first {
            scrollView.frame = view.bounds
            view.bringSubview(toFront:pageControl)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let vcIndex = vcList.index(of: viewController) else {return nil}
        
        let nextIndex = vcIndex + 1
        
        guard vcList.count != nextIndex else { return nil}
        
        guard  vcList.count > nextIndex else { return nil }
        
        return vcList[nextIndex]
    
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let vcIndex = vcList.index(of: viewController) else {return nil}
        
        let previousIndex = vcIndex - 1
        
        guard previousIndex >= 0 else {return nil}
        
        guard vcList.count > previousIndex else {return nil}
        
        return vcList[previousIndex]
    }

}
