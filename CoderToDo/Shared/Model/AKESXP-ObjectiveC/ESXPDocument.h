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
#import "ESXPElement.h"

/// Class for representing a DOM Document.
///
/// \author Andreas P. Koenzen <akc at apkc.net>
/// \see    Builder Pattern
@interface ESXPDocument : NSObject
{
    ESXPElement *root; // The root node of this document.
}

// MARK: Builders
/// Builder of new instances. Follows the Builder Pattern.
///
/// \param name The name of the node.
///
/// \return A new instance of ESXPNode if available, otherwise return NIL.
+ (ESXPDocument *)newBuild:(NSString *)name;

// MARK: Methods
/// Prints this document.
///
/// \param document This document.
///
/// \return A string containing this document's data.
+ (NSString *)printDocument:(ESXPDocument *)document;

/// Puts all Text nodes in the full depth of the sub-tree underneath this
/// Node, including attribute nodes, into a "normal" form where only
/// structure (e.g., elements, comments, processing instructions, CDATA
/// sections, and entity references) separates Text nodes, i.e., there
/// are neither adjacent Text nodes nor empty Text nodes.
- (void)normalize;

/// Returns the root node of this document.
///
/// \return The root node of this document.
- (ESXPElement *)getRootNode;

/// Returns the count of all element nodes of this document.
///
/// \return The count of all element nodes of this document.
- (int)getElementNodeCount;
@end
