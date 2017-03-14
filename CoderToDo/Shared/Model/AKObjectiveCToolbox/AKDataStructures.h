/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2013 EvgenyKarkan
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

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

/// Class for representing a stack data structure.
///
/// \author Andreas P. Koenzen <akc at apkc.net>
@interface AKStack : NSObject
@property (nonatomic, strong) NSMutableArray *stackArray;
@property (nonatomic, assign) NSUInteger     maxStackSize;

/// Initializes a stack with a given size.
///
/// \param size The initial size of the stack.
///
/// \return The stack object.
- (AKStack *)initWithSize:(NSUInteger)size;

/// Get the element at the head of this stack.
///
/// \return The element at the head of this stack.
- (id)pop;

/// Add a new element to the head of this stack.
///
/// \param object The object to add.
- (void)push:(id)object;

/// Get the element at the head of this stack without removing it from the stack.
///
/// \return The element at the head of this stack.
- (id)peek;

/// Calculates the size of this stack.
///
/// \return The size of this stack.
- (NSInteger)size;

/// Checks if this stack is empty.
///
/// \return YES if it's empty, NO otherwise.
- (BOOL)isEmpty;

/// Checks if this stack is full.
///
/// \return YES if it's full, NO otherwise.
- (BOOL)isFull;

/// Clears this stack.
- (void)clear;

/// Returns all objects in this stack as an array of objects.
///
/// \return An array with all objects in this stack.
- (NSArray *)allObjectsFromStack;
@end
