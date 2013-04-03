todo-list
=========

### Steps To Create Application
- Based on the TodoMVC App: http://todomvc.com/architecture-examples/knockoutjs/
- Create a new developer org and assign the CEO role to the registered user
- Create the web library dependencies:
	- Download jquery ui: http://jqueryui.com/download/
	- Download knockout: http://knockoutjs.com/downloads/knockout-2.2.1.js
	- Download knockout-mapping: https://raw.github.com/SteveSanderson/knockout.mapping/master/build/output/knockout.mapping-latest.js
	- Download knockout-validation: https://raw.github.com/ericmbarnard/Knockout-Validation/master/Dist/knockout.validation.js
	- Download underscore: http://underscorejs.org/underscore.js
	- Download director: https://raw.github.com/addyosmani/todomvc/gh-pages/architecture-examples/knockoutjs/components/director/build/director.js
	- Download TodoMvc: https://github.com/addyosmani/todomvc/tree/gh-pages/architecture-examples/knockoutjs/components/todomvc-common 
	- Create a zip file from the contents: $ zip -r includes.zip * 
	- Add the zip file as a static resource. Be sure to set the access level to public.
	- Create a new visualforce component that includes all the libaries; call it Includes.component.
- Create a site home page:
	- Create a new visualforce page, call it TodoList.page
	- Be sure to add: showHeader="false" standardStylesheets="false" since we want our own styling
	- Also set docType="html-5.0" language="en"
- Create a new force.com site:
	- App Setup -> Develop -> Site -> New Site
	- Use the SiteLogin.page as the site home page
	- Enable the customer portal: Customize -> Customer Portal -> Settings -> Edit -> Enable -> Continue
	- Edit the customer portal, 
		- Set the Administrator
		- Enable Self-Registration
		- Set New User Form URL to SiteRegister
		- Set the Default New User License and Default New User Profile to High Volume Customer Portal
	- Enable login for the site: App Setup -> Develop -> Site -> Login Settings -> Edit, set My Profile Page to MyProfilePage
- TODO: Modify the SiteSamples/SiteStyles.css static resource to contain bootstrap styles
- Register a new user on the site
	- Create a new account that all the registered site users will belong to. Call it TodoList Account
	- Copy the Id of the account and edit the SiteRegisterController to reference the account.
	- Modify the registerUser method of the SiteRegisterController to pass in the page URL of the TodoList.page to the login() call
- Create a ToDo Component
	- Include the web dependencies in the component
	- Create a js file called app.js and upload it as a static resource. 
	- Add the knockout code for the todo app.
	- Modify the TodoList.page to include the Todo.component and position it using bootstrap fluid rows.
- Login as the user and test the basic todo list.
- Create a database table (or sObject aka Schema-Object) in salesforce to save our data.
	- App Setup -> Create -> Objects -> New Custom Object
	- Call the object ToDo List, set the following fields (that corresponds with the Todo js model):
	  - Name: Autonumber
	  - Title: Text, Requried, 255
	  - Completed: Boolean 
- Create a POJO value object that contains all data required for the UI model (data structure matches the Todo js model):
	<pre>
	public with sharing class Todo {
		public String recordId = '';
		public String title = '';
		public Boolean completed = false;
		public Boolean editing = false;
	}
	</pre>
- Create a APEX Remoting JS Service to CRUD the Todo list, call the class TodoListService.
	- Modify the Todo.component and set the controller attribute to TodoListService
	- add 2 @RemoteAction methods to this class: 1) getTodoList and 2) saveTodoList
	<pre>
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
	</pre>
	- Add the implementation for the TodoListService methods
		- the getTodoList() implementation is straight orward
		- the saveTodoList() implementation is tricky:
			<pre>
				Cruds the todo list by examining the recordId field of the Todo items in the following way:
				- if the recordId matches the record Id in the database then update the record
				- if the Todo item does not have a recordId then add it to the database
				- remove the remaining items in the list (that were not added/removed) 
			</pre>
	- Create 2 new apex remoting js functions at the bottom of the ToDo.component that invoke the remote actions:
		<pre>
			<script>
				window.todo = {};
				window.todo.retrieveTodoList = function(callback){
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
				window.todo.saveTodoList = function(viewModel, callback){
					Visualforce.remoting.Manager.invokeAction(
						'{!$RemoteAction.TodoListService.saveTodoList}',
						ko.toJS(viewModel),
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
			</script>
		</pre>
	- Modify the app.resource to load the data from the TodoListService:
	<pre>
		window.todo.loadTodoList(function(todos){
			// bind a new instance of our view model to the page
			var viewModel = new ViewModel(todos || []);
			ko.applyBindings(viewModel);
	
			// set up filter routing
			/*jshint newcap:false */
			Router({'/:filter': viewModel.showMode}).init();
		});
	</pre> 
	- Modify the app.resource to save and reload the data from the TodoListService:
	<pre>
		// internal computed observable that fires whenever anything changes in our todos
		ko.computed(function () {
			window.todo.persistTodoList(self.todos, function(todos){
				self.todos.removeAll();
				_.each(todos, function(element, index, list){
					self.todos.push(element);
				});
			});
		}).extend({
			throttle: 500
		}); // save at most twice per second
	</pre> 