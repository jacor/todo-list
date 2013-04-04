@isTest
public with sharing class TestTodoListService {
	@isTest
	public static void testSaveNewTodos(){
		Test.startTest();
		
		System.assertEquals(0, [SELECT COUNT() FROM ToDo_List__c]);
		
		Todo[] savedList = TodoListService.saveTodoList(new Todo[]{
			newTodo('test a'),
			newTodo('test b'),
			newTodo('test c')
		});
		
		System.assertEquals(3, [SELECT COUNT() FROM ToDo_List__c]);
		
		Map<Id, ToDo_List__c> todoDb = new Map<Id, ToDo_List__c>(
			[SELECT Id, Title__c, Completed__c FROM ToDo_List__c]);
			
		System.assertEquals(3, savedList.size());
		
		for(Todo t : savedList){
			System.assert(
				t.recordId != null && 
				todoDb.get(t.recordId) != null);
				
			System.assertEquals(null, t.assignee.name);
			System.assertEquals(null, t.assignee.recordId);
		}
		Test.stopTest();
	}
	@isTest
	public static void testSaveNewTodosDefaultingToUsersContact(){

		Account a = new Account(Name = 'Portal User Account');
		insert a;
		User u = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
		User testUser = null;
		Contact c = null;
		System.runAs(u) {
			c = new Contact(FirstName = 'Test1', LastName = 'Test2', AccountId = a.Id);
			insert c;
			
			testUser = new User(
				Username = 'testuser@ncino.com',
				email = 'test@test.com',
				CommunityNickname = 'testusernickname',
				contactId = c.id,
				FirstName = 'Test 1',
				LastName = 'Test 2',
				Alias = 'test',
				ProfileId = [SELECT Id FROM Profile WHERE Name =: 'High Volume Customer Portal'].Id,
				LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US',
				TimeZoneSidKey = 'America/Chicago',
				EmailEncodingKey = 'UTF-8'
			);
			insert testUser;
		}
		
		Test.startTest();
		
		System.runAs(testUser) {
			Todo[] savedList = TodoListService.saveTodoList(new Todo[]{
				newTodo('test a'),
				newTodo('test b'),
				newTodo('test c')
			});
			
			System.assertEquals(3, [SELECT COUNT() FROM ToDo_List__c]);
			
			Map<Id, ToDo_List__c> todoDb = new Map<Id, ToDo_List__c>(
				[SELECT Id, Title__c, Completed__c FROM ToDo_List__c]);
				
			System.assertEquals(3, savedList.size());
			
			for(Todo t : savedList){
				System.assert(
					t.recordId != null && 
					todoDb.get(t.recordId) != null);
					
				System.assertEquals('Test1 Test2', t.assignee.name);
				System.assertEquals(c.Id, t.assignee.recordId);
			}
		}

		Test.stopTest();
	}
	
	@isTest
	public static void testSaveNewTodosSetToContactIfPassedIn(){

		Account a = new Account(Name = 'Portal User Account');
		insert a;
		User u = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
		User testUser = null;
		User testUser2 = null;
		Contact c = null;
		Contact c2 = null;
		System.runAs(u) {
			c = new Contact(FirstName = 'Test1', LastName = 'Test2', AccountId = a.Id);
			c2 = new Contact(FirstName = 'Test3', LastName = 'Test4', AccountId = a.Id);
			insert c;
			insert c2;
			
			testUser = new User(
				Username = 'testuser@ncino.com',
				email = 'test@test.com',
				CommunityNickname = 'testusernickname',
				contactId = c.id,
				FirstName = 'Test 1',
				LastName = 'Test 2',
				Alias = 'test',
				ProfileId = [SELECT Id FROM Profile WHERE Name =: 'High Volume Customer Portal'].Id,
				LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US',
				TimeZoneSidKey = 'America/Chicago',
				EmailEncodingKey = 'UTF-8'
			);
			testUser2 = new User(
				Username = 'testuser2@ncino.com',
				email = 'tes2t@test.com',
				CommunityNickname = 'testusernickname2',
				contactId = c2.id,
				FirstName = 'Test 3',
				LastName = 'Test 4',
				Alias = 'tst2',
				ProfileId = [SELECT Id FROM Profile WHERE Name =: 'High Volume Customer Portal'].Id,
				LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US',
				TimeZoneSidKey = 'America/Chicago',
				EmailEncodingKey = 'UTF-8'
			);
			insert testUser2;
			insert testUser;
		}
		
		Test.startTest();
		
		System.runAs(testUser) {
			Todo[] todoListItems = new Todo[]{
				newTodo('test a'),
				newTodo('test b'),
				newTodo('test c')
			};
			
			for(Todo t : todoListItems){
				if(t.title == 'test b'){
					t.assignee = new TodoContact();
					t.assignee.name = 'Test3 Test4';
					t.assignee.recordId = c2.Id;
				}
			}
			
			Todo[] savedList = TodoListService.saveTodoList(todoListItems);
			
			
			System.assertEquals(3, [SELECT COUNT() FROM ToDo_List__c]);
			
			Map<Id, ToDo_List__c> todoDb = new Map<Id, ToDo_List__c>(
				[SELECT Id, Title__c, Completed__c FROM ToDo_List__c]);
				
			System.assertEquals(3, savedList.size());
			
			for(Todo t : savedList){
				System.assert(
					t.recordId != null && 
					todoDb.get(t.recordId) != null);
				
				if(t.title != 'test b'){
					System.assertEquals('Test1 Test2', t.assignee.name);
					System.assertEquals(c.Id, t.assignee.recordId);	
				}
				else{
					System.assertEquals('Test3 Test4', t.assignee.name);
					System.assertEquals(c2.Id, t.assignee.recordId);
				}
			}
		}

		Test.stopTest();
	}
	@isTest
	public static void testSaveNewTodosWithoutUsingRecordIdsDeletesPriorOnesAndReCreatesThem(){
		Test.startTest();
		
		System.assertEquals(0, [SELECT COUNT() FROM ToDo_List__c]);
		
		Todo[] savedList = TodoListService.saveTodoList(new Todo[]{
			newTodo('test a'),
			newTodo('test b'),
			newTodo('test c')
		});
		savedList = TodoListService.saveTodoList(new Todo[]{
			newTodo('test a'),
			newTodo('test b'),
			newTodo('test c')
		});
		
		System.assertEquals(3, [SELECT COUNT() FROM ToDo_List__c]);
		
		Test.stopTest();
	}
	@isTest
	public static void testSaveAndUpdateNewTodos(){
		
		Todo[] savedList = TodoListService.saveTodoList(new Todo[]{
			newTodo('test a'),
			newTodo('test b'),
			newTodo('test c')
		});
		
		Test.startTest();
		
		savedList.add(newTodo('test d'));
		savedList = TodoListService.saveTodoList(savedList);
		
		System.assertEquals(4, [SELECT COUNT() FROM ToDo_List__c]);
		
		Map<Id, ToDo_List__c> todoDb = new Map<Id, ToDo_List__c>(
			[SELECT Id, Title__c, Completed__c FROM ToDo_List__c]);
			
		System.assertEquals(4, savedList.size());
		
		for(Todo t : savedList){
			System.assert(
				t.recordId != null && 
				todoDb.get(t.recordId) != null);
		}
		Test.stopTest();
	}
	@IsTest
	public static void testDeleteTodos(){
		Todo[] savedList = TodoListService.saveTodoList(new Todo[]{
			newTodo('test a'),
			newTodo('test b'),
			newTodo('test c')
		});
		
		Test.startTest();
		
		savedList.add(newTodo('test d'));
		savedList = TodoListService.saveTodoList(savedList);
		System.assertEquals(4, [SELECT COUNT() FROM ToDo_List__c]);
		
		Integer index = 0;
		for(Todo t : savedList){
			if('test b'.equals(t.title)){
				savedList.remove(index);
				break;
			}
			index++;
		}
		savedList = TodoListService.saveTodoList(savedList);
		System.assertEquals(3, [SELECT COUNT() FROM ToDo_List__c]);
		
		Map<Id, ToDo_List__c> todoDb = new Map<Id, ToDo_List__c>(
			[SELECT Id, Title__c, Completed__c FROM ToDo_List__c]);
			
		System.assertEquals(3, savedList.size());
		
		for(Todo t : savedList){
			System.assert(
				t.recordId != null && 
				todoDb.get(t.recordId) != null);
		}
		Test.stopTest();
	}
	
	private static Todo newTodo(String title){
		Todo a = new Todo();
		a.title = title;
		a.completed = false;
		a.editing = false;
		return a;
	}
}