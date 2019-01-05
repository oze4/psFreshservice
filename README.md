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
- This command is **invoked automatically during module import** *you do not have to manually run this command yourself!*
- This command is ran during module import
  - ***it is needed to talk to the Freshservice API - it sets the appropriate encryption types for the session and MUST BE RAN EACH TIME YOU IMPORT THE MODULE!!***



## Core
```` powershell
New-FreshserviceApiRequest -ApiUrlQuery <#-or-#> -ApiUrlFull <#-and-#> -RequestMethod -ContentType <#-or-#> [switch] -AsWebRequest
````
- `New-FreshserviceApiRequest` is the 'core' function that the majority of other functions 'wrap' around, specifically the ones that interact with the API via REST
- This command itself is nothing more than a wrapper for `Invoke-RestMethod` - although, supplying the switch `-AsWebRequest` will use `Invoke-WebRequest` instead of `Invoke-RestMethod` (while they both do the same thing, the data they return is different - `Invoke-WebRequest` lets you parse headers, etc..)
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
Get-FreshserviceTicket -TicketId <#-or-#> -RequesterEmail <#-or-#> -TicketFilter <#-(new_and_my_open|monitored_by|spam|deleted)-#>
````
- *If parameters are not used, __~~all~~ 1000 Tickets are returned__*
- ***DEFAULT MAX RETURN FOR TICKETS IS 1000 TICKETS; EACH TIME YOU RUN THIS COMMAND***
  - The API is rate limited by Freshservice

```` powershell
Read-FreshserviceTicketQueue -Tickets <#-and/or-#> -MaxReturn <#-(max size is 1000)-#>
````
- Used inside of `Get-FreshserviceTicket` to iterate through each page of tickets
  - This is because the Freshservice API will only return 100 tickets per page at most

```` powershell
New-FreshserviceTicket
````
- ![#f03c15](https://placehold.it/15/f03c15/000000?text=+) This function is currently in progress! ![#f03c15](https://placehold.it/15/f03c15/000000?text=+)


## Requesters
```` powershell
Get-FreshserviceRequester -Id <#-or-#> -Email <#-or-#> -MobilePhone <#-or-#> -WorkPhone
````
- *If parameters are not used, __all Requesters are returned__*
