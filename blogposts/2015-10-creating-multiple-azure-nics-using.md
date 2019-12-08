I have started playing around with ARM and Azure in general and wanted
to get my feet wet with linked templates and multiple instances. My very
gifted colleague Kristian Nese has [already covered template
linking](http://kristiannese.blogspot.dk/2015/10/azure-resource-manager-linking-templates.html)
just fine, but I have yet to find a simple example on how to use
multiple instances (honestly, I didn\'t try that hard, I want to do it
myself).\
\
Anyways, I thought I would share what I have done so far. It is a good
introduction to [multiple
instances](https://azure.microsoft.com/en-us/documentation/articles/resource-group-create-multiple/) in
ARM templates, and also get to use a few of the [template
functions](https://azure.microsoft.com/en-us/documentation/articles/resource-group-template-functions/).
I will not provide a full solution (strongly suggest you piece it
together yourself for the learning experience), but rather snippets and
explanations (to the best of my knowledge).\
\
If you are new to ARM templates: go away. No, just kidding, but do come
back when you have the basics covered. I attended [this hands on
lab](https://github.com/azuredk/azure-arm-hol) recently and found the
excercises was an excellent learning experience. The teacher suggested
*not* to use Visual Studio as you miss out on learning some of the
basics of ARM templates. Follow that advice and just use your prefered
json-editor (Sublime Text 2).\
\
We will jump right in. The following snippet creates multiple NICs in
Azure based on a parameter *namePrefixes* which we use to prefix various
resources.\
\

    "namePrefixes": {
          "type": "array",
          "defaultValue": [
            "dc",
            "sql",
            "scsm"
          ]
        }

\
The resource NICs are declared as follows\
\

    {
      "dependsOn": [
        "[concat('Microsoft.Resources/deployments/',  parameters('vnetName'))]",
        "[concat('Microsoft.Network/publicIPAddresses/', parameters('namePrefixes')[copyIndex()], '-', variables('pulicIPPostfix'))]"
      ],
      "name": "[concat(parameters('namePrefixes')[copyIndex()], '-', variables('nicPostfix'))]",
      "type": "Microsoft.Network/networkInterfaces",
      "location": "[resourceGroup().location]",
      "apiVersion": "2015-06-15",
      "copy": {
        "name": "nicCopy",
        "count": "[length(parameters('namePrefixes'))]"
      },
      "properties": {
        "ipConfigurations": [
          {
            "name": "[concat('ipconfig', copyIndex())]",
            "properties": {
              "privateIPAllocationMethod": "static",
              "privateIPAddress": "[concat(variables('addressPrefixSplit')[0], '.', variables('addressPrefixSplit')[1], '.', variables('addressPrefixSplit')[2], '.', add(copyIndex(), 4))]",
              "subnet": {
                "id": "[variables('subnetID')]"
              },
              "publicIPAddress": {
                "id": "[resourceId('Microsoft.Network/publicIPAddresses',concat(parameters('namePrefixes')[copyIndex()], '-', variables('pulicIPPostfix')))]"
              }
            }
          }
        ]
      }
    }

\
First we need to indicate that the nics depend on a virtual network.
Here I am using Microsoft.Resources/deployments because the virtual
network has been deployed using a linked template. We also depend on
some public ip addresses that we have created using multiple instances
also.\
The naming scheme is to iterate the *namePrefixes* array and postfix the
variable *nicPostfix* (mine has the value \"nic\").\
Now in order to provide static IP addresses we use the variable
*addressPrefixSplit* which is defined as\
\

    "addressPrefixSplit": "[split(parameters('addressPrefix'), '.')]"

We simply split the *addressPrefix* parameter on \'.\', ex. 10.0.0.0/16
which is also used to create the virtual network. The IP address is then
the first 3 octets of the *addressPrefix* and the 4th octet is the value
of copyIndex() + 4 which would give us the addresses: 10.0.0.4,
10.0.0.5, and 10.0.0.6.\
\
The public IP Address is a reference to the resource ID of public IP
addresses created using the same approach:\
\

    {
          "apiVersion": "2015-06-15",
          "type": "Microsoft.Network/publicIPAddresses",
          "location": "[resourceGroup().location]",
          "name": "[concat(parameters('namePrefixes')[copyIndex()], '-', variables('pulicIPPostfix'))]",
          "copy": {
            "name": "pipCopy",
            "count": "[length(parameters('namePrefixes'))]"
          },
          "properties": {
            "publicIPAllocationMethod": "[variables('publicIPAllocationMethod')]"
          }
    }

<div>

Now you are ready to deploy a billion trillion NICs with just a few
lines of json (not counting the billion trillion lines of name prefixes
:D)

</div>

<div>

</div>
