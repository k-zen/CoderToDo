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
#import "ESXPElement.h"
#import "ESXPNode.h"
#import "ESXPStackDOMWalker.h"

/// Traverses a DOM tree using a stack as a buffer for nodes.
///
/// <pre>
///              |--DOC--NRO<br/>
///     |---CLI--|<br/>
///     |        |--CTA<br/>
///     |<br/>
///     |        |--PIN<br/>
///     |---AUTH-|<br/>
/// TRX-|        |--EST      |-NCTA<br/>
///     |                    |-SALDOC<br/>
///     |---CTAS--------CTA--|-SALDOD       |-DETALLE<br/>
///     |                    |-MOVS----MOV--|<br/>
///     |                                   |-MONTO<br/>
///     |              |-NCTA<br/>
///     |       |-CTA--|<br/>
///     |---TXT-|      |-DENOM<br/>
///     |       |<br/>
///     |       |-SOBRE<br/>
///     |       |-MONTO<br/>
///     |       |-ESTADO<br/>
///     |       |-RAZON<br/>
///     |<br/>
///     |---INFO--IPADDR<br/>
/// </pre>
///
/// <p>
/// The algorithm starts by adding the root node into the stack. Then on the
/// first call to the method nextNode() it removes the root node from the stack
/// but adds all its children into it, obeying the order last to first. This last
/// step makes it possible to visit the nodes from left to right.<br/>
/// This step is repeated until there are no more nodes in the pile.
/// </p>
///
/// <p>
/// Sample behavior of the stack while loading the tree:
///
/// <pre>
///               DOC   NRO<br/>
///         CLI   CTA   CTA   CTA         PIN<br/>
///         AUTH  AUTH  AUTH  AUTH  AUTH  EST<br/>
///         CTAS  CTAS  CTAS  CTAS  CTAS  CTAS<br/>
///         TXT   TXT   TXT   TXT   TXT   TXT<br/>
/// TRX     INFO  INFO  INFO  INFO  INFO  INFO<br/>
///
/// init()  It.1  It.2  It.3  It.4  It.5  It.6
/// </pre>
/// </p>
///
/// \author Andreas P. Koenzen <akc at apkc.net>
/// \see    Builder Pattern
@interface ESXPStackDOMWalker : NSObject
{
    id<ESXPNode>   currentNode;
    NSMutableArray *currentChildren;
    AKStack        *nodes;
    unsigned short nodesToProcess;
}

// MARK: Builders
/// Builder of new instances. Follows the Builder Pattern.
///
/// \return A new instance of this class or nil if any problem.
+ (ESXPStackDOMWalker *)newBuild;

// MARK: Methods
- (ESXPStackDOMWalker *)configure:(NSUInteger)maxNodes rootNode:(ESXPElement *)rootNode nodesToProcess:(unsigned short)ntp;

- (id<ESXPNode>)nextNode;

- (void)skipChildren;

- (BOOL)hasNext;
@end
