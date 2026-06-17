# Apex Mock

A robust, Jest-inspired mocking library for Apex unit tests. This library provides a fluent API for creating mocks, configuring behavior (stubbing), and verifying interactions, making unit tests more readable and expressive.

## Core Features

### 1. Mock Creation

Create mock instances of any class or interface using the `StubProvider` API.

```apex
IService mockUtils = (IService) Mock.of(IService.class);
IService namedMock = (IService) Mock.of(IService.class, 'MyMock');
```

### 2. Stubbing (Configuration)

Configure mock behavior using `spyOn`. Support for sequential returns, exceptions, and dynamic callbacks.

- **Return Values**:

    ```apex
    Mock.spyOn(mock, 'method').mockReturnValue('result');
    Mock.spyOn(mock, 'method')
        .mockReturnValueOnce('First')
        .mockReturnValueOnce('Second');
    ```

- **Exceptions**:

    ```apex
    Mock.spyOn(mock, 'method').mockThrow(new MyException('Boom'));
    ```

- **Dynamic Implementation**:

    ```apex
    Mock.spyOn(mock, 'method').mockImplementation(new MyCallback());
    ```

- **Overload-Specific Stubbing**:

    ```apex
    Mock.spyOn(mock, 'doWork', new List<Type>{ String.class })
        .mockThrow(new MyException('String overload only'));
    ```

- **Argument-Scoped Stubbing**:

    ```apex
    Mock.spyOn(mock, 'add')
        .whenCalledWith(new List<Object>{ 1, 2 })
        .mockReturnValue(3);

    Mock.spyOn(mock, 'add')
        .whenCalledWith(new List<Object>{ Mock.anyInteger(), 0 })
        .mockThrow(new IllegalArgumentException('Second arg cannot be zero'));

    Mock.spyOn(mock, 'add')
        .whenCalledWith(new List<Object>{ 3, 0 })
        .mockThrowOnce(new IllegalArgumentException('Throw once'))
        .mockReturnValue(30);

    Mock.spyOn(mock, 'add')
        .whenCalledWith(new List<Object>{ 10, 20 })
        .mockImplementationOnce(new MyCallback())
        .mockReturnValue(31);
    ```

`whenCalledWith(...)` supports matchers in argument lists and takes precedence over method-level stubs when arguments match.
Scoped one-time stubs fall back to a scoped default when present; otherwise, consumed scoped once-actions continue to method-level behavior or the default `null` return.

### 3. Verification

Verify method calls with Jest-like `expect` syntax. Supports both explicit mock verification and spy-based verification.

- **Basic Verification**:

    ```apex
    Mock.expect(mock).toHaveBeenCalled('method');
    Mock.expect(mock).toHaveBeenCalledTimes('method', 2);
    Mock.expect(mock).toHaveBeenCalledWith('method', new List<Object>{ 'arg1' });
    ```

- **Spy Verification** (cleaner syntax):

    ```apex
    Mock.MethodSpy spy = Mock.spyOn(mock, 'method');
    // ... execution ...
    Mock.expect(spy).toHaveBeenCalled();
    Mock.expect(spy).toHaveBeenCalledWith(new List<Object>{ 'arg1' });
    ```

Use `expect(spy).toHaveBeenCalled()` for no-arg verification. For mock-level verification, pass the method name: `expect(mock).toHaveBeenCalled('method')`.

- **Negation**:

    ```apex
    Mock.expect(spy).notx.toHaveBeenCalled();
    ```

- **Call History**:

    ```apex
    Mock.expect(spy).nthCalledWith(1, new List<Object>{ 'first' });
    Mock.expect(spy).lastCalledWith(new List<Object>{ 'last' });
    ```

- **Return Outcome Assertions**:

    ```apex
    Mock.expect(spy).toHaveReturned();
    Mock.expect(spy).toHaveReturnedTimes(2);
    Mock.expect(spy).toHaveReturnedWith('ok');
    Mock.expect(spy).toHaveNthReturnedWith(1, 'ok');
    Mock.expect(spy).toHaveLastReturnedWith('ok');

    // Mock-level style is also supported
    Mock.expect(mock).toHaveReturned('method');
    Mock.expect(mock).toHaveLastReturnedWith('method', 'ok');
    ```

Aggregate return assertions (`toHaveReturned`, `toHaveReturnedTimes`, `toHaveReturnedWith`) count only successful returns.
Positional return assertions (`toHaveNthReturnedWith`, `toHaveLastReturnedWith`) select from raw call history first, then fail if the selected call threw.

### 4. Argument Matchers

Flexible argument matching for complex verification. All matchers support **recursive nesting**.

- `Mock.any()`: Matches anything.
    - Includes `null`.
- `Mock.anyString()`, `Mock.anyInteger()`, `Mock.anyId()`, `Mock.anyBoolean()`
- `Mock.anyList()`, `Mock.anyMap()`, `Mock.anyDate()`, `Mock.anyDatetime()`
- `Mock.anyTime()`, `Mock.anySObject()`
- `Mock.stringContaining(String)`: Partial string match.
- `Mock.iterableContaining(Object)`: Checks if list or set contains item.
- `Mock.sObjectContaining(SObject)`: Partial match using an SObject template.
- `Mock.sObjectContaining(Map<SObjectField, Object>)`: Compile-safe partial match. **Supports Nested Matchers.**
- `Mock.objectContaining(Map<String, Object>)`: Partial match for Maps, SObjects, or DTOs. **Supports Nested Matchers.**

**Recursive/Nested Matcher Example**:

```apex
// Compile-safe nested matching for SObjects
Mock.sObjectContaining(new Map<SObjectField, Object>{
    Account.Name => Mock.stringContaining('Acme'),
    Account.NumberOfEmployees => Mock.anyInteger()
});
```

### 5. Value Assertions

Generic assertions for values, eliminating the need for `System.Assert` in many cases.

- `toBe(val)`: Strict reference equality (`===`).
- `toEqual(val)` / `toEq(val)`: Value/deep equality (`==`).
- `toBeTrue()`, `toBeFalse()`, `toBeNull()`
- `toMatch(regex)`
- `toContain(item)`
- `toBeLessThan(val)` / `toBeLt(val)`, `toBeLessThanOrEqual(val)` / `toBeLe(val)`
- `toBeGreaterThan(val)` / `toBeGt(val)`, `toBeGreaterThanOrEqual(val)` / `toBeGe(val)`

### 6. Mock Maintenance

Globally or individually clear/reset mocks.

- `Mock.clear(mock)` / `Mock.clearAll()`: Clears call history, keeps configuration.
- `Mock.reset(mock)` / `Mock.resetAll()`: Clears history AND configuration.

### 7. HTTP Mocking

Native support for `HttpCalloutMock` with method-specific responses.

```apex
Mock.HttpMock http = Mock.mockHttp();
// Method-specific responses
http.mockResponse('GET', 'https://api.com/users', '{"users": []}', 200);
http.mockResponse('POST', 'https://api.com/users', '{"status": "created"}', 201);
// Global fallback
http.mockResponse('https://api.com/users', 'error', 500);

Mock.expect(http).toHaveBeenCalledTimes(2);
Mock.expect(http).toHaveBeenCalledWith('https://api.com/users', 'POST');
```

### 8. Exception Assertions

Assert that a code block throws an exception.

```apex
Mock.expect(new MyAction(service)).toThrow('Invalid ID');
```

Requires implementing the `Mock.Block` interface to wrap the code execution.

### 9. Test Utilities

Built-in utilities to simplify test data generation.

```apex
// Generate a valid 18-character Id for an SObject Type
Id accountId = Mock.fakeId(Account.SObjectType);

// Generate a list of legitimate Ids
List<Id> oppIds = Mock.fakeIds(Opportunity.SObjectType, 3);
```

## Architecture

- **Mock.cls**: The central facade containing all static methods and inner classes (`MethodSpy`, `MockExpectation`, `Matcher`).
- **MockProvider**: Internal `System.StubProvider` that handles method interception. Uses a `Map` for **O(1)** call history retrieval by method.
    - Supports overload-safe lookup using method signature keys (`methodName(paramType1,paramType2,...)`) with method-name fallback for backward compatibility.
    - Tracks per-call outcomes (`didReturn`, `returnValue`) so return assertions can distinguish successful returns from thrown calls.
- **Interfaces**:
    - `Mock.Callback`: For dynamic `mockImplementation`.
    - `Mock.Matcher`: For custom argument matching logic.
    - `Mock.Block`: For exception assertions.
