You can often find what you are looking for using the advanced search
feature in Service Manager, but the process is tedious as it only
remembers the class you last searched for. If you often use the exact
same search queries then the great Anton Gritsenko [have a
solution](https://gallery.technet.microsoft.com/Advanced-Search-with-Saver-fbe5b6af) with
the option of saving your queries. Unfortunately this solution cannot
change the query once saved.

```
A middle ground would be to have a custom task that takes one or more
inputs and queries a specific class based on that input.
```
```
```
```
Beaver Dams Inc. sometimes include invoice numbers in the description
field of incidents and service request. This does not happen often
enough to justify extending both classes with a specific field for the
invoice number. Also both types of work items are not annotated in any
way in order to identify which incidents and service requests contains
the invoice numbers.
```
```
```
```
The solution is a query on the description property of the work item
class. The description must contain a variable string (the invoice
number). This is fairly easy to do using advanced search, but does
require you to add the desription property in each search (it remembers
the class picked in each session). As I will show it is also not that
difficult (once you know how) to create a custom console task that
executes the query with a variable property value.
```
```
```
```
***Disclaimer**: A lot of this code is heavily inspired by the
aforementioned solution by Anton.*
```
```
```
```
First order of business is actually installing the \"Advanced Search
with Saver\". It will cleverly hook into the default advanced search and
ask if you wish to save the query. Search for objects of the class Work
Item and add the property Description. Doesn\'t matter what you input,
this will be the variable component of the query in the console task.
```
![](//1.bp.blogspot.com/-sboGr-hYlPs/VYnUmjf2FfI/AAAAAAAASj0/bn5SyvVs-vw/s640/advsearch.png)
```
Likely nothing will turn up. After closing the window you will be
prompted to save the query. Click \"yes\" and enter a query name. Name
it something that you can easily find in the registry later on, ex.
*iwetmybed*. Start the registry editor and search for the query name in
HKEY\_USERS. I will not show it here as it is quite a lot of text. The
part we want to concern ourselves with looks somewhat like this:
```
```
```
```
<Expression>
<SimpleExpression>
<ValueExpressionLeft>
<Property>$Context/Property[Type='f59821e2-0364-ed2c-19e3-752efbb1ece9']/e5162c95-9469-924c-2298-9e351e0dc383$</Property>
</ValueExpressionLeft>
<Operator>Like</Operator>
<ValueExpressionRight>
<Value>%whatever%</Value>
</ValueExpressionRight>
</SimpleExpression>
</Expression>
```
That looks familiar! The entire query will be inserted as a giant block
of text into our code (remeber to escape the double quotes) where
*whatever* will be replaced by a string variable. This variable could
come from anywhere; I have a window popup and ask for the invoice
number.
```
```
```
```
The core of the code then looks like (omitting some of the query for
brevity)
```
```
```
SearchNodeProvider searchNodeProvider = (SearchNodeProvider)FrameworkServices.GetService(typeof(SearchNodeProvider));
String sDescriptionContains = (String)inputWindow.InputText.Text;
String advancedSearchConfiguration = "<Data>..." +
"<Expression>" +
"<SimpleExpression>" +
"<ValueExpressionLeft>" +
"<Property>$Context/Property[Type='f59821e2-0364-ed2c-19e3-752efbb1ece9']/e5162c95-9469-924c-2298-9e351e0dc383$</Property>" +
"</ValueExpressionLeft>" +
"<Operator>Like</Operator>" +
"<ValueExpressionRight>" +
"<Value>%" + sDescriptionContains + "%</Value>" +
"</ValueExpressionRight>" +
"</SimpleExpression>" +
"</Expression>" +
"</Criteria> ...";
searchNodeProvider.AdvancedSearchConfig = advancedSearchConfiguration;
Uri uri = new Uri(((object)NavigationModel.NavigationRoot).ToString() +
"Windows/Search/ConsoleDisplay/Advanced");
NavigationModel.BeginOpenLink(
NavigationModel.FindView((object)null,
(Uri)Microsoft.EnterpriseManagement.UI.Core.Shared.NavigationConstants.ConsoleWindowUri,
(FindViewCriteria)1),
uri,
null,
(object)null);
```
I will not pretend to know exactly what is going on. I was \"inspired\"
by a decompiled version of the *Advanced Search with Saver*. But as you
can see the SearchNodeProvider is fed a search configuration (the one we
got from registry). The NavigationalModel is then told to open the
specified URI, and voila the search results window is opened with the
found objects that matches the search configuration we fed the
SearchNodeProvider.
You can download the entire source
here](https://gallery.technet.microsoft.com/Custom-Console-Task-for-30acf9bf).
Happy coding.
*Edit*: It is needed to change the *thisMPID* variable in
*LocalizationHelper.cs* to the guid of the management pack that contains
the stringresources used. In the example code, this is also where the
console task is defined, hence you will have to import the bundle, get
the MP id, change the code, compile, bundle, and import again. I suggest
looking at my [previous
blogpost](http://codebeaver.blogspot.dk/2015/06/automating-custom-code-testing-in.html)
to automate this process.
```
```

**Converted from html using [convert.ps1](https://github.com/spaelling/Blog/blob/master/convert.ps1)**

