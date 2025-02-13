//
//  Plane.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 11.01.2024.
//

import Foundation

open class AEPlane: AEMesh {
    var name: String = "Plane"

    private var vertices: [Vertex] = [
        .init(
            position: .init(1, 1, 0),
            normal: .init(0, 1, 0),
            uv: .init(1, 0)
        ),
        .init(
            position: .init(-1, 1, 0),
            normal: .init(0, 1, 0),
            uv: .init(0, 0)
        ),
        .init(
            position: .init(-1, -1, 0),
            normal: .init(0, 1, 0),
            uv: .init(0, 1)
        ),
        .init(
            position: .init(1, -1, 0),
            normal: .init(0, 1, 0),
            uv: .init(1, 1)
        ),
    ]

    private var indices: [UInt32] = [
        0, 1, 2,
        0, 2, 3,
    ]

    private var meshBuffer: AEMeshBuffer?

    public func load() -> AEMeshBuffer {
        if let meshBuffer = self.meshBuffer {
            return meshBuffer
        }

        self.meshBuffer = AEMeshBuffer(
            vertices: AERenderer.device.makeBuffer(
                bytes: vertices,
                length: MemoryLayout<Vertex>.stride * self.vertices.count
            )!,
            indices: AERenderer.device.makeBuffer(
                bytes: indices,
                length: MemoryLayout<UInt32>.stride * self.indices.count
            )!,
            indexCount: indices.count
        )

        return meshBuffer!
    }
}
