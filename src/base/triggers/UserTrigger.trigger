trigger UserTrigger on User(before insert, before update, after insert, after update) {
    new MetadataTriggerHandler().run();
}