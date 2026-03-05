# Apex Mock

![](https://img.shields.io/github/v/release/berehovskyi/apex-mock?include_prereleases)
![](https://img.shields.io/badge/build-passing-brightgreen.svg)
![](https://img.shields.io/badge/coverage-90%25-brightgreen.svg)

A robust, Jest-inspired mocking library for Salesforce Apex unit tests. `apex-mock` provides a fluent API for creating mocks, configuring behavior (stubs), verifying interactions, and generating test data, bringing the expressive testing patterns of Jest to the Apex ecosystem.

## Table of Contents

- [Installation](#installation)
- [Features](#features)
- [Usage](#usage)
    - [Mock Creation](#mock-creation)
    - [Stubbing](#stubbing)
    - [Verification](#verification)
    - [Value Assertions](#value-assertions)
    - [Argument Matchers](#argument-matchers)
    - [HTTP Callout Mocking](#http-callout-mocking)
    - [Exception Assertions](#exception-assertions)
    - [Test Utilities](#test-utilities)
- [Architecture](#architecture)
- [Documentation](#documentation)

## Installation

<a href="https://githubsfdeploy.herokuapp.com?owner=berehovskyi&repo=apex-mock&ref=main">
  <img alt="Deploy to Salesforce" src="https://img.shields.io/badge/Deploy%20to-Salesforce-%2300a1e0?style=for-the-badge&logo=appveyor">
</a>

or install as an Unlocked Package using the CLI:

```sh pkg::apex-mock
sf package install -p 04tJ5000000D7gdIAC -o <org-alias> -r -w 10
```

## Features

- **Mock Any Type**: Create mocks for classes and interfaces using the `System.StubProvider` API.
- **Fluent Verification**: Verify method calls with `expect(spy).toHaveBeenCalled()` or `expect(mock).toHaveBeenCalled('methodName')`.
- **Nested Matchers**: Support for deeply nested argument matchers (`objectContaining`, `anyId`, etc.).
- **HTTP Mocking**: Native `HttpCalloutMock` support with method and URL-specific responses.
- **Low Overhead**: Optimized for performance with O(1) call lookup.
- **Test Utilities**: Built-in helpers for rapid test data setup.
- **Exception Testing**: Clean assertions for expected exceptions using `expect(block).toThrow()`.

## Usage

### Mock Creation

External dependencies can be mocked by creating a stub instance. Support is provided for both interfaces and concrete classes suitable for dependency injection.

```apex
// Create a mock for an interface or class
IService mockService = (IService) Mock.of(IService.class);

// Create a named mock (recommended for clearer debugging output)
IService namedMock = (IService) Mock.of(IService.class, 'MyServiceMock');
```

### Stubbing

Configure the behavior of your mock objects. You can define return values, sequences, exceptions, or dynamic implementations.

```apex
// Return a specific value
Mock.spyOn(mockService, 'calculate').mockReturnValue(100);

// Sequential returns (first call returns 10, second returns 20, then null)
Mock.spyOn(mockService, 'next')
    .mockReturnValueOnce(10)
    .mockReturnValueOnce(20);

// Throw an exception
Mock.spyOn(mockService, 'validate').mockThrow(new MyCustomException('Invalid'));

// Dynamic implementation using a callback
Mock.spyOn(mockService, 'process').mockImplementation(new MyCallback());

// Overload-specific stubbing (recommended when method names are overloaded)
Mock.spyOn(mockService, 'doWork', new List<Type>{ String.class })
    .mockThrow(new IllegalArgumentException('String overload only'));
```

When stubbing overloaded methods, prefer `spyOn(stub, methodName, parameterTypes)` so behavior is scoped to the intended signature.

**Available Stubbing:**

| Method                         | Description                                                                       |
| :----------------------------- | :-------------------------------------------------------------------------------- |
| `mockReturnValue(val)`         | Configures the method to always return the specified value.                       |
| `mockReturnValueOnce(val)`     | Configures the method to return the value once (chained calls create a sequence). |
| `mockThrow(exception)`         | Configures the method to throw the specified exception when called.               |
| `mockImplementation(callback)` | Configures a dynamic implementation using the `Mock.Callback` interface.          |

### Verification

Verify that your unit under test interacted with its dependencies as expected.

```apex
// Arrange: Create mock and inject it into the unit under test
IDependency mock = (IDependency) Mock.of(IDependency.class);
MyController controller = new MyController(mock);
Mock.MethodSpy spy = Mock.spyOn(mock, 'save');

// Act: Execute your code
controller.execute(data);

// Assert: Verify interactions
Mock.expect(spy).toHaveBeenCalled();
Mock.expect(spy).toHaveBeenCalledTimes(1);
Mock.expect(spy).toHaveBeenCalledWith(new List<Object>{ expectedValue });
Mock.expect(spy).toHaveReturned();
Mock.expect(spy).toHaveReturnedTimes(1);
Mock.expect(spy).toHaveReturnedWith(expectedResult);
Mock.expect(spy).toHaveNthReturnedWith(1, expectedResult);
Mock.expect(spy).toHaveLastReturnedWith(expectedResult);

// Verify an interaction did NOT happen
Mock.expect(spy).notx.toHaveBeenCalled();

// Overload-specific verification
Mock.MethodSpy stringSpy = Mock.spyOn(mock, 'doWork', new List<Type>{ String.class });
Mock.MethodSpy objectSpy = Mock.spyOn(mock, 'doWork', new List<Type>{ Object.class });
Mock.expect(stringSpy).toHaveBeenCalledTimes(1);
Mock.expect(objectSpy).toHaveBeenCalledTimes(1);
```

**Available Verifications:**

| Verification                 | Description                                                                    |
| :--------------------------- | :----------------------------------------------------------------------------- |
| `toHaveBeenCalled()`         | Asserts the method was called at least once.                                   |
| `toHaveBeenCalledTimes(n)`   | Asserts the method was called exactly `n` times.                               |
| `toHaveBeenCalledWith(args)` | Asserts at least one call was made with the specified arguments.               |
| `lastCalledWith(args)`       | Asserts the most recent call was made with the specified arguments.            |
| `nthCalledWith(n, args)`     | Asserts the `n`-th call was made with the specified arguments (1-based index). |
| `toHaveReturned()`           | Asserts the method returned successfully at least once.                        |
| `toHaveReturnedTimes(n)`     | Asserts the method returned successfully exactly `n` times.                    |
| `toHaveReturnedWith(val)`    | Asserts at least one successful call returned a matching value.                |
| `toHaveNthReturnedWith(n,v)` | Asserts the `n`-th call returned a matching value (1-based index).             |
| `toHaveLastReturnedWith(v)`  | Asserts the most recent call returned a matching value.                        |

> [!NOTE]
> All verifications support negation via the `.notx` property.
> `toHaveReturned*` assertions count only successful returns (calls that throw are excluded).

### Value Assertions

Generic assertions for validating object state or collection contents using matchers.

```apex
// Partial object matching
Mock.expect(mySObject).toMatch(Mock.sObjectContaining(new Map<SObjectField, Object>{
    Account.Name => 'Acme'
}));

// Collection verification
Mock.expect(myList).toContain(Mock.stringContaining('Success'));

// Equality
Mock.expect(obj).toBe(objRef); // Strict reference equality (===)
Mock.expect(obj).toEqual(otherObj); // Value equality (==)
```

**Available Assertions:**

| Assertion              | Description                                                                 |
| :--------------------- | :-------------------------------------------------------------------------- |
| `toBe(val)`            | Asserts strict reference equality (`===`).                                  |
| `toEqual(val)`         | Asserts value equality (`==`).                                              |
| `toMatch(matcher)`     | Asserts that a value matches the criteria of a `Mock.Matcher`.              |
| `toMatch(regex)`       | Asserts that a string matches the specified regular expression.             |
| `toContain(item)`      | Asserts that a List/Set or String contains the specified item (or matcher). |
| `toBeNull()`           | Asserts that the value is `null`.                                           |
| `toBeTrue()`           | Asserts that the value is exactly `true`.                                   |
| `toBeFalse()`          | Asserts that the value is exactly `false`.                                  |
| `toBeLessThan(num)`    | Asserts that the numeric value is less than the specified amount.           |
| `toBeGreaterThan(num)` | Asserts that the numeric value is greater than the specified amount.        |

**Available Matchers:**

| Category        | Matcher                                                       | Description                                                          |
| :-------------- | :------------------------------------------------------------ | :------------------------------------------------------------------- |
| **Primitives**  | `anyString()`, `anyInteger()`, `anyDecimal()`, `anyBoolean()` | Matches any value of the specific primitive type.                    |
| **Identifiers** | `anyId()`, `anySObject()`, `anySObject(type)`                 | Matches any Salesforce Id or SObject (optionally by type).           |
| **Date/Time**   | `anyDate()`, `anyDatetime()`, `anyTime()`                     | Matches any date, datetime, or time value.                           |
| **Collections** | `anyList()`, `anyMap()`                                       | Matches any List or Map collection.                                  |
| **Type Safe**   | `any(Type)`                                                   | Matches any object that is an instance of the specified Type.        |
| **Logic**       | `notx(matcher)`                                               | Negates the criteria of the specified matcher.                       |
| **Partial**     | `stringContaining(sub)`                                       | Matches if the string contains the specified substring.              |
|                 | `iterableContaining(item)`                                    | Matches if a List/Set contains the specified item (or matcher).      |
|                 | `objectContaining(map)`                                       | Matches if an Object/Map/DTO contains the specified key-value pairs. |
|                 | `sObjectContaining(sobj/map)`                                 | Matches if an SObject contains the specified field-value pairs.      |
| **Generic**     | `any()`                                                       | Matches any value (including `null`).                                |

### Argument Matchers

Use matchers to verify arguments flexibly without strict equality checks. Matchers can be nested to arbitrary depths.

```apex
Mock.expect(spy).toHaveBeenCalledWith(new List<Object>{
    Mock.sObjectContaining(new Map<SObjectField, Object>{
        Account.Name => Mock.stringContaining('Acme'),
        Account.NumberOfEmployees => Mock.anyInteger()
    })
});
```

### HTTP Callout Mocking

Simplify HTTP testing with a Mock implementation that handles routing responses based on method and URL.

```apex
Mock.HttpMock http = Mock.mockHttp();

// Define responses for specific endpoints
http.mockResponse('GET', 'https://api.example.com/users', '{"users": []}', 200);
http.mockResponse('POST', 'https://api.example.com/users', '{"id": "123"}', 201);

// Verify callouts
Mock.expect(http).toHaveBeenCalledTimes(2);
Mock.expect(http).toHaveBeenCalledWith(Mock.stringContaining('api.example.com'), 'POST');

// Advanced: Verify body and headers
Mock.expect(http).toHaveBeenCalledWith(
    Mock.anyString(),
    'POST',
    Mock.stringContaining('123'),
    new Map<String, Object>{ 'Content-Type' => 'application/json' }
);
```

### Exception Assertions

Assert that a specific block of code throws an exception, similar to `assertThrows` in other languages.

```apex
// Implement Mock.Block interface or use a wrapper
// Define your block of code
public class MyActionBlock implements Mock.Block {
    public void run() { throw new IllegalArgumentException('Required field missing'); }
}

// Assert expectation
Mock.expect(new MyActionBlock()).toThrow('Required field missing');
```

### Test Utilities

Helper methods to reduce boilerplate in test setup.

```apex
// Generate a valid, typed 18-character Id
Id accountId = Mock.fakeId(Account.SObjectType);

// Generate a list of Ids
List<Id> contactIds = Mock.fakeIds(Contact.SObjectType, 5);
```

## Architecture

This library implements a facade pattern over the `System.StubProvider` interface.

- **Mock.cls**: The primary entry point containing static methods and inner classes (`MethodSpy`, `MockExpectation`, `Matcher`).
- **MockProvider**: The internal handler for method interception and call recording.
- **Performance**: Call history uses `Map<String, List<MethodCall>>` for O(1) retrieval, ensuring verifications remain performant even with high call volumes.

## Limitations

This library is built on top of the native Apex `System.StubProvider` API and inherits its inherent limitations. You cannot mock the following elements:

- **Static methods** (including `@future` methods)
- **Private methods**
- **Properties** (getters and setters)
- **Triggers**
- **Inner classes**
- **System types** (e.g., `Http`, `HttpRequest`)
- **Batchable classes** (classes that implement `Database.Batchable`)
- **Private constructors** (classes that have only private constructors)

Additionally, **Iterators** cannot be used as return types or parameter types in mocked methods.

## Documentation

[Full Apex Mock Documentation](/docs/README.md).
