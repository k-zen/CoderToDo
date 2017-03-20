import Foundation

class AKXMLBuilder
{
    static func marshall() -> BackupInfo?
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
        let date = Date()
        let md5 = finalStr.computeMD5() ?? ""
        
        let xmlWrapper = NSMutableString()
        xmlWrapper.append("<?xml version=\"1.0\"?>")
        xmlWrapper.append(
            String(
                format: "<data date=\"%@\" md5=\"%@\">%@</data>",
                date.description,
                md5,
                finalStr
            )
        )
        
        let data = xmlWrapper.data(using: String.Encoding.utf8.rawValue)
        
        var backupInfo = BackupInfo()
        backupInfo.date = date
        backupInfo.md5 = md5
        backupInfo.size = Int64(data?.count ?? 0)
        backupInfo.data = data
        
        return backupInfo
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
                        NSLog("=> INFO: data => date => %@", outerProcessor?.getNodeAttributeValue(dataNode, attributeName: "date", strict: false) ?? "")
                        NSLog("=> INFO: data => md5 => %@", outerProcessor?.getNodeAttributeValue(dataNode, attributeName: "md5", strict: false) ?? "")
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
                                
                                let innerProcessor = ESXPProcessor.newBuild(GlobalConstants.AKBackupXMLMaxNodes)!
                                if let secondaryWalker = ESXPStackDOMWalker
                                    .newBuild()
                                    .configure(
                                        GlobalConstants.AKBackupXMLMaxNodes,
                                        rootNode: innerParserDelegate?.getDOM().getRootNode(),
                                        nodesToProcess: ELEMENT_NODE.rawValue
                                    ) {
                                    while secondaryWalker.hasNext() {
                                        if let currentNode = secondaryWalker.nextNode() {
                                            // Export.
                                            if currentNode.getType() == ELEMENT_NODE.rawValue && currentNode.getName().caseInsensitiveCompare("export") == .orderedSame {
                                                NSLog("=> INFO: export => username => %@", innerProcessor.getNodeAttributeValue(currentNode, attributeName: "username", strict: false).fromBase64() ?? "")
                                            }
                                            
                                            // Projects.
                                            if currentNode.getType() == ELEMENT_NODE.rawValue && currentNode.getName().caseInsensitiveCompare("project") == .orderedSame {
                                                if let project = AKXMLBuilder.getProject(processor: innerProcessor, rootNode: currentNode as! ESXPElement) {
                                                    if DataInterface.addProject(project: project) {
                                                        if currentNode.hasChildNodes() {
                                                            // Project Categories.
                                                            if let projectCategories = innerProcessor.retrieveSubNode("projectCategories", node: currentNode) as? ESXPElement {
                                                                if projectCategories.hasChildNodes() {
                                                                    for projectCategory in AKXMLBuilder.getProjectCategories(processor: innerProcessor, rootNode: projectCategories) {
                                                                        project.addToProjectCategories(projectCategory)
                                                                    }
                                                                }
                                                            }
                                                            
                                                            // Project Pending Queue.
                                                            if let pendingQueue = innerProcessor.retrieveSubNode("projectPendingQueue", node: currentNode) as? ESXPElement {
                                                                if pendingQueue.hasChildNodes() {
                                                                    for task in AKXMLBuilder.getTasks(processor: innerProcessor, rootNode: pendingQueue) {
                                                                        project.pendingQueue?.addToTasks(task)
                                                                    }
                                                                }
                                                            }
                                                            
                                                            // Project Dilate Queue.
                                                            if let dilateQueue = innerProcessor.retrieveSubNode("projectDilateQueue", node: currentNode) as? ESXPElement {
                                                                if dilateQueue.hasChildNodes() {
                                                                    for task in AKXMLBuilder.getTasks(processor: innerProcessor, rootNode: dilateQueue) {
                                                                        project.dilateQueue?.addToTasks(task)
                                                                    }
                                                                }
                                                            }
                                                            
                                                            // Days.
                                                            if let days = innerProcessor.retrieveSubNode("days", node: currentNode) as? ESXPElement {
                                                                if days.hasChildNodes() {
                                                                    if let daysWalker = ESXPStackDOMWalker
                                                                        .newBuild()
                                                                        .configure(GlobalConstants.AKBackupXMLMaxNodes, rootNode: days, nodesToProcess: ELEMENT_NODE.rawValue) {
                                                                        while daysWalker.hasNext() {
                                                                            if let currentNode = daysWalker.nextNode() {
                                                                                if currentNode.getType() == ELEMENT_NODE.rawValue && currentNode.getName().caseInsensitiveCompare("day") == .orderedSame {
                                                                                    var newDay = AKDayInterface()
                                                                                    newDay.setDate(innerProcessor.getNodeAttributeValue(currentNode, attributeName: "date", strict: false) ?? "")
                                                                                    newDay.setSR(innerProcessor.getNodeAttributeValue(currentNode, attributeName: "sr", strict: false) ?? "")
                                                                                    if let day = AKDayBuilder.mirror(interface: newDay) {
                                                                                        project.addToDays(day)
                                                                                        
                                                                                        if currentNode.hasChildNodes() {
                                                                                            if let categories = innerProcessor.retrieveSubNode("categories", node: currentNode) as? ESXPElement {
                                                                                                if categories.hasChildNodes() {
                                                                                                    if let categoriesWalker = ESXPStackDOMWalker
                                                                                                        .newBuild()
                                                                                                        .configure(GlobalConstants.AKBackupXMLMaxNodes, rootNode: categories, nodesToProcess: ELEMENT_NODE.rawValue) {
                                                                                                        while categoriesWalker.hasNext() {
                                                                                                            if let currentNode = categoriesWalker.nextNode() {
                                                                                                                if currentNode.getType() == ELEMENT_NODE.rawValue && currentNode.getName().caseInsensitiveCompare("category") == .orderedSame {
                                                                                                                    var newCategory = AKCategoryInterface()
                                                                                                                    newCategory.name = innerProcessor.getNodeAttributeValue(currentNode, attributeName: "name", strict: false).fromBase64() ?? ""
                                                                                                                    if let category = AKCategoryBuilder.mirror(interface: newCategory) {
                                                                                                                        day.addToCategories(category)
                                                                                                                        
                                                                                                                        if let tasks = innerProcessor.retrieveSubNode("tasks", node: currentNode) as? ESXPElement {
                                                                                                                            for task in AKXMLBuilder.getTasks(processor: innerProcessor, rootNode: tasks) {
                                                                                                                                category.addToTasks(task)
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
    }
    
    static func getProject(processor: ESXPProcessor, rootNode: ESXPElement) -> Project?
    {
        let closingTime = processor.getNodeAttributeValue(rootNode, attributeName: "closingTime", strict: false) ?? ""
        let closingTimeTolerance = processor.getNodeAttributeValue(rootNode, attributeName: "closingTimeTolerance", strict: false) ?? ""
        let creationDate = processor.getNodeAttributeValue(rootNode, attributeName: "creationDate", strict: false) ?? ""
        let name = processor.getNodeAttributeValue(rootNode, attributeName: "name", strict: false).fromBase64() ?? ""
        let notifyClosingTime = processor.getNodeAttributeValue(rootNode, attributeName: "notifyClosingTime", strict: false) ?? ""
        let osr = processor.getNodeAttributeValue(rootNode, attributeName: "osr", strict: false) ?? ""
        let startingTime = processor.getNodeAttributeValue(rootNode, attributeName: "startingTime", strict: false) ?? ""
        
        var newProject = AKProjectInterface()
        // Custom Setters.
        newProject.setClosingTime(closingTime)
        newProject.setClosingTimeTolerance(closingTimeTolerance)
        newProject.setCreationDate(creationDate)
        newProject.setNotifyClosingTime(notifyClosingTime)
        newProject.setOSR(osr)
        newProject.setStartingTime(startingTime)
        // Normal Setters.
        newProject.name = name
        
        return AKProjectBuilder.mirror(interface: newProject)
    }
    
    static func getProjectCategories(processor: ESXPProcessor, rootNode: ESXPElement) -> [ProjectCategory]
    {
        var projectCategories = [ProjectCategory]()
        if let projectCategoriesWalker = ESXPStackDOMWalker.newBuild().configure(GlobalConstants.AKBackupXMLMaxNodes, rootNode: rootNode, nodesToProcess: ELEMENT_NODE.rawValue) {
            while projectCategoriesWalker.hasNext() {
                if let currentNode = projectCategoriesWalker.nextNode() {
                    if currentNode.getType() == ELEMENT_NODE.rawValue && currentNode.getName().caseInsensitiveCompare("name") == .orderedSame {
                        var newProjectCategory = AKProjectCategoryInterface()
                        newProjectCategory.name = processor.getNodeValue(currentNode, strict: false).fromBase64() ?? ""
                        
                        if let projectCategory = AKProjectCategoryBuilder.mirror(interface: newProjectCategory) {
                            projectCategories.append(projectCategory)
                        }
                    }
                }
            }
        }
        
        return projectCategories
    }
    
    static func getTasks(processor: ESXPProcessor, rootNode: ESXPElement) -> [Task]
    {
        var tasks = [Task]()
        if let taskWalker = ESXPStackDOMWalker.newBuild().configure(GlobalConstants.AKBackupXMLMaxNodes, rootNode: rootNode, nodesToProcess: ELEMENT_NODE.rawValue) {
            while taskWalker.hasNext() {
                if let currentNode = taskWalker.nextNode() {
                    if currentNode.getType() == ELEMENT_NODE.rawValue && currentNode.getName().caseInsensitiveCompare("task") == .orderedSame {
                        let completionPercentage = processor.getNodeValue(processor.retrieveSubNode("completionPercentage", node: currentNode), strict: false) ?? ""
                        let creationDate = processor.getNodeValue(processor.retrieveSubNode("creationDate", node: currentNode), strict: false) ?? ""
                        let initialCompletionPercentage = processor.getNodeValue(processor.retrieveSubNode("initialCompletionPercentage", node: currentNode), strict: false) ?? ""
                        let name = processor.getNodeValue(processor.retrieveSubNode("name", node: currentNode), strict: false).fromBase64() ?? ""
                        let note = processor.getNodeValue(processor.retrieveSubNode("note", node: currentNode), strict: false).fromBase64() ?? ""
                        let state = processor.getNodeValue(processor.retrieveSubNode("state", node: currentNode), strict: false) ?? ""
                        
                        var newTask = AKTaskInterface()
                        // Custom Setters.
                        newTask.setCompletionPercentage(completionPercentage)
                        newTask.setCreationDate(creationDate)
                        newTask.setInitialCompletionPercentage(initialCompletionPercentage)
                        newTask.setState(state)
                        // Normal Setters.
                        newTask.name = name
                        newTask.note = note
                        
                        if let task = AKTaskBuilder.mirror(interface: newTask) {
                            tasks.append(task)
                        }
                    }
                }
            }
        }
        
        return tasks
    }
}
