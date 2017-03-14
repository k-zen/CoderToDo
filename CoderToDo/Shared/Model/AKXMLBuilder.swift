import Foundation

class AKXMLBuilder
{
    static func marshall() -> Data?
    {
        let xml = NSMutableString()
        xml.append(String(format: "<export username=\"%@\">",
                          DataInterface.getUsername().toBase64() // Should be encoded to Base64.
        ))
        xml.append("<configurations></configurations>")
        xml.append("<projects>")
        for project in DataInterface.getProjects(filter: Filter(projectFilter: FilterProject())) {
            xml.append(
                String(format: "<project closingTime=\"%@\" closingTimeTolerance=\"%i\" creationDate=\"%@\" name=\"%@\" notifyClosingTime=\"%@\" osr=\"%.2f\" startingTime=\"%@\">",
                       project.closingTime?.description ?? "",
                       project.closingTimeTolerance,
                       project.creationDate?.description ?? "",
                       project.name?.toBase64() ?? "", // Should be encoded to Base64.
                    project.notifyClosingTime ? "YES" : "NO",
                    project.osr,
                    project.startingTime?.description ?? ""
                )
            )
            xml.append(String(format: "<projectCategories count=\"%i\">", DataInterface.countProjectCategories(project: project)))
            for projectCategory in DataInterface.listProjectCategories(project: project) {
                xml.append(String(format: "<name>%@</name>", projectCategory.toBase64())) // Should be encoded to Base64.
            }
            xml.append("</projectCategories>")
            xml.append(String(format: "<projectPendingQueue count=\"%i\">", DataInterface.countPendingTasks(project: project)))
            for taskInQueue in DataInterface.getPendingTasks(project: project) {
                xml.append("<task>")
                xml.append(String(format: "<completionPercentage>%.2f</completionPercentage>", taskInQueue.completionPercentage))
                xml.append(String(format: "<initialCompletionPercentage>%.2f</initialCompletionPercentage>", taskInQueue.initialCompletionPercentage))
                xml.append(String(format: "<creationDate>%@</creationDate>", taskInQueue.creationDate?.description ?? ""))
                xml.append(String(format: "<name>%@</name>", taskInQueue.name?.toBase64() ?? "")) // Should be encoded to Base64.
                xml.append(String(format: "<note>%@</note>", taskInQueue.note?.toBase64() ?? "")) // Should be encoded to Base64.
                xml.append(String(format: "<state>%@</state>", taskInQueue.state ?? ""))
                xml.append("</task>")
            }
            xml.append("</projectPendingQueue>")
            xml.append(String(format: "<projectDilateQueue count=\"%i\">", DataInterface.countDilateTasks(project: project)))
            for taskInQueue in DataInterface.getDilateTasks(project: project) {
                xml.append("<task>")
                xml.append(String(format: "<completionPercentage>%.2f</completionPercentage>", taskInQueue.completionPercentage))
                xml.append(String(format: "<initialCompletionPercentage>%.2f</initialCompletionPercentage>", taskInQueue.initialCompletionPercentage))
                xml.append(String(format: "<creationDate>%@</creationDate>", taskInQueue.creationDate?.description ?? ""))
                xml.append(String(format: "<name>%@</name>", taskInQueue.name?.toBase64() ?? "")) // Should be encoded to Base64.
                xml.append(String(format: "<note>%@</note>", taskInQueue.note?.toBase64() ?? "")) // Should be encoded to Base64.
                xml.append(String(format: "<state>%@</state>", taskInQueue.state ?? ""))
                xml.append("</task>")
            }
            xml.append("</projectDilateQueue>")
            xml.append(String(format: "<days count=\"%i\">", DataInterface.countDays(project: project)))
            for day in DataInterface.getDays(project: project) {
                xml.append(String(format: "<day date=\"%@\" sr=\"%.2f\">", day.date?.description ?? "", day.sr))
                xml.append(String(format: "<categories count=\"%i\">", DataInterface.countCategories(day: day)))
                for category in DataInterface.getCategories(day: day) {
                    var taskFilter = FilterTask()
                    taskFilter.sortType = TaskSorting.name
                    xml.append(String(format: "<category name=\"%@\">", category.name?.toBase64() ?? "")) // Should be encoded to Base64.
                    xml.append(String(format: "<tasks count=\"%i\">", DataInterface.countTasksInCategory(category: category, filter: Filter(taskFilter: taskFilter))))
                    for task in DataInterface.getTasks(category: category, filter: Filter(taskFilter: taskFilter)) {
                        xml.append("<task>")
                        xml.append(String(format: "<completionPercentage>%.2f</completionPercentage>", task.completionPercentage))
                        xml.append(String(format: "<initialCompletionPercentage>%.2f</initialCompletionPercentage>", task.initialCompletionPercentage))
                        xml.append(String(format: "<creationDate>%@</creationDate>", task.creationDate?.description ?? ""))
                        xml.append(String(format: "<name>%@</name>", task.name?.toBase64() ?? "")) // Should be encoded to Base64.
                        xml.append(String(format: "<note>%@</note>", task.note?.toBase64() ?? "")) // Should be encoded to Base64.
                        xml.append(String(format: "<state>%@</state>", task.state ?? ""))
                        xml.append("</task>")
                    }
                    xml.append("</tasks>")
                    xml.append("</category>")
                }
                xml.append("</categories>")
                xml.append("</day>")
            }
            xml.append("</days>")
            xml.append("</project>")
        }
        xml.append("</projects>")
        xml.append("</export>")
        
        let finalStr = xml.description.toBase64()
        
        let xmlWrapper = NSMutableString()
        xmlWrapper.append("<?xml version=\"1.0\"?>")
        xmlWrapper.append(
            String(
                format: "<data date=\"%@\" md5=\"%@\">%@</data>",
                Date().description,
                finalStr.computeMD5() ?? "",
                finalStr
            )
        )
        
        return xmlWrapper.data(using: String.Encoding.utf8.rawValue)
    }
    
    static func unmarshall(data: Data) throws -> Void
    {
        let outerParser = XMLParser(data: data)
        let outerParserDelegate = ESXPSAX2DOM.newBuild(GlobalConstants.AKBackupXMLMaxNodes)
        outerParser.delegate = outerParserDelegate
        
        outerParser.parse()
        let error = outerParser.parserError
        if error != nil {
            fatalError("=> ERROR: \(error?.localizedDescription)") // TODO: Improve!!!
        }
        
        let outerProcessor = ESXPProcessor.newBuild(GlobalConstants.AKBackupXMLMaxNodes)
        if let mainWalker = ESXPStackDOMWalker
            .newBuild()
            .configure(
                GlobalConstants.AKBackupXMLMaxNodes,
                rootNode: outerParserDelegate?.getDOM().getRootNode(),
                nodesToProcess: ELEMENT_NODE.rawValue
            ) {
            while mainWalker.hasNext() {
                if let dataNode = mainWalker.nextNode() {
                    if dataNode.getType() == ELEMENT_NODE.rawValue && dataNode.getName().caseInsensitiveCompare("data") == .orderedSame {
                        // TODO: Get MD5 hash and compare.
                        // TODO: Also get date.
                        
                        if let dataValue = outerProcessor?.getNodeValue(dataNode, strict: false).fromBase64() {
                            if let innerData = dataValue.data(using: .utf8) {
                                let innerParser = XMLParser(data: innerData)
                                let innerParserDelegate = ESXPSAX2DOM.newBuild(GlobalConstants.AKBackupXMLMaxNodes)
                                innerParser.delegate = innerParserDelegate
                                
                                innerParser.parse()
                                let error = innerParser.parserError
                                if error != nil {
                                    fatalError("=> ERROR: \(error?.localizedDescription)") // TODO: Improve!!!
                                }
                                
                                let innerProcessor = ESXPProcessor.newBuild(GlobalConstants.AKBackupXMLMaxNodes)
                                if let projectsWalker = ESXPStackDOMWalker
                                    .newBuild()
                                    .configure(
                                        GlobalConstants.AKBackupXMLMaxNodes,
                                        rootNode: innerProcessor?.searchNode(innerParserDelegate?.getDOM(), rootNodeName: "export", tagName: "projects") as! ESXPElement!,
                                        nodesToProcess: ELEMENT_NODE.rawValue
                                    ) {
                                    while projectsWalker.hasNext() {
                                        if let projectNode = projectsWalker.nextNode() {
                                            if projectNode.getType() == ELEMENT_NODE.rawValue && projectNode.getName().caseInsensitiveCompare("project") == .orderedSame {
                                                NSLog("=> INFO: FOUND NEW NODE => project => %@", innerProcessor?.getNodeAttributeValue(projectNode, attributeName: "name", strict: false).fromBase64() ?? "")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        //                    SSMAccount *account = [SSMAccount newBuild];
        //                    [account setAccountType:[[ESXPProcessor newBuild] getNodeAttributeValue:node attributeName:@"type" strict:NO]];
        //                    [account setAccountExchange:[[ESXPProcessor newBuild] getNodeAttributeValue:node attributeName:@"moneda" strict:NO]];
        //                    ESXPStackDOMWalker *subWalker = [[ESXPStackDOMWalker newBuild] configure:(ESXPElement *)node nodesToProcess:ELEMENT_NODE];
        //                    while ([subWalker hasNext]) {
        //                        id<ESXPNode> subNode = [subWalker nextNode];
        //                        if ([[subNode getNodeName] isEqualToString:@"ncta"]) {
        //                            [account setAccountNumber:[[ESXPProcessor newBuild] getNodeValue:subNode strict:NO]];
        //                        }
        //                        else if ([[subNode getNodeName] isEqualToString:@"saldoc"]) {
        //                            [account setAccountBalance:[[ESXPProcessor newBuild] getNodeValue:subNode strict:NO]];
        //                        }
        //                        else if ([[subNode getNodeName] isEqualToString:@"saldod"]) {
        //                            [account setAccountAvailableBalance:[[ESXPProcessor newBuild] getNodeValue:subNode strict:NO]];
        //                        }
        //                        else if ([[subNode getNodeName] isEqualToString:@"movs"]) {
        //                            if ([subNode hasChildNodes]) {
        //                                [account setMovements:[SSMXMLProcessor getSavingsAccountsMovements:subNode]];
        //                            }
        //                        }
        //                    }
        //
        //                    if (![account isEmpty]) {
        //                        [accounts addObject:account];
        //                        account = [SSMAccount newBuild];
        //                    }
        //                }
        //            }
        //        }
    }
}
