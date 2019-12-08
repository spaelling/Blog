While working on part 2 of my adventure into Service Manager
customization I came across a seemingly simple problem; comparing two
enumeration values. I wanted to change the value bound to a custom
configuration item if it had a specific value, and it seemed a bit
lackluster to compare the DisplayNames of the two. I would rather
compare GUIDs or something similarly unique.
After spending ages on figuring out how to get the GUID out of the bound
enumeration value I found that the toString method actually provided me
with what I needed.

First a bit of setup. I need the MP that defines the custom class I
made

*ManagementPack mpLendableItemLibrary =
ManagementGroup.ManagementPacks.GetManagementPack(new
Guid(\"370a302c-9b0c-6c1a-033d-9b97f8406db5\")); *

I also need the instance as an EnterpriseManagementObject. In the
ExecuteCommand a list of nodes is provided (containing as many nodes as
selected in a view, or just one in a form). Thus I can get it by

*managementObject = node\[\"\$EMOInstance\$\"\] as
EnterpriseManagementObject*

Or (Suggested by Rob Ford)

*if (node is EnterpriseManagementObjectNode)*
*{*
*    managementObject = (node as
EnterpriseManagementObjectNode).SDKObject;*
*}*
*else if (node is EnterpriseManagementObjectProjectionNode)*
*{*
*    EnterpriseManagementObjectProjection emop =
(EnterpriseManagementObjectProjection)(node as
EnterpriseManagementObjectProjectionNode).SDKObject;*
*    managementObject = emop.Object;*
*}*

I actually couldn\'t use the instance of IDataItem to do the comparison.
The enumeration is defined in the same MP as the custom class.

*ManagementPackEnumeration mpEnumBorrowed =*
*   
mpLendableItemLibrary.GetEnumerations().GetItem(\"Enum.Borrowed\");*

I can get the property *CB\_Status* by

*EnterpriseManagementSimpleObject currentStatusEMO
= managementObject \[mpLendableItemLibrary.GetClass(\"CB.LendableItem\"),
\"CB\_Status\"\];*

And finally I can do the comparison (both ToString methods provide me
with the name of the enumeration which also must be unique).

*if(currentStatusEMO.ToString().Equals(mpEnumBorrowed.ToString()))*
*{*
*    // do something!*
*} *



```

```
