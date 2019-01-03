# psFreshservice

Freshservice Powershell Module.

** If you use SSO (single sign-on), you HAVE TO use the API Key method to connect **

# :Getting Started:

This module offers two ways to connect to Freshservice (Username and Password | Freshservice API Key). In order to get your API Key you'll need to log into your account, go to 'Profile Settings' and your API Key will be on the right hand side.

***[How to get Freshservice API Key](https://help-desk-migration.com/help/how-to-get-freshdesk-freshservice-api-key/)***


## Demo

***[High level module demo](https://github.com/oze4/psFreshservice/blob/master/example/psFreshservice.MODULE-HOW-TO.ps1)***

## :Functions:


### Connecting
```` powershell
Connect-Freshservice -ApiKey <#-or-#> -Username -Password
````

### Core
```` powershell
New-FreshserviceApiRequest -ApiUrlQuery <#-or-#> -ApiUrlFull <#-and-#> -RequestMethod <#-Default|Delete|Get|Head|Merge|Options|Path|Put|Post|Trace-#> -ContentType -AuthorizationHeader -FreshserviceBaseUrl
````
- Important to note that ```` powershell New-FreshserviceApiRequest ````
```` powershell
ConvertTo-Base64 -StringToEncode
````
```` powershell
ConvertFrom-Base64 -EncodedString
````
```` powershell
Confirm-StringIsUri -String
````

### Agents
```` powershell

````


### Tickets

- Get specific ticket (based on a variety of filters)
- Get all tickets (which you can also filter)

### Requesters

- Get all requesters
- Get specific requester
