In this part I will be discussing console tasks that will allow a
console operator to lend out an item as well as return it.

In order to expose the console task to the console we will need a MP
telling Service Manager the necessary details. First off we will define
when a console task should be shown. When using a console task in a form
(a so called FormTask) we have access to an interface called IDataItem.
Changes made using this interface will reflect immediately in the form
(and we will not have to bother with saving the changes).
When calling a console task from a view we will be editing an
EnterpriseManagementObject (or some variant thereof).
First of I will limit the console tasks to only work from a view:
*\<Category ID=\"LendItemTaskHandler.DonotShowFormTask.Category\"
Target=\"LendItemTaskHandler\"
Value=\"Console!Microsoft.EnterpriseManagement.ServiceManager.UI.Console.DonotShowFormTask\"
/\>*
*\<Category ID=\"ReturnItemTaskHandler.DonotShowFormTask.Category\"
Target=\"ReturnItemTaskHandler\"
Value=\"Console!Microsoft.EnterpriseManagement.ServiceManager.UI.Console.DonotShowFormTask\"
/\>*
Next we define the console tasks. I will just show the code for the
first one. The ID is the target we defined above. The target of the
console task is then defined as a class just like when doing [type
projections](http://codebeaver.blogspot.dk/2014/04/nested-type-projections-in-scsm-review.html).
What we are doing is telling the
Microsoft.EnterpriseManagement.UI.SdkDataAccess.ConsoleTaskHandler that
it should invoke CB.LendableItemConsoleTasks (this is the name of the
assembly, the DLL-file) when someone clicks the task in the console, and
type is a combination of the namespace the LendableTaskHandler is
contained in, ie. namespace is CB.LendableItemConsoleTasks in which a
class LendableTaskHandler is defined, and finally we provide a single
argument \"LendItem\" which we can look for in the code later on.
*\<ConsoleTask ID=\"LendItemTaskHandler\" Accessibility=\"Public\"
Enabled=\"true\" Target=\"LendableLibrary!CB.LendableItem\"
RequireOutput=\"false\"\>*
*\<Assembly\>Console!SdkDataAccessAssembly\</Assembly\>*
*\<Handler\>Microsoft.EnterpriseManagement.UI.SdkDataAccess.ConsoleTaskHandler\</Handler\>*
*\<Parameters\>*
*  \<Argument
Name=\"Assembly\"\>CB.LendableItem.ConsoleTasks\</Argument\>*
*  \<Argument
Name=\"Type\"\>CB.LendableItem.TaskHandlers.LendableTaskHandler\</Argument\>*
*  \<Argument\>LendItem\</Argument\>*
*\</Parameters\>*
*\</ConsoleTask\>*
The entire XML can be viewed [here](http://pastebin.com/DmC5Hpid).
Next up is adding an empty project to the solution in which the custom
form is. We call the project CB.LendableItem.ConsoleTasks (this will
also be the name of the DLL). Go to project properties and change the
output type to \"class library\" and make sure the target framework is
.NET Framework 3.5. Optionably you can also sign the assembly in the
signing tab - the console will complain if executing console tasks from
an unsigned assembly.
In order to avoid writing the same code over and over again when
creating console tasks I use inheritance:
*
    class TaskHandler : ConsoleCommand*
*    {*
*        private IDataItem \_dataItem;*
*        private EnterpriseManagementObject \_emo;*
*        EnterpriseManagementObjectProjection \_emop;*
*        private EnterpriseManagementGroup \_mg;*
*
        public override void
ExecuteCommand(IList\<NavigationModelNodeBase\> nodes,
NavigationModelNodeTask task, ICollection\<string\> parameters)*
*        {*
*            base.ExecuteCommand(nodes, task, parameters);*
*
            NavigationModelNodeBase node = nodes.First();*
*
            //Get the server name to connect to*
*            String strServerName =
Registry.GetValue(\"HKEY\_CURRENT\_USER\\\\Software\\\\Microsoft\\\\System
Center\\\\2010\\\\Service Manager\\\\Console\\\\User Settings\",
\"SDKServiceMachine\", \"localhost\").ToString();*
*
            //Connect to the server*
*            \_mg = new EnterpriseManagementGroup(strServerName);*
*
            if (nodes\[0\] is EnterpriseManagementObjectNode)*
*            {*
*                \_emo = (nodes\[0\] as
EnterpriseManagementObjectNode).SDKObject;*
*            }*
*            else if (nodes\[0\] is
EnterpriseManagementObjectProjectionNode)*
*            {*
*                \_emop =
(EnterpriseManagementObjectProjection)(nodes\[0\] as
EnterpriseManagementObjectProjectionNode).SDKObject;*
*                \_emo = \_emop.Object;*
*            }*
*
            \_dataItem =
Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.GetFormDataContext(node);*
*        }*
*
        public IDataItem DataItem*
*        {*
*            get*
*            {*
*                return \_dataItem;*
*            }*
*        }*
*
        public EnterpriseManagementObject ManagementObject*
*        {*
*            get*
*            {*
*                return \_emo;*
*            }*
*        }*
*
        public EnterpriseManagementObjectProjection
ManagementObjectProjection*
*        {*
*            get*
*            {*
*                return \_emop;*
*            }*
*        }*
*
        public EnterpriseManagementGroup ManagementGroup*
*        {*
*            get*
*            {*
*                return \_mg;*
*            }*
*        }*
*    }*
What I have done here is create a generic TaskHandler. I can then simply
inherit it like this
*    class LendableTaskHandler : TaskHandler*
*    {*
*        // variables go here*
*
        public override void
ExecuteCommand(IList\<NavigationModelNodeBase\> nodes,
NavigationModelNodeTask task, ICollection\<string\> parameters)*
*        {*
*            base.ExecuteCommand(nodes, task, parameters);*
And get on with the code specific for this console task. Before we
continue we need to make sure we have a proper object projection in
which we can access ex. the user who borrowed an item.
*// search criteria for ObjectProjectionCriteria*
*String sId =
ManagementObject\[mpLendableItemLibrary.GetClass(\"CB.LendableItem\"),
\"CB\_ItemID\"\].Value.ToString();*
*String sLendableItemSearchCriteria = \"\";*
*sLendableItemSearchCriteria = String.Format(@\"\<Criteria
xmlns=\"\"http://Microsoft.EnterpriseManagement.Core.Criteria/\"\"\>\"
+*
*                \"\<Expression\>\" +*
*                \"\<SimpleExpression\>\" +*
*                    \"\<ValueExpressionLeft\>\" +*
*                   
\"\<Property\>\$Context/Property\[Type=\'CB.LendableItem\'\]/CB\_ItemID\$\</Property\>\"
+*
*                    \"\</ValueExpressionLeft\>\" +*
*                    \"\<Operator\>Equal\</Operator\>\" +*
*                    \"\<ValueExpressionRight\>\" +*
*                    \"\<Value\>\" + sId + \"\</Value\>\" +*
*                    \"\</ValueExpressionRight\>\" +*
*                \"\</SimpleExpression\>\" +*
*                \"\</Expression\>\" +*
*            \"\</Criteria\>\");*
*
ManagementPackTypeProjection mptpLendable =
mpLendableItemLibrary.GetTypeProjection(\"TypeProjection.LendableItem\");*
*
ObjectProjectionCriteria opcLendable = new
ObjectProjectionCriteria(sLendableItemSearchCriteria, mptpLendable,
mpLendableItemLibrary, ManagementGroup);*
*
IObjectProjectionReader\<EnterpriseManagementObject\> oprLendables =*
*   
ManagementGroup.EntityObjects.GetObjectProjectionReader\<EnterpriseManagementObject\>(opcLendable,
ObjectQueryOptions.Default);*
*
\_emop = oprLendables.First();*
This is based on
something [Travis](http://blogs.technet.com/b/servicemanager/archive/2010/10/04/using-the-sdk-to-create-and-edit-objects-and-relationships-using-type-projections.aspx) posted.
In short we retrieve the item already provided to use in
*ExecuteCommand*, but with the necessary type projections.
Remember the argument provided in the xml ealier? It can be accessed
like this
*if(parameters.Contains(\"LendItem\"))*
*{*
*    LendItem();*
*}*
*else if(parameters.Contains(\"ReturnItem\"))*
*{*
*    ReturnItem();*
*}*
*
RequestViewRefresh();*
, and when either of those two methods are done executing we refresh the
view.
I will also setup some helper functions
*public EnterpriseManagementSimpleObject GetCurrentStatus()*
*{*
*    return ManagementObject\[mpcLendableItem, \"CB\_Status\"\];*
*}*
I will be looking up the current status alot. *mpcLendableItem* is
defined in ExecuteCommand, and *ManagementObject* in the parent
ExecuteCommand (the generic one).
I will also be in need of retrieving related users, such as the user who
reserved the item
*public EnterpriseManagementObject GetReservedByUser()*
*{*
*    ManagementPackRelationship mprReservedBy =
mpLendableItemLibrary.GetRelationship(\"CB\_ReservedBy\");*
*
    foreach
(EnterpriseManagementRelationshipObject\<EnterpriseManagementObject\>
obj in*
*       
ManagementGroup.EntityObjects.GetRelationshipObjectsWhereSource\<EnterpriseManagementObject\>(ManagementObject.Id,
TraversalDepth.OneLevel, ObjectQueryOptions.Default))*
*    {*
*        if (obj.RelationshipId == mprReservedBy.Id)*
*            return obj.TargetObject;*
*    }*
*    return null;*
*}*
This is just an altered code snippet from [Rob
Ford](http://scsmnz.net/c-code-snippets-for-service-manager-1/).
Now let\'s get on with lending out an item. First I will be validating
that the item is actually lendable, ie. someone reserved it, and the
status is \'Reserved\'.
*EnterpriseManagementSimpleObject currentStatusEMO =
GetCurrentStatus();*
*EnterpriseManagementObject reservedBy = GetReservedByUser();*
*
if (reservedBy != null &&
currentStatusEMO.ToString().Equals(mpEnumReserved.ToString()))*
*{*
I am already using the helper functions! See this
[post](http://codebeaver.blogspot.dk/2014/05/comparing-enumeration-values-in-service.html)
on comparing enumerations.
Next we will be creating a \'borrowed\' relationship between the user
who reserved the item and the item.
*EnterpriseManagementObjectProjection projection
= ManagementObjectProjection;*
*ManagementPackRelationship mprBorrowedBy =
mpLendableItemLibrary.GetRelationship(\"CB\_BorrowedBy\");*
*
projection.Add(reservedBy, mprBorrowedBy.Target);*
So we simply retrieve the projection defined earlier in this post and
then add the relationship. Note that the relationship is defined as
*\<RelationshipType ID=\"CB\_BorrowedBy\" Accessibility=\"Public\"
Abstract=\"false\" Base=\"System!System.Reference\"\>*
*  \<Source ID=\"Source\_bad06373\_9362\_433d\_be2f\_adf7aa2b5912\"
MinCardinality=\"0\" MaxCardinality=\"2147483647\"
Type=\"CB.LendableItem\" /\>*
*  \<Target ID=\"Target\_87f8bbbd\_5aba\_4013\_aaf1\_b2f15c00addc\"
MinCardinality=\"0\" MaxCardinality=\"1\"
Type=\"MicrosoftWindowsLibrary!Microsoft.AD.User\" /\>*
*\</RelationshipType\>*
which is why we use *mprBorrowedBy.Target and
not mprBorrowedBy.Source*.
In order to avoid commit clashing (calling commit on the same object in
succession) properties in the projection is entered as
*DateTime now = DateTime.Now;*
*projection.Object\[mpLendableItemLibrary.GetClass(\"CB.LendableItem\"),
\"CB\_BorrowedDate\"\].Value = now;*
*
// must be returned within 28 days*
*projection.Object\[mpLendableItemLibrary.GetClass(\"CB.LendableItem\"),
\"CB\_ReturnDate\"\].Value = now.AddDays(28);*
*
// status is now borrowed*
*projection.Object\[mpLendableItemLibrary.GetClass(\"CB.LendableItem\"),
\"CB\_Status\"\].Value = mpEnumBorrowed;*
*
// commit on projection will also commit the object*
*projection.Commit();*
Return item is somewhat similar, except that we need to remove some
relationships. What I ended up with
*EnterpriseManagementSimpleObject currentStatusEMO =
GetCurrentStatus();*
*EnterpriseManagementObject borrowedBy = GetBorrowedByUser();*
*
if (borrowedBy != null &&
currentStatusEMO.ToString().Equals(mpEnumBorrowed.ToString()))*
*{  *
*    ManagementPackRelationship mprReservedBy =
mpLendableItemLibrary.GetRelationship(\"CB\_ReservedBy\");*
*    ManagementPackRelationship mprBorrowedBy =
mpLendableItemLibrary.GetRelationship(\"CB\_BorrowedBy\");*
*
// Remove the related users* *   
(ManagementObjectProjection\[mprReservedBy.Target\].First() as
IComposableProjection).Remove();*
*    (ManagementObjectProjection\[mprBorrowedBy.Target\].First() as
IComposableProjection).Remove();*
*
ManagementObjectProjection.Object\[mpLendableItemLibrary.GetClass(\"CB.LendableItem\"),
\"CB\_BorrowedDate\"\].Value = null;*
*   
ManagementObjectProjection.Object\[mpLendableItemLibrary.GetClass(\"CB.LendableItem\"),
\"CB\_ReservedDate\"\].Value = null;*
*   
ManagementObjectProjection.Object\[mpLendableItemLibrary.GetClass(\"CB.LendableItem\"),
\"CB\_ReturnDate\"\].Value = null;*
*   
ManagementObjectProjection.Object\[mpLendableItemLibrary.GetClass(\"CB.LendableItem\"),
\"CB\_Status\"\].Value = mpEnumAvailable;*
*
    ManagementObjectProjection.Commit();*
*} *
In part 2b I will be adding an offering on the portal allowing a user to
reserve the item. I may also elaborate abit on the current solution (ex.
returning items in bulks).
Full source-code available [here](http://filebin.ca/1ODFsHFJHTEn).
```
```
