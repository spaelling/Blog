I wanted to figure out what we were spending our money on, but our bank
is lacking behind when it comes to finance insight, so what better way
than to use [PowerBI](https://app.powerbi.com/)?

First you need to export your bank statements into CSV. We have multiple
accounts, so I just looked into the account that we use for everyday
shopping (food, etc.). I had some trouble importing into PowerBI, so I
imported the CSV data into Excel where you then have to select (all) the
data and make it into a table (ctrl+t) before you can import it into
PowerBI.

I had to sanitize the data; removing transfers from one account to
another and purchases that should have been made on another account. If
you spot something later simply remove the row in excel and import the
file again.

[![](https://2.bp.blogspot.com/-hQbn5nrqx7I/V9ukS_T9eWI/AAAAAAAAStE/UP4pXGlFqqYEmVDFtaGuaJZ7QnMgLPRmQCK4B/s640/1.png){width="640"
height="528"}](//2.bp.blogspot.com/-hQbn5nrqx7I/V9ukS_T9eWI/AAAAAAAAStE/UP4pXGlFqqYEmVDFtaGuaJZ7QnMgLPRmQCK4B/s1600/1.png)

You are now ready to create some reports based on the bank statement
data. It should look something like this (if there is only a single row
in the *fields* box it means that PowerBI was unable to make sense of
the data):

[![](https://1.bp.blogspot.com/-vaG1ISkRCmA/V9ulY27UFiI/AAAAAAAAStM/FFo-SL6Yl5k-jWdhoM77xVPaGcg2dcoBwCK4B/s640/2.png){width="640"
height="376"}](//1.bp.blogspot.com/-vaG1ISkRCmA/V9ulY27UFiI/AAAAAAAAStM/FFo-SL6Yl5k-jWdhoM77xVPaGcg2dcoBwCK4B/s1600/2.png)

Now check the box next to the Σ and then one of the other options and
then click the pie-chart icon. My bank statement comes with category and
sub-category for each entry. If you have some sort of categorisation,
and checked that, then you will see something like this (without
redactions):

[![](https://4.bp.blogspot.com/-WeNZsl5rfnA/V9unbNrimnI/AAAAAAAAStY/mL5xTDW7-5ML6JDoDOcCGJ0qh5Gjlw9zgCK4B/s640/3.png){width="640"
height="612"}](//4.bp.blogspot.com/-WeNZsl5rfnA/V9unbNrimnI/AAAAAAAAStY/mL5xTDW7-5ML6JDoDOcCGJ0qh5Gjlw9zgCK4B/s1600/3.png)
Wow! Ok, you could do that in Excel also (I would spend hours how to
figure this out in Excel though). It simply shows the distribution of
purchases into each category. The big one is grocery-shopping, which is
the primary purpose for this account.

Now comes the magic. Deselect the graph and then again click on the Σ,
and whatever translates into an entry description and select the table
icon. That is more or less just what we have in Excel, right?

Select one of the categories in the piechart and see what happens.

[![](https://3.bp.blogspot.com/-PtWrXc6MWlg/V9upBSI4wVI/AAAAAAAAStg/koCHfjS-DvYCbdAs8hejertb-t1E9S2QACK4B/s640/4.png){width="640"
height="372"}](//3.bp.blogspot.com/-PtWrXc6MWlg/V9upBSI4wVI/AAAAAAAAStg/koCHfjS-DvYCbdAs8hejertb-t1E9S2QACK4B/s1600/4.png)

It now shows only the entries (summary of the amount) in the table that
are related to the category that you selected. This is just the tip of
the iceberg. PowerBI can do much more than that!

Finally you can figure out what your wife is spending all your money on
;)

```

```
