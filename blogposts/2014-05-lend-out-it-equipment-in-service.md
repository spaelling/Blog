Inspired by John Hennens [Building Custom Forms for Service Manager with
Visual
Studio](http://www.concurrency.com/blog/building-custom-forms-for-service-manager-with-visual-studio/) I
will give an example that is somewhat closer to a reallife Service
Manager customization. Many IT departments lend out equipment to
employees. One could use something like a service request to keep track
of who has borrowed what, and besides the fact that a service request
shouldn\'t be long lived by design, a seperate system (be that post-it
notes or something more advanced) is needed to keep track of the
equipment. So what we wish from a Service Manager customization is

1.  Users can browse and reserve equipment on the self service portal
2.  Items can be managed in the console (details will follow)
```
First we will create a new custom class based on the configuration item
class with the following properties and relationships:
```
```
-   Borrowed Date - Datetime - The date the item was borrowed by a user
-   Reserved Date - Datetime - The date the item was reserved by a user
-   Return Date - Datetime - The date the item must be returned by a
user
-   Status - List - A list of the different states an item can be in,
Available, Reserved, Borrowed, Overdue
-   Reserved by - Relationship - The user the item is reserved by
-   Borrowed by - Relationship - The user the item is borrowed by
```
We then create a [type
projection](http://codebeaver.blogspot.dk/2014/04/nested-type-projections-in-scsm-review.html) exposing
these two relationships allowing us to easily access these when building
the form.
```
```
```
```
```
We need a custom form that can display all of these properties (and
more), and console tasks to manage them:
```
```
-   Borrow item - Changes the status to \'Borrowed\' and updates the
\'Borrowed by\' relationship.
-   Return item - Changes the status to \'Available\' and deletes the
\'Borrowed by\' relationship.
-   Reset item - Sets all properties to default values and removes
relationships.
```
We also need a runbook that reserves the requested item. For the sake of
it I will be using SMA (or die trying).
Enough talk, more action! First I created the custom form. You can view
the entire XAML-code [here](http://pastebin.com/wejAntMs).
It looks like this btw:
![](//1.bp.blogspot.com/-5FRUp3B1x9Q/U3H70qV8a0I/AAAAAAAAC6M/6NMQpIXy5JM/s1600/Form1.PNG)
It seems that there is currently a bug in WPFToolkit where the
Datepicker resides which makes the \"Show Calendar\" button looks greyed
out as if it was disabled.
**Edit:**
This](http://www.concurrency.com/blog/show-calendar-button-in-custom-service-manager-forms/)
is supposedly a fix to the issue, but the datepickers are still wrong in
my implementation. Bummer :(
We will using the form primarily for viewing and not editing. For this
purpose I will create a few console tasks.
As explained by John one will need to target the custom form at a type
projection in order to access class relationships directly using XAML.
The class definition is described [here](http://pastebin.com/uEBUbnY7),
along with type projections and values for the status enumeration.
The custom form is defined in XML [here](http://pastebin.com/YPgz8Fze).
Note that I have signed the assembly using the same key as I use for
signing management packs. This can be done in Visual Studio in
properties for a project in the signing tab. Check the \"Sign the
assembly\" box and select the key to sign with. I am also signing all
MPs except the one containing views.
All source code can be found [here](http://filebin.ca/1MUFsIOOJ7Rp), and
a ready to import MP-bundle [here](http://filebin.ca/1MUE8tPEKoVM).
In [part
2](http://codebeaver.blogspot.dk/2014/05/lend-out-it-equipment-in-service_30.html)
I will be doing console tasks and putting an offering on the portal for
end-users to request reservation of an item. In part 3 I will attempt at
adding an easy to view history to the custom form that shows who
reserved or borrowed an item in the past.
***Update:***
I just realized I was not using a UserPicker, the obvious choice for
picking users, DOH! Simply use this code in place of the
SingleInstancePicker
*\<scwpf:UserPicker User=\"{Binding Path=IsReservedBy, Mode=TwoWay,
UpdateSourceTrigger=PropertyChanged}\"/\>*
```
```

**Converted from html using [convert.ps1](https://github.com/spaelling/Blog/blob/master/convert.ps1)**

