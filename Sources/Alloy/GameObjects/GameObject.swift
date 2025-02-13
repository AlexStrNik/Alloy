//
//  GameObject.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 11.01.2024.
//

import Foundation
import Metal

open class AEGameObject {
    public var transform: AETransform = .init()

    private(set) var parent: AEGameObject?

    private var head: AEGameObject?
    private var tail: AEGameObject?

    private var next: AEGameObject?
    private var prev: AEGameObject?

    private var destroyed: Bool = false

    public init() {}

    open func performUpdate(deltaTime: Float) {
        forEach { child in
            child.performUpdate(deltaTime: deltaTime)
            if child.destroyed {
                child.prev?.next = child.next
                child.next?.prev = child.prev
            }
        }
        if let head = head, head.destroyed {
            self.head = head.next
        }
        if let tail = tail, tail.destroyed {
            self.tail = tail.prev
        }
    }

    public func initialize() {
        forEach { child in
            child.initialize()
        }
    }

    open func performRender(commandEncoder: MTLRenderCommandEncoder) {
        forEach { child in
            child.performRender(commandEncoder: commandEncoder)
        }
    }

    public func addChild(_ gameObject: AEGameObject) {
        gameObject.parent = self
        gameObject.transform.parent = self.transform

        if let tailNode = tail {
            tailNode.next = gameObject
            gameObject.prev = tailNode
        } else {
            head = gameObject
        }

        tail = gameObject
    }

    open func destroy() {
        self.destroyed = true
    }

    private func forEach(_ f: (AEGameObject) -> Void) {
        var cursor = head

        while let node = cursor {
            f(node)
            cursor = cursor?.next
        }
    }
}
