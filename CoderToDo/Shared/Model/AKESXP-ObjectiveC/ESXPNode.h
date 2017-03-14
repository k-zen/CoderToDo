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

/// The Node interface is the primary datatype for the entire Document Object Model. It represents a single node in the document tree.
/// While all objects implementing the Node interface expose methods for dealing with children, not all objects implementing the Node
/// interface may have children. For example, Text nodes may not have children, and adding children to such nodes results in a DOMException
/// being raised. The attributes nodeName, nodeValue and attributes are included as a mechanism to get at node information without casting down to the specific
/// derived interface. In cases where there is no obvious mapping of these attributes for a specific nodeType (e.g., nodeValue for an
/// Element or attributes for a Comment), this returns null. Note that the specialized interfaces may contain additional and more convenient
/// mechanisms to get and set the relevant information.
///
/// <br/>
///
/// <table>
///  <tbody>
///   <tr>
///    <th>Interface</th>
///    <th>nodeName</th>
///    <th>nodeValue</th>
///    <th>attributes</th>
///   </tr>
///   <tr>
///    <td><code>Document</code></td>
///    <td><code>"#document"</code></td>
///    <td><code>null</code></td>
///    <td><code>null</code></td>
///   </tr>
///   <tr>
///    <td><code>Element</code></td>
///    <td>Same as <code>Element.tagName</code></td>
///    <td><code>null</code></td>
///    <td><code>NSDictionary</code></td>
///   </tr>
///   <tr>
///    <td><code>Text</code></td>
///    <td><code>"#text"</code></td>
///    <td>Same as <code>CharacterData.data</code>, the content of the text node.</td>
///    <td><code>null</code></td>
///   </tr>
///  </tbody>
/// </table>
///
/// \author Andreas P. Koenzen <akc at apkc.net>
/// \see    Builder Pattern
@protocol ESXPNode
typedef enum Nodes : unsigned short
{
    COMMENT_NODE,
    ELEMENT_NODE,
    TEXT_NODE
} Nodes;

@required
/// Builder of new instances. Follows the Builder Pattern.
///
/// \param name The name of the node.
///
/// \return A new instance of ESXPNode if available, otherwise return NIL.
+ (id<ESXPNode>)newBuild:(NSString *)name;

/// Builder of new instances. Follows the Builder Pattern.
///
/// \param name       The name of the node.
/// \param parentNode The parent node of this node.
///
/// \return A new instance of ESXPNode if available, otherwise return NIL.
+ (id<ESXPNode>)newBuild:(NSString *)name parentNode:(id<ESXPNode>)parentNode;

/// Appends a new child to the children list.
///
/// \param newChild The new child to append.
///
/// \return The child recently added.
- (id<ESXPNode>)appendChild:(id<ESXPNode>)newChild;

/// Counts all element nodes inside this node.
///
/// \param counter The counter.
- (void)countElementNodes:(unsigned short *)counter;

/// A dictionary containing the attributes of this node (if it is an
/// Element) or null otherwise.
///
/// \return A dictionary containing all attributes, only if it's an
///         Element node, nil otherwise.
- (NSDictionary *)getAttributes;

/// The absolute base URI of this node or null if the implementation
/// wasn't able to obtain an absolute URI.
///
/// \return The base URI of this node.
- (NSString *)getBaseURI;

/// A mutable array that contains all children of this node. If there are
/// no children, this is a mutable array containing no nodes.
///
/// \return A mutable array containing all children nodes of this node.
- (NSMutableArray *)getChildNodes;

/// The first child of this node. If there is no such node, this returns null.
///
/// \return The first child of this node.
- (id<ESXPNode>)getFirstChild;

/// The last child of this node. If there is no such node, this returns null.
///
/// \return The last child of this node.
- (id<ESXPNode>)getLastChild;

/// Returns the local part of the qualified name of this node.
///
/// \return Returns the local part of the qualified name of this node.
- (NSString *)getLocalName;

/// The namespace URI of this node, or null if it is unspecified.
///
/// \return The namespace URI of this node, or null if it is unspecified.
- (NSString *)getNamespaceURI;

/// The name of this node, depending on its type; see the table above.
///
/// \return The name of this node.
- (NSString *)getNodeName;

/// A code representing the type of the underlying object, as defined above.
///
/// \return A code representing the type of the underlying object, as defined above.
- (unsigned short)getNodeType;

/// The value of this node, depending on its type; see the table above.
/// When it is defined to be null, setting it has no effect,
/// including if the node is read-only.
///
/// \return The value of this node.
- (NSString *)getNodeValue;

/// The parent of this node. All nodes, except Attr, Document,
/// DocumentFragment, Entity, and Notation may have a parent.
/// However, if a node has just been created and not yet added
/// to the tree, or if it has been removed from the tree, this is null.
///
/// \return The parent node of this node.
- (id<ESXPNode>)getParentNode;

/// Returns whether this node (if it is an element) has any attributes.
///
/// \return Returns true if this node has any attributes, false otherwise.
- (BOOL)hasAttributes;

/// Returns whether this node has any children.
///
/// \return Returns true if this node has any children, false otherwise.
- (BOOL)hasChildNodes;

/// This method checks if the specified namespaceURI is the default
/// namespace or not.
///
/// \param namespaceURI The namespace URI to look for.
///
/// \return Returns true if the specified namespaceURI is the
///         default namespace, false otherwise.
- (BOOL)isDefaultNamespace:(NSString *)namespaceURI;

/// Tests whether two nodes are equal.
///
/// \param other The node to compare equality with.
///
/// \return Returns true if the nodes are equal, false otherwise.
- (BOOL)isEqualNode:(id<ESXPNode>)other;

/// Returns whether this node is the same node as the given one.
///
/// \param other The node to test against.
///
/// \return Returns true if the nodes are the same, false otherwise.
- (BOOL)isSameNode:(id<ESXPNode>)other;

/// Look up the namespace URI associated to the given prefix, starting from this node.
///
/// \param prefix The prefix to look for. If this parameter is null, the method will
///               return the default namespace URI if any.
///
/// \return Returns the associated namespace URI or null if none is found.
- (NSString *)lookupNamespaceURI:(NSString *)prefix;

/// Puts all Text nodes in the full depth of the sub-tree underneath this
/// Node, including attribute nodes, into a "normal" form where only
/// structure (e.g., elements, comments, processing instructions, CDATA
/// sections, and entity references) separates Text nodes, i.e., there
/// are neither adjacent Text nodes nor empty Text nodes.
- (void)normalize;

/// Prints this node.
///
/// \param indent The indentation level.
///
/// \return A string containing this node's data.
- (NSString *)printNode:(int)indent;

/// Removes the child node indicated by oldChild from the list of children, and returns it.
///
/// \param oldChild The node being removed.
///
/// \return The node removed.
- (id<ESXPNode>)removeChild:(id<ESXPNode>)oldChild;

/// Replaces the child node oldChild with newChild in the list of
/// children, and returns the oldChild node.
///
/// \param newChild The new node to put in the child list.
/// \param oldChild The node being replaced in the list.
///
/// \return The node replaced.
- (id<ESXPNode>)replaceChild:(id<ESXPNode>)newChild oldChild:(id<ESXPNode>)oldChild;

/// The value of this node, depending on its type; see the table
/// above. When it is defined to be null, setting it has no effect,
/// including if the node is read-only.
///
/// \param nodeValue The value of this node.
- (void)setNodeValue:(NSString *)nodeValue;
@end
