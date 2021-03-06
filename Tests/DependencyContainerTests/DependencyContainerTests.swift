import XCTest
@testable import DependencyContainer

final class DependencyContainerTests: XCTestCase {
    private class DummyTest: Equatable {
        let name: String
        let id: String = UUID().uuidString

        init(name: String) {
            self.name = name
        }

        static func == (lhs: DependencyContainerTests.DummyTest, rhs: DependencyContainerTests.DummyTest) -> Bool {
            guard lhs.id == rhs.id else { return false }
            guard lhs.name == rhs.name else { return false }
            return true
        }
    }

    private class MultipleArgsDummyTest: Equatable {
        let name: String
        let city: String
        let state: String
        let country: String

        init(name: String, city: String, state: String, country: String) {
            self.name = name
            self.city = city
            self.state = state
            self.country = country
        }

        static func == (lhs: DependencyContainerTests.MultipleArgsDummyTest, rhs: DependencyContainerTests.MultipleArgsDummyTest) -> Bool {
            guard lhs.name == rhs.name else { return false }
            guard lhs.city == rhs.city else { return false }
            guard lhs.state == rhs.state else { return false }
            guard lhs.country == rhs.country else { return false }
            return true
        }
    }

    func testContainerResolvesRegisteredClasses() {
        let container = DependencyContainer()

        container.register(DummyTest.self) { (di) -> DummyTest in
            return DummyTest(name: "Test")
        }

        let resolvedTest1 = container.resolve(DummyTest.self)
        let resolvedTest2 = container.resolve(DummyTest.self)

        XCTAssertNotEqual(resolvedTest1, resolvedTest2, "Factory creates a new instance for every instance resolved")
    }

    func testContainerResolvesSingletonRegisteredClasses() {
        let container = DependencyContainer()

        container.registerSingleton(DummyTest.self) { (di) -> DummyTest in
            return DummyTest(name: "Test")
        }

        let resolvedTest1 = container.resolve(DummyTest.self)
        let resolvedTest2 = container.resolve(DummyTest.self)

        XCTAssertEqual(resolvedTest1, resolvedTest2, "Singleton factories returns the same instance for every instance resolved")
        XCTAssertTrue(resolvedTest1 === resolvedTest2, "Resolve singleton should return the same instance every time")
    }
}

extension DependencyContainerTests {
    // MARK: - Test Contains

    func testContainerContainsRegisteredSingletonClass() {
        let container = DependencyContainer()

        XCTAssertFalse(container.contains(DummyTest.self))

        container.registerSingleton(DummyTest.self) { di -> DummyTest in
            return DummyTest(name: "Test")
        }

        XCTAssertTrue(container.contains(DummyTest.self), "container should contain the registered singleton")
    }

    func testContainerContainsInstantiatedSingletonClass() {
        let container = DependencyContainer()

        XCTAssertFalse(container.contains(DummyTest.self))

        container.registerSingleton(DummyTest.self) { di -> DummyTest in
            return DummyTest(name: "Test")
        }

        let singleton = container.resolve(DummyTest.self)

        XCTAssertTrue(singleton === container.resolve(DummyTest.self), "Singletons should have the same memory address")
        XCTAssertTrue(container.contains(DummyTest.self), "container should contain the registered singleton")
    }

    func testContainerContainsRegisteredFactoryClass() {
        let container = DependencyContainer()

        XCTAssertFalse(container.contains(DummyTest.self))

        container.register(DummyTest.self) { di -> DummyTest in
            return DummyTest(name: "Test")
        }

        // The singleton instance hasn't been created yet because it has never been resolved.
        XCTAssertTrue(container.contains(DummyTest.self), "container should contain the registered factory")
    }
}

extension DependencyContainerTests {
    // MARK: - Test One Argument

    func testContainerContainsRegisteredFactoryClassWithSingleArgument() {
        let container = DependencyContainer()

        XCTAssertFalse(container.contains(DummyTest.self))

        container.register(DummyTest.self) { di, name -> DummyTest in
            return DummyTest(name: name)
        }

        XCTAssertTrue(container.contains(DummyTest.self), "container should contain the registered factory")
    }

    func testContainerResolveFactoryClassWithSingleArgument() {
        let container = DependencyContainer()

        XCTAssertFalse(container.contains(DummyTest.self))

        container.register(DummyTest.self) { di, name -> DummyTest in
            return DummyTest(name: name)
        }

        let resolved = container.resolve(DummyTest.self, argument: "Some name")
        XCTAssertEqual(resolved.name, "Some name")
        XCTAssertFalse(resolved === container.resolve(DummyTest.self, argument: "Some name"), "Resolve factory should create new instances every time")
    }
}

extension DependencyContainerTests {
    // MARK: - Test Two Argument

    func testContainerContainsRegisteredFactoryClassWithTwoArguments() {
        let container = DependencyContainer()

        XCTAssertFalse(container.contains(MultipleArgsDummyTest.self))

        container.register(MultipleArgsDummyTest.self) { di, name, city -> MultipleArgsDummyTest in
            return MultipleArgsDummyTest(name: name, city: city, state: "NSW", country: "Australia")
        }

        XCTAssertTrue(container.contains(MultipleArgsDummyTest.self), "container should contain the registered factory")
    }

    func testContainerResolveFactoryClassWithTwoArguments() {
        let container = DependencyContainer()

        XCTAssertFalse(container.contains(DummyTest.self))

        container.register(MultipleArgsDummyTest.self) { di, name, city -> MultipleArgsDummyTest in
            return MultipleArgsDummyTest(name: name, city: city, state: "NSW", country: "Australia")
        }

        let resolved = container.resolve(MultipleArgsDummyTest.self, arguments: "Some name", "Sydney")
        XCTAssertEqual(resolved.name, "Some name")
        XCTAssertEqual(resolved.city, "Sydney")
        XCTAssertEqual(resolved.state, "NSW")
        XCTAssertEqual(resolved.country, "Australia")
        XCTAssertFalse(resolved === container.resolve(MultipleArgsDummyTest.self, arguments: "Some name", "Sydney"), "Resolve factory should create new instances every time")
    }
}

extension DependencyContainerTests {
    // MARK: - Test Three Argument

    func testContainerContainsRegisteredFactoryClassWithThreeArguments() {
        let container = DependencyContainer()

        XCTAssertFalse(container.contains(MultipleArgsDummyTest.self))

        container.register(MultipleArgsDummyTest.self) { di, name, city, state -> MultipleArgsDummyTest in
            return MultipleArgsDummyTest(name: name, city: city, state: state, country: "Australia")
        }

        XCTAssertTrue(container.contains(MultipleArgsDummyTest.self), "container should contain the registered factory")
    }

    func testContainerResolveFactoryClassWithThreeArguments() {
        let container = DependencyContainer()

        XCTAssertFalse(container.contains(DummyTest.self))

        container.register(MultipleArgsDummyTest.self) { di, name, city, state -> MultipleArgsDummyTest in
            return MultipleArgsDummyTest(name: name, city: city, state: state, country: "Australia")
        }

        let resolved = container.resolve(MultipleArgsDummyTest.self, arguments: "Some name", "Sydney", "NSW")
        XCTAssertEqual(resolved.name, "Some name")
        XCTAssertEqual(resolved.city, "Sydney")
        XCTAssertEqual(resolved.state, "NSW")
        XCTAssertEqual(resolved.country, "Australia")
        XCTAssertFalse(resolved === container.resolve(MultipleArgsDummyTest.self, arguments: "Some name", "Sydney", "NSW"), "Resolve factory should create new instances every time")
    }
}

extension DependencyContainerTests {
    // MARK: - Test Four Argument

    func testContainerContainsRegisteredFactoryClassWithFourArguments() {
        let container = DependencyContainer()

        XCTAssertFalse(container.contains(MultipleArgsDummyTest.self))

        container.register(MultipleArgsDummyTest.self) { di, name, city, state, country -> MultipleArgsDummyTest in
            return MultipleArgsDummyTest(name: name, city: city, state: state, country: country)
        }

        XCTAssertTrue(container.contains(MultipleArgsDummyTest.self), "container should contain the registered factory")
    }

    func testContainerResolveFactoryClassWithFourArguments() {
        let container = DependencyContainer()

        XCTAssertFalse(container.contains(DummyTest.self))

        container.register(MultipleArgsDummyTest.self) { di, name, city, state, country -> MultipleArgsDummyTest in
            return MultipleArgsDummyTest(name: name, city: city, state: state, country: country)
        }

        let resolved = container.resolve(MultipleArgsDummyTest.self, arguments: "Some name", "Sydney", "NSW", "Australia")
        XCTAssertEqual(resolved.name, "Some name")
        XCTAssertEqual(resolved.city, "Sydney")
        XCTAssertEqual(resolved.state, "NSW")
        XCTAssertEqual(resolved.country, "Australia")
        XCTAssertFalse(resolved === container.resolve(MultipleArgsDummyTest.self, arguments: "Some name", "Sydney", "NSW", "Australia"), "Resolve factory should create new instances every time")
    }
}
