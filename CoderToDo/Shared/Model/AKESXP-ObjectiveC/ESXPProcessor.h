/*
 * Copyright (c) 2014, Andreas P. Koenzen <akc at apkc.net>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>
#import "ESXPDocument.h"
#import "ESXPStackDOMWalker.h"

/// XML Processor.
///
/// \author Andreas P. Koenzen <akc at apkc.net>
/// \see    Builder Pattern
@interface ESXPProcessor : NSObject
// MARK: Properties
@property (nonatomic, assign) NSUInteger maxNodes;

// MARK: Builders
/// Builder of new instances. Follows the Builder Pattern.
///
/// \param maxNodes The maximum number of nodes.
///
/// \return A new instance of this class or nil if any problem.
+ (ESXPProcessor *)newBuild:(NSUInteger)maxNodes;

// MARK: Methods
/// Walks the DOM tree in search of a given tag and when found retrieves the tag's value.<br/>
/// <b>Throws:</b> TagNotFoundException: If the required tag was not found.
///
/// \param doc          The XML document to parse.
/// \param rootNodeName The name of the root node of the XML.
/// \param tag          The tag's name
/// \param strict       If TRUE this method will raise an exception if the tag to search was not found. If
///                     FALSE will return an empty string.
///
/// \return The tag's value
- (NSString *)searchTagValue:(ESXPDocument *)doc rootNodeName:(NSString *)rootNodeName tagName:(NSString *)tagName strict:(BOOL)strict;

/// Walks the DOM tree in search of a given tag and when found retrieves the tag's attribute value.
/// <b>Throws:</b> TagNotFoundException: If the required tag was not found.
/// <b>Throws:</b> AttributeNotFoundException: If the required attribute was not found.
///
/// \param doc           The XML document to parse.
/// \param rootNodeName  The name of the root node of the XML.
/// \param tag           The tag's name
/// \param attributeName The attribute name
/// \param strict        If TRUE this method will raise an exception if the tag or attribute to search were not found. If
///                      FALSE will return an empty string.
///
/// \return The attribute value
- (NSString *)searchTagAttributeValue:(ESXPDocument *)doc rootNodeName:(NSString *)rootNodeName tagName:(NSString *)tagName attributeName:(NSString *)attributeName strict:(BOOL)strict;

/// Retrieves a specific attribute value from a given element node.
/// <b>Throws:</b> AttributeNotFoundException: If the required attribute was not found.
/// <b>Throws:</b> InvalidNodeException: If the node is not an element node.
///
/// \param node          The node from which to extract the attribute.
/// \param attributeName The name of the attribute.
/// \param strict        If TRUE this method will raise an exception if the attribute to search was not found. If
///                      FALSE will return an empty string.
///
/// \return The value of the given attribute.
- (NSString *)getNodeAttributeValue:(id<ESXPNode>)node attributeName:(NSString *)attributeName strict:(BOOL)strict;

/// Retrieves TEXT data from a given element node.
/// <b>Throws:</b> TextNotFoundException: If no text was found.
///
/// \param node   The element node from where to extract TEXT data if available.
/// \param strict If TRUE this method will raise an exception if the value to retrieve was not found. If
///               FALSE will return an empty string.
///
/// \return A String representing the TEXT.
- (NSString *)getNodeValue:(id<ESXPNode>)node strict:(BOOL)strict;

/// Find the named node in a node's sublist.
/// <b>Throws:</b> NodeNotFoundException: If no node was found.
///
/// <ul>
/// <li>Ignores comments and processing instructions.</li>
/// <li>Ignores TEXT nodes (likely to exist and contain ignorable whitespace, if not validating.</li>
/// <li>Ignores CDATA nodes and EntityRef nodes.</li>
/// <li>Examines element nodes to find one with the specified name.</li>
/// </ul>
///
/// \param name The tag name for the element to find.
/// \param node The element node to start searching from.
///
/// \return The sub node found.
- (id<ESXPNode>)retrieveSubNode:(NSString *)name node:(id<ESXPNode>)node;

/// Walks the DOM tree in search of a given node and when found retrieves the node.
/// <b>Throws:</b> NodeNotFoundException: If no node was found.
///
/// \param doc          The XML document to parse.
/// \param rootNodeName The name of the root node of the XML.
/// \param tag          The tag's name
///
/// \return The node
- (id<ESXPNode>)searchNode:(ESXPDocument *)doc rootNodeName:(NSString *)rootNodeName tagName:(NSString *)tagName;
@end
