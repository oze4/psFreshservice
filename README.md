# psFreshservice

Freshservice Powershell Module.

## :Getting Started:

**If you use SSO (single sign-on), you HAVE TO use the API Key method to connect**
This module offers two ways to connect to Freshservice (Username and Password | Freshservice API Key). In order to get your API Key you'll need to log into your account, go to 'Profile Settings' and your API Key will be on the right hand side.

***[How to get Freshservice API Key](https://help-desk-migration.com/help/how-to-get-freshdesk-freshservice-api-key/)***


## :Demo:

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
- `New-FreshserviceApiRequest` is the 'core' function that the majority of other functions 'wrap' around, specifically the ones that interact with the API via REST ***(the `Connect-Freshservice` command must be ran before you are able to use `New-FreshserviceApiRequest`)***
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

### Agents
```` powershell

````


### Tickets

- Get specific ticket (based on a variety of filters)
- Get all tickets (which you can also filter)

### Requesters

- Get all requesters
- Get specific requester
