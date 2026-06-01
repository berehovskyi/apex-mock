@SuppressWarnings('PMD.ApexDoc, PMD.ApexUnitTestClassShouldHaveAsserts')
@IsTest(IsParallel=true)
private class MockTest {
    // Basic Stubbing Tests
    @IsTest
    static void should_return_configured_value() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.spyOn(mockService, 'getValue').mockReturnValue('Success');
        Mock.spyOn(mockService, 'add').mockReturnValue(10);

        // Act
        Object result = mockService.getValue();
        Integer firstAddResult = mockService.add(1, 2);
        Integer secondAddResult = mockService.add(5, 5);

        // Assert
        Assert.areEqual('Success', result, 'Should return configured value');
        Assert.areEqual(10, firstAddResult, 'Should return configured value ignoring args');
        Assert.areEqual(10, secondAddResult, 'Should return configured value regardless of args');
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

        // Act
        Object actual1 = mockService.getValue();
        Object actual2 = mockService.getValue();
        Object actual3 = mockService.getValue();
        Object actual4 = mockService.getValue();

        // Assert
        Assert.areEqual('First', actual1, 'First call should return first value');
        Assert.areEqual('Second', actual2, 'Second call should return second value');
        Assert.areEqual('Default', actual3, 'Third call should return default value');
        Assert.areEqual('Default', actual4, 'Fourth call should still return default');
    }

    @IsTest
    static void should_return_null_after_exhausting_once_values() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.spyOn(mockService, 'getValue').mockReturnValueOnce('Only');

        // Act
        Object actual1 = mockService.getValue();
        Object actual2 = mockService.getValue();

        // Assert
        Assert.areEqual('Only', actual1, 'First call should return the once value');
        Assert.areEqual(null, actual2, 'Second call should return null');
    }

    @IsTest
    static void should_support_argument_scoped_return_stubbing() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.MethodSpy addSpy = Mock.spyOn(mockService, 'add');
        addSpy.mockReturnValue(999);
        addSpy.whenCalledWith(new List<Object>{ 1, 2 }).mockReturnValue(3);

        // Act
        Object actual1 = mockService.add(1, 2);
        Object actual2 = mockService.add(5, 5);

        // Assert
        Assert.areEqual(3, actual1, 'Expected argument-scoped stubbing to win over default stub.');
        Assert.areEqual(999, actual2, 'Expected default method stub for non-matching arguments.');
    }

    @IsTest
    static void should_support_argument_scoped_matcher_stubbing() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.spyOn(mockService, 'add')
            .whenCalledWith(new List<Object>{ Mock.anyInteger(), 0 })
            .mockThrow(new IllegalArgumentException('Second arg cannot be zero'));

        // Act & Assert
        Boolean threw = false;
        try {
            mockService.add(7, 0);
        } catch (IllegalArgumentException e) {
            threw = true;
            Assert.isTrue(e.getMessage().contains('cannot be zero'));
        }
        Assert.isTrue(threw, 'Expected matcher-based argument scope to throw for matching args.');
        Assert.areEqual(null, mockService.add(7, 1), 'Expected non-matching args to use default behavior.');
    }

    @IsTest
    static void should_support_argument_scoped_mock_implementation_once() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.spyOn(mockService, 'add')
            .whenCalledWith(new List<Object>{ 10, 20 })
            .mockImplementationOnce(new AddWithOffset(5))
            .mockReturnValue(31);

        // Act
        Object actual1 = mockService.add(10, 20);
        Object actual2 = mockService.add(10, 20);
        Object actual3 = mockService.add(10, 20);

        // Assert
        Assert.areEqual(35, actual1, 'Expected one-time implementation to run first.');
        Assert.areEqual(31, actual2, 'Expected scoped default value after once callback is consumed.');
        Assert.areEqual(31, actual3, 'Expected scoped default to remain active.');
    }

    @IsTest
    static void should_support_argument_scoped_stubbing_with_signature_spy() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.spyOn(mockService, 'doWork', new List<Type>{ String.class })
            .whenCalledWith(new List<Object>{ 'boom' })
            .mockThrow(new IllegalArgumentException('String overload scoped throw'));

        // Act & Assert
        Boolean stringOverloadThrew = false;
        try {
            mockService.doWork('boom');
        } catch (IllegalArgumentException e) {
            stringOverloadThrew = true;
        }

        Boolean objectOverloadThrew = false;
        try {
            mockService.doWork((Object) 'boom');
        } catch (IllegalArgumentException e) {
            objectOverloadThrew = true;
        }

        Assert.isTrue(stringOverloadThrew, 'Expected argument-scoped behavior on String overload.');
        Assert.isFalse(objectOverloadThrew, 'Expected Object overload not to use String-overload scoped behavior.');
    }

    @IsTest
    static void should_support_argument_scoped_return_value_once() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.MethodSpy addSpy = Mock.spyOn(mockService, 'add');
        addSpy.mockReturnValue(999);
        addSpy.whenCalledWith(new List<Object>{ 2, 2 }).mockReturnValueOnce(4).mockReturnValue(22);

        // Act
        Object actual1 = mockService.add(2, 2);
        Object actual2 = mockService.add(2, 2);
        Object actual3 = mockService.add(5, 5);

        // Assert
        Assert.areEqual(4, actual1, 'Expected scoped once value on first matching call.');
        Assert.areEqual(22, actual2, 'Expected scoped default value after once value is consumed.');
        Assert.areEqual(999, actual3, 'Expected method-level fallback for non-matching arguments.');
    }

    @IsTest
    static void should_support_argument_scoped_throw_once() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.spyOn(mockService, 'add')
            .whenCalledWith(new List<Object>{ 3, 0 })
            .mockThrowOnce(new IllegalArgumentException('Throw only once'))
            .mockReturnValue(30);

        // Act & Assert
        Boolean threw = false;
        try {
            mockService.add(3, 0);
        } catch (IllegalArgumentException e) {
            threw = true;
            Assert.isTrue(e.getMessage().contains('only once'));
        }
        Assert.isTrue(threw, 'Expected scoped throw-once behavior on first matching call.');
        Assert.areEqual(30, mockService.add(3, 0), 'Expected scoped fallback value after throw-once is consumed.');
    }

    @IsTest
    static void should_support_argument_scoped_persistent_callback() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.spyOn(mockService, 'add')
            .whenCalledWith(new List<Object>{ 4, 4 })
            .mockImplementation(new AddWithOffset(1));

        // Act
        Object actual1 = mockService.add(4, 4);
        Object actual2 = mockService.add(4, 4);

        // Assert
        Assert.areEqual(9, actual1, 'Expected scoped callback result on first match.');
        Assert.areEqual(9, actual2, 'Expected scoped callback to stay active.');
    }

    @IsTest
    static void should_handle_null_and_mismatched_argument_shapes_in_scoped_matching() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.MethodSpy getValueSpy = Mock.spyOn(mockService, 'getValue');
        getValueSpy.whenCalledWith(null).mockReturnValue('NULL_ARGS');
        getValueSpy.whenCalledWith(new List<Object>()).mockReturnValue('EMPTY_ARGS');

        Mock.MethodSpy addSpy = Mock.spyOn(mockService, 'add');
        addSpy.mockReturnValue(77);
        addSpy.whenCalledWith(null).mockReturnValue(11);
        addSpy.whenCalledWith(new List<Object>{ 1 }).mockReturnValue(12);

        // Act
        String noArgResult = mockService.getValue();
        Integer addResult = mockService.add(1, 1);

        // Assert
        Assert.isTrue(
            noArgResult == 'NULL_ARGS' || noArgResult == 'EMPTY_ARGS',
            'No-arg calls should match one supported argument shape.'
        );
        Assert.areEqual(
            77,
            addResult,
            'Null or different-size scoped argument patterns should not match two-arg method calls.'
        );
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

        // Assert
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

        // Act
        Boolean matches = matcher.matches(actual);

        // Assert
        Assert.isTrue(matches, 'Should match map containing the key');
    }

    @IsTest
    static void should_not_match_when_field_missing() {
        // Arrange
        Mock.Matcher matcher = Mock.objectContaining(new Map<String, Object>{ 'MissingField' => 'value' });
        Account acc = new Account(Name = 'Test');

        // Act
        Boolean matches = matcher.matches(acc);

        // Assert
        Assert.isFalse(matches, 'Should not match when field is missing or different');
    }

    // Chaining Tests
    @IsTest
    static void should_support_chained_expectations() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);

        // Act
        mockService.getValue();
        mockService.add(1, 2);

        // Assert
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

        // Assert
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

        // Assert
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

        // Act & Assert
        Mock.expect(spy).notx.toHaveBeenCalled();

        mockService.getValue();

        Mock.expect(spy).notx.toHaveBeenCalledTimes(2);

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

        // Act
        mockService.add(1, 1);
        mockService.add(2, 2);

        // Assert
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

        // Assert
        Mock.expect(spy).toHaveBeenCalledTimes(1);

        Mock.clear(mockService);
        Mock.expect(spy).notx.toHaveBeenCalled(); // History cleared
        Assert.areEqual('A', mockService.getValue()); // Config preserved

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
    static void should_support_matchers_in_string_to_contain() {
        // Act & Assert
        Mock.expect('Hello World').toContain(Mock.stringContaining('World'));
        Mock.expect('Hello World').notx.toContain(Mock.stringContaining('xyz'));

        try {
            Mock.expect('Hello World').toContain(Mock.stringContaining('xyz'));
            Assert.fail('Should fail when matcher does not match the string');
        } catch (Mock.MockException e) {
            Assert.isTrue(e.getMessage().contains('to contain'));
        }

        try {
            Mock.expect('Hello World').toContain(5);
            Assert.fail('Should reject a non-String, non-Matcher item for a String actual');
        } catch (Mock.MockException e) {
            Assert.isTrue(e.getMessage().contains('String or Matcher item'));
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

        Mock.clearAll();
        Mock.expect(mock1).notx.toHaveBeenCalled('getValue');
        Mock.expect(mock2).notx.toHaveBeenCalled('getValue');
        Assert.areEqual('MOCK1', mock1.getValue());
        Assert.areEqual('MOCK2', mock2.getValue());

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
        Assert.isTrue(((Mock.Matcher) Mock.any(Time.class)).matches(Time.newInstance(1, 0, 0, 0)));
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

        // Act
        mockService.doWork('Test');

        // Assert
        Mock.expect(mockService).toHaveBeenCalledWith('doWork', new List<Object>{ Mock.stringContaining('es') });

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
    static void should_verify_return_outcome_assertions() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.MethodSpy spy = Mock.spyOn(mockService, 'add');
        spy.mockImplementation(new ReturnOrThrowByFirstArg());

        // Act & Assert
        Assert.areEqual(3, mockService.add(1, 2), 'First call should return from callback');
        try {
            mockService.add(-1, 5);
            Assert.fail('Second call should throw from callback');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('Sentinel throw'));
        }
        Assert.areEqual(9, mockService.add(4, 5), 'Third call should return from callback');

        Mock.expect(spy).toHaveReturned();
        Mock.expect(spy).toHaveReturnedTimes(2);
        Mock.expect(spy).toHaveReturnedWith(3);
        Mock.expect(spy).toHaveNthReturnedWith(1, 3);
        Mock.expect(spy).toHaveNthReturnedWith(3, 9);
        Mock.expect(spy).notx.toHaveReturnedWith(100);

        Mock.expect(mockService).toHaveReturned('add');
        Mock.expect(mockService).toHaveReturnedTimes('add', 2);
        Mock.expect(mockService).toHaveReturnedWith('add', 9);
        Mock.expect(mockService).toHaveNthReturnedWith('add', 1, 3);
    }

    @IsTest
    static void should_fail_to_have_nth_returned_with_when_nth_call_throws() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.MethodSpy spy = Mock.spyOn(mockService, 'add');
        spy.mockImplementation(new ReturnOrThrowByFirstArg());

        // Act
        mockService.add(1, 2);

        // Assert
        try {
            mockService.add(-1, 0);
            Assert.fail('Expected callback to throw on sentinel input');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('Sentinel throw'));
        }

        try {
            Mock.expect(spy).toHaveNthReturnedWith(2, 0);
            Assert.fail('Should fail because the second call threw');
        } catch (Mock.MockException e) {
            Assert.isTrue(e.getMessage().contains('but it threw.'));
        }
    }

    @IsTest
    static void should_treat_void_calls_as_successful_null_returns() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.MethodSpy stringSpy = Mock.spyOn(mockService, 'doWork', new List<Type>{ String.class });

        // Act
        mockService.doWork('noop');

        // Assert
        Mock.expect(stringSpy).toHaveReturned();
        Mock.expect(stringSpy).toHaveReturnedTimes(1);
        Mock.expect(stringSpy).toHaveReturnedWith(null);
        Mock.expect(stringSpy).toHaveNthReturnedWith(1, null);
        Mock.expect(stringSpy).notx.toHaveNthReturnedWith(1, 'unexpected');
    }

    @IsTest
    static void should_verify_last_returned_with() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.MethodSpy spy = Mock.spyOn(mockService, 'add');
        spy.mockImplementation(new ReturnOrThrowByFirstArg());

        // Act
        mockService.add(1, 2); // 3
        mockService.add(2, 3); // 5

        // Assert
        Mock.expect(spy).toHaveLastReturnedWith(5);
        Mock.expect(spy).notx.toHaveLastReturnedWith(3);
        Mock.expect(mockService).toHaveLastReturnedWith('add', 5);
    }

    @IsTest
    static void should_fail_last_returned_with_when_last_call_throws() {
        // Arrange
        IMockTestService mockService = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.MethodSpy spy = Mock.spyOn(mockService, 'add');
        spy.mockImplementation(new ReturnOrThrowByFirstArg());

        // Act
        mockService.add(1, 2);

        // Assert
        try {
            mockService.add(-1, 0);
            Assert.fail('Expected callback to throw on sentinel input');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('Sentinel throw'));
        }

        try {
            Mock.expect(spy).toHaveLastReturnedWith(0);
            Assert.fail('Should fail because the last call threw');
        } catch (Mock.MockException e) {
            Assert.isTrue(e.getMessage().contains('but it threw.'));
        }
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

        HttpRequest getReq = new HttpRequest();
        getReq.setEndpoint('https://api.com/users');
        getReq.setMethod('GET');

        // Act
        HttpResponse getRes = new Http().send(getReq);

        // Assert
        Assert.areEqual(200, getRes.getStatusCode());
        Assert.areEqual('{"users": []}', getRes.getBody());

        HttpRequest postReq = new HttpRequest();
        postReq.setEndpoint('https://api.com/users');
        postReq.setMethod('POST');
        HttpResponse postRes = new Http().send(postReq);
        Assert.areEqual(201, postRes.getStatusCode());
        Assert.areEqual('{"status": "created"}', postRes.getBody());

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

        // Act & Assert
        Mock.expect(data).toMatch(Mock.objectContaining(new Map<String, Object>{ 'Name' => 'Test' }));
        Mock.expect(data).notx.toMatch(Mock.objectContaining(new Map<String, Object>{ 'Name' => 'Other' }));

        Mock.expect(listData).toContain(Mock.objectContaining(new Map<String, Object>{ 'Value' => 100 }));
        Mock.expect(listData).notx.toContain(Mock.stringContaining('missing'));
    }

    @IsTest
    static void should_validate_matcher_sobject_assertions() {
        // Arrange
        Account data = new Account(Name = 'Test', NumberOfEmployees = 100);
        List<Object> listData = new List<Object>{ data, 'simple' };

        // Act & Assert
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

        Mock.expect(listData)
            .toContain(Mock.sObjectContaining(new Map<SObjectField, Object>{ Account.NumberOfEmployees => 100 }));
        Mock.expect(listData).notx.toContain(Mock.stringContaining('missing'));
    }

    @IsTest
    static void should_generate_fake_ids() {
        // Arrange
        Id accountId1 = Mock.fakeId(Account.SObjectType);
        Id accountId2 = Mock.fakeId(Account.SObjectType);
        Id contactId = Mock.fakeId(Contact.SObjectType);

        // Act & Assert
        Assert.areNotEqual(null, accountId1);
        Assert.areNotEqual(null, accountId2);
        Assert.areNotEqual(accountId1, accountId2, 'IDs should be unique');
        Assert.areEqual('001', String.valueOf(accountId1).substring(0, 3), 'Should have Account prefix');
        Assert.areEqual('003', String.valueOf(contactId).substring(0, 3), 'Should have Contact prefix');
        Assert.areEqual(18, String.valueOf(accountId1).length(), 'Should be an 18-character ID');
    }

    @IsTest
    static void should_generate_multiple_fake_ids() {
        // Arrange
        List<Id> accountIds = Mock.fakeIds(Account.SObjectType, 3);

        // Act & Assert
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

        // Act & Assert
        Mock.expect(acc1).toEqual(acc2);
        Mock.expect(acc1).notx.toEqual(new Account(Name = 'Other'));

        Mock.expect(acc1).toBe(accRef);
        Mock.expect(acc1).notx.toBe(acc2); // Same values, different references
    }

    @IsTest
    static void should_support_advanced_matchers() {
        // Arrange
        Account acc = new Account(Name = 'Test');
        TestDTO dto = new TestDTO('Test', 100);

        // Act & Assert
        Mock.expect(dto).toMatch(Mock.any(TestDTO.class));
        Mock.expect(dto).notx.toMatch(Mock.any(Account.class));

        Mock.expect(acc).toMatch(Mock.anySObject(Account.SObjectType));
        Mock.expect(acc).notx.toMatch(Mock.anySObject(Contact.SObjectType));

        Mock.expect('Success').toMatch(Mock.notx(Mock.stringContaining('Failure')));
        Mock.expect(100).toMatch(Mock.notx(Mock.anyString()));
    }

    @IsTest
    static void should_verify_advanced_http() {
        // Arrange
        Mock.HttpMock http = Mock.mockHttp();
        http.mockResponse('POST', 'https://api.com/v1', '{"status":"ok"}', 200);

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.com/v1');
        req.setMethod('POST');
        req.setBody('{"name":"test"}');
        req.setHeader('Content-Type', 'application/json');

        // Act
        new Http().send(req);

        // Assert
        Mock.expect(http)
            .toHaveBeenCalledWith(
                Mock.stringContaining('api.com'),
                'POST',
                Mock.stringContaining('test'),
                new Map<String, Object>{ 'Content-Type' => 'application/json' }
            );

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

    @IsTest
    static void should_verify_default_get_method_when_request_method_is_not_set() {
        // Arrange
        Mock.HttpMock http = Mock.mockHttp();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.example.com/users');
        // intentionally no setMethod(...)

        // Act
        http.respond(req);

        // Assert
        Mock.expect(http).toHaveBeenCalledWith('https://api.example.com/users', 'GET');
    }

    @IsTest
    static void should_verify_http_method_case_insensitively() {
        // Arrange
        Mock.HttpMock http = Mock.mockHttp();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.example.com/users');
        req.setMethod('post');

        // Act
        http.respond(req);

        // Assert
        Mock.expect(http).toHaveBeenCalledWith('https://api.example.com/users', 'POST');
    }

    @IsTest
    static void should_cover_signature_keyed_provider_paths() {
        // Arrange
        IMockTestService callbackMock = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.spyOn(callbackMock, 'add', new List<Type>{ Integer.class, Integer.class })
            .mockImplementation(new AddWithOffset(1));
        // Act & Assert
        Assert.areEqual(6, callbackMock.add(2, 3), 'Expected method-key callback branch to execute.');

        IMockTestService onceMock = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.spyOn(onceMock, 'add', new List<Type>{ Integer.class, Integer.class }).mockReturnValueOnce(42);
        Assert.areEqual(42, onceMock.add(8, 9), 'Expected method-key one-time return branch to execute.');

        IMockTestService valueMock = (IMockTestService) Mock.of(IMockTestService.class);
        Mock.MethodSpy addSigSpy = Mock.spyOn(valueMock, 'add', new List<Type>{ Integer.class, Integer.class });
        addSigSpy.mockReturnValue(99);
        Assert.areEqual(99, valueMock.add(1, 1), 'Expected method-key persistent return branch to execute.');
        List<List<Object>> signatureCalls = addSigSpy.calls;
        Assert.areEqual(1, signatureCalls.size(), 'Expected signature spy to read call history by method key.');
        Assert.areEqual(2, signatureCalls[0].size(), 'Expected captured argument list for signature spy.');
    }

    @IsTest
    static void should_cover_edge_branches_in_expectations_and_matchers() {
        // Act & Assert
        try {
            Mock.expect(123).toContain('x');
            Assert.fail('Expected toContain() to reject non-iterable, non-string actual values.');
        } catch (Mock.MockException e) {
            Assert.isTrue(e.getMessage().contains('Iterable or String'));
        }

        Mock.ExceptionExpectation expectation = Mock.expect(new TestBlock(true));
        expectation.toThrow();
        expectation.toThrow();

        Assert.isFalse(Mock.anySObject().matches('not-an-sobject'));
        Assert.isFalse(Mock.any(String.class).matches(null));
        Assert.isFalse(Mock.iterableContaining('x').matches(10));

        Mock.Matcher containsField = Mock.objectContaining(new Map<String, Object>{ 'Name' => 'Acme' });
        Assert.isFalse(containsField.matches(null), 'Null should fail objectContaining match.');
        Assert.isFalse(containsField.matches('plain-text'), 'Non-map/DTO fallback cast failure should return false.');
    }

    @IsTest
    static void should_cover_http_header_mismatch_path() {
        // Arrange
        Mock.HttpMock http = Mock.mockHttp();
        http.mockResponse('POST', 'https://api.com/h', 'ok', 200);

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.com/h');
        req.setMethod('POST');
        req.setBody('payload');
        req.setHeader('X-Token', 'actual');

        // Act
        new Http().send(req);

        try {
            // Assert
            Mock.expect(http)
                .toHaveBeenCalledWith(
                    'https://api.com/h',
                    'POST',
                    'payload',
                    new Map<String, Object>{ 'X-Token' => 'expected' }
                );
            Assert.fail('Expected header mismatch to fail verification.');
        } catch (Mock.MockException e) {
            Assert.isTrue(e.getMessage().contains('no matching call was found'));
        }
    }

    @IsTest
    static void should_cover_provider_method_key_when_param_types_are_null() {
        // Arrange
        Mock.MockProvider provider = new Mock.MockProvider('DirectProvider');

        // Act
        Object result = provider.handleMethodCall(
            new Account(),
            'dynamicCall',
            String.class,
            null,
            new List<String>(),
            new List<Object>{ 'arg' }
        );

        // Assert
        Assert.areEqual(null, result, 'Expected default null return for unconfigured direct provider call.');
        Assert.areEqual(
            1,
            provider.getCalls('dynamicCall').size(),
            'Expected call to be recorded under method name key.'
        );
    }

    public class MultiplyByTwo implements Mock.Callback {
        public Object call(List<Object> args) {
            Integer input = (Integer) args[0];
            return input * 2;
        }
    }

    public class AddWithOffset implements Mock.Callback {
        private final Integer offset;
        public AddWithOffset(Integer offset) {
            this.offset = offset;
        }
        public Object call(List<Object> args) {
            Integer first = (Integer) args[0];
            Integer second = (Integer) args[1];
            return first + second + offset;
        }
    }

    public class ReturnOrThrowByFirstArg implements Mock.Callback {
        public Object call(List<Object> args) {
            Integer first = (Integer) args[0];
            Integer second = (Integer) args[1];
            if (first == -1) {
                throw new IllegalArgumentException('Sentinel throw');
            }
            return first + second;
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
