# psFreshservice

Freshservice Powershell Module.



#### Table of Contents
- [Getting Started](https://github.com/oze4/psFreshservice/blob/master/README.md#getting-started)
- [Demo](https://github.com/oze4/psFreshservice/blob/master/README.md#demo)
- [Functions](https://github.com/oze4/psFreshservice/blob/master/README.md#functions)
  - [Connecting](https://github.com/oze4/psFreshservice/blob/master/README.md#connecting)
  - [Core](https://github.com/oze4/psFreshservice/blob/master/README.md#core)
  - [Agents](https://github.com/oze4/psFreshservice/blob/master/README.md#agents)
  - [Tickets](https://github.com/oze4/psFreshservice/blob/master/README.md#tickets)
  - [Requesters](https://github.com/oze4/psFreshservice/blob/master/README.md#requesters)



# :Getting Started:

**If you use SSO (single sign-on), you HAVE TO use the API Key method to connect!!!**

This module offers two ways to connect to Freshservice (`Username and Password | Freshservice API Key`). In order to get your API Key you'll need to log into your account, go to 'Profile Settings' and your API Key will be on the right hand side.

***[How to get Freshservice API Key](https://help-desk-migration.com/help/how-to-get-freshdesk-freshservice-api-key/)***



# :Demo:

***[High level module demo](https://github.com/oze4/psFreshservice/blob/master/demo/psFreshservice.MODULE-HOW-TO.ps1)***



# :Functions:

## Connecting
```` powershell
Connect-Freshservice -ApiKey <#-or-#> -Username -Password <#-and-#> -Domain
````
- Within the `-Domain` parameter, you **DO NOT** have to supply the entire domain name!!!
  - *If your domain is `google.com` then you only need to use `google` for this parameter!!!*
```` powershell
Set-RequiredSecurityProtocol
````
- This command is ran during module import
  - ***it is needed to talk to the Freshservice API - it sets the appropriate encryption types for the session and MUST BE RAN EACH TIME YOU IMPORT THE MODULE!!***



## Core
```` powershell
New-FreshserviceApiRequest -ApiUrlQuery <#-or-#> -ApiUrlFull <#-and-#> -RequestMethod -ContentType
````
- `New-FreshserviceApiRequest` is the 'core' function that the majority of other functions 'wrap' around, specifically the ones that interact with the API via REST 
  - ***The `Connect-Freshservice` command must be ran before you are able to use `New-FreshserviceApiRequest`***
  - `-ApiUrlQuery` means you only have to supply everything after the root domain/host 
    - ex: (`/api/v2/agents`)
  - `-ApiUrlFull` means you have to supply the full URL
    - ex: (`https://domain.freshservice.com/api/v2/agents`)
  - You can use `New-FreshserviceApiRequest` on its own (as long as you use `-ApiUrlFull`)
```` powershell
ConvertTo-Base64 -StringToEncode
````
```` powershell
ConvertFrom-Base64 -EncodedString
````
```` powershell
Confirm-StringIsUri -String
````



## Agents
```` powershell
Get-FreshserviceAgent -Id <#-or-#> -State <#-(fulltime|occasional)-#> <#-or-#> -Email <#-or-#> -MobilePhone <#-or-#> -WorkPhone
````
- *If parameters are not used, __all Agents are returned__*



## Tickets
```` powershell
Get-FreshserviceTicket -TicketId <#-or-#> -RequesterEmail <#-or-#> -TicketFilter <#-(all_tickets|new_my_open|monitored_by|spam|deleted)-#>
````
- *If parameters are not used, __all Tickets are returned__*

```` powershell
New-FreshserviceTicket
````
#### - ***This function is currently in progress***


## Requesters
```` powershell
Get-FreshserviceRequester -Id <#-or-#> -Email <#-or-#> -MobilePhone <#-or-#> -WorkPhone
````
- *If parameters are not used, __all Requesters are returned__*
