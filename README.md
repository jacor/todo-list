Simple todo list on the force.com platform
===========================================
![force logo](http://www.force.com/common/assets/img/header-logo-update.png)

# Steps To Create Application
- Based on the TodoMVC App: http://todomvc.com/architecture-examples/knockoutjs/
- Here is the code: https://github.com/addyosmani/todomvc/tree/gh-pages/architecture-examples/knockoutjs
- Create a new developer org and assign the CEO role to the registered user
- Create a new force.com site:
	- App Setup -> Develop -> Site -> New Site 
	- Site Label: todo-list, Site Name: todo_list, Active: checked
	- Use the SiteLogin.page as the site home page
	- Enable the customer portal: Customize -> Customer Portal -> Settings -> Edit -> Enable -> Continue
	- Edit the customer portal, 
		- Set the Administrator
		- Enable Self-Registration
		- Set New User Form URL to SiteRegister
		- Set the Default New User License and Default New User Profile to High Volume Customer Portal
	- Enable login for the site: App Setup -> Develop -> Site -> Login Settings -> Edit, set My Profile Page to MyProfilePage


### Register a new user on the site:
	- Create a new account that all the registered site users will belong to. Call it TodoList Account
	- Copy the Id of the account and edit the SiteRegisterController to reference the account.
	- Register a new user by clicking the register link
	- Add the FirstName and LastName fields to SiteRegister.page and the SiteRegisterController:

```java
	public String lastname {get; set;}
	public String firstname {get; set;}
```
 
```java
     if(firstname == null || firstname.length() == 0){
		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Enter a first name');
     	ApexPages.addMessage(msg);
         return null;
     }
     if(lastname == null || lastname.length() == 0){
		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Enter a last name');
     	ApexPages.addMessage(msg);
         return null;
     }
     
     User u = new User();
     u.Username = username;
     u.Email = email;
     u.FirstName = firstname;
     u.LastName = lastname;
     u.CommunityNickname = communityNickname;
``` 


```html
 <apex:panelGrid columns="2" style="margin-top:1em;">
    <apex:outputLabel value="{!$Label.site.username}" for="username"/>
    <apex:inputText required="true" id="username" value="{!username}"/>
    <apex:outputLabel value="First Name" for="firstname"/>
    <apex:inputText required="true" id="firstname" value="{!firstname}"/>
    <apex:outputLabel value="Last Name" for="lastname"/>
    <apex:inputText required="true" id="lastname" value="{!lastname}"/>
    <apex:outputLabel value="{!$Label.site.community_nickname}" for="communityNickname"/>
    <apex:inputText required="true" id="communityNickname" value="{!communityNickname}"/>
    <apex:outputLabel value="{!$Label.site.email}" for="email"/>
    <apex:inputText required="true" id="email" value="{!email}"/>
    <apex:outputLabel value="{!$Label.site.password}" for="password"/>
    <apex:inputSecret id="password" value="{!password}"/>
    <apex:outputLabel value="{!$Label.site.confirm_password}" for="confirmPassword"/>
    <apex:inputSecret id="confirmPassword" value="{!confirmPassword}"/>
    <apex:outputText value=""/>
    <apex:commandButton action="{!registerUser}" value="{!$Label.site.submit}" id="submit"/>
  </apex:panelGrid> 
```

### Add some nCino styling

- TODO: Modify the SiteSamples/SiteStyles.css static resource to contain bootstrap styles
- Add the nCino logos in content/images to the SiteSamples static resource in the /img folder
	- nCinoLogo.gif
	- nCinoLogoBars.gif
- Modify the generated SitePoweredBy.component to reference the nCino logo:

```html
<apex:outputLink value="http://www.ncino.com"><apex:image url="{!URLFOR($Resource.SiteSamples, 'img/nCinoLogo.png')}" height="55px" styleClass="poweredByImage"/></apex:outputLink>
```

- Search and remove all files in the project that contain:

```html
<apex:image url="{!URLFOR($Resource.SiteSamples, 'img/clock.png')}"/>
```

- Modify the image in the SiteHeader.component:

```html
<apex:image url="{!URLFOR($Resource.SiteSamples, 'img/nCinoLogoBars.gif')}" style="align: left;" alt="nCino" height="33" title="nCino"/>
```

### Include bootstrap and other web dependencies

- Create the web library dependencies (can be found in content/web_libs):
	- Download jquery ui: http://jqueryui.com/download/
	- Download knockout: http://knockoutjs.com/downloads/knockout-2.2.1.js
	- Download knockout-mapping: https://raw.github.com/SteveSanderson/knockout.mapping/master/build/output/knockout.mapping-latest.js
	- Download knockout-validation: https://raw.github.com/ericmbarnard/Knockout-Validation/master/Dist/knockout.validation.js
	- Download underscore: http://underscorejs.org/underscore.js
	- Download director: https://raw.github.com/addyosmani/todomvc/gh-pages/architecture-examples/knockoutjs/components/director/build/director.js
	- Download TodoMvc: https://github.com/addyosmani/todomvc/tree/gh-pages/architecture-examples/knockoutjs/components/todomvc-common 
	- Create a zip file from the contents: $ zip -r includes.zip * 
	- Add the zip file as a static resource. Be sure to set the access level to public; call it includes
	- Create a new visualforce component that includes all the libaries; call it Includes.component:
	
```html
    <apex:component >
         <script type="text/javascript">
            jQuery.noConflict();
        </script>
        <script src="/soap/ajax/27.0/connection.js" type="text/javascript"></script>
        <script src="/soap/ajax/27.0/apex.js" type="text/javascript"></script>

        <apex:includeScript value="{!URLFOR($Resource.includes, 'jquery-ui-1.10.2.custom/js/jquery-1.9.1.js')}" />
        <apex:includeScript value="{!URLFOR($Resource.includes, 'jquery-ui-1.10.2.custom/js/jquery-ui-1.10.2.custom.js')}" />
        <apex:stylesheet value="{!URLFOR($Resource.includes, 'jquery-ui-1.10.2.custom/css/redmond/jquery-ui-1.10.2.custom.css')}" />

        <apex:includeScript value="{!URLFOR($Resource.includes, 'underscore.js')}" />
        <apex:includeScript value="{!URLFOR($Resource.includes, 'knockout-2.2.1.js')}" />
        <apex:includeScript value="{!URLFOR($Resource.includes, 'knockout.mapping-latest.js')}" />
        <apex:includeScript value="{!URLFOR($Resource.includes, 'knockout.validation.js')}" />

        <apex:includeScript value="{!URLFOR($Resource.includes, 'bootstrap/js/bootstrap.js')}" />
        <apex:stylesheet value="{!URLFOR($Resource.includes, 'bootstrap/css/bootstrap.css')}" />
        <apex:stylesheet value="{!URLFOR($Resource.includes, 'bootstrap/css/bootstrap-responsive.css')}" />

        <apex:includeScript value="{!URLFOR($Resource.includes, 'todomvc-common/base.js')}" />
        <apex:stylesheet value="{!URLFOR($Resource.includes, 'todomvc-common/base.css')}" />
        <apex:includeScript value="{!URLFOR($Resource.includes, 'director.js')}" />

    </apex:component>
```

- Add this component to the SiteTemplate.page and wrap all headers in a bootstrap div navbar and move the hrs tags

```html
<apex:page showHeader="false" id="SiteTemplate">
	<c:Includes />
  <apex:stylesheet value="{!URLFOR($Resource.SiteSamples, 'SiteStyles.css')}"/>
  <div class="navbar navbar-fixed-top">
  	<div class="navbar-inner">
	  <apex:insert name="header">
	    <c:SiteHeader />
	  </apex:insert>
	</div>
  </div>
  <hr/>
  <hr/>
	<div>
  		<apex:insert name="body"/>
  	</div>
  <apex:insert name="footer">
    <hr/>
    <c:SiteFooter />
    <site:googleAnalyticsTracking />
  </apex:insert>
</apex:page>
```

- Fix up the SiteLogin, ForgotPassord and SiteRegister header links in SiteHeader.component:

```html
		<apex:outputLink value="SiteLogin">{!$Label.site.login_button}</apex:outputLink>
		<apex:outputText value=" | "/>
		<apex:outputLink value="ForgotPassword">{!$Label.site.forgot_your_password_q}</apex:outputLink>
		<apex:outputText value=" | " rendered="{!$Site.RegistrationEnabled}"/>
		<apex:outputLink value="SiteRegister" rendered="{!$Site.RegistrationEnabled}">{!$Label.site.new_user_q}</apex:outputLink>
	  </apex:panelGroup>
```

### Add the main web page and port the TodoMVC knockout app

- Create a site home page:
	- Create a new visualforce page, call it TodoList.page
	- Be sure to add: showHeader="false" standardStylesheets="false" since we want our own styling
	- Also set docType="html-5.0" language="en"
	- Modify the registerUser method of the SiteRegisterController & SiteLoginControllers to pass in the page URL of the TodoList.page to the login() call
	- Add the page to the site: App Setup -> Develop -> Sites -> Site visualforce pages -> Edit
 
```html
<apex:page showHeader="false" standardStylesheets="false" docType="html-5.0" language="en">
	<apex:composition template="{!$Site.Template}">
		<apex:define name="body">
			<div>
				insert content here
			</div>
		</apex:define>
	</apex:composition>
</apex:page>
```

```java
	return Site.login(username, password, '/TodoList');
```

- Create a ToDo Component
	- Create a js file called app.js and upload it as a static resource. 
	- Copy in the knockout code for the todo app.js; be sure to wrap it in jQuery(function(){}); to allow for a ready DOM
	- Inlcude the app.js script in the ToDo component

```html
<apex:includeScript value="{!URLFOR($Resource.app)}" />
```

- Copy in todo html code into ToDo component
	- remove the base.css stylesheet include in the head tag
	- remove the js include tags at the bottom of the file
	- find autofocus and set it to autofocus="true"
	- find all input and meta tags and be sure to end them
	- Modify the TodoList.page to include the Todo.component 
	
```html
<apex:component>
	<head>
		<meta charset="utf-8" />
		<meta content="IE=edge,chrome=1" http-equiv="X-UA-Compatible" />
		<title>Knockout.js • TodoMVC</title>
	</head>
	<body id="todolistapp">
		<section id="todoapp">
			<header id="header">
				<h1>todos</h1>
				<input id="new-todo" data-bind="value: current, valueUpdate: 'afterkeydown', enterKey: add" placeholder="What needs to be done?" autofocus="true"/>
			</header>
			<section id="main" data-bind="visible: todos().length">
				<input id="toggle-all" data-bind="checked: allCompleted" type="checkbox"/>
				<label for="toggle-all">Mark all as complete</label>
				<ul id="todo-list" data-bind="foreach: filteredTodos">
					<li data-bind="css: { completed: completed, editing: editing }">
						<div class="view">
							<input class="toggle" data-bind="checked: completed" type="checkbox"/>
							<label data-bind="text: title, event: { dblclick: $root.editItem }"></label>
							<button class="destroy" data-bind="click: $root.remove"></button>
						</div>
						<input class="edit" data-bind="value: title, valueUpdate: 'afterkeydown', enterKey: $root.stopEditing, selectAndFocus: editing, event: { blur: $root.stopEditing }"/>
					</li>
				</ul>
			</section>
			<footer id="footer" data-bind="visible: completedCount() || remainingCount()">
				<span id="todo-count">
					<strong data-bind="text: remainingCount">0</strong>
					<span data-bind="text: getLabel( remainingCount )"></span> left
				</span>
				<ul id="filters">
					<li>
						<a data-bind="css: { selected: showMode() == 'all' }" href="#/all">All</a>
					</li>
					<li>
						<a data-bind="css: { selected: showMode() == 'active' }" href="#/active">Active</a>
					</li>
					<li>
						<a data-bind="css: { selected: showMode() == 'completed' }" href="#/completed">Completed</a>
					</li>
				</ul>
				<button id="clear-completed" data-bind="visible: completedCount, click: removeCompleted">
					Clear completed (<span data-bind="text: completedCount"></span>)
				</button>
			</footer>
		</section>
		<footer id="info">
			<p>Double-click to edit a todo</p>
			<p>Original Knockout version from <a href="https://github.com/ashish01/knockoutjs-todos">Ashish Sharma</a></p>
			<p>Rewritten to use Knockout 2.0 and standard template by <a href="http://knockmeout.net">Ryan Niemeyer</a></p>
			<p>Patches/fixes for cross-browser compat: <a href="http://twitter.com/addyosmani">Addy Osmani</a></p>
			<p>Part of <a href="http://todomvc.com">TodoMVC</a></p>
		</footer>
	</body>
	<apex:includeScript value="{!URLFOR($Resource.app)}" />
</apex:component>
```


### Test the ported app:

- Login as the user and test the basic todo list.
	- add some todo items
	- items are stored in a local cookie
	- log out and log back in

### Enhance the app to persist todo item in salesforce

- Create a database table (or sObject aka Schema-Object) in salesforce to save our data.
	- App Setup -> Create -> Objects -> New Custom Object
	- Call the object ToDo List, set the following fields (that corresponds with the Todo js model):
	  - Name: Autonumber
	  - Title: Text, Requried, 255
	  - Completed: Boolean 
- Create a POJO value object that contains all data required for the UI model (data structure matches the Todo js model):

```java
	public with sharing class Todo {
		public String recordId;
		public String title;
		public Boolean completed;
		public Boolean editing;
	}
```

- Change the Todo js model to set the completed & recordId variables if they are not set:

```js
	var Todo = function (title, recordId, completed) {
		this.recordId = ko.observable(recordId == null? '' : recordId);
		this.title = ko.observable(title);
		this.completed = ko.observable(completed == null? false: completed);
		this.editing = ko.observable(false);
	};
```

- Modify the initialization of the self.todos observable array to set the additional constructor variable:

```js
	self.todos = ko.observableArray(ko.utils.arrayMap(todos, function (todo) {
		return new Todo(todo.title, todo.recordId, todo.completed);
	}));

```

- Create a APEX Remoting JS Service to CRUD the Todo list, call the class TodoListService.
	- Modify the Todo.component and set the controller attribute to TodoListService
	- add 2 @RemoteAction methods to this class: 1) getTodoList and 2) saveTodoList
	
```java
	public with sharing class TodoListService {
		@RemoteAction
		public static Todo[] getTodoList(){
			return null;
		}
		@RemoteAction 
		public static Todo[] saveTodoList(Todo[] todoList){
			return null;
		}
	}
```

- Add the implementation for the TodoListService methods
- the getTodoList() implementation is straight forward
	
```java
	@RemoteAction
	public static Todo[] getTodoList(){
		return retrieveTodoList();
	}
	private static Todo[] retrieveTodoList(){
		Todo[] todoList = new Todo[]{};
		ToDo_List__c[] records = retrieveListFromDb(UserInfo.getUserId());
		
		for(ToDo_List__c l : records){
			Todo t = new Todo();
			mapFromDbRecord(l, t);
			todoList.add(t);
		}
		return todoList;
	}
	private static void mapFromDbRecord(ToDo_List__c dbRecord, Todo t){
		t.recordId = dbRecord.Id;
		t.title = dbRecord.Title__c;
		t.completed = dbRecord.Completed__c;
	}
	private static ToDo_List__c[] retrieveListFromDb(Id userId){
		return [	
			SELECT 
				Id, 
				Title__c, 
				Completed__c
			FROM 
				ToDo_List__c
			WHERE
				OwnerId =: userId
			ORDER BY CreatedDate ASC];
	}
```
- the saveTodoList() implementation is tricky:
<pre>
	Cruds the todo list by examining the recordId field of the Todo items in the following way:
	- if the recordId matches the record Id in the database then update the record
	- if the Todo item does not have a recordId then add it to the database
	- remove the remaining items in the list (that were not added/removed) 
</pre>

```java
	@RemoteAction 
	public static Todo[] saveTodoList(Todo[] todoList){
		saveTodoListToDb(todoList);
		return getTodoList();
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
		
		
		Map<Id,ToDo_List__c> records = new Map<Id,ToDo_List__c>(
			retrieveListFromDb(
			UserInfo.getUserId());
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
```

- Create testcases for CRUD operations
- Create 2 new apex remoting js functions at the bottom of the ToDo.component that invoke the remote actions:
	
```js
	window.todo = {};
	window.todo.loadTodoList = function(callback){
		Visualforce.remoting.Manager.invokeAction(
			'{!$RemoteAction.TodoListService.getTodoList}',
			function(result, event){
				if(event.type == 'exception'){
					 alert('Your session has timed out.');
				}
				if(event.status){
					callback.apply(this, [result]);
				}
				else{
					console.log('error');
					console.log(result);
				}
			},
			{escape: true} );
	};
	window.todo.persistTodoList = function(todos, callback){
		Visualforce.remoting.Manager.invokeAction(
			'{!$RemoteAction.TodoListService.saveTodoList}',
			_.map(ko.toJS(todos()), function(value, key, list){
				return value;
			}),
			function(result, event){
				if(event.type == 'exception'){
					 alert('Your session has timed out.');
				}
				if(event.status){
					callback.apply(this, [result]);
				}
				else{
					console.log('error');
					console.log(result);
				}
			},
			{escape: true} );
	};
```
- Modify the app.resource to load the data from the TodoListService:
 
```js
	window.todo.loadTodoList(function(todos){
		// bind a new instance of our view model to the page
		var viewModel = new ViewModel(todos || []);
		ko.applyBindings(viewModel);
	
		// set up filter routing
		/*jshint newcap:false */
		Router({'/:filter': viewModel.showMode}).init();
	});
```
- Modify the app.resource to save and reload-rebind the data from the TodoListService:

```js
	// internal computed observable that fires whenever anything changes in our todos
	ko.computed(function () {
		window.todo.persistTodoList(self.todos, function(todos){
			_.each(todos, function(element, index, list){
				_.each(self.todos(), function(innerElement, innerIndex, innerList){
					if(element.title == innerElement.title() &&
							element.recordId != innerElement.recordId()){
						innerElement.recordId(element.recordId);
					}
				});
			});
		});
	}).extend({
		throttle: 500
	}); // save at most twice per second
```

### Test the app and observe the todos being saved to the database 

### Combine the Todo list with a salesforce contact: 

- Add a contact lookup column to the ToDo List database table
- Modify the TodoListService to set this contact field for every new record.
	- The User table has column for ContactId
- Modify the contact page layout to add the TodoList related list and add the relevant columns
- At this point each todo list item is assigned to the contact that created the issue.
	- Let's add the ability to assign the todo list item to another user
	- Add a POJO to house the data
			
```java
	public with sharing class TodoContact {
		public String recordId;
		public String name;
	}
```
- compose this in the Todo record:
			
```java
	public with sharing class Todo {
		public String recordId;
		public String title;
		public Boolean completed;
		public Boolean editing;
		public TodoContact assignee;
	}
```
- add a new @RemoteAction to the TodoListService to retrieve all contacts
			
```java
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
```
- Add a Apex Remoting function to invoke the service:
			
```js
	window.todo.loadContacts = function(callback){
		Visualforce.remoting.Manager.invokeAction(
			'{!$RemoteAction.TodoListService.getContacts}',
			function(result, event){
				if(event.type == 'exception'){
					 alert('Your session has timed out.');
				}
				if(event.status){
					callback.apply(this, [result]);
				}
				else{
					console.log('error');
					console.log(result);
				}
			},
			{escape: true} );
	};
```
- Modify the TodoList service to load the contact id and name in the load from db call
- Also, modify the mapFromDbRecord and mapToDbRecord methods to set the contact to the assignee it is set
			
```java
	private static void mapToDbRecord(Todo t, ToDo_List__c dbRecord){
		dbRecord.Title__c = t.title;
		dbRecord.Completed__c = t.completed;
		dbRecord.Contact__c = t.assignee != null && 
			t.assignee.recordId != null ? t.assignee.recordId : null;
	}
	private static void mapFromDbRecord(ToDo_List__c dbRecord, Todo t){
		t.recordId = dbRecord.Id;
		t.title = dbRecord.Title__c;
		t.completed = dbRecord.Completed__c;
		t.assignee = new TodoContact();
		t.assignee.name = dbRecord.Contact__r.Name;
		t.assignee.recordId = dbRecord.Contact__r.Id;
	}	
```

- Ensure that the Contact__c is set to the contact o the logged in user when an assignee is not provided
- Modify the TodoListService todo record selection retrieval criteria to include items in the list that are assigned to the user

```java
	ToDo_List__c newTodo = new ToDo_List__c();
	mapToDbRecord(t, newTodo);
	if(newTodo.Contact__c == null){
		newTodo.Contact__c = contactId;
	}
	insertList.add(newTodo);
```

```java
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
```

- Make the corresponding js model changes to accomodate the assignee:
			
```js
	var TodoContact = function(name, recordId){
		this.name = ko.observable(name);
		this.recordId = ko.observable(recordId);
	}
	// represent a single todo item
	var Todo = function (title, recordId, completed, assignee) {
		this.recordId = ko.observable(recordId == null? '' : recordId);
		this.title = ko.observable(title);
		this.completed = ko.observable(completed == null? false: completed);
		this.editing = ko.observable(false);
		this.assignee = ko.observable(assignee);
	};
	// map array of passed in todos to an observableArray of Todo objects
	self.todos = ko.observableArray(ko.utils.arrayMap(todos, function (todo) {
		return new Todo(
				todo.title, 
				todo.recordId, 
				todo.completed, 
				new TodoContact(
						todo.assignee.name, 
						todo.assignee.recordId));
	}));
``` 
- We also need to make sure that the assignee observable is set correctly from the response:
			
```js
	// internal computed observable that fires whenever anything changes in our todos
	ko.computed(function () {
		window.todo.persistTodoList(self.todos, function(todos){
			_.each(todos, function(element, index, list){
				_.each(self.todos(), function(innerElement, innerIndex, innerList){
					if(element.title == innerElement.title() && 
							element.recordId != innerElement.recordId()){
						
						innerElement.recordId(element.recordId);
						innerElement.assignee(element.assignee);
					}
				});
			});
		});
	}).extend({
		throttle: 500
	}); // save at most twice per second
```

- Create a new observable for the contacts:
			
```js
	self.contacts = ko.observableArray([]);
```

- load the contacts when the app is initialized
			
```js
	....
	....
		self.reloadContacts = function(){
			window.todo.loadContacts(function(contacts){
				_.each(contacts, function(element, index, list){
					self.contacts.push(new TodoContact(element.name, element.recordId));
				});
			});
		}
	};
	window.todo.loadTodoList(function(todos){
		// bind a new instance of our view model to the page
		var viewModel = new ViewModel(todos || []);
		ko.applyBindings(viewModel);

		// set up filter routing
		/*jshint newcap:false */
		Router({'/:filter': viewModel.showMode}).init();
		
		// load contacts
		viewModel.reloadContacts();
	});
```

- Add a function to assign the selected user to the todo list item:
			
```js
	self.assignContact = function(todo, contact){
		todo.assignee(contact);
	}
```

- Let's add the assignee control to the todo list (be sure to add it inside the view div):
			
```html
	<div class="btn-group assignee" >
		<a class="btn btn-primary btn-mini" href="#"><i class="icon-user icon-white"></i> <span data-bind="text: assignee() != null ? assignee().name : ''"></span></a>
		<a class="btn btn-primary btn-mini dropdown-toggle" data-toggle="dropdown" href="#"><span class="caret"></span></a>
		<ul class="dropdown-menu" data-bind="foreach: {data: $root.contacts, as: 'contact'}">
			 <li><a href="#" data-bind="click: $root.assignContact.bind($data, todo, contact)"><i class="icon-hand-up"></i> <span data-bind="text: name"></span></a></li>
		</ul>
	</div>
	<div class="assignee-readonly">
		<i class="icon-user icon-black"></i> <span data-bind="text: assignee() != null ? assignee().name : ''"></span>
	</div>
```

- The filteredTodos foreach should be changed to specify the alias:
```html
	foreach: {data: filteredTodos, as: 'todo'}
```

- Wire it into the click event on the select-list:
			
```html
	<li><a href="#" data-bind="click: $root.assignContact.bind($data, todo, contact)"><i class="icon-hand-up"></i> <span data-bind="text: name"></span></a></li>
````

- We should style the assignee drop down to make it seem more integrated and only allow changing the assignee for uncompleted tasks:
- Change the body styling to body#todoappbody

```css
	#todo-list li div.view div.assignee{
		display: none;
	}
	#todo-list li.completed:hover div.view div.assignee{
		display: none;
	}
	#todo-list li:hover div.view div.assignee{
		display: block;
		font-size: 14px;
		margin-left: 45px;
	}
	#todo-list li:hover div.view div.assignee ul li{
		font-size: 14px;
	}
	#todo-list li div.view div.assignee-readonly{
		display: block;
	}
	#todo-list li.completed:hover div.view div.assignee-readonly{
		display: block;
	}
	#todo-list li:hover div.view div.assignee-readonly{
		display: none;
	}
	#todo-list li div.view div.assignee-readonly span{
		font-size: 14px;
	}
	#todo-list li div.view div.assignee-readonly i{
		margin-top: 8px;
	}
	#todo-list li div.view div.assignee-readonly{
		margin-left: 45px;
	}
	#todo-list li:hover div.view div.assignee a.dropdown-toggle{
		margin-left: -8px;
	}
```

## License

MIT License

