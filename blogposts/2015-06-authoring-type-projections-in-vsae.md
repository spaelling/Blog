It seems that VSAE is not that widely used. That may be a lack of
information on the hows and the whats of things. So today I will just
show something basic; authoring a type projection.

The VSAE can be downloaded from
[here](http://www.microsoft.com/en-us/download/details.aspx?id=30169).
You will need Visual Studio 2012/13 Ultimate or Professional.
Now in Visual Studio create a new project. Select Templates-\>Management
Pack-\>Service Manager and select the template that matches your
environment version. I will pick the R2 one. I will name
mine *Codebeaver.IR.TypeProjection.Tutorial*.
I will do a type projection on the incident class, hence we will need to
reference the MP where this is defined. If you don\'t know this there
are a few ways to find out. I prefer using powershell. Open a Service
Manager Shell which will load the native service manager powershell
module. Enter
```
*Get-SCSMClass -Name \"\*incident\" -ComputerName SM01*
```
```
```
```
This tells it to look for classes that matches \*incident (anything
followed by incident) and the computername is the name of your
management server.
```
```
This will give you three results. We are looking for the
*System.WorkItem.Incident* class. Repeat the command with this more
specific name. To get the management pack we can write
```
```
```
```
*(Get-SCSMClass -Name \"System.WorkItem.Incident\" -ComputerName
SM01).getmanagementpack()*
```
```
*
*
```
```
Which tells us that the incident class is found in the
System.WorkItem.Incident.Library management pack.
```
```
I find the easiest approach is to go to C:\\Program Files
(x86)\\Microsoft System Center 2012\\Service Manager Authoring (or where
ever you have installed the authoring console), and then simply search
for the managegement pack. When found right click and \"open file
location\". Copy the path.
```
```
```
```
Now back in visual studio right click the references and \"Add
reference\...\"
```
```
```
::: {.separator}
[![](//2.bp.blogspot.com/-P_evR856A90/VZEdZhT84XI/AAAAAAAASlU/I2EAXxJSn-g/s640/addref.png){width="640"
height="400"}](//2.bp.blogspot.com/-P_evR856A90/VZEdZhT84XI/AAAAAAAASlU/I2EAXxJSn-g/s1600/addref.png)
:::
```
```
```
Click the browse tab and paste in the path. Scroll and look for
the System.WorkItem.Incident.Library.mp file. Now that it is added we
can reference it using an auto genereated alias.
```
```
```
```
Now right click the project and select *Add-\> New item\...* Pick the
\"empty management pack fragment\". I will name
mine *IncidentTypeProjection.mpx*.
```
```
You will be presented with some xml. Type \< and a number of possible
XML-tags are suggested.
```
::: {.separator}
[![](//1.bp.blogspot.com/-3EcLZP3hh48/VZEfocru3mI/AAAAAAAASlg/xGpK1F71gx0/s640/xml.png){width="640"
height="418"}](//1.bp.blogspot.com/-3EcLZP3hh48/VZEfocru3mI/AAAAAAAASlg/xGpK1F71gx0/s1600/xml.png)
:::
```
```
```
It will narrow down the list as you type. We want TypeDefinitions, and
inside that EntityTypes, and finally inside that TypeProjections. VSAE
will mostly present you with valid XML.
```
```
```
::: {.separator}
[![](//1.bp.blogspot.com/-tiyXXHNHz_Q/VZEgWvtG_UI/AAAAAAAASlo/dkQZSkB1WUw/s640/xml2.png){width="640"
height="418"}](//1.bp.blogspot.com/-tiyXXHNHz_Q/VZEgWvtG_UI/AAAAAAAASlo/dkQZSkB1WUw/s1600/xml2.png)
:::
```
```
```
Inside the TypeProjections tag we enter TypeProjection and then a space
and you get to pick amongst a number of possible attributes for that
tag. Sometimes it can even autocomplete the value for a given attribute,
ex. Accesibility (as there are only two possible values). You can put
anything into the ID. For type we want something that looks like:
Alias!Class. To get the alias select the management pack reference that
we just added and hit F4. Here you can see that the alias is SWIL. Hence
we enter SWIL!System.WorkItem.Incident, and we can finish the type
projection with a \>. This is a good time to build (ctrl+shift+b).
Resolve any errors (there should be none).
```
```
```
::: {.separator}
[![](//2.bp.blogspot.com/-QE1yZNecm6E/VZEjBxQL66I/AAAAAAAASl0/dClGVmqtds8/s640/xml3.png){width="640"
height="400"}](//2.bp.blogspot.com/-QE1yZNecm6E/VZEjBxQL66I/AAAAAAAASl0/dClGVmqtds8/s1600/xml3.png)
:::
```
```
```
```
```
Now we must add a component to the type projection. You must provide the
component with an alias (type in anything). the Path is a bit more
tricky, and VSAE will not help you one bit. I suggest you read my [bit
on type
projections](http://codebeaver.blogspot.dk/2014/04/nested-type-projections-in-scsm-review.html)
before you continue reading. To get the relationship part we use the
same trick as we did for getting the class. Here is a little help:
```
```
```
```
*Get-SCSMRelationshipClass -Name \"created\" -ComputerName SM01 \| fl
Name*
```
```
*
*
```
```
My component ends up looking
```
    <Component Alias="IsCreatedBy" Path="$Target/Path[Relationship='SWL!System.WorkItemCreatedByUser']$"/>
```
And no errors when building! Be really carefull with \$ and \' and \[\]
at the right places.
```
```
```
```
We also need to add a section of display strings to finish up. After the
closing TypeDefinitions add a LanguagePacks tag. It will end up looking
like this
```
```
```
      <LanguagePacks>
        <LanguagePack ID="ENU" IsDefault="true">
          <DisplayStrings>
            <DisplayString ElementID="ThisCanBeAnythingAsLongAsItIsUnique.TypeProjection">
              <Name>
                Incident (Is created by)
              </Name>
            </DisplayString>
          </DisplayStrings>
        </LanguagePack>
      </LanguagePacks>
```
```
```
Note that the LanguagePack ID must a valid ID. I haven\'t found a table
with all possible IDs (post in the comments below if you do).
```
```
```
```
We are almost there. Go to properties of the project and in the build
tab check \"generate sealed and signed management pack\". Browse for a
key file and select your snk-file (if you don\'t know this part read
[this](http://scsmnz.net/sealing-a-management-pack-using-fastseal-exe/)
to get up to speed - you just need to read the part on Create your SNK).
```
```
In the Management group tab click Add and enter your Service Manager
Management Server (you only need add it once), if already added select
it and click \"*Set as Default*\". Finally in the Deployment tab under
\"start action\" select \"Deploy projects to default management group
only\".
```
```
```
```
Build again and make sure there are not errors. Now we can deploy the
type projection directly to the server by hitting F5. That is pretty
sweet and can really speed up your development even for basic stuff such
as type projections.
```
```
```
```
The entirety of the fragment looks as below
```
```
```
    <ManagementPackFragment SchemaVersion="SM2.0" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
      <TypeDefinitions>
        <EntityTypes>
          <TypeProjections>
            <TypeProjection ID="ThisCanBeAnythingAsLongAsItIsUnique.TypeProjection" 
                            Accessibility="Public" 
                            Type="SWIL!System.WorkItem.Incident">
              <Component Alias="IsCreatedBy" 
                         Path="$Target/Path[Relationship='SWL!System.WorkItemCreatedByUser']$"
                         />
            </TypeProjection>
          </TypeProjections>
        </EntityTypes>
      </TypeDefinitions>
      <LanguagePacks>
        <LanguagePack ID="ENU" IsDefault="true">
          <DisplayStrings>
            <DisplayString ElementID="ThisCanBeAnythingAsLongAsItIsUnique.TypeProjection">
              <Name>
                Incident (Is created by)
              </Name>
            </DisplayString>
          </DisplayStrings>
        </LanguagePack>
      </LanguagePacks>
    </ManagementPackFragment>
```
```
