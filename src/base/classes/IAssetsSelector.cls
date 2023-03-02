public interface IAssetsSelector extends IApplicationSObjectSelector {
    List<Asset> selectById(Set<Id> idSet);
}