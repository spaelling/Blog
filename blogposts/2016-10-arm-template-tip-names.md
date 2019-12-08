Naming resources in ARM templates can be quite lengthy. This is an
example of naming a network interface:\
\

<div>

    "name": "[concat(parameters('vmNamePrefix'), '-', padLeft(copyIndex(1), 2, '0'), variables('nicPostfix'), '-', padLeft(copyIndex(1), 2, '0'))]",

</div>

\
And we have to reference this at a later point for the virtual machine
resource. If we then change the name, we will have to remember to change
this reference also.\
\
What we can do is to define the name in the variables section like
this:\
\

<div>

        "nic": {
          "name": "[concat(parameters('vmNamePrefix'), '-', padLeft('{0}', 4, '0'), variables('nicPostfix'), '-', padLeft('{0}', 4, '0'))]"
        }

</div>

\
(I like to group variables). And then reference this variable in the
resource like:\
\

<div>

    "name": "[replace(variables('nic').name, '{0}', string(copyIndex(1)))]",

</div>

\
What I have done is to make **{0}** a placeholder and then replace it
with the result from **copyIndex()**. We now have a central location to
change the name if needed with no need to update any resources.\
\
Would be cool if we had a template function for formatting:\
\

<div>

    "name": "[format(variables('nic').name, copyIndex(1), '-nic')]"

</div>

\
It would take the string as input and then a variable number of
additional arguments. Ex.\
\
\

<div>

    "nic": {
       "name": "concat(parameters('vmNamePrefix'), '0{0}', '{1}')]"
    }

</div>

\
would become(**{0}** is replaced with the result from **copyIndex(1)**
and **{1}** replaced with **-nic**):\
\

<div>

    "VM01-nic"

</div>

\
And it could be made more advanced, perhaps leaning on the good ol\'
*sprintf.*

<div>

</div>
