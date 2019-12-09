The Azure Application Gateway can also function as a Web Application
Firewall (WAF), and is a must have in any enterprise environment. In
order to audit the firewall events the **ApplicationGatewayFirewallLog**
must be ex. achieved to a storage account or even better, send to log
analytics. This can be setup in the **Diagnostic settings **tab in the
WAF.

The WAF has more than 300 rules it matches each request against, and if
the **Advanced rule configuration** is disabled then all rules enabled
and a single match will result in a request being blocked. Each rule is
also identified by an Id, and with the amount of rules we will need to
map the Id to a descriptive text. Microsoft has this readily available
in markdown
at <https://raw.githubusercontent.com/MicrosoftDocs/azure-docs/master/articles/application-gateway/application-gateway-crs-rulegroups-rules.md>,
which is what they use to generate documentation for the WAF. Currently
it is missing a few rule Ids. But we will get back to this part.
The end goal is to get something like this, presented in a Azure
dashboard.
![](https://1.bp.blogspot.com/-k9eBbJixTgY/XO0DBXLxRyI/AAAAAAAAtW4/2MgIgbN1Tdg4NrICwYDfYmzYnD_TfY4MwCLcBGAs/s640/WAF01.png)
Let\'s look at the query we need to write first.
```
// variables
let resourceId = "/SUBSCRIPTIONS/<SUBSCRIPTION_ID>/RESOURCEGROUPS/<RESOURCEGROUPNAME>/PROVIDERS/MICROSOFT.NETWORK/APPLICATIONGATEWAYS/<WAF_NAME>";
let period = 3d;
// show transactions with a block action
AzureDiagnostics
| where TimeGenerated > ago(period)
| where Category == "ApplicationGatewayFirewallLog"
| where ResourceId == resourceId
| where action_s == "Matched"
| project transactionId_s, ruleId_s, hostname_s, requestUri_s, TimeGenerated
| join (
AzureDiagnostics
| where TimeGenerated > ago(period)
| where Category == "ApplicationGatewayFirewallLog"
| where ResourceId == resourceId
| where action_s == "Blocked"
// using distinct as there will always be 0 or 2 "Blocked" entries for the transaction - resulting in duplicates when joining
| distinct transactionId_s
) on transactionId_s
| sort by TimeGenerated desc
| take 50
| project Rule = strcat(ruleId_s, ' - ', rule_mapping[ruleId_s]), Uri = strcat(hostname_s,requestUri_s),Timestamp = TimeGenerated
```
First find your WAF resource Id and paste it in. This query will look at
past 3 days of data (and we will eventually take the latest 50 entries).
The last part is only relevant in the Log Analytics query editor, but it
is best practice to limit data by date early on.
The *left* part of the join will get the transactions where the
*action* is *Matched*. Each request will generate 0 (no rule matches) or
more transactions, one for each matching rule, and two more (block
actions) if one of the rules are enabled.
Finally only the properties that are needed is projected.
The *right* part of the join is very similar, only we look transactions
where the *action* is *Blocked.* And then we project, using *distinct*,
the property *transactionId\_s*. This is the only property we need for
the join, and we use distinct as there will for each transaction be
either 0 or 2 entries. If we used project the join would double up each
*Matched* entry.
The results is then sorted by date and we *take* the latest 50 entries.
In the projection we use a dynamic array to map each rule Id to a
descriptive text, which is explained next.
The following script will generate the code we need to put before the
Log Analytics query.
```
$Markdown = (wget 'https://raw.githubusercontent.com/MicrosoftDocs/azure-docs/master/articles/application-gateway/application-gateway-crs-rulegroups-rules.md').Content
function Is-RuleId ($Value) {
return $Value -match "^[\d\.]+$"
}
# remove each line starting with # and blank lines
cls
# $VerbosePreference = 'Continue'
$Lines = $Markdown.Split('|')
$RuleId = $null
$Rules = @{}
foreach ($line in $Lines) {
if($RuleId)
{
# we just had a rule id, the next must be description
$Rules[$RuleId] = $line
$RuleId = $null
}
elseif(Is-RuleId $line)
{
$RuleId = [int]$line
}
}
# we can add missing mappings like this
$Rules['0'] = 'Mandatory rule. Inbound Anomaly Score Exceeded'
$Rules['941160'] = 'NoScript XSS InjectionChecker: HTML Injection'
$Rules['942240'] = 'Detects MySQL charset switch and MSSQL DoS attempts'
$Rules['942180'] = 'Detects basic SQL authentication bypass attempts 1/3'
$Rules['942390'] = 'SQL Injection Attack'
#$Rules['XXX'] = ''
#next we format to a Kusto mapping
#$Rules.Keys | ForEach-Object {"`t`t`"$_`" : `"$($Rules[$_])`","}
$KustoMapping =
@"
let rule_mapping = dynamic(
{
$(
$Rules.Keys | ForEach-Object {"    `"$_`" : `"$($Rules[$_])`",`n"}
)
});
"@
# $Rules.Keys.Count
# removes the very last , and put the result into clipboard
$KustoMapping -replace "(?s)(.*),(.*)", '' | clip
```
After pasting be sure to remove any blank lines in the query. The result
can then be pinned to a dashboard of your choice.
Note that if you have all rules enabled, you can skip the join entirely.
Each rule matched will result in the request being blocked. But you may
at some point disable some rules (some are very stringent), or perhaps
in a future version of WAF it can be customized at what score treshold
the request is being blocked; each matched rule will provide a score,
the sum of the score is then matched against a treshold I think is
\"greater than 0\" currently. The point of this is that some rules
matched is more dangerous than others, and the sum of them all provides
a way to determine the risk of not blocking the request.
The result of the script can be seen below.
```
let rule_mapping = dynamic(
{
"941320" : "Possible XSS Attack Detected - HTML Tag Handler",
"960343" : "Total uploaded files size too large",
"960342" : "Uploaded file size too large",
"960341" : "Total arguments size exceeded",
"960335" : "Too many arguments in request",
"958033" : "Cross-site Scripting (XSS) Attack",
"973315" : "IE XSS Filters - Attack Detected.",
"981253" : "Detects MySQL and PostgreSQL stored procedure/function injections",
"920340" : "Request Containing Content but Missing Content-Type header",
"958423" : "Cross-site Scripting (XSS) Attack",
"958422" : "Cross-site Scripting (XSS) Attack",
"958421" : "Cross-site Scripting (XSS) Attack",
"958420" : "Cross-site Scripting (XSS) Attack",
"958419" : "Cross-site Scripting (XSS) Attack",
"958418" : "Cross-site Scripting (XSS) Attack",
"958417" : "Cross-site Scripting (XSS) Attack",
"958416" : "Cross-site Scripting (XSS) Attack",
"958415" : "Cross-site Scripting (XSS) Attack",
"958414" : "Cross-site Scripting (XSS) Attack",
"958413" : "Cross-site Scripting (XSS) Attack",
"958412" : "Cross-site Scripting (XSS) Attack",
"958411" : "Cross-site Scripting (XSS) Attack",
"958410" : "Cross-site Scripting (XSS) Attack",
"958409" : "Cross-site Scripting (XSS) Attack",
"958408" : "Cross-site Scripting (XSS) Attack",
"958407" : "Cross-site Scripting (XSS) Attack",
"958406" : "Cross-site Scripting (XSS) Attack",
"958405" : "Cross-site Scripting (XSS) Attack",
"958404" : "Cross-site Scripting (XSS) Attack",
"950922" : "Backdoor access",
"958059" : "Cross-site Scripting (XSS) Attack",
"950120" : "Possible Remote File Inclusion (RFI) Attack = Off-Domain Reference/Link",
"950119" : "Remote File Inclusion Attack",
"950118" : "Remote File Inclusion Attack",
"950117" : "Remote File Inclusion Attack",
"950116" : "Unicode Full/Half Width Abuse Attack Attempt",
"0" : "Mandatory rule. Inbound Anomaly Score Exceeded",
"950110" : "Backdoor access",
"950109" : "Multiple URL Encoding Detected",
"950108" : "URL Encoding Abuse Attack Attempt",
"950107" : "URL Encoding Abuse Attack Attempt",
"973305" : "XSS Attack Detected",
"950103" : "Path Traversal Attack",
"960209" : "Argument name too long",
"960208" : "Argument value too long",
"981270" : "Finds basic MongoDB SQL injection attempts",
"981320" : "SQL Injection Attack = Common DB Names Detected",
"981317" : "SQL SELECT Statement Anomaly Detection Alert",
"981316" : "Rule 981316",
"981315" : "Rule 981315",
"981314" : "Rule 981314",
"981313" : "Rule 981313",
"981312" : "Rule 981312",
"981311" : "Rule 981311",
"981310" : "Rule 981310",
"981309" : "Rule 981309",
"981308" : "Rule 981308",
"981307" : "Rule 981307",
"981306" : "Rule 981306",
"981305" : "Rule 981305",
"981304" : "Rule 981304",
"981303" : "Rule 981303",
"981302" : "Rule 981302",
"981301" : "Rule 981301",
"981300" : "Rule 981300",
"932120" : "Remote Command Execution = Windows PowerShell Command Found",
"933110" : "PHP Injection Attack = PHP Script File Upload Found",
"981276" : "Looking for basic sql injection. Common attack string for mysql oracle and others.",
"950921" : "Backdoor access",
"981272" : "Detects blind sqli tests using sleep() or benchmark().",
"958295" : "Multiple/Conflicting Connection Header Data Found.",
"958291" : "Range = field exists and begins with 0.",
"950019" : "Email Injection Attack",
"950018" : "Universal PDF XSS URL Detected.",
"960911" : "Invalid HTTP Request Line",
"981260" : "SQL Hex Encoding Identified",
"950012" : "HTTP Request Smuggling Attack.",
"950011" : "SSI injection Attack",
"950010" : "LDAP Injection Attack",
"950009" : "Session Fixation Attack",
"950008" : "Injection of Undocumented ColdFusion Tags",
"950007" : "Blind SQL Injection Attack",
"950006" : "System Command Injection",
"950005" : "Remote File Access Attempt",
"981250" : "Detects SQL benchmark and sleep injection attempts including conditional queries",
"950003" : "Session Fixation",
"950002" : "System Command Access",
"950001" : "SQL Injection Attack",
"950000" : "Session Fixation",
"981241" : "Detects conditional SQL injection attempts",
"981251" : "Detects MySQL UDF injection and other data/structure manipulation attempts",
"950911" : "HTTP Response Splitting Attack",
"950910" : "HTTP Response Splitting Attack",
"950908" : "SQL Injection Attack.",
"981231" : "SQL Comment Sequence Detected.",
"981227" : "Apache Error = Invalid URI in Request.",
"959151" : "PHP Injection Attack",
"958230" : "Range = Invalid Last Byte Value.",
"933100" : "PHP Injection Attack = Opening/Closing Tag Found",
"973318" : "IE XSS Filters - Attack Detected.",
"942370" : "Detects classic SQL injection probings 2/2",
"960038" : "HTTP header is restricted by policy",
"960035" : "URL file extension is restricted by policy",
"960034" : "HTTP protocol version is not allowed by policy",
"960032" : "Method is not allowed by policy",
"958057" : "Cross-site Scripting (XSS) Attack",
"973313" : "XSS Attack Detected",
"960010" : "Request content type is not allowed by policy",
"960024" : "Meta-Character Anomaly Detection Alert - Repetitive Non-Word Characters",
"960022" : "Expect Header Not Allowed for HTTP 1.0.",
"960021" : "Request Has an Empty Accept Header",
"960020" : "Pragma Header requires Cache-Control Header for HTTP/1.1 requests.",
"960018" : "Invalid character in request",
"200004" : "Possible Multipart Unmatched Boundary.",
"960016" : "Content-Length HTTP header is not numeric.",
"960015" : "Request Missing an Accept Header",
"960012" : "POST request missing Content-Length Header.",
"960011" : "GET or HEAD Request with Body Content.",
"973303" : "XSS Attack Detected",
"960009" : "Request Missing a User Agent Header",
"960008" : "Request Missing a Host Header",
"960007" : "Empty Host Header",
"960006" : "Empty User Agent Header",
"981136" : "Rule 981136",
"981134" : "Rule 981134",
"981133" : "Rule 981133",
"960914" : "Multipart request body failed strict validation",
"960912" : "Failed to parse request body.",
"959073" : "SQL Injection Attack",
"950801" : "UTF8 Encoding Abuse Attack Attempt",
"913120" : "Found request filename/argument associated with security scanner",
"960904" : "Request Containing Content but Missing Content-Type header",
"960902" : "Invalid Use of Identity Encoding.",
"960901" : "Invalid character in request",
"913110" : "Found request header associated with security scanner",
"920460" : "Abnormal escape characters",
"913102" : "Found User-Agent associated with web crawler/bot",
"913101" : "Found User-Agent associated with scripting/generic HTTP client",
"913100" : "Found User-Agent associated with security scanner",
"920450" : "HTTP header is restricted by policy (%@{MATCHED_VAR})",
"921120" : "HTTP Response Splitting Attack",
"920440" : "URL file extension is restricted by policy",
"920430" : "HTTP protocol version is not allowed by policy",
"920420" : "Request content type is not allowed by policy",
"920410" : "Total uploaded files size too large",
"958002" : "Cross-site Scripting (XSS) Attack",
"942460" : "Meta-Character Anomaly Detection Alert - Repetitive Non-Word Characters",
"920400" : "Uploaded file size too large",
"942450" : "SQL Hex Encoding Identified",
"920390" : "Total arguments size exceeded",
"942440" : "SQL Comment Sequence Detected.",
"920380" : "Too many arguments in request",
"958977" : "PHP Injection Attack",
"958976" : "PHP Injection Attack",
"958056" : "Cross-site Scripting (XSS) Attack",
"958054" : "Cross-site Scripting (XSS) Attack",
"942430" : "Restricted SQL Character Anomaly Detection (args): # of special characters exceeded (12)",
"958052" : "Cross-site Scripting (XSS) Attack",
"958051" : "Cross-site Scripting (XSS) Attack",
"958049" : "Cross-site Scripting (XSS) Attack",
"958047" : "Cross-site Scripting (XSS) Attack",
"958046" : "Cross-site Scripting (XSS) Attack",
"958045" : "Cross-site Scripting (XSS) Attack",
"981018" : "Rule 981018",
"958041" : "Cross-site Scripting (XSS) Attack",
"958040" : "Cross-site Scripting (XSS) Attack",
"958039" : "Cross-site Scripting (XSS) Attack",
"958038" : "Cross-site Scripting (XSS) Attack",
"958037" : "Cross-site Scripting (XSS) Attack",
"958036" : "Cross-site Scripting (XSS) Attack",
"958034" : "Cross-site Scripting (XSS) Attack",
"942410" : "SQL Injection Attack",
"958032" : "Cross-site Scripting (XSS) Attack",
"958031" : "Cross-site Scripting (XSS) Attack",
"958030" : "Cross-site Scripting (XSS) Attack",
"920350" : "Host header is a numeric IP address",
"958028" : "Cross-site Scripting (XSS) Attack",
"958027" : "Cross-site Scripting (XSS) Attack",
"958026" : "Cross-site Scripting (XSS) Attack",
"958025" : "Cross-site Scripting (XSS) Attack",
"958024" : "Cross-site Scripting (XSS) Attack",
"958023" : "Cross-site Scripting (XSS) Attack",
"958022" : "Cross-site Scripting (XSS) Attack",
"958020" : "Cross-site Scripting (XSS) Attack",
"958019" : "Cross-site Scripting (XSS) Attack",
"958018" : "Cross-site Scripting (XSS) Attack",
"958017" : "Cross-site Scripting (XSS) Attack",
"958016" : "Cross-site Scripting (XSS) Attack",
"958013" : "Cross-site Scripting (XSS) Attack",
"958012" : "Cross-site Scripting (XSS) Attack",
"958011" : "Cross-site Scripting (XSS) Attack",
"958010" : "Cross-site Scripting (XSS) Attack",
"920330" : "Empty User Agent Header",
"958008" : "Cross-site Scripting (XSS) Attack",
"958007" : "Cross-site Scripting (XSS) Attack",
"958006" : "Cross-site Scripting (XSS) Attack",
"958005" : "Cross-site Scripting (XSS) Attack",
"958004" : "Cross-site Scripting (XSS) Attack",
"958003" : "Cross-site Scripting (XSS) Attack",
"942350" : "Detects MySQL UDF injection and other data/structure manipulation attempts",
"958001" : "Cross-site Scripting (XSS) Attack",
"958000" : "Cross-site Scripting (XSS) Attack",
"920320" : "Missing User Agent Header",
"933180" : "PHP Injection Attack = Variable Function Call Found",
"920311" : "Request Has an Empty Accept Header",
"920310" : "Request Has an Empty Accept Header",
"942360" : "Detects concatenated basic SQL injection and SQLLFI attempts",
"960017" : "Host header is a numeric IP address",
"920300" : "Request Missing an Accept Header",
"933161" : "PHP Injection Attack = Low-Value PHP Function Call Found",
"933160" : "PHP Injection Attack = High-Risk PHP Function Call Found",
"920290" : "Empty Host Header",
"973346" : "IE XSS Filters - Attack Detected.",
"933151" : "PHP Injection Attack = Medium-Risk PHP Function Name Found",
"942340" : "Detects basic SQL authentication bypass attempts 3/3",
"920280" : "Request Missing a Host Header",
"920274" : "Invalid character in request headers (outside of very strict set)",
"920273" : "Invalid character in request (outside of very strict set)",
"920272" : "Invalid character in request (outside of printable chars below ascii 127)",
"920271" : "Invalid character in request (non printable characters)",
"920270" : "Invalid character in request (null character)",
"933131" : "PHP Injection Attack = Variables Found",
"933130" : "PHP Injection Attack = Variables Found",
"942390" : "SQL Injection Attack",
"921180" : "HTTP Parameter Pollution (%@{TX.1})",
"920260" : "Unicode Full/Half Width Abuse Attack Attempt",
"933120" : "PHP Injection Attack = Configuration Directive Found",
"921170" : "HTTP Parameter Pollution",
"920250" : "UTF8 Encoding Abuse Attack Attempt",
"933111" : "PHP Injection Attack = PHP Script File Upload Found",
"942300" : "Detects MySQL comments, conditions and ch(a)r injections",
"921160" : "HTTP Header Injection Attack via payload (CR/LF and header-name detected)",
"920240" : "URL Encoding Abuse Attack Attempt",
"942290" : "Finds basic MongoDB SQL injection attempts",
"921151" : "HTTP Header Injection Attack via payload (CR/LF detected)",
"921150" : "HTTP Header Injection Attack via payload (CR/LF detected)",
"920230" : "Multiple URL Encoding Detected",
"932171" : "Remote Command Execution = Shellshock (CVE-2014-6271)",
"932170" : "Remote Command Execution = Shellshock (CVE-2014-6271)",
"921140" : "HTTP Header Injection Attack via headers",
"920220" : "URL Encoding Abuse Attack Attempt",
"942270" : "Looking for basic sql injection. Common attack string for mysql oracle and others.",
"941350" : "UTF-7 Encoding IE XSS - Attack Detected.",
"921130" : "HTTP Response Splitting Attack",
"920210" : "Multiple/Conflicting Connection Header Data Found.",
"942260" : "Detects basic SQL authentication bypass attempts 2/3",
"941340" : "IE XSS Filters - Attack Detected.",
"920202" : "Range = Too many fields for pdf request (6 or more)",
"920201" : "Range = Too many fields for pdf request (35 or more)",
"920200" : "Range = Too many fields (6 or more)",
"942251" : "Detects HAVING injections",
"941330" : "IE XSS Filters - Attack Detected.",
"921110" : "HTTP Request Smuggling Attack",
"920190" : "Range = Invalid Last Byte Value.",
"973345" : "IE XSS Filters - Attack Detected.",
"932130" : "Remote Command Execution = Unix Shell Expression Found",
"921100" : "HTTP Request Smuggling Attack.",
"920180" : "POST request missing Content-Length Header.",
"942230" : "Detects conditional SQL injection attempts",
"941310" : "US-ASCII Malformed Encoding XSS Filter - Attack Detected.",
"920170" : "GET or HEAD Request with Body Content.",
"990012" : "Rogue web site crawler",
"941300" : "XSS using 'object' tag",
"920160" : "Content-Length HTTP header is not numeric.",
"990002" : "Request Indicates a Security Scanner Scanned the Site",
"941290" : "XSS using 'applet' tag",
"911100" : "Method is not allowed by policy",
"943120" : "Possible Session Fixation Attack = SessionID Parameter Name with No Referrer",
"942200" : "Detects MySQL comment-/space-obfuscated injections and backtick termination",
"941280" : "XSS using 'base' tag",
"920370" : "Argument value too long",
"920140" : "Multipart request body failed strict validation",
"990902" : "Request Indicates a Security Scanner Scanned the Site",
"990901" : "Request Indicates a Security Scanner Scanned the Site",
"943110" : "Possible Session Fixation Attack = SessionID Parameter Name with Off-Domain Referrer",
"942190" : "Detects MSSQL code execution and information gathering attempts",
"941270" : "XSS using 'link' href",
"920130" : "Failed to parse request body.",
"932160" : "Remote Command Execution = Unix Shell Code Found",
"933150" : "PHP Injection Attack = High-Risk PHP Function Name Found",
"943100" : "Possible Session Fixation Attack = Setting Cookie Values in HTML",
"941260" : "XSS using 'meta' tag",
"942330" : "Detects classic SQL injection probings 1/2",
"942170" : "Detects SQL benchmark and sleep injection attempts including conditional queries",
"942160" : "Detects blind sqli tests using sleep() or benchmark().",
"941240" : "XSS using 'import' or 'implementation' attribute",
"931130" : "Possible Remote File Inclusion (RFI) Attack = Off-Domain Reference/Link",
"920100" : "Invalid HTTP Request Line",
"960915" : "Multipart parser detected a possible unmatched boundary.",
"942150" : "SQL Injection Attack",
"941230" : "XSS using 'embed' tag",
"931120" : "Possible Remote File Inclusion (RFI) Attack = URL Payload Used w/Trailing Question Mark Character (?)",
"942180" : "Detects basic SQL authentication bypass attempts 1/3",
"942140" : "SQL Injection Attack = Common DB Names Detected",
"941220" : "XSS using obfuscated VB Script",
"931110" : "Possible Remote File Inclusion (RFI) Attack = Common RFI Vulnerable Parameter Name used w/URL Payload",
"958009" : "Cross-site Scripting (XSS) Attack",
"942130" : "SQL Injection Attack: SQL Tautology Detected.",
"941210" : "XSS using obfuscated Javascript",
"931100" : "Possible Remote File Inclusion (RFI) Attack = URL Parameter using IP Address",
"941200" : "XSS using VML frames",
"942110" : "SQL Injection Attack: Common Injection Testing Detected",
"941190" : "XSS using style sheets",
"973348" : "IE XSS Filters - Attack Detected.",
"942100" : "SQL Injection Attack Detected via libinjection",
"941180" : "Node-Validator Blacklist Keywords",
"920360" : "Argument name too long",
"973338" : "XSS Filter - Category 3 = Javascript URI Vector",
"973336" : "XSS Filter - Category 1 = Script Tag Vector",
"973331" : "IE XSS Filters - Attack Detected.",
"973330" : "IE XSS Filters - Attack Detected.",
"973329" : "IE XSS Filters - Attack Detected.",
"973328" : "IE XSS Filters - Attack Detected.",
"973327" : "IE XSS Filters - Attack Detected.",
"973326" : "IE XSS Filters - Attack Detected.",
"973324" : "IE XSS Filters - Attack Detected.",
"930130" : "Restricted File Access Attempt",
"973321" : "IE XSS Filters - Attack Detected.",
"973320" : "IE XSS Filters - Attack Detected.",
"942320" : "Detects MySQL and PostgreSQL stored procedure/function injections",
"973317" : "IE XSS Filters - Attack Detected.",
"941150" : "XSS Filter - Category 5 = Disallowed HTML Attributes",
"973314" : "XSS Attack Detected",
"930120" : "OS File Access Attempt",
"941160" : "NoScript XSS InjectionChecker: HTML Injection",
"973311" : "XSS Attack Detected",
"973309" : "XSS Attack Detected",
"973308" : "XSS Attack Detected",
"973307" : "XSS Attack Detected",
"973306" : "XSS Attack Detected",
"941140" : "XSS Filter - Category 4 = Javascript URI Vector",
"973304" : "XSS Attack Detected",
"930110" : "Path Traversal Attack (/../)",
"973302" : "XSS Attack Detected",
"973301" : "XSS Attack Detected",
"973300" : "Possible XSS Attack Detected - HTML Tag Handler",
"942240" : "Detects MySQL charset switch and MSSQL DoS attempts",
"941130" : "XSS Filter - Category 3 = Attribute Vector",
"930100" : "Path Traversal Attack (/../)",
"941110" : "XSS Filter - Category 1 = Script Tag Vector",
"973323" : "IE XSS Filters - Attack Detected.",
"941100" : "XSS Attack Detected via libinjection",
"932140" : "Remote Command Execution = Windows FOR/IF Command Found"
});
```

**Converted from html using [convert.ps1](https://github.com/spaelling/Blog/blob/master/convert.ps1)**

