public interface ITasksSelector extends IApplicationSObjectSelector {
    List<Task> selectById(Set<Id> idSet);
}