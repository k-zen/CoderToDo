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
#import "AKDataStructures.h"
#import "ESXPDocument.h"
#import "ESXPNode.h"
#import "ESXPText.h"

/// Creates a DOM Document using a SAX parser.
///
/// \author Andreas P. Koenzen <akc at apkc.net>
@interface ESXPSAX2DOM : NSObject <NSXMLParserDelegate>
@property (nonatomic, strong) id<ESXPNode> nextSibling;
@property (nonatomic, strong) id<ESXPNode> lastSibling;
@property (nonatomic, strong) ESXPDocument *document;
@property (nonatomic, strong) AKStack      *stack;

// MARK: Builders
/// Builder of new instances. Follows the Builder Pattern.
///
/// \param maxNodes The maximum number of nodes.
///
/// \return A new instance of this class or nil if any problem.
+ (ESXPSAX2DOM *)newBuild:(NSUInteger)maxNodes;

// MARK: Methods
/// Returns the XML file as a DOM representation.
///
/// \return The DOM object.
- (ESXPDocument *)getDOM;
@end
