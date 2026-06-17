# Mock

`APIVERSION: 65`

`STATUS: ACTIVE`

Jest-inspired mocking utility for Apex unit tests.
Provides a fluent API for creating, configuring, and verifying mock objects.

## Methods
### `public static Object of(Type type, String mockName)`

Creates a named mock instance for better identification in error messages.

#### Parameters

|Param|Description|
|---|---|
|`type`|The interface or class type to mock|
|`mockName`|Name used in assertion failure messages|

#### Returns

|Type|Description|
|---|---|
|`Object`|A mock instance|

### `public static Object of(Type type)`

Creates a mock instance of the specified type.

#### Parameters

|Param|Description|
|---|---|
|`type`|The interface or class type to mock|

#### Returns

|Type|Description|
|---|---|
|`Object`|A mock instance|

#### Example
```apex
IService mock = (IService) Mock.of(IService.class);
```


### `public static String getMockName(Object stub)`

Gets the name of the mock object.

#### Parameters

|Param|Description|
|---|---|
|`stub`|The mock object|

#### Returns

|Type|Description|
|---|---|
|`String`|The mock name or null|

### `public static MethodSpy spyOn(Object stub, String methodName)`

Creates a spy on a specific method of a mock object.

#### Parameters

|Param|Description|
|---|---|
|`stub`|The mock object created by Mock.of()|
|`methodName`|The name of the method to spy on|

#### Returns

|Type|Description|
|---|---|
|`MethodSpy`|A MethodSpy for stubbing or call history access|

### `public static MockExpectation expect(Object stub)`

Creates an expectation for verifying mock interactions or asserting values.

#### Parameters

|Param|Description|
|---|---|
|`stub`|The mock object or value to assert|

#### Returns

|Type|Description|
|---|---|
|`MockExpectation`|A MockExpectation for fluent verification|

### `public static void clear(Object stub)`

Clears the interaction history of the specific mock object.

#### Parameters

|Param|Description|
|---|---|
|`stub`|The mock object|

### `public static void clearAll()`

Clears the interaction history of ALL registered mock objects.

### `public static void reset(Object stub)`

Resets the mock object completely.

#### Parameters

|Param|Description|
|---|---|
|`stub`|The mock object|

### `public static void resetAll()`

Resets ALL registered mock objects.

### `public static MockExpectation expect(MethodSpy spy)`

Creates an expectation for a specific method spy.

#### Parameters

|Param|Description|
|---|---|
|`spy`|The method spy to expect|

#### Returns

|Type|Description|
|---|---|
|`MockExpectation`|A MockExpectation for verification|

### `public static HttpMock mockHttp()`

Creates and registers an HTTP mock for callout testing.

#### Returns

|Type|Description|
|---|---|
|`HttpMock`|The HttpMock instance|

#### Example
```apex
Mock.HttpMock http = Mock.mockHttp();
http.mockResponse('https://api.com', '{"ok":true}', 200);
```


### `public static HttpMockExpectation expect(HttpMock mock)`

Creates an expectation for verifying HTTP mocks.

#### Parameters

|Param|Description|
|---|---|
|`mock`|The HTTP mock to verify|

#### Returns

|Type|Description|
|---|---|
|`HttpMockExpectation`|An HttpMockExpectation|

### `public static ExceptionExpectation expect(Block b)`

Creates an expectation for verifying code block exceptions.

#### Parameters

|Param|Description|
|---|---|
|`b`|The block of code|

#### Returns

|Type|Description|
|---|---|
|`ExceptionExpectation`|An ExceptionExpectation|

### `public static Matcher any()`

Matches any value.

#### Returns

|Type|Description|
|---|---|
|`Matcher`|A Matcher instance|

### `public static Matcher anyString()`

Matches any String value.

#### Returns

|Type|Description|
|---|---|
|`Matcher`|A Matcher instance|

### `public static Matcher anyInteger()`

Matches any Integer value.

#### Returns

|Type|Description|
|---|---|
|`Matcher`|A Matcher instance|

### `public static Matcher anyDecimal()`

Matches any Decimal value.

#### Returns

|Type|Description|
|---|---|
|`Matcher`|A Matcher instance|

### `public static Matcher anyId()`

Matches any Id value.

#### Returns

|Type|Description|
|---|---|
|`Matcher`|A Matcher instance|

### `public static Matcher anyBoolean()`

Matches any Boolean value.

#### Returns

|Type|Description|
|---|---|
|`Matcher`|A Matcher instance|

### `public static Matcher anyList()`

Matches any List value.

#### Returns

|Type|Description|
|---|---|
|`Matcher`|A Matcher instance|

### `public static Matcher anyMap()`

Matches any Map value.

#### Returns

|Type|Description|
|---|---|
|`Matcher`|A Matcher instance|

### `public static Matcher anyDate()`

Matches any Date value.

#### Returns

|Type|Description|
|---|---|
|`Matcher`|A Matcher instance|

### `public static Matcher anyDatetime()`

Matches any Datetime value.

#### Returns

|Type|Description|
|---|---|
|`Matcher`|A Matcher instance|

### `public static Matcher anyTime()`

Matches any Time value.

#### Returns

|Type|Description|
|---|---|
|`Matcher`|A Matcher instance|

### `public static Matcher any(Type type)`

Matches any value of a specific type.

#### Parameters

|Param|Description|
|---|---|
|`type`|The type to match|

#### Returns

|Type|Description|
|---|---|
|`Matcher`|A Matcher instance|

### `public static Matcher anySObject()`

Matches any SObject.

#### Returns

|Type|Description|
|---|---|
|`Matcher`|A Matcher instance|

### `public static Matcher anySObject(Schema sObjectType)`

Matches any SObject of a specific type.

#### Parameters

|Param|Description|
|---|---|
|`sObjectType`|The SObject type to match|

#### Returns

|Type|Description|
|---|---|
|`Matcher`|A Matcher instance|

### `public static Matcher notx(Matcher matcher)`

Negates the specified matcher.

#### Parameters

|Param|Description|
|---|---|
|`matcher`|The matcher to negate|

#### Returns

|Type|Description|
|---|---|
|`Matcher`|A negated Matcher|

### `public static Matcher objectContaining(Map<String,Object> expected)`

Creates a matcher that checks if an object contains specific fields.

#### Parameters

|Param|Description|
|---|---|
|`expected`|Map of field names to values or matchers|

#### Returns

|Type|Description|
|---|---|
|`Matcher`|A Matcher instance|

### `public static Matcher sObjectContaining(SObject expected)`

Matches SObjects containing specified populated fields.

#### Parameters

|Param|Description|
|---|---|
|`expected`|The template SObject|

#### Returns

|Type|Description|
|---|---|
|`Matcher`|A Matcher instance|

### `public static Matcher sObjectContaining(Map<SObjectField,Object> expected)`

Matches SObjects containing specific field/value pairs.

#### Parameters

|Param|Description|
|---|---|
|`expected`|Map of field/value pairs|

#### Returns

|Type|Description|
|---|---|
|`Matcher`|A Matcher instance|

### `public static Matcher stringContaining(String expected)`

Matches strings containing a specific substring.

#### Parameters

|Param|Description|
|---|---|
|`expected`|The substring to find|

#### Returns

|Type|Description|
|---|---|
|`Matcher`|A Matcher instance|

### `public static Matcher iterableContaining(Object expected)`

Matches collections containing a specific item.

#### Parameters

|Param|Description|
|---|---|
|`expected`|The item or matcher to find|

#### Returns

|Type|Description|
|---|---|
|`Matcher`|A Matcher instance|

### `public static Id fakeId(Schema sObjectType)`

Generates a valid 18-character fake ID for the specified SObject type.

#### Parameters

|Param|Description|
|---|---|
|`sObjectType`|The SObject type|

#### Returns

|Type|Description|
|---|---|
|`Id`|A unique fake ID|

### `public static List<Id> fakeIds(Schema sObjectType, Integer count)`

Generates a list of valid 18-character fake IDs for the specified SObject type.

#### Parameters

|Param|Description|
|---|---|
|`sObjectType`|The SObject type|
|`count`|Number of IDs to generate|

#### Returns

|Type|Description|
|---|---|
|`List<Id>`|List of fake IDs|

---
## Classes
### AnyMatcher

Matcher that matches any non-null value (or null if used as any()).


**Implemented types**

[Matcher](Matcher)

#### Methods
##### `public Boolean matches(Object actual)`

Returns true for any value.

###### Parameters

|Param|Description|
|---|---|
|`actual`|The value to check|

###### Returns

|Type|Description|
|---|---|
|`Boolean`|True|

---

### BooleanMatcher

Matcher for Boolean values.


**Implemented types**

[Matcher](Matcher)

#### Methods
##### `public Boolean matches(Object actual)`

Checks if the value is a Boolean.

###### Parameters

|Param|Description|
|---|---|
|`actual`|Value|

###### Returns

|Type|Description|
|---|---|
|`Boolean`|True if Boolean|

---

### DateMatcher

Matcher for Date values.


**Implemented types**

[Matcher](Matcher)

#### Methods
##### `public Boolean matches(Object actual)`

Checks if the value is a Date.

###### Parameters

|Param|Description|
|---|---|
|`actual`|Value|

###### Returns

|Type|Description|
|---|---|
|`Boolean`|True if Date|

---

### DatetimeMatcher

Matcher for Datetime values.


**Implemented types**

[Matcher](Matcher)

#### Methods
##### `public Boolean matches(Object actual)`

Checks if the value is a Datetime.

###### Parameters

|Param|Description|
|---|---|
|`actual`|Value|

###### Returns

|Type|Description|
|---|---|
|`Boolean`|True if Datetime|

---

### DecimalMatcher

Matcher for Decimal values.


**Implemented types**

[Matcher](Matcher)

#### Methods
##### `public Boolean matches(Object actual)`

Checks if the value is a Decimal.

###### Parameters

|Param|Description|
|---|---|
|`actual`|Value|

###### Returns

|Type|Description|
|---|---|
|`Boolean`|True if Decimal|

---

### ExceptionExpectation

Fluent API for asserting that a block of code throws an exception.

#### Constructors
##### `public ExceptionExpectation(Block b)`

Constructor for ExceptionExpectation.

###### Parameters

|Param|Description|
|---|---|
|`b`|The block of code to test|

---
#### Methods
##### `public void toThrow()`

Asserts that the block of code threw an exception.

##### `public void toThrow(String message)`

Asserts that the block threw an exception with a message containing the specified string.

###### Parameters

|Param|Description|
|---|---|
|`message`|The substring to look for in the exception message|

##### `public void toThrow(Type exceptionType)`

Asserts that the block threw an exception of the specific Type.

###### Parameters

|Param|Description|
|---|---|
|`exceptionType`|The expected exception type|

---

### HttpMock

Mock implementation for the HttpCalloutMock interface.


**Implemented types**

[HttpCalloutMock](HttpCalloutMock)

#### Methods
##### `public void mockResponse(String url, HttpResponse res)`

Registers a response for a specific URL.

###### Parameters

|Param|Description|
|---|---|
|`url`|The endpoint URL|
|`res`|The response to return|

##### `public void mockResponse(String method, String url, HttpResponse res)`

Registers a response for a specific HTTP method and URL.

###### Parameters

|Param|Description|
|---|---|
|`method`|HTTP method|
|`url`|Endpoint URL|
|`res`|The response to return|

##### `public void mockResponse(String url, String body, Integer statusCode)`

Registers a response for any method if URL matches.

###### Parameters

|Param|Description|
|---|---|
|`url`|Endpoint URL|
|`body`|Response body|
|`statusCode`|HTTP status|

##### `public void mockResponse(String method, String url, String body, Integer statusCode)`

Registers a response for a specific HTTP method, URL, and body.

###### Parameters

|Param|Description|
|---|---|
|`method`|HTTP method (e.g., 'GET', 'POST')|
|`url`|Endpoint URL|
|`body`|Response body|
|`statusCode`|HTTP status code|

##### `public HttpResponse respond(HttpRequest req)`

Implementation of HttpCalloutMock.respond.

###### Parameters

|Param|Description|
|---|---|
|`req`|The HTTP request|

###### Returns

|Type|Description|
|---|---|
|`HttpResponse`|Mocked HTTP response|

##### `public List<HttpRequest> getRequests()`

Returns all recorded HTTP requests made to this mock.

###### Returns

|Type|Description|
|---|---|
|`List<HttpRequest>`|List of HttpRequests|

##### `public void clear()`

Clears requests.

##### `public void reset()`

Resets mock.

---

### HttpMockExpectation

Fluent API for verifying interactions with HttpMock.

#### Constructors
##### `public HttpMockExpectation(HttpMock targetMock)`

Constructor for HttpMockExpectation.

###### Parameters

|Param|Description|
|---|---|
|`targetMock`|The mock to verify|

---
#### Properties

##### `public notx` → `HttpMockExpectation`


Negates the expectation.

---
#### Methods
##### `public void toHaveBeenCalled()`

Asserts that at least one HTTP call was made.

##### `public void toHaveBeenCalledTimes(Integer times)`

Asserts that exactly n HTTP calls were made.

###### Parameters

|Param|Description|
|---|---|
|`times`|Expected number of calls|

##### `public void toHaveBeenCalledWith(Object url, Object method)`

Asserts that an HTTP call was made with specific URL and method.

###### Parameters

|Param|Description|
|---|---|
|`url`|Expected URL or matcher|
|`method`|Expected HTTP method or matcher|

##### `public void toHaveBeenCalledWith(Object url, Object method, Object body)`

Asserts that an HTTP call was made with specific URL, method and body.

###### Parameters

|Param|Description|
|---|---|
|`url`|Expected URL or matcher|
|`method`|Expected HTTP method or matcher|
|`body`|Expected body or matcher|

##### `public void toHaveBeenCalledWith(Object url, Object method, Object body, Map<String,Object> headers)`

Full verification of an HTTP callout.

###### Parameters

|Param|Description|
|---|---|
|`url`|Expected URL or matcher|
|`method`|Expected HTTP method or matcher|
|`body`|Expected body or matcher|
|`headers`|Expected headers map|

---

### IdMatcher

Matcher for Id values.


**Implemented types**

[Matcher](Matcher)

#### Methods
##### `public Boolean matches(Object actual)`

Checks if the value is an Id.

###### Parameters

|Param|Description|
|---|---|
|`actual`|Value|

###### Returns

|Type|Description|
|---|---|
|`Boolean`|True if Id|

---

### IntegerMatcher

Matcher for Integer values.


**Implemented types**

[Matcher](Matcher)

#### Methods
##### `public Boolean matches(Object actual)`

Checks if the value is an Integer.

###### Parameters

|Param|Description|
|---|---|
|`actual`|Value|

###### Returns

|Type|Description|
|---|---|
|`Boolean`|True if Integer|

---

### IterableContainingMatcher

Matcher for collection items.


**Implemented types**

[Matcher](Matcher)

#### Constructors
##### `public IterableContainingMatcher(Object expectedItem)`

Constructor for IterableContainingMatcher.

###### Parameters

|Param|Description|
|---|---|
|`expectedItem`|Item or matcher|

---
#### Methods
##### `public Boolean matches(Object actual)`

Checks if collection contains item.

###### Parameters

|Param|Description|
|---|---|
|`actual`|Collection|

###### Returns

|Type|Description|
|---|---|
|`Boolean`|True if item found|

---

### ListMatcher

Matcher for List values.


**Implemented types**

[Matcher](Matcher)

#### Methods
##### `public Boolean matches(Object actual)`

Checks if the value is a List.

###### Parameters

|Param|Description|
|---|---|
|`actual`|Value|

###### Returns

|Type|Description|
|---|---|
|`Boolean`|True if List|

---

### MapMatcher

Matcher for Map values.


**Implemented types**

[Matcher](Matcher)

#### Methods
##### `public Boolean matches(Object actual)`

Checks if the value is a Map.

###### Parameters

|Param|Description|
|---|---|
|`actual`|Value|

###### Returns

|Type|Description|
|---|---|
|`Boolean`|True if Map|

---

### MethodCall

Represents a recorded method call.

#### Constructors
##### `public MethodCall(String methodName, List<Object> args)`

Constructor for MethodCall.

###### Parameters

|Param|Description|
|---|---|
|`methodName`|Name of the method|
|`args`|List of arguments|

---
#### Properties

##### `public args` → `List<Object>`


List of arguments.

##### `public methodName` → `String`


Name of the method.

---

### MethodSpy

Fluent builder for configuring method return values and behaviors.

#### Fields

##### `public methodName` → `String`


##### `public provider` → `MockProvider`


---
#### Properties

##### `public calls` → `List<List<Object>>`


Returns the list of arguments for each call to this spy.

---
#### Methods
##### `public MethodSpy mockReturnValue(Object value)`

Configures the method to always return the specified value.

###### Parameters

|Param|Description|
|---|---|
|`value`|The value to return|

###### Returns

|Type|Description|
|---|---|
|`MethodSpy`|This spy instance for chaining|

##### `public MethodSpy mockReturnValueOnce(Object value)`

Configures the method to return the specified value once. Useful for testing sequential calls with different outcomes.

###### Parameters

|Param|Description|
|---|---|
|`value`|The value to return once|

###### Returns

|Type|Description|
|---|---|
|`MethodSpy`|This spy instance for chaining|

##### `public MethodSpy mockThrow(Exception error)`

Configures the method to throw an exception when called.

###### Parameters

|Param|Description|
|---|---|
|`error`|The exception to throw|

###### Returns

|Type|Description|
|---|---|
|`MethodSpy`|This spy instance for chaining|

##### `public MethodSpy mockImplementation(Callback callback)`

Configures a dynamic implementation for the method.

###### Parameters

|Param|Description|
|---|---|
|`callback`|The dynamic implementation|

###### Returns

|Type|Description|
|---|---|
|`MethodSpy`|This spy instance for chaining|

###### Example
```apex
spy.mockImplementation(new MyCallback());
```


---

### MockException

Exception thrown by the Mock library for assertion failures.


**Inheritance**

MockException


### MockExpectation

Fluent API for verifying mock interactions or asserting values.

#### Properties

##### `public notx` → `MockExpectation`


Negates the expectation.

---
#### Methods
##### `public void toBe(Object expected)`

Asserts strict reference equality (===).

###### Parameters

|Param|Description|
|---|---|
|`expected`|The expected object reference|

##### `public void toEqual(Object expected)`

Asserts value equality (==).

###### Parameters

|Param|Description|
|---|---|
|`expected`|The expected value|

##### `public void toEq(Object expected)`

Alias for toEqual().

###### Parameters

|Param|Description|
|---|---|
|`expected`|The expected value|

##### `public void toMatch(String regex)`

Asserts that a value matches the specified regex pattern.

###### Parameters

|Param|Description|
|---|---|
|`regex`|The regular expression|

##### `public void toMatch(Matcher matcher)`

Asserts that a value matches the specified Matcher.

###### Parameters

|Param|Description|
|---|---|
|`matcher`|The matcher to use|

##### `public void toContain(Object item)`

Asserts that a string or collection contains the specified item.

###### Parameters

|Param|Description|
|---|---|
|`item`|The item or substring to look for|

##### `public void toBeNull()`

Asserts that the value is null.

##### `public void toBeTrue()`

Asserts that the value is true.

##### `public void toBeFalse()`

Asserts that the value is false.

##### `public void toBeLessThan(Decimal value)`

Asserts that the value is less than the specified number.

###### Parameters

|Param|Description|
|---|---|
|`value`|The maximum value (exclusive)|

##### `public void toBeLt(Decimal value)`

Alias for toBeLessThan().

###### Parameters

|Param|Description|
|---|---|
|`value`|The maximum value (exclusive)|

##### `public void toBeLessThanOrEqual(Decimal value)`

Asserts that the value is less than or equal to the specified number.

###### Parameters

|Param|Description|
|---|---|
|`value`|The maximum value (inclusive)|

##### `public void toBeLe(Decimal value)`

Alias for toBeLessThanOrEqual().

###### Parameters

|Param|Description|
|---|---|
|`value`|The maximum value (inclusive)|

##### `public void toBeGreaterThan(Decimal value)`

Asserts that the value is greater than the specified number.

###### Parameters

|Param|Description|
|---|---|
|`value`|The minimum value (exclusive)|

##### `public void toBeGt(Decimal value)`

Alias for toBeGreaterThan().

###### Parameters

|Param|Description|
|---|---|
|`value`|The minimum value (exclusive)|

##### `public void toBeGreaterThanOrEqual(Decimal value)`

Asserts that the value is greater than or equal to the specified number.

###### Parameters

|Param|Description|
|---|---|
|`value`|The minimum value (inclusive)|

##### `public void toBeGe(Decimal value)`

Alias for toBeGreaterThanOrEqual().

###### Parameters

|Param|Description|
|---|---|
|`value`|The minimum value (inclusive)|

##### `public MockExpectation toHaveBeenCalled()`

Verifies the bound method (from expect(spy)) was called at least once.

###### Returns

|Type|Description|
|---|---|
|`MockExpectation`|This expectation instance for chaining|

##### `public MockExpectation toHaveBeenCalled(String methodName)`

Verifies the method was called at least once.

###### Parameters

|Param|Description|
|---|---|
|`methodName`|The name of the method to verify|

###### Returns

|Type|Description|
|---|---|
|`MockExpectation`|This expectation instance for chaining|

##### `public MockExpectation toHaveBeenCalledTimes(Integer times)`

Verifies the bound method was called exactly n times.

###### Parameters

|Param|Description|
|---|---|
|`times`|Expected number of calls|

###### Returns

|Type|Description|
|---|---|
|`MockExpectation`|This expectation instance for chaining|

##### `public MockExpectation toHaveBeenCalledTimes(String methodName, Integer times)`

Verifies the method was called exactly n times.

###### Parameters

|Param|Description|
|---|---|
|`methodName`|Name of the method|
|`times`|Expected number of calls|

###### Returns

|Type|Description|
|---|---|
|`MockExpectation`|This expectation instance for chaining|

##### `public MockExpectation toHaveBeenCalledWith(List<Object> expectedArgs)`

Verifies the bound method was called with specific arguments.

###### Parameters

|Param|Description|
|---|---|
|`expectedArgs`|List of expected arguments|

###### Returns

|Type|Description|
|---|---|
|`MockExpectation`|This expectation instance for chaining|

###### Example
```apex
Mock.expect(spy).toHaveBeenCalledWith(new List<Object>{ 'test', 100 });
```


##### `public MockExpectation toHaveBeenCalledWith(String methodName, List<Object> expectedArgs)`

Verifies the method was called with specific arguments.

###### Parameters

|Param|Description|
|---|---|
|`methodName`|Name of the method|
|`expectedArgs`|List of expected arguments|

###### Returns

|Type|Description|
|---|---|
|`MockExpectation`|This expectation instance for chaining|

##### `public MockExpectation lastCalledWith(List<Object> expectedArgs)`

Verifies that the absolute last call to this method matched the specified arguments.

###### Parameters

|Param|Description|
|---|---|
|`expectedArgs`|List of expected arguments|

###### Returns

|Type|Description|
|---|---|
|`MockExpectation`|This expectation instance for chaining|

##### `public MockExpectation nthCalledWith(Integer n, List<Object> expectedArgs)`

Verifies that the N-th call (1-based index) to this method matched the specified arguments.

###### Parameters

|Param|Description|
|---|---|
|`n`|Call index (1-based)|
|`expectedArgs`|List of expected arguments|

###### Returns

|Type|Description|
|---|---|
|`MockExpectation`|This expectation instance for chaining|

---

### MockProvider

Internal implementation of System.StubProvider.


**Implemented types**

[System.StubProvider](System.StubProvider)

#### Constructors
##### `public MockProvider(String mockName)`

Constructor for MockProvider with a name.

###### Parameters

|Param|Description|
|---|---|
|`mockName`|The name of the mock|

---
#### Fields

##### `public mockName` → `String`


---
#### Methods
##### `public void setReturnValue(String methodName, Object returnValue)`

Sets a persistent return value for a method.

###### Parameters

|Param|Description|
|---|---|
|`methodName`|Name of the method|
|`returnValue`|The value to return|

##### `public void addReturnValueOnce(String methodName, Object returnValue)`

Adds a one-time return value for a method.

###### Parameters

|Param|Description|
|---|---|
|`methodName`|Name of the method|
|`returnValue`|The value to return once|

##### `public void setException(String methodName, Exception error)`

Sets an exception to be thrown by a method.

###### Parameters

|Param|Description|
|---|---|
|`methodName`|Name of the method|
|`error`|The exception to throw|

##### `public void setCallback(String methodName, Callback callback)`

Sets a callback for a method.

###### Parameters

|Param|Description|
|---|---|
|`methodName`|Name of the method|
|`callback`|The callback implementation|

##### `public void clear()`

Clears call history.

##### `public void reset()`

Resets history and behavior.

##### `public List<MethodCall> getCalls(String methodName)`

Returns calls for a method.

###### Parameters

|Param|Description|
|---|---|
|`methodName`|Name of the method|

###### Returns

|Type|Description|
|---|---|
|`List<MethodCall>`|List of MethodCalls|

##### `public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType, List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs)`

Handle method call from Test.createStub.

###### Parameters

|Param|Description|
|---|---|
|`stubbedObject`|The stub object|
|`stubbedMethodName`|The method name|
|`returnType`|Expected return type|
|`listOfParamTypes`|Parameter types|
|`listOfParamNames`|Parameter names|
|`listOfArgs`|Arguments|

###### Returns

|Type|Description|
|---|---|
|`Object`|Mocked result or null|

---

### NotMatcher

Negating matcher.


**Implemented types**

[Matcher](Matcher)

#### Constructors
##### `public NotMatcher(Matcher matcher)`

Constructor for NotMatcher.

###### Parameters

|Param|Description|
|---|---|
|`matcher`|Matcher to negate|

---
#### Methods
##### `public Boolean matches(Object actual)`

Inverse matcher check.

###### Parameters

|Param|Description|
|---|---|
|`actual`|Value|

###### Returns

|Type|Description|
|---|---|
|`Boolean`|Inverse match result|

---

### ObjectContainingMatcher

Matcher that checks if an object, map, or SObject contains specific fields.


**Implemented types**

[Matcher](Matcher)

#### Constructors
##### `public ObjectContainingMatcher(Map<String,Object> expected)`

Constructor for ObjectContainingMatcher.

###### Parameters

|Param|Description|
|---|---|
|`expected`|Map of field names to values or matchers|

---
#### Methods
##### `public Boolean matches(Object actual)`

Checks if the object contains the expected fields.

###### Parameters

|Param|Description|
|---|---|
|`actual`|The object, Map, or SObject to check|

###### Returns

|Type|Description|
|---|---|
|`Boolean`|True if all expected fields match|

---

### SObjectMatcher

Matcher for SObjects.


**Implemented types**

[Matcher](Matcher)

#### Constructors
##### `public SObjectMatcher()`

Default constructor.

##### `public SObjectMatcher(Schema sObjectType)`

Constructor for SObjectMatcher.

###### Parameters

|Param|Description|
|---|---|
|`sObjectType`|Expected type|

---
#### Methods
##### `public Boolean matches(Object actual)`

Checks if the SObject matches the expected type.

###### Parameters

|Param|Description|
|---|---|
|`actual`|The SObject to check|

###### Returns

|Type|Description|
|---|---|
|`Boolean`|True if the SObjectType matches|

---

### StringContainingMatcher

Matcher for substrings.


**Implemented types**

[Matcher](Matcher)

#### Constructors
##### `public StringContainingMatcher(String expected)`

Constructor for StringContainingMatcher.

###### Parameters

|Param|Description|
|---|---|
|`expected`|Substring|

---
#### Methods
##### `public Boolean matches(Object actual)`

Checks if string contains substring.

###### Parameters

|Param|Description|
|---|---|
|`actual`|Value|

###### Returns

|Type|Description|
|---|---|
|`Boolean`|True if contains|

---

### StringMatcher

Matcher for String values.


**Implemented types**

[Matcher](Matcher)

#### Methods
##### `public Boolean matches(Object actual)`

Checks if the value is a String.

###### Parameters

|Param|Description|
|---|---|
|`actual`|Value|

###### Returns

|Type|Description|
|---|---|
|`Boolean`|True if String|

---

### TimeMatcher

Matcher for Time values.


**Implemented types**

[Matcher](Matcher)

#### Methods
##### `public Boolean matches(Object actual)`

Checks if the value is a Time.

###### Parameters

|Param|Description|
|---|---|
|`actual`|Value|

###### Returns

|Type|Description|
|---|---|
|`Boolean`|True if Time|

---

### TypeMatcher

Matcher for specific Types.


**Implemented types**

[Matcher](Matcher)

#### Constructors
##### `public TypeMatcher(Type expectedType)`

Constructor for TypeMatcher.

###### Parameters

|Param|Description|
|---|---|
|`expectedType`|Expected type|

---
#### Methods
##### `public Boolean matches(Object actual)`

Checks if the object is an instance of the expected type.

###### Parameters

|Param|Description|
|---|---|
|`actual`|The object to check|

###### Returns

|Type|Description|
|---|---|
|`Boolean`|True if the object matches the type|

---

---
## Interfaces
### Block

Represents a block of code for exception testing.

#### Methods
##### `public void run()`

Runs the code block.

---

### Callback

Callback interface for dynamic mock implementations.

#### Methods
##### `public Object call(List<Object> args)`

Executes the callback logic.

###### Parameters

|Param|Description|
|---|---|
|`args`|The arguments passed to the mocked method|

###### Returns

|Type|Description|
|---|---|
|`Object`|The value to return from the mocked method|

---

### Matcher

Base interface for custom argument matchers.

#### Methods
##### `public Boolean matches(Object actual)`

Determines if the actual value matches the criteria.

###### Parameters

|Param|Description|
|---|---|
|`actual`|The value to check|

###### Returns

|Type|Description|
|---|---|
|`Boolean`|True if the value matches|

---
