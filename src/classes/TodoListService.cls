public with sharing class TodoListService {
	@RemoteAction
	public static Todo[] getTodoList(){
		return retrieveTodoList();
	}
	@RemoteAction 
	public static Todo[] saveTodoList(Todo[] todoList){
		saveTodoListToDb(todoList);
		return getTodoList();
	}
	@RemoteAction
	public static TodoContact[] getContacts(){
		TodoContact[] toReturn = new TodoContact[]{};
		Contact[] contacts = [SELECT Id, Name FROM Contact];
		for(Contact c : contacts){
			TodoContact tContact = new TodoContact();
			tContact.recordId = c.Id;
			tContact.name = c.Name;
			toReturn.add(tContact);
		}
		return toReturn;
	}
	
	private static Todo[] retrieveTodoList(){
		Todo[] todoList = new Todo[]{};
		ToDo_List__c[] records = retrieveListFromDb(UserInfo.getUserId(), getContactId());
		
		for(ToDo_List__c l : records){
			Todo t = new Todo();
			mapFromDbRecord(l, t);
			todoList.add(t);
		}
		return todoList;
	}
	/**
	* Cruds the todo list by examining the recordId field of the Todo items in the following way:
	* <ul>
	* <li>if the recordId matches the record Id in the database then update the record</li>
	* <li>if the Todo item does not have a recordId then add it to the database</li>
	* <li>Remove the remaining items in the list (that were not added/removed)</li>
	* </ul> 
	*/
	private static void saveTodoListToDb(Todo[] todoList){
		ToDo_List__c[] insertList = new ToDo_List__c[]{};
		ToDo_List__c[] updateList = new ToDo_List__c[]{};
		ToDo_List__c[] deleteList = new ToDo_List__c[]{};
		
		Id contactId = getContactId();
		
		Map<Id,ToDo_List__c> records = new Map<Id,ToDo_List__c>(
			retrieveListFromDb(
			UserInfo.getUserId(), 
			contactId));
		for(Integer i=todoList.size()-1;i>=0;i--){
			Todo t = todoList[i];
			if(t.recordId != null && t.recordId.length() > 0){
				ToDo_List__c dbRecord = records.remove(t.recordId); // remove from list
				if(dbRecord != null){
					mapToDbRecord(t, dbRecord);
					updateList.add(dbRecord);
				}
			}
			else{
				ToDo_List__c newTodo = new ToDo_List__c();
				mapToDbRecord(t, newTodo);
				// if the contact was not set by the UI, default to current user
				if(newTodo.Contact__c == null){
					newTodo.Contact__c = contactId;
				}
				insertList.add(newTodo);
			}
		}
		deleteList.addAll(records.values());

		Database.insert(insertList);
		Database.update(updateList);
		Database.delete(deleteList);
	}
	private static void mapToDbRecord(Todo t, ToDo_List__c dbRecord){
		dbRecord.Title__c = t.title;
		dbRecord.Completed__c = t.completed;
		dbRecord.Contact__c = 
			t.assignee != null && 
			t.assignee.recordId != null &&
			t.assignee.recordId.length() > 0 ? t.assignee.recordId : null;
	}
	private static void mapFromDbRecord(ToDo_List__c dbRecord, Todo t){
		t.recordId = dbRecord.Id;
		t.title = dbRecord.Title__c;
		t.completed = dbRecord.Completed__c;
		t.assignee = new TodoContact();
		t.assignee.name = dbRecord.Contact__r.Name;
		t.assignee.recordId = dbRecord.Contact__r.Id;
	}
	private static ToDo_List__c[] retrieveListFromDb(Id userId, Id contactId){
		return [	
			SELECT 
				Id, 
				Title__c, 
				Completed__c,
				Contact__r.Id,
				Contact__r.Name
			FROM 
				ToDo_List__c
			WHERE
				OwnerId =: userId
			OR
				Contact__c =: contactId
			ORDER BY CreatedDate ASC];
	}
	private static Id getContactId(){
		return [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()].ContactId;
	}
}