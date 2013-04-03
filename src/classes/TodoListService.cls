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
	
	private static Todo[] retrieveTodoList(){
		Todo[] todoList = new Todo[]{};
		ToDo_List__c[] records = retrieveListFromDb();
		
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
		 
		Map<Id,ToDo_List__c> records = new Map<Id,ToDo_List__c>(retrieveListFromDb());
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
	}
	private static void mapFromDbRecord(ToDo_List__c dbRecord, Todo t){
		t.recordId = dbRecord.Id;
		t.title = dbRecord.Title__c;
		t.completed = dbRecord.Completed__c;
	}
	private static ToDo_List__c[] retrieveListFromDb(){
		return [
			SELECT 
				Id, 
				Title__c, 
				Completed__c 
			FROM 
				ToDo_List__c
			WHERE
				OwnerId =: UserInfo.getUserId()];
	}
}