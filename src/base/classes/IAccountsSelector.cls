public interface IAccountsSelector extends IApplicationSObjectSelector {
    List<Account> selectById(Set<Id> idSet);
    List<Account> selectByIdWithAssets(Set<Id> idSet, Set<String> assetFields);
    String testing();
}