@SuppressWarnings('PMD.ApexDoc, PMD.ApexUnitTestClassShouldHaveAsserts')
@IsTest(IsParallel=true)
private class MockTest {
    // Basic Stubbing Tests
    @IsTest
    static void should_return_configured_value() {
        // Uses top-level IMockTestService because Apex cannot stub inner types
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.spyOn(mockService, 'getValue').mockReturnValue('Success');
        Mock.spyOn(mockService, 'add').mockReturnValue(10);

        // Assert
        Assert.areEqual('Success', mockService.getValue(), 'Should return configured value');
        Assert.areEqual(10, mockService.add(1, 2), 'Should return configured value ignoring args');
        Assert.areEqual(10, mockService.add(5, 5), 'Should return configured value regardless of args');
    }

    @IsTest
    static void should_return_null_for_unconfigured_methods() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);

        // Act
        Object result = mockService.getValue();

        // Assert
        Assert.areEqual(null, result, 'Should return null for unconfigured methods');
    }

    @IsTest
    static void should_throw_exception_for_invalid_mock() {
        // Act & Assert
        try {
            Mock.spyOn(new Account(), 'someMethod');
            Assert.fail('Should have thrown exception');
        } catch (Mock.MockException e) {
            Assert.areEqual('Object is not a valid Mock instance.', e.getMessage());
        }
    }

    // mockReturnValueOnce Tests
    @IsTest
    static void should_return_values_in_sequence_with_mock_return_value_once() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.spyOn(mockService, 'getValue')
            .mockReturnValueOnce('First')
            .mockReturnValueOnce('Second')
            .mockReturnValue('Default');

        // Assert
        Assert.areEqual('First', mockService.getValue(), 'First call should return first value');
        Assert.areEqual('Second', mockService.getValue(), 'Second call should return second value');
        Assert.areEqual('Default', mockService.getValue(), 'Third call should return default value');
        Assert.areEqual('Default', mockService.getValue(), 'Fourth call should still return default');
    }

    @IsTest
    static void should_return_null_after_exhausting_once_values() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.spyOn(mockService, 'getValue').mockReturnValueOnce('Only');

        // Act & Assert
        Assert.areEqual('Only', mockService.getValue(), 'First call should return the once value');
        Assert.areEqual(null, mockService.getValue(), 'Second call should return null');
    }

    // Verification Tests
    @IsTest
    static void should_verify_method_was_called() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);

        // Act
        mockService.getValue();

        // Assert
        Mock.expect(mockService).toHaveBeenCalled('getValue');
    }

    @IsTest
    static void should_fail_verification_when_method_not_called() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);

        // Act & Assert
        try {
            Mock.expect(mockService).toHaveBeenCalled('getValue');
            Assert.fail('Should have thrown exception');
        } catch (Mock.MockException e) {
            Assert.isTrue(e.getMessage().contains('Expected method "getValue" to have been called'));
        }
    }

    @IsTest
    static void should_verify_method_called_times() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);

        // Act
        mockService.getValue();
        mockService.getValue();
        mockService.getValue();

        // Assert
        Mock.expect(mockService).toHaveBeenCalledTimes('getValue', 3);
    }

    @IsTest
    static void should_fail_when_call_count_mismatch() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);

        // Act
        mockService.getValue();

        // Assert
        try {
            Mock.expect(mockService).toHaveBeenCalledTimes('getValue', 2);
            Assert.fail('Should have thrown exception');
        } catch (Mock.MockException e) {
            Assert.isTrue(e.getMessage().contains('called 1 times'));
        }
    }

    @IsTest
    static void should_verify_method_called_with_args() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);

        // Act
        mockService.add(5, 10);

        // Assert
        Mock.expect(mockService).toHaveBeenCalledWith('add', new List<Object>{ 5, 10 });
    }

    @IsTest
    static void should_fail_when_args_dont_match() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);

        // Act
        mockService.add(5, 10);

        // Assert
        try {
            Mock.expect(mockService).toHaveBeenCalledWith('add', new List<Object>{ 1, 2 });
            Assert.fail('Should have thrown exception');
        } catch (Mock.MockException e) {
            Assert.isTrue(e.getMessage().contains('no matching call was found'));
        }
    }

    // Argument Matcher Tests
    @IsTest
    static void should_match_any_argument() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);

        // Act
        mockService.add(42, 99);

        // Assert - Mock.any() should match any value
        Mock.expect(mockService).toHaveBeenCalledWith('add', new List<Object>{ Mock.any(), Mock.any() });
    }

    @IsTest
    static void should_match_object_containing_fields() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);
        Account acc = new Account(Name = 'Test Corp', Industry = 'Technology');

        // Act
        mockService.findById(null); // Just to record a call

        // Assert
        Mock.Matcher matcher = Mock.objectContaining(new Map<String, Object>{ 'Name' => 'Test Corp' });
        Assert.isTrue(matcher.matches(acc), 'Should match SObject containing the field');
    }

    @IsTest
    static void should_match_map_containing_keys() {
        // Arrange
        Mock.Matcher matcher = Mock.objectContaining(new Map<String, Object>{ 'key1' => 'value1' });
        Map<String, Object> actual = new Map<String, Object>{ 'key1' => 'value1', 'key2' => 'value2' };

        // Act & Assert
        Assert.isTrue(matcher.matches(actual), 'Should match map containing the key');
    }

    @IsTest
    static void should_not_match_when_field_missing() {
        // Arrange
        Mock.Matcher matcher = Mock.objectContaining(new Map<String, Object>{ 'MissingField' => 'value' });
        Account acc = new Account(Name = 'Test');

        // Act & Assert
        Assert.isFalse(matcher.matches(acc), 'Should not match when field is missing or different');
    }

    // Chaining Tests
    @IsTest
    static void should_support_chained_expectations() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);

        // Act
        mockService.getValue();
        mockService.add(1, 2);

        // Assert - chained verification
        Mock.expect(mockService)
            .toHaveBeenCalled('getValue')
            .toHaveBeenCalled('add')
            .toHaveBeenCalledTimes('getValue', 1)
            .toHaveBeenCalledWith('add', new List<Object>{ 1, 2 });
    }

    // Spy Verification Tests (Jest-style)
    @IsTest
    static void should_verify_spy_was_called() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.MethodSpy spy = Mock.spyOn(mockService, 'getValue');

        // Act
        mockService.getValue();

        // Assert - verify using the spy directly
        Mock.expect(spy).toHaveBeenCalled();
    }

    @IsTest
    static void should_verify_spy_called_times() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.MethodSpy spy = Mock.spyOn(mockService, 'getValue');

        // Act
        mockService.getValue();
        mockService.getValue();

        // Assert
        Mock.expect(spy).toHaveBeenCalledTimes(2);
    }

    @IsTest
    static void should_verify_spy_called_with_args() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.MethodSpy spy = Mock.spyOn(mockService, 'add');

        // Act
        mockService.add(5, 10);

        // Assert
        Mock.expect(spy).toHaveBeenCalledWith(new List<Object>{ 5, 10 });
    }

    @IsTest
    static void should_support_mixed_verification_styles() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.MethodSpy spy = Mock.spyOn(mockService, 'getValue');

        // Act
        mockService.getValue();

        // Assert - both styles should work
        Mock.expect(spy).toHaveBeenCalled(); // New style
        Mock.expect(mockService).toHaveBeenCalled('getValue'); // Old style
    }

    // Advanced Features Tests
    @IsTest
    static void should_throw_exception_when_configured() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.spyOn(mockService, 'doWork').mockThrow(new Mock.MockException('Custom Error'));

        // Act & Assert
        try {
            mockService.doWork('test');
            Assert.fail('Should have thrown exception');
        } catch (Mock.MockException e) {
            Assert.areEqual('Custom Error', e.getMessage());
        }
    }

    @IsTest
    static void should_verify_negation() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.MethodSpy spy = Mock.spyOn(mockService, 'getValue');

        // Assert - not called yet
        Mock.expect(spy).notx.toHaveBeenCalled();

        // Act
        mockService.getValue();

        // Assert
        Mock.expect(spy).notx.toHaveBeenCalledTimes(2);

        // Negative test
        try {
            Mock.expect(spy).notx.toHaveBeenCalled();
            Assert.fail('Should fail negation check');
        } catch (Mock.MockException e) {
            Assert.isTrue(e.getMessage().contains('NOT to have been called'));
        }

        try {
            Mock.expect(spy).notx.toHaveBeenCalledTimes(1);
            Assert.fail('Should fail negation check');
        } catch (Mock.MockException e) {
            Assert.isTrue(e.getMessage().contains('NOT to have been called 1 times'));
        }
    }

    @IsTest
    static void should_verify_call_history() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.MethodSpy spy = Mock.spyOn(mockService, 'add');

        // Act
        mockService.add(1, 1);
        mockService.add(2, 2);
        mockService.add(3, 3);

        // Assert
        Mock.expect(spy).nthCalledWith(1, new List<Object>{ 1, 1 });
        Mock.expect(spy).nthCalledWith(2, new List<Object>{ 2, 2 });
        Mock.expect(spy).lastCalledWith(new List<Object>{ 3, 3 });

        // Act & Assert error cases
        try {
            Mock.expect(spy).nthCalledWith(4, new List<Object>{ 4, 4 });
            Assert.fail('Should fail for out of bounds');
        } catch (Mock.MockException e) {
            Assert.isTrue(e.getMessage().contains('at least 4 calls'));
        }

        try {
            Mock.expect(spy).nthCalledWith(1, new List<Object>{ 9, 9 });
            Assert.fail('Should fail for mismatched args');
        } catch (Mock.MockException e) {
            Assert.isTrue(e.getMessage().contains('Expected call #1'));
        }
    }

    @IsTest
    static void should_fail_negated_call_history_assertions_when_args_match() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.MethodSpy spy = Mock.spyOn(mockService, 'add');
        mockService.add(1, 1);
        mockService.add(2, 2);

        // Act
        Boolean lastCalledWithThrew = false;
        try {
            Mock.expect(spy).notx.lastCalledWith(new List<Object>{ 2, 2 });
        } catch (Mock.MockException e) {
            lastCalledWithThrew = true;
        }

        Boolean nthCalledWithThrew = false;
        try {
            Mock.expect(spy).notx.nthCalledWith(1, new List<Object>{ 1, 1 });
        } catch (Mock.MockException e) {
            nthCalledWithThrew = true;
        }

        // Assert
        Assert.isTrue(
            lastCalledWithThrew,
            'Expected .notx.lastCalledWith to throw when last call matches, but it did not (bug).'
        );
        Assert.isTrue(
            nthCalledWithThrew,
            'Expected .notx.nthCalledWith to throw when Nth call matches, but it did not (bug).'
        );
    }

    @IsTest
    static void should_clear_and_reset_mock() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.MethodSpy spy = Mock.spyOn(mockService, 'getValue').mockReturnValue('A');

        // Act
        mockService.getValue();
        Mock.expect(spy).toHaveBeenCalledTimes(1);

        // Act & Assert Clear
        Mock.clear(mockService);
        Mock.expect(spy).notx.toHaveBeenCalled(); // History cleared
        Assert.areEqual('A', mockService.getValue()); // Config preserved

        // Act & Assert Reset
        Mock.reset(mockService);
        Mock.expect(spy).notx.toHaveBeenCalled(); // History cleared
        Assert.areEqual(null, mockService.getValue()); // Config cleared
    }

    @IsTest
    static void should_match_list_containing() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.MethodSpy spy = Mock.spyOn(mockService, 'doWork');

        // Act
        mockService.doWork('Hello World');

        // Assert
        Mock.expect(spy).toHaveBeenCalledWith(new List<Object>{ Mock.stringContaining('World') });
        Mock.expect(spy).notx.toHaveBeenCalledWith(new List<Object>{ Mock.stringContaining('Goodbye') });
    }

    @IsTest
    static void should_assert_values_tobe_toequal() {
        // Act & Assert
        // Primitives are NOT reference equal in Apex when boxed as Object
        Mock.expect(1).notx.toBe(1);
        Mock.expect('a').toBe('a');
        Mock.expect(true).notx.toBe(true);
        Mock.expect((Object) null).toBe(null);

        Mock.expect(1).notx.toBe(2);

        try {
            Mock.expect(1).toBe(2);
            Assert.fail('Should fail');
        } catch (Mock.MockException e) {
            Assert.isTrue(e.getMessage().contains('Expected reference equality: 2, but was: 1'));
        }

        // toEqual performs value equality
        Mock.expect(1).toEqual(1);
        Mock.expect('a').toEqual('a');
        Mock.expect(true).toEqual(true);
        Mock.expect(1).notx.toEqual(2);
    }

    @IsTest
    static void should_assert_string_contains_matches() {
        // Act & Assert
        Mock.expect('Hello World').toContain('World');
        Mock.expect('Hello World').notx.toContain('Goodbye');
        Mock.expect('Hello World').toMatch('Hello.*');
        Mock.expect('Hello World').notx.toMatch('Good.*');

        try {
            Mock.expect('Hello').toContain('World');
            Assert.fail('Should fail');
        } catch (Mock.MockException e) {
            Assert.isTrue(e.getMessage().contains('to contain: World'));
        }

        try {
            Mock.expect('Hello').toMatch('World');
            Assert.fail('Should fail');
        } catch (Mock.MockException e) {
            Assert.isTrue(e.getMessage().contains('match pattern: World'));
        }
    }

    @IsTest
    static void should_assert_iterable_contains() {
        // Arrange
        List<String> listStr = new List<String>{ 'a', 'b', 'c' };
        Set<Integer> setInt = new Set<Integer>{ 1, 2, 3 };

        // Act & Assert
        Mock.expect(listStr).toContain('a');
        Mock.expect(listStr).notx.toContain('z');

        Mock.expect(setInt).toContain(1);
        Mock.expect(setInt).notx.toContain(9);

        try {
            Mock.expect(listStr).toContain('z');
            Assert.fail('Should fail');
        } catch (Mock.MockException e) {
            Assert.isTrue(e.getMessage().contains('to contain: z'));
        }
    }

    @IsTest
    static void should_assert_booleans_nulls() {
        // Act & Assert
        Mock.expect(true).toBeTrue();
        Mock.expect(false).toBeFalse();
        Mock.expect((Object) null).toBeNull();

        Mock.expect(false).notx.toBeTrue();
        Mock.expect(true).notx.toBeFalse();
        Mock.expect('not null').notx.toBeNull();

        try {
            Mock.expect(false).toBeTrue();
            Assert.fail('Should fail');
        } catch (Mock.MockException e) {
            Assert.isTrue(e.getMessage().contains('Expected true, but was: false'));
        }
    }

    @IsTest
    static void should_clear_and_reset_all_mocks() {
        // Arrange
        IMockTestService mock1 = (IMockTestService) Mock.of(IMockTestService.class);
        IMockTestService mock2 = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.spyOn(mock1, 'getValue').mockReturnValue('MOCK1');
        Mock.spyOn(mock2, 'getValue').mockReturnValue('MOCK2');

        // Act
        mock1.getValue();
        mock2.getValue();

        // Assert
        Mock.expect(mock1).toHaveBeenCalled('getValue');
        Mock.expect(mock2).toHaveBeenCalled('getValue');

        // Act & Assert - Clear All
        Mock.clearAll();
        Mock.expect(mock1).notx.toHaveBeenCalled('getValue');
        Mock.expect(mock2).notx.toHaveBeenCalled('getValue');
        Assert.areEqual('MOCK1', mock1.getValue());
        Assert.areEqual('MOCK2', mock2.getValue());

        // Act & Assert - Reset All
        Mock.resetAll();
        Mock.expect(mock1).notx.toHaveBeenCalled('getValue');
        Mock.expect(mock2).notx.toHaveBeenCalled('getValue');
        Assert.areEqual(null, mock1.getValue());
        Assert.areEqual(null, mock2.getValue());
    }
    @IsTest
    static void should_support_mock_implementation() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.MethodSpy spy = Mock.spyOn(mockService, 'add');
        spy.mockImplementation(new MultiplyByTwo());

        // Act
        Integer result = mockService.add(10, 0); // Second arg ignored by callback

        // Assert
        Assert.areEqual(20, result, 'Should return result from callback');
        Mock.expect(spy).toHaveBeenCalledWith(new List<Object>{ 10, 0 });
    }
    @IsTest
    static void should_match_sobject_containing() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.MethodSpy spy = Mock.spyOn(mockService, 'doWork');
        Account acc = new Account(Name = 'Test Corp', Industry = 'Technology');

        // Act
        mockService.doWork(acc);

        // Assert
        Mock.expect(spy)
            .toHaveBeenCalledWith(new List<Object>{ Mock.sObjectContaining(new Account(Name = 'Test Corp')) });
        Mock.expect(spy)
            .notx.toHaveBeenCalledWith(new List<Object>{ Mock.sObjectContaining(new Account(Name = 'Other Corp')) });
    }

    @IsTest
    static void should_match_custom_object_fields() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.MethodSpy spy = Mock.spyOn(mockService, 'doWork');
        TestDTO dto = new TestDTO('Test', 123);

        // Act
        mockService.doWork(dto);

        // Assert
        Mock.expect(spy)
            .toHaveBeenCalledWith(
                new List<Object>{ Mock.objectContaining(new Map<String, Object>{ 'name' => 'Test', 'value' => 123 }) }
            );

        Mock.expect(spy)
            .toHaveBeenCalledWith(
                new List<Object>{ Mock.objectContaining(new Map<String, Object>{ 'name' => 'Test' }) }
            );

        Mock.expect(spy)
            .notx.toHaveBeenCalledWith(
                new List<Object>{ Mock.objectContaining(new Map<String, Object>{ 'name' => 'Wrong' }) }
            );
    }

    @IsTest
    static void should_mock_http_responses() {
        // Arrange
        Mock.HttpMock http = Mock.mockHttp();
        http.mockResponse('https://api.example.com/data', '{"success":true}', 200);

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.example.com/data');
        req.setMethod('GET');

        // Act
        HttpResponse res = new Http().send(req);

        // Assert
        Assert.areEqual(200, res.getStatusCode());
        Assert.areEqual('{"success":true}', res.getBody());
        Mock.expect(http).toHaveBeenCalledWith('https://api.example.com/data', 'GET');
    }

    @IsTest
    static void should_verify_http_requests() {
        // Arrange
        Mock.HttpMock http = Mock.mockHttp();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.test.com');
        req.setMethod('POST');

        // Act
        new Http().send(req);

        // Assert
        Mock.expect(http).toHaveBeenCalledWith('https://api.test.com', 'POST');
        Mock.expect(http).notx.toHaveBeenCalledWith('https://api.test.com', 'GET');
        Mock.expect(http).notx.toHaveBeenCalledWith('https://other.com', 'POST');

        try {
            Mock.expect(http).toHaveBeenCalledWith('https://missing.com', 'GET');
            Assert.fail('Should fail');
        } catch (Mock.MockException e) {
            Assert.isTrue(
                e.getMessage()
                    .contains('Expected HTTP call to GET https://missing.com, but no matching call was found.')
            );
        }

        try {
            Mock.expect(http).notx.toHaveBeenCalledWith('https://api.test.com', 'POST');
            Assert.fail('Should fail');
        } catch (Mock.MockException e) {
            Assert.isTrue(
                e.getMessage()
                    .contains('Expected HTTP call to POST https://api.test.com NOT to have been made, but it was.')
            );
        }
    }

    @IsTest
    static void should_inspect_mock_name() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class, 'MyNamedMock');

        // Act
        String name = Mock.getMockName(mockService);

        // Assert
        Assert.areEqual('MyNamedMock', name);
        try {
            Mock.expect(mockService).toHaveBeenCalled('getValue');
            Assert.fail('Should fail');
        } catch (Mock.MockException e) {
            Assert.isTrue(e.getMessage().contains('[MyNamedMock]'));
        }
    }

    @IsTest
    static void should_inspect_call_arguments_manually() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.MethodSpy spy = Mock.spyOn(mockService, 'add');

        // Act
        mockService.add(10, 20);
        mockService.add(30, 40);

        // Assert
        List<List<Object>> calls = spy.calls;
        Assert.areEqual(2, calls.size());
        Assert.areEqual(10, calls[0][0]);
        Assert.areEqual(20, calls[0][1]);
        Assert.areEqual(30, calls[1][0]);
        Assert.areEqual(40, calls[1][1]);
    }

    @IsTest
    static void should_match_typed_arguments() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);

        // Act
        mockService.doWork('MyString');
        mockService.add(10, 20);

        // Assert
        Mock.expect(mockService).toHaveBeenCalledWith('doWork', new List<Object>{ Mock.anyString() });
        Mock.expect(mockService).toHaveBeenCalledWith('add', new List<Object>{ Mock.anyInteger(), Mock.anyInteger() });

        try {
            Mock.expect(mockService).toHaveBeenCalledWith('doWork', new List<Object>{ Mock.anyInteger() });
            Assert.fail('Should fail');
        } catch (Mock.MockException e) {
            Assert.isTrue(e.getMessage().contains('matching arguments, but no matching call was found'));
        }

        // Matchers direct check
        Assert.isTrue(((Mock.Matcher) Mock.anyId()).matches(UserInfo.getUserId()));
        Assert.isTrue(((Mock.Matcher) Mock.anyDecimal()).matches(10.5));
        Assert.isTrue(((Mock.Matcher) Mock.anyBoolean()).matches(true));
        Assert.isFalse(((Mock.Matcher) Mock.anyBoolean()).matches('true'));
        Assert.isTrue(((Mock.Matcher) Mock.anyList()).matches(new List<String>()));
        Assert.isTrue(((Mock.Matcher) Mock.anyMap()).matches(new Map<String, Object>()));
        Assert.isTrue(((Mock.Matcher) Mock.anyDate()).matches(Date.today()));
        Assert.isTrue(((Mock.Matcher) Mock.anyDatetime()).matches(Datetime.now()));
        Assert.isTrue(((Mock.Matcher) Mock.anySObject()).matches(new Account()));
        Assert.isTrue(((Mock.Matcher) Mock.anyTime()).matches(Time.newInstance(1, 0, 0, 0)));
    }

    @IsTest
    static void should_assert_exceptions() {
        // Act & Assert
        Mock.expect(new TestBlock(true)).toThrow();
        Mock.expect(new TestBlock(true)).toThrow('Test error');
        Mock.expect(new TestBlock(true)).toThrow(IllegalArgumentException.class);

        try {
            Mock.expect(new TestBlock(false)).toThrow();
            Assert.fail('Should fail');
        } catch (Mock.MockException e) {
            Assert.isTrue(e.getMessage().contains('Expected block to throw an exception'));
        }

        try {
            Mock.expect(new TestBlock(true)).toThrow('Wrong message');
            Assert.fail('Should fail');
        } catch (Mock.MockException e) {
            Assert.isTrue(e.getMessage().contains('Expected exception message to contain "Wrong message"'));
        }

        try {
            Mock.expect(new TestBlock(true)).toThrow(NullPointerException.class);
            Assert.fail('Should fail');
        } catch (Mock.MockException e) {
            Assert.isTrue(e.getMessage().contains('Expected exception of type System.NullPointerException'));
        }
    }

    @IsTest
    static void should_support_nested_matchers() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);

        // Act & Assert - Nested in arguments
        mockService.doWork('Test');
        Mock.expect(mockService).toHaveBeenCalledWith('doWork', new List<Object>{ Mock.stringContaining('es') });

        // Act & Assert - Nested in objectContaining
        mockService.updateDTO(new TestDTO('MyName', 10));
        Mock.expect(mockService)
            .toHaveBeenCalledWith(
                'updateDTO',
                new List<Object>{
                    Mock.objectContaining(
                        new Map<String, Object>{ 'name' => Mock.stringContaining('My'), 'value' => Mock.anyInteger() }
                    )
                }
            );
    }

    @IsTest
    static void should_support_overload_specific_spy_configuration() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.MethodSpy stringSpy = Mock.spyOn(mockService, 'doWork', new List<Type>{ String.class });
        stringSpy.mockThrow(new IllegalArgumentException('String overload only'));
        Mock.MethodSpy objectSpy = Mock.spyOn(mockService, 'doWork', new List<Type>{ Object.class });

        // Act
        Boolean stringOverloadThrew = false;
        try {
            mockService.doWork('hello');
        } catch (IllegalArgumentException e) {
            stringOverloadThrew = true;
        }

        Boolean objectOverloadThrew = false;
        try {
            mockService.doWork((Object) new Account(Name = 'Overload Check'));
        } catch (IllegalArgumentException e) {
            objectOverloadThrew = true;
        }

        // Assert
        Assert.isTrue(stringOverloadThrew, 'Expected configured String overload to throw.');
        Assert.isFalse(objectOverloadThrew, 'Expected Object overload not to use String-overload behavior.');
        Mock.expect(stringSpy).toHaveBeenCalledTimes(1);
        Mock.expect(objectSpy).toHaveBeenCalledTimes(1);
    }

    @IsTest
    static void should_verify_http_calls_advanced() {
        // Arrange
        Mock.HttpMock http = Mock.mockHttp();
        http.mockResponse('https://api.com', 'ok', 200);

        // Act
        new Http().send(new HttpRequest()); // Default endpoint check

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.com');
        req.setMethod('GET');
        new Http().send(req);
        new Http().send(req);

        // Assert
        Mock.expect(http).toHaveBeenCalled();
        Mock.expect(http).toHaveBeenCalledTimes(3);
        Mock.expect(http).toHaveBeenCalledWith('https://api.com', 'GET');
        Mock.expect(http).notx.toHaveBeenCalledWith('https://other.com', 'GET');
    }

    @IsTest
    static void should_identify_mock_in_all_errors() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class, 'NamedMock');

        // Act & Assert
        try {
            Mock.expect(mockService).toHaveBeenCalled('doWork');
            Assert.fail('Should fail');
        } catch (Mock.MockException e) {
            Assert.isTrue(e.getMessage().contains('[NamedMock]'));
        }

        try {
            Mock.expect(mockService).toHaveBeenCalledTimes('doWork', 1);
            Assert.fail('Should fail');
        } catch (Mock.MockException e) {
            Assert.isTrue(e.getMessage().contains('[NamedMock]'));
        }
    }

    @IsTest
    static void should_support_multi_method_http() {
        // Arrange
        Mock.HttpMock http = Mock.mockHttp();
        http.mockResponse('GET', 'https://api.com/users', '{"users": []}', 200);
        http.mockResponse('POST', 'https://api.com/users', '{"status": "created"}', 201);
        http.mockResponse('https://api.com/fallback', 'generic', 200);

        // Act & Assert GET
        HttpRequest getReq = new HttpRequest();
        getReq.setEndpoint('https://api.com/users');
        getReq.setMethod('GET');
        HttpResponse getRes = new Http().send(getReq);
        Assert.areEqual(200, getRes.getStatusCode());
        Assert.areEqual('{"users": []}', getRes.getBody());

        // Act & Assert POST
        HttpRequest postReq = new HttpRequest();
        postReq.setEndpoint('https://api.com/users');
        postReq.setMethod('POST');
        HttpResponse postRes = new Http().send(postReq);
        Assert.areEqual(201, postRes.getStatusCode());
        Assert.areEqual('{"status": "created"}', postRes.getBody());

        // Act & Assert Fallback
        HttpRequest fallbackReq = new HttpRequest();
        fallbackReq.setEndpoint('https://api.com/fallback');
        fallbackReq.setMethod('PUT');
        HttpResponse fallbackRes = new Http().send(fallbackReq);
        Assert.areEqual(200, fallbackRes.getStatusCode());
        Assert.areEqual('generic', fallbackRes.getBody());
    }

    @IsTest
    static void should_match_sobject_using_field_map() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);
        Account acc = new Account(Name = 'Acme Corp', NumberOfEmployees = 100);

        // Act
        mockService.updateSObject(acc);

        // Assert
        Mock.expect(mockService)
            .toHaveBeenCalledWith(
                'updateSObject',
                new List<Object>{
                    Mock.sObjectContaining(
                        new Map<SObjectField, Object>{
                            Account.Name => Mock.stringContaining('Acme'),
                            Account.NumberOfEmployees => Mock.anyInteger()
                        }
                    )
                }
            );
    }

    @IsTest
    static void should_validate_matcher_assertions() {
        // Arrange
        Map<String, Object> data = new Map<String, Object>{ 'Name' => 'Test', 'Value' => 100 };
        List<Object> listData = new List<Object>{ data, 'simple' };

        // Assert - toMatch(Matcher)
        Mock.expect(data).toMatch(Mock.objectContaining(new Map<String, Object>{ 'Name' => 'Test' }));
        Mock.expect(data).notx.toMatch(Mock.objectContaining(new Map<String, Object>{ 'Name' => 'Other' }));

        // Assert - toContain(Matcher)
        Mock.expect(listData).toContain(Mock.objectContaining(new Map<String, Object>{ 'Value' => 100 }));
        Mock.expect(listData).notx.toContain(Mock.stringContaining('missing'));
    }

    @IsTest
    static void should_validate_matcher_sobject_assertions() {
        // Arrange
        Account data = new Account(Name = 'Test', NumberOfEmployees = 100);
        List<Object> listData = new List<Object>{ data, 'simple' };

        // Assert - toMatch(Matcher)
        Mock.expect(data)
            .toMatch(
                Mock.sObjectContaining(
                    new Map<SObjectField, Object>{ Account.Name => 'Test', Account.NumberOfEmployees => 100 }
                )
            );
        Mock.expect(data).toMatch(Mock.sObjectContaining(new Account(NumberOfEmployees = 100)));
        Mock.expect(data)
            .notx.toMatch(Mock.sObjectContaining(new Map<SObjectField, Object>{ Account.Name => 'Other' }));
        Mock.expect(data).notx.toMatch(Mock.sObjectContaining(new Account(Name = 'Other')));

        // Assert - toContain(Matcher)
        Mock.expect(listData)
            .toContain(Mock.sObjectContaining(new Map<SObjectField, Object>{ Account.NumberOfEmployees => 100 }));
        Mock.expect(listData).notx.toContain(Mock.stringContaining('missing'));
    }

    @IsTest
    static void should_generate_fake_ids() {
        // Act
        Id accountId1 = Mock.fakeId(Account.SObjectType);
        Id accountId2 = Mock.fakeId(Account.SObjectType);
        Id contactId = Mock.fakeId(Contact.SObjectType);

        // Assert
        Assert.areNotEqual(null, accountId1);
        Assert.areNotEqual(null, accountId2);
        Assert.areNotEqual(accountId1, accountId2, 'IDs should be unique');
        Assert.areEqual('001', String.valueOf(accountId1).substring(0, 3), 'Should have Account prefix');
        Assert.areEqual('003', String.valueOf(contactId).substring(0, 3), 'Should have Contact prefix');
        Assert.areEqual(18, String.valueOf(accountId1).length(), 'Should be an 18-character ID');
    }

    @IsTest
    static void should_generate_multiple_fake_ids() {
        // Act
        List<Id> accountIds = Mock.fakeIds(Account.SObjectType, 3);

        // Assert
        Assert.areEqual(3, accountIds.size());
        Assert.areNotEqual(accountIds[0], accountIds[1]);
        Assert.areNotEqual(accountIds[1], accountIds[2]);
        for (Id accId : accountIds) {
            Assert.areEqual('001', String.valueOf(accId).substring(0, 3));
        }
    }

    @IsTest
    static void should_differentiate_to_be_and_to_equal() {
        // Arrange
        Account acc1 = new Account(Name = 'Test');
        Account acc2 = new Account(Name = 'Test');
        Account accRef = acc1;

        // Assert - toEqual (Value Equality)
        Mock.expect(acc1).toEqual(acc2);
        Mock.expect(acc1).notx.toEqual(new Account(Name = 'Other'));

        // Assert - toBe (Reference Equality)
        Mock.expect(acc1).toBe(accRef);
        Mock.expect(acc1).notx.toBe(acc2); // Same values, different references
    }

    @IsTest
    static void should_support_advanced_matchers() {
        // Arrange
        Account acc = new Account(Name = 'Test');
        TestDTO dto = new TestDTO('Test', 100);

        // Assert - any(Type)
        Mock.expect(dto).toMatch(Mock.any(TestDTO.class));
        Mock.expect(dto).notx.toMatch(Mock.any(Account.class));

        // Assert - anySObject(type)
        Mock.expect(acc).toMatch(Mock.anySObject(Account.SObjectType));
        Mock.expect(acc).notx.toMatch(Mock.anySObject(Contact.SObjectType));

        // Assert - notx(Matcher)
        Mock.expect('Success').toMatch(Mock.notx(Mock.stringContaining('Failure')));
        Mock.expect(100).toMatch(Mock.notx(Mock.anyString()));
    }

    @IsTest
    static void should_verify_advanced_http() {
        // Arrange
        Mock.HttpMock http = Mock.mockHttp();
        http.mockResponse('POST', 'https://api.com/v1', '{"status":"ok"}', 200);

        // Act
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.com/v1');
        req.setMethod('POST');
        req.setBody('{"name":"test"}');
        req.setHeader('Content-Type', 'application/json');
        new Http().send(req);

        // Assert
        Mock.expect(http)
            .toHaveBeenCalledWith(
                Mock.stringContaining('api.com'),
                'POST',
                Mock.stringContaining('test'),
                new Map<String, Object>{ 'Content-Type' => 'application/json' }
            );

        // Negation
        Mock.expect(http)
            .notx.toHaveBeenCalledWith(
                'https://api.com/v1',
                'POST',
                '{"name":"wrong"}',
                new Map<String, Object>{ 'Content-Type' => 'text/plain' }
            );
    }

    @IsTest
    static void should_match_iterable_containing_with_matcher() {
        // Arrange
        List<String> items = new List<String>{ 'Alpha', 'Beta', 'Gamma' };

        // Act & Assert
        Assert.isTrue(Mock.iterableContaining('Alpha').matches(items));
        Assert.isTrue(Mock.iterableContaining(Mock.stringContaining('Bet')).matches(items));
        Assert.isFalse(Mock.iterableContaining('Delta').matches(items));
    }

    @IsTest
    static void should_assert_numeric_comparisons() {
        // Act & Assert
        Mock.expect(10).toBeLessThan(20);
        Mock.expect(20).toBeGreaterThan(10);
        Mock.expect(10).notx.toBeLessThan(5);
        Mock.expect(5).notx.toBeGreaterThan(10);

        try {
            Mock.expect(20).toBeLessThan(10);
            Assert.fail('Should fail');
        } catch (Mock.MockException e) {
            Assert.isTrue(e.getMessage().contains('to be less than 10'));
        }

        try {
            Mock.expect(5).toBeGreaterThan(10);
            Assert.fail('Should fail');
        } catch (Mock.MockException e) {
            Assert.isTrue(e.getMessage().contains('to be greater than 10'));
        }
    }

    @IsTest
    static void should_mock_http_response_with_object() {
        // Arrange
        Mock.HttpMock http = Mock.mockHttp();
        HttpResponse res = new HttpResponse();
        res.setBody('{"custom": "response"}');
        res.setStatusCode(201);

        http.mockResponse('https://api.custom.com', res);

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.custom.com');
        req.setMethod('GET');

        // Act
        HttpResponse actual = new Http().send(req);

        // Assert
        Assert.areEqual(201, actual.getStatusCode());
        Assert.areEqual('{"custom": "response"}', actual.getBody());
    }

    @IsTest
    static void should_mock_http_response_with_method_and_object() {
        // Arrange
        Mock.HttpMock http = Mock.mockHttp();
        HttpResponse res = new HttpResponse();
        res.setBody('done');

        http.mockResponse('PATCH', 'https://api.custom.com/id', res);

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.custom.com/id');
        req.setMethod('PATCH');

        // Act
        HttpResponse actual = new Http().send(req);

        // Assert
        Assert.areEqual('done', actual.getBody());
        Mock.expect(http).toHaveBeenCalledWith('https://api.custom.com/id', 'PATCH');
    }

    @IsTest
    static void should_clear_http_mock() {
        // Arrange
        Mock.HttpMock http = Mock.mockHttp();
        http.mockResponse('https://api.com', 'ok', 200);
        new Http().send(new HttpRequest()); // records a call

        // Act
        http.clear();

        // Assert
        Mock.expect(http).notx.toHaveBeenCalled();
        // Since clear() only clears call history (not responses), sending again should still work
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.com');
        req.setMethod('GET');
        HttpResponse res = new Http().send(req);
        Assert.areEqual(200, res.getStatusCode(), 'Response config should be preserved');
        Assert.areEqual('ok', res.getBody());
    }

    @IsTest
    static void should_reset_http_mock() {
        // Arrange
        Mock.HttpMock http = Mock.mockHttp();
        http.mockResponse('https://api.com', 'ok', 200);
        new Http().send(new HttpRequest()); // records a call

        // Act
        http.reset();

        // Assert
        Mock.expect(http).notx.toHaveBeenCalled();
        // Since reset clears responses too, sending again should return null (default Stub behavior if not found)
        // Actually HttpMock.respond returns null if no response matched.
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.com');
        HttpResponse res = new Http().send(req);
        Assert.areEqual(404, res.getStatusCode(), 'Config should be cleared (StatusCode)');
        Assert.areEqual('Not Found', res.getStatus(), 'Config should be cleared (Status)');
    }

    @IsTest
    static void should_verify_http_call_with_body() {
        // Arrange
        Mock.HttpMock http = Mock.mockHttp();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.com/v1');
        req.setMethod('POST');
        req.setBody('data');

        // Act
        new Http().send(req);

        // Assert
        Mock.expect(http).toHaveBeenCalledWith('https://api.com/v1', 'POST', 'data');
        Mock.expect(http).notx.toHaveBeenCalledWith('https://api.com/v1', 'POST', 'wrong');
    }

    public class MultiplyByTwo implements Mock.Callback {
        public Object call(List<Object> args) {
            Integer input = (Integer) args[0];
            return input * 2;
        }
    }

    public class TestDTO {
        public String name;
        public Integer value;
        public TestDTO(String name, Integer value) {
            this.name = name;
            this.value = value;
        }
    }

    private class TestBlock implements Mock.Block {
        private final Boolean shouldThrow;
        public TestBlock(Boolean shouldThrow) {
            this.shouldThrow = shouldThrow;
        }
        public void run() {
            if (shouldThrow) {
                throw new IllegalArgumentException('Test error');
            }
        }
    }
}
