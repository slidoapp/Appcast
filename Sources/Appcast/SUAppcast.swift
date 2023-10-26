//
// Copyright 2023 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//
// Based on SUAppcast.m from Sparkle project.
//

import Foundation

public class SUAppcast {
    
    internal static let empty = SUAppcast()
    
    internal init() {
        self.items = []
    }

    public init(xmlData appcastData: Data, relativeTo: URL?, stateResolver: SPUAppcastItemStateResolver?) throws {
        self.items = []
        
        let document = try XMLDocument(data: appcastData, options: .nodeLoadExternalEntitiesNever)
        let xmlItems = try document.nodes(forXPath: "/rss/channel/item")
     
//        if ([[node children] count]) {
//            node = [node childAtIndex:0];
//            while (nil != node) {
//                NSString *name = [self sparkleNamespacedNameOfNode:node];
//                if (name) {
//                    NSMutableArray *nodes = [nodesDict objectForKey:name];
//                    if (nodes == nil) {
//                        nodes = [NSMutableArray array];
//                        [nodesDict setObject:nodes forKey:name];
//                    }
//                    [nodes addObject:node];
//                }
//                node = [node nextSibling];
//            }
//        }
        
        for item in xmlItems {
            var dict = [String: Any]()
            var nodesDict = [String: [XMLNode]]()
            
            if item.childCount > 0 {
                var node = item.child(at: 0)
                
                while node != nil {
                    guard let currentNode = node else {
                        break;
                    }

                    if let name = self.sparkleNamespacedName(of: currentNode) {
                        nodesDict[name, default: [XMLNode]()].append(currentNode)
//                        var nodes = nodesDict[name]
//                        if nodes == nil {
//                            nodes = [XMLNode]()
//                            nodesDict[name] = nodes
//                        }
//
//                        nodes?.append(currentNode)
                    }
                    
                    node = currentNode.nextSibling
                }
            }
            
            for nodeInfo in nodesDict {
                let name = nodeInfo.key
                let nodeSet = nodeInfo.value
                guard let node = self.bestNode(in: nodeSet, name: name) else {
                    print("Missing node value for element \(name)")
                    continue
                }
                
                // Parse enclosure element
                // <enclosure url="http://localhost:1337/Sparkle_Test_App.zip" length="1346234" />
                // Parse criticalUpdate element
                // <sparkle:criticalUpdate></sparkle:criticalUpdate>
                
                if name == SURSSElement.Enclosure || name == SUAppcastElement.CriticalUpdate {
                    
                    // These are flattened as a separate dictionary for some reason
                    let innerDict = self.attributes(of: node)
                    dict[name] = innerDict
                }
                else if name == SURSSElement.PubDate {
                    // We don't want to parse and create a NSDate instance -
                    // that's a risk we can avoid. We don't use the date anywhere other
                    // than it being accessible from SUAppcastItem
                    if let dateString = node.stringValue {
                        dict[name] = dateString
                    }
                }
                else if name == SURSSElement.Description {
                    if let description = node.stringValue {
                        let attributes = self.attributes(of: node)
                        let descriptionFormat = attributes[SUAppcastAttribute.Format]
                        
                        var descriptionDict = AttributesDictionary()
                        descriptionDict["content"] = description
                        descriptionDict["format"] = descriptionFormat
                        
                        dict[SURSSElement.Description] = descriptionDict
                    }
                }
                else if name == SUAppcastElement.Deltas {
                    var deltas = [[String: String]]()
                    
                    if let children = node.children {
                        for child in children {
                            if child.name == SURSSElement.Enclosure {
                                let att = self.attributes(of: child)
                                deltas.append(att)
                            }
                        }
                    }
                    
                    dict[name] = deltas
                }
                else if name == SUAppcastElement.Tags {
                    var tags = [String]()
                    
                    if let children = node.children {
                        for child in children {
                            if let childName = child.name {
                                tags.append(childName)
                            }
                        }
                    }
                    
                    dict[name] = tags
                }
                else if name == SUAppcastElement.InformationalUpdate {
                    var informationalUpdateVersions = SUAppcastItem.InformationalUpdateType()
                    
                    if let children = node.children {
                        for child in children {
                            if child.name == SUAppcastElement.Version {
                                if let version = child.stringValue {
                                    informationalUpdateVersions.insert(version)
                                }
                            }
                            else if child.name == SUAppcastElement.BelowVersion {
                                if let version = child.stringValue {
                                    // Denote version is used as an upper bound by using '<'
                                    informationalUpdateVersions.insert("<\(version)")
                                }
                            }
                        }
                    }

                    dict[name] = informationalUpdateVersions
                }
                else {
                    // add all other values as strings
                    if let stringValue = node.stringValue?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
                        dict[name] = stringValue
                    }
                }
            }
            
            
            let appcastItem = try SUAppcastItem(dictionary: dict, relativeTo: relativeTo, stateResolver: stateResolver, resolvedState: nil)
            
            self.items.append(appcastItem)
        }
    }

    public var items: [SUAppcastItem]
    
    func sparkleNamespacedName(of node: XMLNode) -> String? {
        // XML namespace prefix is semantically meaningless, so compare namespace URI
        // NS URI isn't used to fetch anything, and must match exactly, so we look for http:// not https://
        if node.uri == "http://www.andymatuschak.org/xml-namespaces/sparkle" {
            guard let localName = node.localName else {
                return nil
            }

            return "sparkle:\(localName)"
        }
        
        // Backwards compatibility
        return node.name
    }
    
    static let SUXMLLanguage = "xml:lang"
    
    func bestNode(in nodes: [XMLNode], name: String) -> XMLNode? {
        // We use this method to pick out the localized version of a node when one's available.
        if nodes.count == 1 {
            return nodes[0]
        } else if nodes.count == 0 {
            return nil
        }
        
        // Now that we reached here, we are dealing with multiple nodes
        var languages = [String]()
        for node in nodes {
            guard let element = node as? XMLElement else {
                continue
            }
            
            let nodeLanguage = element.attribute(forName: SUAppcast.SUXMLLanguage)?.stringValue ?? ""
            let language = nodeLanguage.isEmpty ? "en" : nodeLanguage
            languages.append(language)
        }
        
        guard let preferredLanguage = Bundle.preferredLocalizations(from: languages).first else {
            // "Error: Failed to obtain preferred localizations from \(languages) for node \(name)."
            return nodes[0]
        }
        
        guard let preferredLanguageIndex = languages.firstIndex(of: preferredLanguage) else {
            // "Error: Failed to find preferred language index for \(preferredLanguage) for node \(name)."
            return nodes[0]
        }
        
        return nodes[preferredLanguageIndex]
    }
    
    typealias AttributesDictionary = [String: String]
    
    func attributes(of node: XMLNode) -> [String: String] {
        var dictionary = [String: String]()
        
        guard let element = node as? XMLElement else {
            return dictionary
        }
        
        guard let attributes = element.attributes else {
            return dictionary
        }

        for attribute in attributes {
            if let attrName = self.sparkleNamespacedName(of: attribute) {
                if let attributeStringValue = attribute.stringValue {
                    dictionary[attrName] = attributeStringValue
                }
            }
        }

        return dictionary
    }
}
