Not too long ago I showed how to [deploy your custom
code](http://codebeaver.blogspot.dk/2015/06/automating-custom-code-testing-in.html) to
Service Manager using a script. What I later found out is that VS can do
it all for you with the help of VSAE.
I will base the code off of my previous blog post, and I suggest you
read
[it](http://codebeaver.blogspot.dk/2015/06/custom-task-for-work-item-search-in.html)
before continuing. Also get acquainted with VSAE in [Authoring Type
Projections in
VSAE](http://codebeaver.blogspot.dk/2015/06/authoring-type-projections-in-vsae.html).
I will not repeat some of the principles mentioned there.

First we open the solution that contains your code. Add an additional
project to this solution and select the \"Service Manager 2012 R2
Management Pack\" template (or whatever version that suits your
environment). You will need to add references to the following
management packs

-   Microsoft.EnterpriseManagement.ServiceManager.UI.Console
-   ServiceManager.ConfigurationManagement.Library
-   ServiceManager.WorkItem.Library

```

They can be found in ex. the library folder of the Authoring Tool
installation path.

We also add the dll we are coding as a reference. When added select it
and click F4 (properties) and change *Package To Bundle* to **True**.
This means it will be included in the .mpb file we are building.

Add a new item and select \"Empty Management Pack Fragment\". We will
call it ConsoleTask.mpx. It doesn\'t matter what you call all of these
mpx-files. The names will not appear anywhere in the final product.


::: {.separator}
[![](//4.bp.blogspot.com/-Tuh6l1Qf_Cg/VaZX9lXoaRI/AAAAAAAASmI/H374ZFloJhY/s640/1.png){width="640"
height="442"}](//4.bp.blogspot.com/-Tuh6l1Qf_Cg/VaZX9lXoaRI/AAAAAAAASmI/H374ZFloJhY/s1600/1.png)
:::


Copy paste in the code below:


    <ManagementPackFragment SchemaVersion="SM2.0" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
      <Categories>
        <!-- provide an ID for the category -->
        <Category ID="CB.ConsoleTask.CustomWISearch.Category" 
                  Value="MESUC!Microsoft.EnterpriseManagement.ServiceManager.ManagementPack">
          <!-- this is the same name as the VS project or the management pack ID found in project properties -->
          <ManagementPackName>CB.ConsoleTask.CustomWISearch</ManagementPackName>
          <ManagementPackVersion>1.0.0.0</ManagementPackVersion>
          <!-- you can get the public key token using sn.exe, read more at http://scsmnz.net/sealing-a-management-pack-using-fastseal-exe/ -->
          <ManagementPackPublicKeyToken>098dab1c6092cc7a</ManagementPackPublicKeyToken>
        </Category>
      </Categories>
      <Presentation>
        <ConsoleTasks>
          <!-- provide an ID for the console task -->
          <!-- provide a Target for the console task -->
          <ConsoleTask ID="CustomSearchTask.ConsoleTask" 
                       Accessibility="Public" 
                       Enabled="true" 
                       Target="MESUC!Microsoft.EnterpriseManagement.ServiceManager.UI.Console.ConsoleTaskTarget" 
                       RequireOutput="false">
            <Assembly>MESUC!SdkDataAccessAssembly</Assembly>
            <Handler>Microsoft.EnterpriseManagement.UI.SdkDataAccess.ConsoleTaskHandler</Handler>
            <Parameters>
              <!--Name of the assembly file without extension -->
              <Argument Name="Assembly">CB.SCSM.CustomWISearch</Argument>
              <!-- classname of your ConsoleCommand task including namespace -->
              <Argument Name="Type">CB.SCSM.CustomWISearch.CustomSearchTask</Argument>
            </Parameters>
          </ConsoleTask>
        </ConsoleTasks>
        <FolderItems>
          <!-- Show in Work Item root -->
          <FolderItem ElementID="CustomSearchTask.ConsoleTask" 
                      ID="CustomSearchTask.ConsoleTask.FolderItem" 
                      Folder="SWL!ServiceManager.Console.WorkItem.Root"/>
          <!-- Show in CI root -->
          <FolderItem ElementID="CustomSearchTask.ConsoleTask"
                      ID="CustomSearchTask.ConsoleTask.FolderItem"
                      Folder="SCL!ServiceManager.Console.ConfigurationManagement.ConfigItem.Root"/>

          </FolderItems>
      </Presentation>

      <Resources>
        <!-- 
        ID is normally not used if ever
        Filename including extension (.dll)
        QualifiedName - include PublicKeyToken if you sign the assembly (strongly suggested)
        -->
        <Assembly ID="Assembly.ConsoleTask.CustomWISearch" 
                  Accessibility="Public" 
                  FileName="CB.SCSM.CustomWISearch.dll" 
                  HasNullStream="false" 
                  QualifiedName="CB.SCSM.CustomWISearch, Version=1.0.0.0, Culture=neutral, PublicKeyToken=098dab1c6092cc7a" />
      </Resources>
    </ManagementPackFragment>


It works right off the bat with the [Custom Task for Work Item Search in
Service
Manager](http://codebeaver.blogspot.dk/2015/06/custom-task-for-work-item-search-in.html) as
mentioned earlier. And should be fairly easy to change as needed using
the provided comments.

We will also do abit of \"localization\". I haven\'t found [the
way]{.underline} to do localization in custom console tasks, so this is
just one way to do it. If using my code here is a nice optimization for
connecting to the management server. I haven\'t gotten around changing
the downloadeable source yet.


    //Connect to the server
    Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession session = (Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession)FrameworkServices.GetService<IManagementGroupSession>();
    if(session == null)
    {
        //Get the server name to connect to
        String strServerName = Registry.GetValue("HKEY_CURRENT_USER\\Software\\Microsoft\\System Center\\2010\\Service Manager\\Console\\User Settings", "SDKServiceMachine", "localhost").ToString();
        // connect
        _mg = new EnterpriseManagementGroup(strServerName);
    }
    else
    {
        _mg = session.ManagementGroup;
    }


It piggybacks the existing connection in place of connecting a new one.

Create two more empty management pack fragments and paste in the code
below. It doesn\'t matter what you call them, I would suggest something
along the lines of LocalizationLANG.mpx where LANG is the language of
the displaystrings contained.


    <ManagementPackFragment SchemaVersion="SM2.0" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
      <Presentation>
        <StringResources>
          <StringResource ID="SearchDialogTitle.StringResource"/>
          <StringResource ID="SearchDialogSearchBtn.StringResource"/>
        </StringResources>
      </Presentation>
      <LanguagePacks>
        <LanguagePack ID="ENU" IsDefault="true">
          <DisplayStrings>
            <DisplayString ElementID="CB.ConsoleTask.CustomWISearch">
              <Name>CB.ConsoleTask.CustomWISearch</Name>
            </DisplayString>
            <DisplayString ElementID="CustomSearchTask.ConsoleTask">
              <Name>Search!</Name>
            </DisplayString>
            <DisplayString ElementID="SearchDialogTitle.StringResource">
              <Name>Search!</Name>
            </DisplayString>
            <DisplayString ElementID="SearchDialogSearchBtn.StringResource">
              <Name>Search!</Name>
            </DisplayString>
          </DisplayStrings>
        </LanguagePack>
      </LanguagePacks>  
    </ManagementPackFragment>

The other one you can fill in your language of choice.

In the project properties  we go to build and check \"Generate sealed
and signed management pack\" and select the .snk file to use for signing
the management pack. In the Management group tab add and set the proper
management group as default.


::: {.separator}
[![](//2.bp.blogspot.com/-Vw8UZTqB30Y/VaZalw2h_iI/AAAAAAAASmU/6BTi4VuadAY/s640/2.png){width="640"
height="320"}](//2.bp.blogspot.com/-Vw8UZTqB30Y/VaZalw2h_iI/AAAAAAAASmU/6BTi4VuadAY/s1600/2.png)
:::


And finally in the Deployment tab you check auto-increment version,
start action must be \"Deploy projects to default management group
only\" and projects to deploy is \"Deploy StartUp projects only\". The
startup project can be selected in solution properties.


::: {.separator}
[![](//4.bp.blogspot.com/-bbsAkGJ3glY/VaZbZVmPcyI/AAAAAAAASmc/0_mXBbT488w/s640/3.png){width="640"
height="320"}](//4.bp.blogspot.com/-bbsAkGJ3glY/VaZbZVmPcyI/AAAAAAAASmc/0_mXBbT488w/s1600/3.png)
:::


You should be good to go. First build using ctrl+shift+b (or right click
solution and select *build solution*). Resolve any errors. When
error-free (let me know in the comments below if I missed something) we
can deploy the project by hitting F5.

```

```

```
