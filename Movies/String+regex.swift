//
//  String+regex.swift
//  MovieTrailers
//
//  Created by Robert Dodson on 1/21/22.
//  Copyright © 2022 Shy Frog Productions LLC. All rights reserved.
//

import Foundation

extension String
{
    public func matchRegex(regex: String) throws -> [NSTextCheckingResult]
    {
        let re = try NSRegularExpression(pattern: regex, options: [])
        return re.matches(in: self, options:[], range:NSMakeRange(0,self.count))
    }

    
    public func match(regex: String) -> [[String]]
    {
        let nsString = self as NSString

        do
        {
            let re = try NSRegularExpression(pattern: regex,options: [])

            let matches = re.matches(in:self, options:[], range:NSMakeRange(0, count)).map
            { match in
                (0..<match.numberOfRanges).map
                {
                    match.range(at: $0).location == NSNotFound ? "" : nsString.substring(with: match.range(at: $0))
                }
            }

            return matches
        }
        catch
        {
            return []
        }
    }
}
