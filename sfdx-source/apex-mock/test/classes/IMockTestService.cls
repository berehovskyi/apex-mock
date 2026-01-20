// Test interface for Mock unit tests.
// Must be a top-level interface because Apex cannot stub inner types.
@SuppressWarnings('PMD.ApexDoc')
public interface IMockTestService {
    String getValue();
    Integer add(Integer a, Integer b);
    void doWork(String input);
    void doWork(Object input);
    Account findById(Id recordId);
    void updateDTO(Object dto);
    void updateSObject(SObject record);
}
