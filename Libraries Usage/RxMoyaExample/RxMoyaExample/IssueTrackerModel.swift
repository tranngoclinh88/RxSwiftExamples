//
//  IssueTrackerModel.swift
//  RxMoyaExample
//
//  Created by Lukasz Mroz on 11.02.2016.
//  Copyright © 2016 Droids on Roids. All rights reserved.
//

import Foundation
import Mapper
import Moya
import Moya_ModelMapper
import RxOptional
import RxSwift

struct IssueTrackerModel {
    let provider: MoyaProvider<GitHub>
    let repositoryName: Observable<String>
    
    func trackIssues() -> Observable<[Issue]> {
        return self.repositoryName
            .observeOn(MainScheduler.instance)
            .flatMapLatest { name -> Observable<Repository?> in
                print("Name: \(name)")
                return self
                    .findRepository(name)
            }
            .flatMapLatest { repository -> Observable<[Issue]?> in
                guard let repository = repository else { return Observable.just(nil) }
                
                print("Repository: \(repository.fullName)")
                return self.findIssues(repository)
            }
            .replaceNilWith([])
    }
    
    internal func findIssues(_ repository: Repository) -> Observable<[Issue]?> {
        return self.provider
            .rx
            .request(GitHub.issues(repositoryFullName: repository.fullName))
            .mapOptional(to: [Issue].self)
            .asObservable()
    }
    
    internal func findRepository(_ name: String) -> Observable<Repository?> {
        return self.provider
            .rx
            .request(GitHub.repo(fullName: name))
            .mapOptional(to: Repository.self)
            .asObservable()
    }
}
