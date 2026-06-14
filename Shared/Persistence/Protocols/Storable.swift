import SwiftData

/// An object that can be remapped to and from ``SwiftData/PersistentModel``.
protocol Storable: Identifiable {
	/// ``PersistentModel`` that represents this object.
	associatedtype Stored: PersistentModel

	/// A function that creates this object from its stored representation.
	static func fromStored(_ stored: Stored) -> Self

	/// A function that creates the stored representation of this object.
	func toStored() -> Stored
}
