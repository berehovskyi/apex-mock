/**
 * Jest-inspired mocking utility for Apex unit tests.
 * Provides a fluent API for creating, configuring, and verifying mock objects.
 *
 * @example
 * IService mock = (IService) Mock.of(IService.class);
 * Mock.spyOn(mock, 'doWork').mockReturnValue('Success');
 * Mock.expect(mock).toHaveBeenCalled('doWork');
 */
public class Mock {
    private static final Map<Object, MockProvider> PROVIDERS = new Map<Object, MockProvider>();
    private static Integer fakeIdCount = 0;

    /**
     * Creates a named mock instance for better identification in error messages.
     * @param type The interface or class type to mock
     * @param mockName Name used in assertion failure messages
     * @return A mock instance
     * @example
     * IService mock = (IService) Mock.of(IService.class, 'service');
     */
    public static Object of(Type type, String mockName) {
        MockProvider provider = new MockProvider(mockName);
        Object stub = Test.createStub(type, provider);
        PROVIDERS.put(stub, provider);
        return stub;
    }

    /**
     * Creates a mock instance of the specified type.
     * @param type The interface or class type to mock
     * @return A mock instance
     * @example
     * IService mock = (IService) Mock.of(IService.class);
     */
    public static Object of(Type type) {
        return of(type, null);
    }

    /**
     * Gets the name of the mock object.
     * @param stub The mock object
     * @return The mock name or null
     * @example
     * String mockName = Mock.getMockName(mock);
     */
    public static String getMockName(Object stub) {
        return PROVIDERS.get(stub)?.mockName;
    }

    /**
     * Creates a spy on a specific method of a mock object.
     * @param stub The mock object created by Mock.of()
     * @param methodName The name of the method to spy on
     * @return A MethodSpy for stubbing or call history access
     * @example
     * Mock.MethodSpy doWorkSpy = Mock.spyOn(mock, 'doWork');
     */
    public static MethodSpy spyOn(Object stub, String methodName) {
        return spyOn(stub, methodName, null);
    }

    /**
     * Creates a spy on a specific method overload of a mock object.
     * @param stub The mock object created by Mock.of()
     * @param methodName The name of the method to spy on
     * @param parameterTypes The parameter types that identify the overload
     * @return A MethodSpy for stubbing or call history access
     * @example
     * Mock.MethodSpy doWorkStringSpy = Mock.spyOn(mock, 'doWork', new List<Type>{ String.class });
     */
    public static MethodSpy spyOn(Object stub, String methodName, List<Type> parameterTypes) {
        failUnless(PROVIDERS.containsKey(stub), 'Object is not a valid Mock instance.');
        return new MethodSpy(PROVIDERS.get(stub), methodName, parameterTypes);
    }

    /**
     * Creates an expectation for verifying mock interactions or asserting values.
     * @param stub The mock object or value to assert
     * @return A MockExpectation for fluent verification
     * @example
     * Mock.MockExpectation expectation = Mock.expect(mock);
     */
    public static MockExpectation expect(Object stub) {
        if (PROVIDERS.containsKey(stub)) {
            return new MockExpectation(PROVIDERS.get(stub));
        }
        return new MockExpectation(stub, false);
    }

    /**
     * Clears the interaction history of the specific mock object.
     * @param stub The mock object
     * @example
     * Mock.clear(mock);
     */
    public static void clear(Object stub) {
        MockProvider provider = PROVIDERS.get(stub);
        if (provider != null) {
            provider.clear();
        }
    }

    /**
     * Clears the interaction history of ALL registered mock objects.
     */
    public static void clearAll() {
        for (MockProvider provider : PROVIDERS.values()) {
            provider.clear();
        }
    }

    /**
     * Resets the mock object completely.
     * @param stub The mock object
     * @example
     * Mock.reset(mock);
     */
    public static void reset(Object stub) {
        MockProvider provider = PROVIDERS.get(stub);
        if (provider != null) {
            provider.reset();
        }
    }

    /**
     * Resets ALL registered mock objects.
     */
    public static void resetAll() {
        for (MockProvider provider : PROVIDERS.values()) {
            provider.reset();
        }
    }

    /**
     * Creates an expectation for a specific method spy.
     * @param spy The method spy to expect
     * @return A MockExpectation for verification
     * @example
     * Mock.MockExpectation expectation = Mock.expect(Mock.spyOn(mock, 'doWork'));
     */
    public static MockExpectation expect(MethodSpy spy) {
        return new MockExpectation(spy.provider, spy.methodName, spy.methodKey, spy.hasSignature);
    }

    /**
     * Creates and registers an HTTP mock for callout testing.
     * @return The HttpMock instance
     * @example
     * Mock.HttpMock http = Mock.mockHttp();
     * http.mockResponse('https://api.com', '{"ok":true}', 200);
     */
    public static HttpMock mockHttp() {
        HttpMock mock = new HttpMock();
        Test.setMock(HttpCalloutMock.class, mock);
        return mock;
    }

    /**
     * Creates an expectation for verifying HTTP mocks.
     * @param mock The HTTP mock to verify
     * @return An HttpMockExpectation
     * @example
     * Mock.HttpMockExpectation httpExpectation = Mock.expect(httpMock);
     */
    public static HttpMockExpectation expect(HttpMock mock) {
        return new HttpMockExpectation(mock);
    }

    /**
     * Creates an expectation for verifying code block exceptions.
     * @param b The block of code
     * @return An ExceptionExpectation
     * @example
     * Mock.ExceptionExpectation exceptionExpectation = Mock.expect(block);
     */
    public static ExceptionExpectation expect(Block b) {
        return new ExceptionExpectation(b);
    }

    /**
     * Matches any value.
     * @return A Matcher instance
     */
    public static Matcher any() {
        return new AnyMatcher();
    }

    /**
     * Matches any String value.
     * @return A Matcher instance
     */
    public static Matcher anyString() {
        return new StringMatcher();
    }

    /**
     * Matches any Integer value.
     * @return A Matcher instance
     */
    public static Matcher anyInteger() {
        return new IntegerMatcher();
    }

    /**
     * Matches any Decimal value.
     * @return A Matcher instance
     */
    public static Matcher anyDecimal() {
        return new DecimalMatcher();
    }

    /**
     * Matches any Id value.
     * @return A Matcher instance
     */
    public static Matcher anyId() {
        return new IdMatcher();
    }

    /**
     * Matches any Boolean value.
     * @return A Matcher instance
     */
    public static Matcher anyBoolean() {
        return new BooleanMatcher();
    }

    /**
     * Matches any List value.
     * @return A Matcher instance
     */
    public static Matcher anyList() {
        return new ListMatcher();
    }

    /**
     * Matches any Map value.
     * @return A Matcher instance
     */
    public static Matcher anyMap() {
        return new MapMatcher();
    }

    /**
     * Matches any Date value.
     * @return A Matcher instance
     */
    public static Matcher anyDate() {
        return new DateMatcher();
    }

    /**
     * Matches any Datetime value.
     * @return A Matcher instance
     */
    public static Matcher anyDatetime() {
        return new DatetimeMatcher();
    }

    /**
     * Matches any Time value.
     * @return A Matcher instance
     */
    public static Matcher anyTime() {
        return new TimeMatcher();
    }

    /**
     * Matches any value of a specific type.
     * @param type The type to match
     * @return A Matcher instance
     */
    public static Matcher any(Type type) {
        return new TypeMatcher(type);
    }

    /**
     * Matches any SObject.
     * @return A Matcher instance
     */
    public static Matcher anySObject() {
        return new SObjectMatcher();
    }

    /**
     * Matches any SObject of a specific type.
     * @param sObjectType The SObject type to match
     * @return A Matcher instance
     */
    public static Matcher anySObject(Schema.SObjectType sObjectType) {
        return new SObjectMatcher(sObjectType);
    }

    /**
     * Negates the specified matcher.
     * @param matcher The matcher to negate
     * @return A negated Matcher
     * @example
     * Mock.Matcher notString = Mock.notx(Mock.anyString());
     */
    public static Matcher notx(Matcher matcher) {
        return new NotMatcher(matcher);
    }

    /**
     * Creates a matcher that checks if an object contains specific fields.
     * @param expected Map of field names to values or matchers
     * @return A Matcher instance
     * @example
     * Mock.Matcher hasName = Mock.objectContaining(new Map<String, Object>{ 'Name' => 'Acme' });
     */
    public static Matcher objectContaining(Map<String, Object> expected) {
        return new ObjectContainingMatcher(expected);
    }

    /**
     * Matches SObjects containing specified populated fields.
     * @param expected The template SObject
     * @return A Matcher instance
     * @example
     * Mock.Matcher accountLike = Mock.sObjectContaining(new Account(Name = 'Acme'));
     */
    public static Matcher sObjectContaining(SObject expected) {
        return new ObjectContainingMatcher(expected.getPopulatedFieldsAsMap());
    }

    /**
     * Matches SObjects containing specific field/value pairs.
     * @param expected Map of field/value pairs
     * @return A Matcher instance
     * @example
     * Mock.Matcher hasField = Mock.sObjectContaining(new Map<SObjectField, Object>{ Account.Name => 'Acme' });
     */
    public static Matcher sObjectContaining(Map<SObjectField, Object> expected) {
        Map<String, Object> stringMap = new Map<String, Object>();
        for (SObjectField field : expected.keySet()) {
            stringMap.put(String.valueOf(field), expected.get(field));
        }
        return new ObjectContainingMatcher(stringMap);
    }

    /**
     * Matches strings containing a specific substring.
     * @param expected The substring to find
     * @return A Matcher instance
     * @example
     * Mock.Matcher hasText = Mock.stringContaining('value');
     */
    public static Matcher stringContaining(String expected) {
        return new StringContainingMatcher(expected);
    }

    /**
     * Matches collections containing a specific item.
     * @param expected The item or matcher to find
     * @return A Matcher instance
     * @example
     * Mock.Matcher hasItem = Mock.iterableContaining('value');
     */
    public static Matcher iterableContaining(Object expected) {
        return new IterableContainingMatcher(expected);
    }

    /**
     * Generates a valid 18-character fake ID for the specified SObject type.
     * @param sObjectType The SObject type
     * @return A unique fake ID
     * @example
     * Id accountId = Mock.fakeId(Account.SObjectType);
     */
    public static Id fakeId(Schema.SObjectType sObjectType) {
        String keyPrefix = sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix();
        fakeIdCount++;
        return Id.valueOf(keyPrefix + '0'.repeat(12 - String.valueOf(fakeIdCount).length()) + fakeIdCount);
    }

    /**
     * Generates a list of valid 18-character fake IDs for the specified SObject type.
     * @param sObjectType The SObject type
     * @param count Number of IDs to generate
     * @return List of fake IDs
     * @example
     * List<Id> accountIds = Mock.fakeIds(Account.SObjectType, 2);
     */
    public static List<Id> fakeIds(Schema.SObjectType sObjectType, Integer count) {
        List<Id> ids = new List<Id>();
        for (Integer i = 0; i < count; i++) {
            ids.add(fakeId(sObjectType));
        }
        return ids;
    }

    private static Boolean valuesMatch(Object act, Object exp) {
        if (exp instanceof Matcher) {
            return ((Matcher) exp).matches(act);
        }
        return exp == act || exp?.equals(act) == true;
    }

    private static Boolean argsMatchValues(List<Object> actual, List<Object> expected) {
        if (actual == null || expected == null) {
            return actual == expected;
        }
        if (actual.size() != expected.size()) {
            return false;
        }
        for (Integer i = 0; i < expected.size(); i++) {
            if (!valuesMatch(actual[i], expected[i])) {
                return false;
            }
        }
        return true;
    }

    private static void failIf(Boolean condition, String message) {
        if (condition) {
            throw new MockException(message);
        }
    }

    private static void failUnless(Boolean condition, String message) {
        failIf(!condition, message);
    }

    private static Type getType(Object o) {
        return Type.forName(getTypeName(o));
    }

    private static String getTypeName(Object o) {
        Time probe;
        try {
            probe = (Time) o;
            return 'Time';
        } catch (TypeException e) {
            return e.getMessage().substringBetween('Invalid conversion from runtime type ', ' to Time');
        }
    }

    private static String buildMethodKey(String methodName, List<Type> parameterTypes) {
        if (parameterTypes == null) {
            return methodName;
        }
        List<String> typeNames = new List<String>();
        for (Type paramType : parameterTypes) {
            typeNames.add(paramType?.getName() ?? 'null');
        }
        return methodName + '(' + String.join(typeNames, ',') + ')';
    }

    /**
     * Fluent builder for configuring method return values and behaviors.
     */
    public class MethodSpy {
        public final MockProvider provider;
        public final String methodName;
        public final String methodKey;
        public final Boolean hasSignature;

        private MethodSpy(MockProvider provider, String methodName, List<Type> parameterTypes) {
            this.provider = provider;
            this.methodName = methodName;
            this.hasSignature = parameterTypes != null;
            this.methodKey = hasSignature ? buildMethodKey(methodName, parameterTypes) : methodName;
        }

        /**
         * Returns the list of arguments for each call to this spy.
         */
        public List<List<Object>> calls {
            get {
                List<List<Object>> history = new List<List<Object>>();
                List<MethodCall> methodCalls = hasSignature
                    ? provider.getCallsByKey(methodKey)
                    : provider.getCalls(methodName);
                for (MethodCall call : methodCalls) {
                    history.add(call.args);
                }
                return history;
            }
        }

        /**
         * Configures the method to always return the specified value.
         * @param value The value to return
         * @return This spy instance for chaining
         * @example
         * spy.mockReturnValue('value');
         */
        public MethodSpy mockReturnValue(Object value) {
            provider.setReturnValue(methodKey, value);
            return this;
        }

        /**
         * Configures the method to return the specified value once.
         * Useful for testing sequential calls with different outcomes.
         * @param value The value to return once
         * @return This spy instance for chaining
         * @example
         * spy.mockReturnValueOnce('value');
         */
        public MethodSpy mockReturnValueOnce(Object value) {
            provider.addReturnValueOnce(methodKey, value);
            return this;
        }

        /**
         * Configures the method to throw an exception when called.
         * @param error The exception to throw
         * @return This spy instance for chaining
         * @example
         * spy.mockThrow(new Mock.MockException('boom'));
         */
        public MethodSpy mockThrow(Exception error) {
            provider.setException(methodKey, error);
            return this;
        }

        /**
         * Configures a dynamic implementation for the method.
         * @param callback The dynamic implementation
         * @return This spy instance for chaining
         * @example
         * spy.mockImplementation(new MyCallback());
         */
        public MethodSpy mockImplementation(Callback callback) {
            provider.setCallback(methodKey, callback);
            return this;
        }

        /**
         * Creates argument-scoped stubbing for this method.
         * Matchers are supported in the expected arguments list.
         * @param expectedArgs Expected argument list
         * @return Scoped stubbing builder
         * @example
         * Mock.spyOn(mock, 'add')
         *     .whenCalledWith(new List<Object>{ 1, 2 })
         *     .mockReturnValue(3);
         */
        public WhenCalledWithStub whenCalledWith(List<Object> expectedArgs) {
            return new WhenCalledWithStub(provider.addConditionalBehavior(methodKey, expectedArgs));
        }
    }

    /**
     * Fluent builder for configuring behavior for specific argument patterns.
     */
    public class WhenCalledWithStub {
        private final ConditionalBehavior behavior;

        private WhenCalledWithStub(ConditionalBehavior behavior) {
            this.behavior = behavior;
        }

        /**
         * Configures a persistent return value for this argument pattern.
         * @param value Value to return
         * @return This scoped builder
         * @example
         * stub.mockReturnValue('value');
         */
        public WhenCalledWithStub mockReturnValue(Object value) {
            return setDefaultAction(value, null, null);
        }

        /**
         * Configures a one-time return value for this argument pattern.
         * @param value Value to return once
         * @return This scoped builder
         * @example
         * stub.mockReturnValueOnce('value');
         */
        public WhenCalledWithStub mockReturnValueOnce(Object value) {
            return addOnceAction(value, null, null);
        }

        /**
         * Configures a persistent exception for this argument pattern.
         * @param error Exception to throw
         * @return This scoped builder
         * @example
         * stub.mockThrow(new Mock.MockException('boom'));
         */
        public WhenCalledWithStub mockThrow(Exception error) {
            return setDefaultAction(null, error, null);
        }

        /**
         * Configures a one-time exception for this argument pattern.
         * @param error Exception to throw once
         * @return This scoped builder
         * @example
         * stub.mockThrowOnce(new Mock.MockException('boom'));
         */
        public WhenCalledWithStub mockThrowOnce(Exception error) {
            return addOnceAction(null, error, null);
        }

        /**
         * Configures a persistent callback for this argument pattern.
         * @param callback Callback implementation
         * @return This scoped builder
         * @example
         * stub.mockImplementation(callback);
         */
        public WhenCalledWithStub mockImplementation(Callback callback) {
            return setDefaultAction(null, null, callback);
        }

        /**
         * Configures a one-time callback for this argument pattern.
         * @param callback Callback implementation used once
         * @return This scoped builder
         * @example
         * stub.mockImplementationOnce(callback);
         */
        public WhenCalledWithStub mockImplementationOnce(Callback callback) {
            return addOnceAction(null, null, callback);
        }

        private WhenCalledWithStub setDefaultAction(Object returnValue, Exception error, Callback callback) {
            behavior.setDefaultAction(new ConditionalAction(returnValue, error, callback));
            return this;
        }

        private WhenCalledWithStub addOnceAction(Object returnValue, Exception error, Callback callback) {
            behavior.addOnceAction(new ConditionalAction(returnValue, error, callback));
            return this;
        }
    }

    /**
     * Fluent API for verifying mock interactions or asserting values.
     */
    public class MockExpectation {
        private final MockProvider provider;
        private final String boundMethodName;
        private final String boundMethodKey;
        private final Boolean boundHasSignature;
        private final Boolean isNegated;
        private final Object actualValue;
        private final Boolean isValueAssertion;
        private final String boundMethodRequiredMessage = 'Method name must be provided when not using expect(spy).';

        private MockExpectation(MockProvider provider) {
            this(provider, null, null, false, false);
        }

        private MockExpectation(
            MockProvider provider,
            String boundMethodName,
            String boundMethodKey,
            Boolean boundHasSignature
        ) {
            this(provider, boundMethodName, boundMethodKey, boundHasSignature, false);
        }

        private MockExpectation(
            MockProvider provider,
            String boundMethodName,
            String boundMethodKey,
            Boolean boundHasSignature,
            Boolean isNegated
        ) {
            this.provider = provider;
            this.boundMethodName = boundMethodName;
            this.boundMethodKey = boundMethodKey;
            this.boundHasSignature = boundHasSignature;
            this.isNegated = isNegated;
            this.actualValue = null;
            this.isValueAssertion = false;
        }

        private MockExpectation(Object actualValue, Boolean isNegated) {
            this.provider = null;
            this.boundMethodName = null;
            this.boundMethodKey = null;
            this.boundHasSignature = false;
            this.isNegated = isNegated;
            this.actualValue = actualValue;
            this.isValueAssertion = true;
        }

        /**
         * Negates the expectation.
         * @example
         * expectation.notx.toEqual('value');
         */
        public MockExpectation notx {
            get {
                if (isValueAssertion) {
                    return new MockExpectation(actualValue, !isNegated);
                }
                return new MockExpectation(provider, boundMethodName, boundMethodKey, boundHasSignature, !isNegated);
            }
        }

        private List<MethodCall> getBoundCalls() {
            return boundHasSignature ? provider.getCallsByKey(boundMethodKey) : provider.getCalls(boundMethodName);
        }

        /**
         * Asserts strict reference equality (===).
         * @param expected The expected object reference
         * @example
         * expectation.toBe('value');
         */
        public void toBe(Object expected) {
            validateAssertion();
            failIf(
                !isNegated && actualValue !== expected,
                'Expected reference equality: ' + expected + ', but was: ' + actualValue
            );
            failIf(
                isNegated && actualValue === expected,
                'Expected NOT reference equality: ' + expected + ', but was: ' + actualValue
            );
        }

        /**
         * Asserts value equality (==).
         * @param expected The expected value
         * @example
         * expectation.toEqual('value');
         */
        public void toEqual(Object expected) {
            validateAssertion();
            failIf(
                !isNegated && actualValue != expected,
                'Expected value equality: ' + expected + ', but was: ' + actualValue
            );
            failIf(
                isNegated && actualValue == expected,
                'Expected NOT value equality: ' + expected + ', but was: ' + actualValue
            );
        }

        /**
         * Asserts that a value matches the specified regex pattern.
         * @param regex The regular expression
         * @example
         * expectation.toMatch('^a.*');
         */
        public void toMatch(String regex) {
            validateAssertion();
            String actualStr = String.valueOf(actualValue);
            Pattern p = Pattern.compile(regex);
            System.Matcher m = p.matcher(actualStr);
            Boolean matches = m.find();

            failIf(!isNegated && !matches, 'Expected: "' + actualValue + '" to match pattern: ' + regex);
            failIf(isNegated && matches, 'Expected: "' + actualValue + '" NOT to match pattern: ' + regex);
        }

        /**
         * Asserts that a value matches the specified Matcher.
         * @param matcher The matcher to use
         * @example
         * expectation.toMatch(Mock.any());
         */
        public void toMatch(Matcher matcher) {
            validateAssertion();
            Boolean matches = matcher.matches(actualValue);

            failIf(!isNegated && !matches, 'Expected value to match ' + matcher);
            failIf(isNegated && matches, 'Expected value NOT to match ' + matcher);
        }

        /**
         * Asserts that a string or collection contains the specified item.
         * @param item The item or substring to look for
         * @example
         * expectation.toContain('value');
         */
        public void toContain(Object item) {
            validateAssertion();
            Boolean contains = false;

            if (actualValue instanceof String) {
                if (item instanceof String) {
                    contains = ((String) actualValue).contains((String) item);
                } else if (item instanceof Matcher) {
                    contains = ((Matcher) item).matches(actualValue);
                } else {
                    throw new MockException('toContain() expected a String or Matcher item, but got: ' + item);
                }
            } else if (actualValue instanceof Iterable<Object>) {
                for (Object nextItem : (Iterable<Object>) actualValue) {
                    if (valuesMatch(nextItem, item)) {
                        contains = true;
                        break;
                    }
                }
            } else {
                throw new MockException('toContain() expected an Iterable or String, but got: ' + actualValue);
            }

            failIf(!isNegated && !contains, 'Expected: ' + actualValue + ' to contain: ' + item);
            failIf(isNegated && contains, 'Expected: ' + actualValue + ' NOT to contain: ' + item);
        }

        /**
         * Asserts that the value is null.
         * @example
         * expectation.toBeNull();
         */
        public void toBeNull() {
            validateAssertion();
            failIf(!isNegated && actualValue != null, 'Expected null, but was: ' + actualValue);
            failIf(isNegated && actualValue == null, 'Expected NOT null, but was null');
        }

        /**
         * Asserts that the value is true.
         * @example
         * expectation.toBeTrue();
         */
        public void toBeTrue() {
            validateAssertion();
            failIf(!isNegated && actualValue != true, 'Expected true, but was: ' + actualValue);
            failIf(isNegated && actualValue == true, 'Expected NOT true, but was true');
        }

        /**
         * Asserts that the value is false.
         * @example
         * expectation.toBeFalse();
         */
        public void toBeFalse() {
            validateAssertion();
            failIf(!isNegated && actualValue != false, 'Expected false, but was: ' + actualValue);
            failIf(isNegated && actualValue == false, 'Expected NOT false, but was false');
        }

        /**
         * Asserts that the value is less than the specified number.
         * @param value The maximum value (exclusive)
         * @example
         * expectation.toBeLessThan(1);
         */
        public void toBeLessThan(Decimal value) {
            validateAssertion();
            Decimal actualDec = (Decimal) actualValue;
            failIf(!isNegated && !(actualDec < value), 'Expected ' + actualValue + ' to be less than ' + value);
            failIf(isNegated && actualDec < value, 'Expected ' + actualValue + ' NOT to be less than ' + value);
        }

        /**
         * Asserts that the value is greater than the specified number.
         * @param value The minimum value (exclusive)
         * @example
         * expectation.toBeGreaterThan(1);
         */
        public void toBeGreaterThan(Decimal value) {
            validateAssertion();
            Decimal actualDec = (Decimal) actualValue;
            failIf(!isNegated && !(actualDec > value), 'Expected ' + actualValue + ' to be greater than ' + value);
            failIf(isNegated && actualDec > value, 'Expected ' + actualValue + ' NOT to be greater than ' + value);
        }

        private void validateAssertion() {
            failIf(!isValueAssertion, 'Cannot call value assertion methods on a mock verification object.');
        }

        private void validateMockVerification() {
            failIf(isValueAssertion, 'Cannot call mock verification methods on a value assertion object.');
        }

        /**
         * Verifies the bound method (from expect(spy)) was called at least once.
         * @return This expectation instance for chaining
         * @example
         * expectation.toHaveBeenCalled();
         */
        public MockExpectation toHaveBeenCalled() {
            validateMockVerification();
            MethodScope scope = getBoundScope();
            return verifyCalled(scope.methodName, scope.calls);
        }

        /**
         * Verifies the method was called at least once.
         * @param methodName The name of the method to verify
         * @return This expectation instance for chaining
         * @example
         * expectation.toHaveBeenCalled('doWork');
         */
        public MockExpectation toHaveBeenCalled(String methodName) {
            validateMockVerification();
            return verifyCalled(methodName, provider.getCalls(methodName));
        }

        /**
         * Verifies the bound method was called exactly n times.
         * @param times Expected number of calls
         * @return This expectation instance for chaining
         * @example
         * expectation.toHaveBeenCalledTimes(1);
         */
        public MockExpectation toHaveBeenCalledTimes(Integer times) {
            validateMockVerification();
            MethodScope scope = getBoundScope();
            return verifyCalledTimes(scope.methodName, scope.calls, times);
        }

        /**
         * Verifies the method was called exactly n times.
         * @param methodName Name of the method
         * @param times Expected number of calls
         * @return This expectation instance for chaining
         * @example
         * expectation.toHaveBeenCalledTimes('doWork', 1);
         */
        public MockExpectation toHaveBeenCalledTimes(String methodName, Integer times) {
            validateMockVerification();
            return verifyCalledTimes(methodName, provider.getCalls(methodName), times);
        }

        /**
         * Verifies the bound method was called with specific arguments.
         * @param expectedArgs List of expected arguments
         * @return This expectation instance for chaining
         * @example
         * Mock.expect(spy).toHaveBeenCalledWith(new List<Object>{ 'test', 100 });
         */
        public MockExpectation toHaveBeenCalledWith(List<Object> expectedArgs) {
            validateMockVerification();
            MethodScope scope = getBoundScope();
            return verifyCalledWith(scope.methodName, scope.calls, expectedArgs);
        }

        /**
         * Verifies the method was called with specific arguments.
         * @param methodName Name of the method
         * @param expectedArgs List of expected arguments
         * @return This expectation instance for chaining
         * @example
         * expectation.toHaveBeenCalledWith('doWork', new List<Object>{ 'value' });
         */
        public MockExpectation toHaveBeenCalledWith(String methodName, List<Object> expectedArgs) {
            validateMockVerification();
            return verifyCalledWith(methodName, provider.getCalls(methodName), expectedArgs);
        }

        /**
         * Verifies that the absolute last call to this method matched the specified arguments.
         * @param expectedArgs List of expected arguments
         * @return This expectation instance for chaining
         * @example
         * expectation.lastCalledWith(new List<Object>{ 'value' });
         */
        public MockExpectation lastCalledWith(List<Object> expectedArgs) {
            validateMockVerification();
            failIf(boundMethodName == null, 'Method name must be provided for lastCalledWith.');
            List<MethodCall> calls = getBoundCalls();
            failIf(calls.isEmpty(), 'Expected method "' + boundMethodName + '" to have been called, but it was not.');

            MethodCall lastCall = calls.get(calls.size() - 1);
            String prefix = getNamePrefix();
            Boolean matches = argsMatch(lastCall.args, expectedArgs);
            verifyMatchExpectation(
                matches,
                prefix +
                    'Expected last call to "' +
                    boundMethodName +
                    '" to be with ' +
                    expectedArgs +
                    ', but was ' +
                    lastCall.args,
                prefix +
                    'Expected last call to "' +
                    boundMethodName +
                    '" NOT to be with ' +
                    expectedArgs +
                    ', but it was.'
            );
            return this;
        }

        /**
         * Verifies that the N-th call (1-based index) to this method matched the specified arguments.
         * @param n Call index (1-based)
         * @param expectedArgs List of expected arguments
         * @return This expectation instance for chaining
         * @example
         * expectation.nthCalledWith(1, new List<Object>{ 'value' });
         */
        public MockExpectation nthCalledWith(Integer n, List<Object> expectedArgs) {
            validateMockVerification();
            failIf(boundMethodName == null, 'Method name must be provided for nthCalledWith.');
            List<MethodCall> calls = getBoundCalls();
            failIf(
                calls.size() < n,
                'Expected at least ' + n + ' calls to "' + boundMethodName + '", but only found ' + calls.size()
            );

            MethodCall nthCall = calls.get(n - 1); // 1-based index
            String prefix = getNamePrefix();
            Boolean matches = argsMatch(nthCall.args, expectedArgs);
            verifyMatchExpectation(
                matches,
                prefix +
                    'Expected call #' +
                    n +
                    ' to "' +
                    boundMethodName +
                    '" to be with ' +
                    expectedArgs +
                    ', but was ' +
                    nthCall.args,
                prefix +
                    'Expected call #' +
                    n +
                    ' to "' +
                    boundMethodName +
                    '" NOT to be with ' +
                    expectedArgs +
                    ', but it was.'
            );
            return this;
        }

        /**
         * Verifies the bound method returned successfully at least once.
         * @return This expectation instance for chaining
         * @example
         * expectation.toHaveReturned();
         */
        public MockExpectation toHaveReturned() {
            validateMockVerification();
            MethodScope scope = getBoundScope();
            return verifyReturned(scope.methodName, scope.calls);
        }

        /**
         * Verifies the method returned successfully at least once.
         * @param methodName Name of the method
         * @return This expectation instance for chaining
         * @example
         * expectation.toHaveReturned('doWork');
         */
        public MockExpectation toHaveReturned(String methodName) {
            validateMockVerification();
            return verifyReturned(methodName, provider.getCalls(methodName));
        }

        /**
         * Verifies the bound method returned successfully exactly n times.
         * @param times Expected number of successful returns
         * @return This expectation instance for chaining
         * @example
         * expectation.toHaveReturnedTimes(1);
         */
        public MockExpectation toHaveReturnedTimes(Integer times) {
            validateMockVerification();
            MethodScope scope = getBoundScope();
            return verifyReturnedTimes(scope.methodName, scope.calls, times);
        }

        /**
         * Verifies the method returned successfully exactly n times.
         * @param methodName Name of the method
         * @param times Expected number of successful returns
         * @return This expectation instance for chaining
         * @example
         * expectation.toHaveReturnedTimes('doWork', 1);
         */
        public MockExpectation toHaveReturnedTimes(String methodName, Integer times) {
            validateMockVerification();
            return verifyReturnedTimes(methodName, provider.getCalls(methodName), times);
        }

        /**
         * Verifies the bound method returned with a matching value at least once.
         * @param expectedValue Expected returned value
         * @return This expectation instance for chaining
         * @example
         * expectation.toHaveReturnedWith('value');
         */
        public MockExpectation toHaveReturnedWith(Object expectedValue) {
            validateMockVerification();
            MethodScope scope = getBoundScope();
            return verifyReturnedWith(scope.methodName, scope.calls, expectedValue);
        }

        /**
         * Verifies the method returned with a matching value at least once.
         * @param methodName Name of the method
         * @param expectedValue Expected returned value
         * @return This expectation instance for chaining
         * @example
         * expectation.toHaveReturnedWith('doWork', 'value');
         */
        public MockExpectation toHaveReturnedWith(String methodName, Object expectedValue) {
            validateMockVerification();
            return verifyReturnedWith(methodName, provider.getCalls(methodName), expectedValue);
        }

        /**
         * Verifies the N-th call (1-based index) returned with a matching value.
         * @param n Call index (1-based)
         * @param expectedValue Expected returned value
         * @return This expectation instance for chaining
         * @example
         * expectation.toHaveNthReturnedWith(1, 'value');
         */
        public MockExpectation toHaveNthReturnedWith(Integer n, Object expectedValue) {
            validateMockVerification();
            MethodScope scope = getBoundScope();
            return verifyNthReturnedWith(scope.methodName, scope.calls, n, expectedValue);
        }

        /**
         * Verifies the N-th call (1-based index) to a method returned with a matching value.
         * @param methodName Name of the method
         * @param n Call index (1-based)
         * @param expectedValue Expected returned value
         * @return This expectation instance for chaining
         * @example
         * expectation.toHaveNthReturnedWith('doWork', 1, 'value');
         */
        public MockExpectation toHaveNthReturnedWith(String methodName, Integer n, Object expectedValue) {
            validateMockVerification();
            return verifyNthReturnedWith(methodName, provider.getCalls(methodName), n, expectedValue);
        }

        /**
         * Verifies the most recent call returned with a matching value.
         * @param expectedValue Expected returned value
         * @return This expectation instance for chaining
         * @example
         * expectation.toHaveLastReturnedWith('value');
         */
        public MockExpectation toHaveLastReturnedWith(Object expectedValue) {
            validateMockVerification();
            MethodScope scope = getBoundScope();
            return verifyLastReturnedWith(scope.methodName, scope.calls, expectedValue);
        }

        /**
         * Verifies the most recent call to a method returned with a matching value.
         * @param methodName Name of the method
         * @param expectedValue Expected returned value
         * @return This expectation instance for chaining
         * @example
         * expectation.toHaveLastReturnedWith('doWork', 'value');
         */
        public MockExpectation toHaveLastReturnedWith(String methodName, Object expectedValue) {
            validateMockVerification();
            return verifyLastReturnedWith(methodName, provider.getCalls(methodName), expectedValue);
        }

        private MethodScope getBoundScope() {
            ensureBoundMethod(boundMethodRequiredMessage);
            return new MethodScope(boundMethodName, getBoundCalls());
        }

        private void ensureBoundMethod(String errorMessage) {
            failIf(boundMethodName == null, errorMessage);
        }

        private MockExpectation verifyCalled(String methodName, List<MethodCall> calls) {
            String prefix = getNamePrefix();
            failIf(
                !isNegated && calls.isEmpty(),
                prefix + 'Expected method "' + methodName + '" to have been called, but it was not.'
            );
            failIf(
                isNegated && !calls.isEmpty(),
                prefix +
                    'Expected method "' +
                    methodName +
                    '" NOT to have been called, but it was called ' +
                    calls.size() +
                    ' times.'
            );
            return this;
        }

        private MockExpectation verifyCalledTimes(String methodName, List<MethodCall> calls, Integer times) {
            String prefix = getNamePrefix();
            failIf(
                !isNegated && calls.size() != times,
                prefix +
                    'Expected method "' +
                    methodName +
                    '" to have been called ' +
                    times +
                    ' times, but it was called ' +
                    calls.size() +
                    ' times.'
            );
            failIf(
                isNegated && calls.size() == times,
                prefix + 'Expected method "' + methodName + '" NOT to have been called ' + times + ' times, but it was.'
            );
            return this;
        }

        private MockExpectation verifyCalledWith(String methodName, List<MethodCall> calls, List<Object> expectedArgs) {
            String prefix = getNamePrefix();
            failIf(
                !isNegated && calls.isEmpty(),
                prefix + 'Expected method "' + methodName + '" to have been called, but it was not.'
            );

            Boolean matchFound = false;
            for (MethodCall call : calls) {
                if (argsMatch(call.args, expectedArgs)) {
                    matchFound = true;
                    failIf(
                        isNegated,
                        prefix +
                            'Expected method "' +
                            methodName +
                            '" NOT to have been called with arguments ' +
                            expectedArgs +
                            ', but it was.'
                    );
                    return this;
                }
            }

            failIf(
                !isNegated && !matchFound,
                prefix +
                    'Expected method "' +
                    methodName +
                    '" to have been called with matching arguments, but no matching call was found.'
            );

            return this;
        }

        private MockExpectation verifyReturned(String methodName, List<MethodCall> calls) {
            String prefix = getNamePrefix();
            Integer returnedCount = countReturnedCalls(calls);
            failIf(
                !isNegated && returnedCount == 0,
                prefix + 'Expected method "' + methodName + '" to have returned at least once, but it never returned.'
            );
            failIf(
                isNegated && returnedCount > 0,
                prefix +
                    'Expected method "' +
                    methodName +
                    '" NOT to have returned, but it returned ' +
                    returnedCount +
                    ' times.'
            );
            return this;
        }

        private MockExpectation verifyReturnedTimes(String methodName, List<MethodCall> calls, Integer times) {
            String prefix = getNamePrefix();
            Integer returnedCount = countReturnedCalls(calls);
            failIf(
                !isNegated && returnedCount != times,
                prefix +
                    'Expected method "' +
                    methodName +
                    '" to have returned ' +
                    times +
                    ' times, but it returned ' +
                    returnedCount +
                    ' times.'
            );
            failIf(
                isNegated && returnedCount == times,
                prefix + 'Expected method "' + methodName + '" NOT to have returned ' + times + ' times, but it did.'
            );
            return this;
        }

        private MockExpectation verifyReturnedWith(String methodName, List<MethodCall> calls, Object expectedValue) {
            String prefix = getNamePrefix();
            Boolean matchFound = false;
            for (MethodCall call : calls) {
                if (didReturnWith(call, expectedValue)) {
                    matchFound = true;
                    break;
                }
            }

            failIf(
                !isNegated && !matchFound,
                prefix +
                    'Expected method "' +
                    methodName +
                    '" to have returned with ' +
                    expectedValue +
                    ', but no matching returned value was found.'
            );
            failIf(
                isNegated && matchFound,
                prefix +
                    'Expected method "' +
                    methodName +
                    '" NOT to have returned with ' +
                    expectedValue +
                    ', but it did.'
            );
            return this;
        }

        private MockExpectation verifyNthReturnedWith(
            String methodName,
            List<MethodCall> calls,
            Integer n,
            Object expectedValue
        ) {
            String prefix = getNamePrefix();
            failIf(n == null || n < 1, 'Call index must be greater than 0.');
            failIf(
                calls.size() < n,
                'Expected at least ' + n + ' calls to "' + methodName + '", but only found ' + calls.size()
            );

            MethodCall nthCall = calls.get(n - 1);
            if (!isNegated) {
                failIf(
                    !nthCall.didReturn,
                    prefix +
                        'Expected call #' +
                        n +
                        ' to "' +
                        methodName +
                        '" to have returned ' +
                        expectedValue +
                        ', but it threw.'
                );
                failIf(
                    !valuesMatch(nthCall.returnValue, expectedValue),
                    prefix +
                        'Expected call #' +
                        n +
                        ' to "' +
                        methodName +
                        '" to have returned ' +
                        expectedValue +
                        ', but returned ' +
                        nthCall.returnValue +
                        '.'
                );
                return this;
            }

            failIf(
                didReturnWith(nthCall, expectedValue),
                prefix +
                    'Expected call #' +
                    n +
                    ' to "' +
                    methodName +
                    '" NOT to have returned ' +
                    expectedValue +
                    ', but it did.'
            );
            return this;
        }

        private MockExpectation verifyLastReturnedWith(
            String methodName,
            List<MethodCall> calls,
            Object expectedValue
        ) {
            String prefix = getNamePrefix();
            failIf(
                calls.isEmpty(),
                prefix + 'Expected method "' + methodName + '" to have been called, but it was not.'
            );
            return verifyNthReturnedWith(methodName, calls, calls.size(), expectedValue);
        }

        private Boolean didReturnWith(MethodCall call, Object expectedValue) {
            return call.didReturn && valuesMatch(call.returnValue, expectedValue);
        }

        private void verifyMatchExpectation(
            Boolean matches,
            String positiveFailureMessage,
            String negatedFailureMessage
        ) {
            failIf(!isNegated && !matches, positiveFailureMessage);
            failIf(isNegated && matches, negatedFailureMessage);
        }

        private Integer countReturnedCalls(List<MethodCall> calls) {
            Integer returnedCount = 0;
            for (MethodCall call : calls) {
                if (call.didReturn) {
                    returnedCount++;
                }
            }
            return returnedCount;
        }

        private String getNamePrefix() {
            return provider?.mockName != null ? '[' + provider.mockName + '] ' : '';
        }

        private Boolean argsMatch(List<Object> actual, List<Object> expected) {
            return argsMatchValues(actual, expected);
        }
    }

    /**
     * Fluent API for asserting that a block of code throws an exception.
     */
    public class ExceptionExpectation {
        private final Block b;
        private Exception caughtException;
        private Boolean executed = false;

        /**
         * Constructor for ExceptionExpectation.
         * @param b The block of code to test
         */
        public ExceptionExpectation(Block b) {
            this.b = b;
        }

        private void execute() {
            if (executed) {
                return;
            }
            try {
                b.run();
            } catch (Exception e) {
                caughtException = e;
            }
            executed = true;
        }

        /**
         * Asserts that the block of code threw an exception.
         * @example
         * exceptionExpectation.toThrow();
         */
        public void toThrow() {
            execute();
            failIf(caughtException == null, 'Expected block to throw an exception, but it did not.');
        }

        /**
         * Asserts that the block threw an exception with a message containing the specified string.
         * @param message The substring to look for in the exception message
         * @example
         * exceptionExpectation.toThrow('value');
         */
        public void toThrow(String message) {
            execute();
            failIf(
                caughtException == null,
                'Expected block to throw an exception with message containing "' + message + '", but it did not throw.'
            );
            failIf(
                !caughtException.getMessage().contains(message),
                'Expected exception message to contain "' + message + '", but got: ' + caughtException.getMessage()
            );
        }

        /**
         * Asserts that the block threw an exception of the specific Type.
         * @param exceptionType The expected exception type
         * @example
         * exceptionExpectation.toThrow(CustomException.class);
         */
        public void toThrow(Type exceptionType) {
            execute();
            failIf(
                caughtException == null,
                'Expected block to throw exception of type ' + exceptionType.getName() + ', but it did not throw.'
            );
            failIf(
                Type.forName(caughtException.getTypeName()) != exceptionType,
                'Expected exception of type ' + exceptionType.getName() + ', but got: ' + caughtException.getTypeName()
            );
        }
    }

    /**
     * Represents a recorded method call.
     */
    public class MethodCall {
        /**
         * Name of the method.
         * @example
         * call.methodName;
         */
        public String methodName { get; private set; }
        /**
         * List of arguments.
         * @example
         * call.args;
         */
        public List<Object> args { get; private set; }
        /**
         * Whether the call returned successfully.
         * @example
         * call.didReturn;
         */
        public Boolean didReturn { get; private set; }
        /**
         * Return value for successful calls.
         * @example
         * call.returnValue;
         */
        public Object returnValue { get; private set; }

        /**
         * Constructor for MethodCall.
         * @param methodName Name of the method
         * @param args List of arguments
         * @example
         * new MethodCall('doWork', new List<Object>());
         */
        public MethodCall(String methodName, List<Object> args) {
            this.methodName = methodName;
            this.args = args;
            this.didReturn = false;
            this.returnValue = null;
        }

        /**
         * Marks this call as successfully returned.
         * @param returnValue Returned value
         * @example
         * call.markReturned('value');
         */
        public void markReturned(Object returnValue) {
            this.didReturn = true;
            this.returnValue = returnValue;
        }

        /**
         * Marks this call as thrown.
         * @example
         * call.markThrew();
         */
        public void markThrew() {
            this.didReturn = false;
            this.returnValue = null;
        }
    }

    /**
     * Internal implementation of System.StubProvider.
     */
    public class MockProvider implements System.StubProvider {
        private final Map<String, Object> returnValues = new Map<String, Object>();
        private final Map<String, List<Object>> returnValuesOnce = new Map<String, List<Object>>();
        private final Map<String, Exception> exceptions = new Map<String, Exception>();
        private final Map<String, Callback> callbacks = new Map<String, Callback>();
        private final Map<String, List<ConditionalBehavior>> conditionalBehaviorsByMethod = new Map<String, List<ConditionalBehavior>>();
        private final Map<String, List<MethodCall>> callsByMethod = new Map<String, List<MethodCall>>();
        private final Map<String, List<MethodCall>> callsByKey = new Map<String, List<MethodCall>>();
        private final List<MethodCall> calls = new List<MethodCall>();
        public final String mockName;

        /**
         * Constructor for MockProvider with a name.
         * @param mockName The name of the mock
         */
        public MockProvider(String mockName) {
            this.mockName = mockName;
        }

        /**
         * Sets a persistent return value for a method.
         * @param methodName Name of the method
         * @param returnValue The value to return
         * @example
         * provider.setReturnValue('doWork', 'value');
         */
        public void setReturnValue(String methodName, Object returnValue) {
            returnValues.put(methodName, returnValue);
        }

        /**
         * Adds a one-time return value for a method.
         * @param methodName Name of the method
         * @param returnValue The value to return once
         * @example
         * provider.addReturnValueOnce('doWork', 'value');
         */
        public void addReturnValueOnce(String methodName, Object returnValue) {
            if (!returnValuesOnce.containsKey(methodName)) {
                returnValuesOnce.put(methodName, new List<Object>());
            }
            returnValuesOnce.get(methodName).add(returnValue);
        }

        /**
         * Sets an exception to be thrown by a method.
         * @param methodName Name of the method
         * @param error The exception to throw
         * @example
         * provider.setException('doWork', new Mock.MockException('boom'));
         */
        public void setException(String methodName, Exception error) {
            exceptions.put(methodName, error);
        }

        /**
         * Sets a callback for a method.
         * @param methodName Name of the method
         * @param callback The callback implementation
         * @example
         * provider.setCallback('doWork', callback);
         */
        public void setCallback(String methodName, Callback callback) {
            callbacks.put(methodName, callback);
        }

        /**
         * Adds a conditional behavior for a method key and expected arguments.
         * @param methodKey Method name or signature key
         * @param expectedArgs Expected arguments
         * @return Configurable conditional behavior
         * @example
         * provider.addConditionalBehavior('value', new List<Object>{ 'value' });
         */
        private ConditionalBehavior addConditionalBehavior(String methodKey, List<Object> expectedArgs) {
            if (!conditionalBehaviorsByMethod.containsKey(methodKey)) {
                conditionalBehaviorsByMethod.put(methodKey, new List<ConditionalBehavior>());
            }
            ConditionalBehavior behavior = new ConditionalBehavior(expectedArgs);
            conditionalBehaviorsByMethod.get(methodKey).add(behavior);
            return behavior;
        }

        /**
         * Clears call history.
         */
        public void clear() {
            calls.clear();
            callsByMethod.clear();
            callsByKey.clear();
        }

        /**
         * Resets history and behavior.
         */
        public void reset() {
            calls.clear();
            callsByMethod.clear();
            callsByKey.clear();
            returnValues.clear();
            returnValuesOnce.clear();
            exceptions.clear();
            callbacks.clear();
            conditionalBehaviorsByMethod.clear();
        }

        /**
         * Returns calls for a method.
         * @param methodName Name of the method
         * @return List of MethodCalls
         * @example
         * provider.getCalls('doWork');
         */
        public List<MethodCall> getCalls(String methodName) {
            return callsByMethod.get(methodName) ?? new List<MethodCall>();
        }

        /**
         * Returns calls for an exact method key (name + signature).
         * @param methodKey Method key
         * @return List of MethodCalls
         * @example
         * provider.getCallsByKey('methodKey');
         */
        public List<MethodCall> getCallsByKey(String methodKey) {
            return callsByKey.get(methodKey) ?? new List<MethodCall>();
        }

        private ConditionalAction consumeConditionalAction(String methodNameOrKey, List<Object> actualArgs) {
            List<ConditionalBehavior> behaviors = conditionalBehaviorsByMethod.get(methodNameOrKey);
            if (behaviors == null) {
                return null;
            }
            for (Integer i = behaviors.size() - 1; i >= 0; i--) {
                ConditionalBehavior behavior = behaviors.get(i);
                if (behavior.matches(actualArgs)) {
                    return behavior.consumeAction();
                }
            }
            return null;
        }

        private ConditionalAction consumeConditionalActionWithFallback(
            String methodKey,
            String methodName,
            List<Object> actualArgs
        ) {
            ConditionalAction action = consumeConditionalAction(methodKey, actualArgs);
            if (action != null || methodKey == methodName) {
                return action;
            }
            return consumeConditionalAction(methodName, actualArgs);
        }

        /**
         * Handle method call from Test.createStub.
         * @param stubbedObject The stub object
         * @param stubbedMethodName The method name
         * @param returnType Expected return type
         * @param listOfParamTypes Parameter types
         * @param listOfParamNames Parameter names
         * @param listOfArgs Arguments
         * @return Mocked result or null
         * @example
         * // Mocked method signature: String doWork(String input)
         * Object result = provider.handleMethodCall(
         *     mock,
         *     'doWork',
         *     String.class,
         *     new List<Type>{ String.class },
         *     new List<String>{ 'input' },
         *     new List<Object>{ 'hello' }
         * );
         */
        public Object handleMethodCall(
            Object stubbedObject,
            String stubbedMethodName,
            Type returnType,
            List<Type> listOfParamTypes,
            List<String> listOfParamNames,
            List<Object> listOfArgs
        ) {
            String methodKey = buildMethodKey(stubbedMethodName, listOfParamTypes);

            // Record the call
            MethodCall call = new MethodCall(stubbedMethodName, listOfArgs);
            calls.add(call);
            if (!callsByMethod.containsKey(stubbedMethodName)) {
                callsByMethod.put(stubbedMethodName, new List<MethodCall>());
            }
            callsByMethod.get(stubbedMethodName).add(call);
            if (!callsByKey.containsKey(methodKey)) {
                callsByKey.put(methodKey, new List<MethodCall>());
            }
            callsByKey.get(methodKey).add(call);

            try {
                ConditionalAction conditionalAction = consumeConditionalActionWithFallback(
                    methodKey,
                    stubbedMethodName,
                    listOfArgs
                );
                if (conditionalAction != null) {
                    if (conditionalAction.error != null) {
                        throw conditionalAction.error;
                    }
                    Object conditionalResult = conditionalAction.callback != null
                        ? conditionalAction.callback.call(listOfArgs)
                        : conditionalAction.returnValue;
                    call.markReturned(conditionalResult);
                    return conditionalResult;
                }

                // Check if we should throw an exception
                if (exceptions.containsKey(methodKey)) {
                    throw exceptions.get(methodKey);
                }
                if (exceptions.containsKey(stubbedMethodName)) {
                    throw exceptions.get(stubbedMethodName);
                }

                Object result;
                // Check for callbacks
                if (callbacks.containsKey(methodKey)) {
                    result = callbacks.get(methodKey).call(listOfArgs);
                } else if (callbacks.containsKey(stubbedMethodName)) {
                    result = callbacks.get(stubbedMethodName).call(listOfArgs);
                } else if (returnValuesOnce.containsKey(methodKey) && !returnValuesOnce.get(methodKey).isEmpty()) {
                    // Check for one-time return values first
                    result = returnValuesOnce.get(methodKey).remove(0);
                } else if (
                    returnValuesOnce.containsKey(stubbedMethodName) &&
                    !returnValuesOnce.get(stubbedMethodName).isEmpty()
                ) {
                    result = returnValuesOnce.get(stubbedMethodName).remove(0);
                } else if (returnValues.containsKey(methodKey)) {
                    // Fall back to persistent return value
                    result = returnValues.get(methodKey);
                } else {
                    result = returnValues.get(stubbedMethodName);
                }

                call.markReturned(result);
                return result;
            } catch (Exception e) {
                call.markThrew();
                throw e;
            }
        }
    }

    /**
     * Callback interface for dynamic mock implementations.
     */
    public interface Callback {
        /**
         * Executes the callback logic.
         * @param args The arguments passed to the mocked method
         * @return The value to return from the mocked method
         */
        Object call(List<Object> args);
    }

    /**
     * Represents a block of code for exception testing.
     */
    public interface Block {
        /**
         * Runs the code block.
         */
        void run();
    }

    /**
     * Base interface for custom argument matchers.
     */
    public interface Matcher {
        /**
         * Determines if the actual value matches the criteria.
         * @param actual The value to check
         * @return True if the value matches
         * @example
         * matcher.matches('value');
         */
        Boolean matches(Object actual);
    }

    /**
     * Matcher that matches any non-null value (or null if used as any()).
     */
    public class AnyMatcher implements Matcher {
        /**
         * Returns true for any value.
         * @param actual The value to check
         * @return True
         * @example
         * matcher.matches('value');
         */
        public Boolean matches(Object actual) {
            return true;
        }
    }

    /**
     * Matcher for String values.
     */
    public class StringMatcher implements Matcher {
        /**
         * Checks if the value is a String.
         * @param actual Value
         * @return True if String
         * @example
         * matcher.matches('value');
         */
        public Boolean matches(Object actual) {
            return actual instanceof String;
        }
    }

    /**
     * Matcher for Integer values.
     */
    public class IntegerMatcher implements Matcher {
        /**
         * Checks if the value is an Integer.
         * @param actual Value
         * @return True if Integer
         * @example
         * matcher.matches(1);
         */
        public Boolean matches(Object actual) {
            return actual instanceof Integer;
        }
    }

    /**
     * Matcher for Decimal values.
     */
    public class DecimalMatcher implements Matcher {
        /**
         * Checks if the value is a Decimal.
         * @param actual Value
         * @return True if Decimal
         * @example
         * matcher.matches(2.5);
         */
        public Boolean matches(Object actual) {
            return actual instanceof Decimal;
        }
    }

    /**
     * Matcher for Id values.
     */
    public class IdMatcher implements Matcher {
        /**
         * Checks if the value is an Id.
         * @param actual Value
         * @return True if Id
         * @example
         * matcher.matches('00100000000000AAA');
         */
        public Boolean matches(Object actual) {
            return actual instanceof Id;
        }
    }

    /**
     * Matcher for Boolean values.
     */
    public class BooleanMatcher implements Matcher {
        /**
         * Checks if the value is a Boolean.
         * @param actual Value
         * @return True if Boolean
         * @example
         * matcher.matches(true);
         */
        public Boolean matches(Object actual) {
            return actual instanceof Boolean;
        }
    }

    /**
     * Matcher for List values.
     */
    public class ListMatcher implements Matcher {
        /**
         * Checks if the value is a List.
         * @param actual Value
         * @return True if List
         * @example
         * matcher.matches(someList);
         */
        public Boolean matches(Object actual) {
            return actual instanceof List<Object>;
        }
    }

    /**
     * Matcher for Map values.
     */
    public class MapMatcher implements Matcher {
        /**
         * Checks if the value is a Map.
         * @param actual Value
         * @return True if Map
         * @example
         * matcher.matches(byStringMap);
         */
        public Boolean matches(Object actual) {
            return actual instanceof Map<String, Object>;
        }
    }

    /**
     * Matcher for Date values.
     */
    public class DateMatcher implements Matcher {
        /**
         * Checks if the value is a Date.
         * @param actual Value
         * @return True if Date
         * @example
         * matcher.matches(Date.today());
         */
        public Boolean matches(Object actual) {
            return actual instanceof Date;
        }
    }

    /**
     * Matcher for Datetime values.
     */
    public class DatetimeMatcher implements Matcher {
        /**
         * Checks if the value is a Datetime.
         * @param actual Value
         * @return True if Datetime
         * @example
         * matcher.matches(Datetime.now());
         */
        public Boolean matches(Object actual) {
            return actual instanceof Datetime;
        }
    }

    /**
     * Matcher for Time values.
     */
    public class TimeMatcher implements Matcher {
        /**
         * Checks if the value is a Time.
         * @param actual Value
         * @return True if Time
         * @example
         * matcher.matches(someTime);
         */
        public Boolean matches(Object actual) {
            return actual instanceof Time;
        }
    }

    /**
     * Matcher for SObjects.
     */
    public class SObjectMatcher implements Matcher {
        private final Schema.SObjectType sObjectType;

        /**
         * Default constructor.
         */
        public SObjectMatcher() {
            this(null);
        }

        /**
         * Constructor for SObjectMatcher.
         * @param sObjectType Expected type
         * @example
         * new SObjectMatcher(Account.SObjectType);
         */
        public SObjectMatcher(Schema.SObjectType sObjectType) {
            this.sObjectType = sObjectType;
        }

        /**
         * Checks if the SObject matches the expected type.
         * @param actual The SObject to check
         * @return True if the SObjectType matches
         * @example
         * matcher.matches(account);
         */
        public Boolean matches(Object actual) {
            if (!(actual instanceof SObject)) {
                return false;
            }
            if (sObjectType != null) {
                return ((SObject) actual).getSObjectType() == sObjectType;
            }
            return true;
        }
    }

    /**
     * Matcher for specific Types.
     */
    public class TypeMatcher implements Matcher {
        private final Type expectedType;
        /**
         * Constructor for TypeMatcher.
         * @param expectedType Expected type
         */
        public TypeMatcher(Type expectedType) {
            this.expectedType = expectedType;
        }
        /**
         * Checks if the object is an instance of the expected type.
         * @param actual The object to check
         * @return True if the object matches the type
         * @example
         * matcher.matches(String.class);
         */
        public Boolean matches(Object actual) {
            if (actual == null) {
                return false;
            }
            return expectedType.isAssignableFrom(Mock.getType(actual));
        }
    }

    /**
     * Negating matcher.
     */
    public class NotMatcher implements Matcher {
        private final Matcher matcher;
        /**
         * Constructor for NotMatcher.
         * @param matcher Matcher to negate
         * @example
         * new NotMatcher(Mock.any());
         */
        public NotMatcher(Matcher matcher) {
            this.matcher = matcher;
        }
        /**
         * Inverse matcher check.
         * @param actual Value
         * @return Inverse match result
         * @example
         * matcher.matches('value');
         */
        public Boolean matches(Object actual) {
            return !matcher.matches(actual);
        }
    }

    /**
     * Matcher for substrings.
     */
    public class StringContainingMatcher implements Matcher {
        private final String expected;
        /**
         * Constructor for StringContainingMatcher.
         * @param expected Substring
         * @example
         * new StringContainingMatcher('value');
         */
        public StringContainingMatcher(String expected) {
            this.expected = expected;
        }
        /**
         * Checks if string contains substring.
         * @param actual Value
         * @return True if contains
         * @example
         * matcher.matches('value');
         */
        public Boolean matches(Object actual) {
            return actual instanceof String && ((String) actual).contains(expected);
        }
    }

    /**
     * Matcher for collection items.
     */
    public class IterableContainingMatcher implements Matcher {
        private final Object expectedItem;
        /**
         * Constructor for IterableContainingMatcher.
         * @param expectedItem Item or matcher
         */
        public IterableContainingMatcher(Object expectedItem) {
            this.expectedItem = expectedItem;
        }
        /**
         * Checks if collection contains item.
         * @param actual Collection
         * @return True if item found
         * @example
         * matcher.matches(someList);
         */
        public Boolean matches(Object actual) {
            if (!(actual instanceof Iterable<Object>)) {
                return false;
            }

            Iterator<Object> it = ((Iterable<Object>) actual).iterator();
            while (it.hasNext()) {
                Object item = it.next();
                if (valuesMatch(item, expectedItem)) {
                    return true;
                }
            }
            return false;
        }
    }

    /**
     * Matcher that checks if an object, map, or SObject contains specific fields.
     */
    public class ObjectContainingMatcher implements Matcher {
        private final Map<String, Object> expected;

        /**
         * Constructor for ObjectContainingMatcher.
         * @param expected Map of field names to values or matchers
         */
        public ObjectContainingMatcher(Map<String, Object> expected) {
            this.expected = expected;
        }

        /**
         * Checks if the object contains the expected fields.
         * @param actual The object, Map, or SObject to check
         * @return True if all expected fields match
         * @example
         * matcher.matches(o);
         */
        public Boolean matches(Object actual) {
            if (actual == null) {
                return false;
            }

            // For SObjects
            if (actual instanceof SObject) {
                SObject record = (SObject) actual;
                for (String field : expected.keySet()) {
                    Object expectedValue = expected.get(field);
                    Object actualValue;
                    try {
                        actualValue = record.get(field);
                    } catch (SObjectException e) {
                        return false; // Field doesn't exist on SObject
                    }
                    if (!valuesMatch(actualValue, expectedValue)) {
                        return false;
                    }
                }
                return true;
            }

            // For Maps
            if (actual instanceof Map<String, Object>) {
                return matchMap((Map<String, Object>) actual);
            }

            // Fallback for DTOs/Custom Objects: Treat as Map via JSON serialization
            try {
                Map<String, Object> actualMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(actual));
                return matchMap(actualMap);
            } catch (Exception e) {
                return false;
            }
        }

        /**
         * Helper to match map contents.
         * @param actualMap Map
         * @return True if match
         * @example
         * matcher.matchMap(new Map<String, Object>{ 'Name' => 'Acme' });
         */
        private Boolean matchMap(Map<String, Object> actualMap) {
            for (String key : expected.keySet()) {
                if (!actualMap.containsKey(key) || !valuesMatch(actualMap.get(key), expected.get(key))) {
                    return false;
                }
            }
            return true;
        }
    }

    /**
     * Mock implementation for the HttpCalloutMock interface.
     */
    public class HttpMock implements HttpCalloutMock {
        private final Map<String, HttpResponse> responses = new Map<String, HttpResponse>();
        private final List<HttpRequest> requests = new List<HttpRequest>();

        /**
         * Registers a response for a specific URL.
         * @param url The endpoint URL
         * @param res The response to return
         * @example
         * HttpResponse res = new HttpResponse();
         * res.setBody('{}');
         * res.setStatusCode(200);
         * httpMock.mockResponse('https://example.com', res);
         */
        public void mockResponse(String url, HttpResponse res) {
            responses.put(url, res);
        }

        /**
         * Registers a response for a specific HTTP method and URL.
         * @param method HTTP method
         * @param url Endpoint URL
         * @param res The response to return
         * @example
         * HttpResponse res = new HttpResponse();
         * res.setBody('{}');
         * res.setStatusCode(200);
         * httpMock.mockResponse('GET', 'https://example.com', res);
         */
        public void mockResponse(String method, String url, HttpResponse res) {
            responses.put(method.toUpperCase() + ' ' + url, res);
        }

        /**
         * Registers a response for any method if URL matches.
         * @param url Endpoint URL
         * @param body Response body
         * @param statusCode HTTP status
         * @example
         * httpMock.mockResponse('https://example.com', 'value', 200);
         */
        public void mockResponse(String url, String body, Integer statusCode) {
            mockResponse(null, url, body, statusCode);
        }

        /**
         * Registers a response for a specific HTTP method, URL, and body.
         * @param method HTTP method (e.g., 'GET', 'POST')
         * @param url Endpoint URL
         * @param body Response body
         * @param statusCode HTTP status code
         * @example
         * httpMock.mockResponse('GET', 'https://example.com', 'value', 200);
         */
        public void mockResponse(String method, String url, String body, Integer statusCode) {
            HttpResponse res = new HttpResponse();
            res.setBody(body);
            res.setStatusCode(statusCode);
            if (method != null) {
                responses.put(method.toUpperCase() + ' ' + url, res);
            } else {
                responses.put(url, res);
            }
        }

        /**
         * Implementation of HttpCalloutMock.respond.
         * @param req The HTTP request
         * @return Mocked HTTP response
         * @example
         * HttpRequest req = new HttpRequest();
         * httpMock.respond(req);
         */
        public HttpResponse respond(HttpRequest req) {
            requests.add(req);
            String endpoint = req.getEndpoint();
            String method = (req.getMethod() ?? 'GET').toUpperCase();
            String key = method + ' ' + endpoint;

            if (responses.containsKey(key)) {
                return responses.get(key);
            }
            if (responses.containsKey(endpoint)) {
                return responses.get(endpoint);
            }

            // Default 404
            HttpResponse res = new HttpResponse();
            res.setStatusCode(404);
            res.setStatus('Not Found');
            return res;
        }

        /**
         * Returns all recorded HTTP requests made to this mock.
         * @return List of HttpRequests
         * @example
         * httpMock.getRequests();
         */
        public List<HttpRequest> getRequests() {
            return requests;
        }

        /**
         * Clears requests.
         */
        public void clear() {
            requests.clear();
        }

        /**
         * Resets mock.
         */
        public void reset() {
            requests.clear();
            responses.clear();
        }
    }

    /**
     * Fluent API for verifying interactions with HttpMock.
     */
    public class HttpMockExpectation {
        private final HttpMock targetMock;
        private final Boolean isNegated;

        /**
         * Constructor for HttpMockExpectation.
         * @param targetMock The mock to verify
         */
        public HttpMockExpectation(HttpMock targetMock) {
            this(targetMock, false);
        }

        private HttpMockExpectation(HttpMock targetMock, Boolean isNegated) {
            this.targetMock = targetMock;
            this.isNegated = isNegated;
        }

        /**
         * Negates the expectation.
         * @example
         * httpExpectation.notx.toHaveBeenCalled();
         */
        public HttpMockExpectation notx {
            get {
                return new HttpMockExpectation(targetMock, !isNegated);
            }
        }

        /**
         * Asserts that at least one HTTP call was made.
         * @example
         * httpExpectation.toHaveBeenCalled();
         */
        public void toHaveBeenCalled() {
            failIf(!isNegated && targetMock.getRequests().isEmpty(), 'Expected HTTP call, but none were made.');
            failIf(
                isNegated && !targetMock.getRequests().isEmpty(),
                'Expected NO HTTP calls, but ' + targetMock.getRequests().size() + ' were made.'
            );
        }

        /**
         * Asserts that exactly n HTTP calls were made.
         * @param times Expected number of calls
         * @example
         * httpExpectation.toHaveBeenCalledTimes(1);
         */
        public void toHaveBeenCalledTimes(Integer times) {
            Integer actual = targetMock.getRequests().size();
            failIf(!isNegated && actual != times, 'Expected ' + times + ' HTTP calls, but ' + actual + ' were made.');
            failIf(isNegated && actual == times, 'Expected NOT to have ' + times + ' HTTP calls, but it did.');
        }

        /**
         * Asserts that an HTTP call was made with specific URL and method.
         * @param url Expected URL or matcher
         * @param method Expected HTTP method or matcher
         * @example
         * httpExpectation.toHaveBeenCalledWith('https://example.com', 'GET');
         */
        public void toHaveBeenCalledWith(Object url, Object method) {
            toHaveBeenCalledWith(url, method, null, null);
        }

        /**
         * Asserts that an HTTP call was made with specific URL, method and body.
         * @param url Expected URL or matcher
         * @param method Expected HTTP method or matcher
         * @param body Expected body or matcher
         * @example
         * httpExpectation.toHaveBeenCalledWith('https://example.com', 'GET', 'value');
         */
        public void toHaveBeenCalledWith(Object url, Object method, Object body) {
            toHaveBeenCalledWith(url, method, body, null);
        }

        /**
         * Full verification of an HTTP callout.
         * @param url Expected URL or matcher
         * @param method Expected HTTP method or matcher
         * @param body Expected body or matcher
         * @param headers Expected headers map
         * @example
         * httpExpectation.toHaveBeenCalledWith('https://example.com', 'GET', 'value', new Map<String, Object>());
         */
        public void toHaveBeenCalledWith(Object url, Object method, Object body, Map<String, Object> headers) {
            Boolean matchFound = false;
            for (HttpRequest req : targetMock.getRequests()) {
                if (requestMatches(req, url, method, body, headers)) {
                    matchFound = true;
                    break;
                }
            }

            String msg = 'Expected HTTP call to ' + method + ' ' + url;
            if (body != null) {
                msg += ' with body matching ' + body;
            }
            if (headers != null) {
                msg += ' with headers matching ' + headers;
            }

            failIf(!isNegated && !matchFound, msg + ', but no matching call was found.');
            failIf(isNegated && matchFound, msg + ' NOT to have been made, but it was.');
        }

        /**
         * Helper to match request details.
         * @param req The request
         * @param url Expected URL
         * @param method Expected method
         * @param body Expected body
         * @param headers Expected headers
         * @return True if matches
         * @example
         * httpExpectation.requestMatches(null, 'https://example.com', 'GET', 'value', new Map<String, Object>());
         */
        private Boolean requestMatches(
            HttpRequest req,
            Object url,
            Object method,
            Object body,
            Map<String, Object> headers
        ) {
            if (!valuesMatch(req.getEndpoint(), url)) {
                return false;
            }
            if (!valuesMatch(req.getMethod(), method)) {
                return false;
            }
            if (body != null && !valuesMatch(req.getBody(), body)) {
                return false;
            }

            if (headers != null) {
                for (String key : headers.keySet()) {
                    if (!valuesMatch(req.getHeader(key), headers.get(key))) {
                        return false;
                    }
                }
            }
            return true;
        }
    }

    /**
     * Exception thrown by the Mock library for assertion failures.
     */
    public class MockException extends Exception {
    }

    private class MethodScope {
        private final String methodName;
        private final List<MethodCall> calls;

        private MethodScope(String methodName, List<MethodCall> calls) {
            this.methodName = methodName;
            this.calls = calls;
        }
    }

    private class ConditionalAction {
        private final Object returnValue;
        private final Exception error;
        private final Callback callback;

        private ConditionalAction(Object returnValue, Exception error, Callback callback) {
            this.returnValue = returnValue;
            this.error = error;
            this.callback = callback;
        }
    }

    private class ConditionalBehavior {
        private final List<Object> expectedArgs;
        private final List<ConditionalAction> onceActions = new List<ConditionalAction>();
        private ConditionalAction defaultAction;

        private ConditionalBehavior(List<Object> expectedArgs) {
            this.expectedArgs = expectedArgs == null ? null : new List<Object>(expectedArgs);
        }

        private Boolean matches(List<Object> actualArgs) {
            return argsMatchValues(actualArgs, expectedArgs);
        }

        private ConditionalAction consumeAction() {
            if (!onceActions.isEmpty()) {
                return onceActions.remove(0);
            }
            return defaultAction;
        }

        private void addOnceAction(ConditionalAction action) {
            onceActions.add(action);
        }

        private void setDefaultAction(ConditionalAction action) {
            defaultAction = action;
        }
    }
}
