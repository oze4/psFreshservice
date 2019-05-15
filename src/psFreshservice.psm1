<#

        MIT License

        Copyright (c) 2019 Matthew Oestreich

        Permission is hereby granted, free of charge, to any person obtaining a copy
        of this software and associated documentation files (the "Software"), to deal
        in the Software without restriction, including without limitation the rights
        to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
        copies of the Software, and to permit persons to whom the Software is
        furnished to do so, subject to the following conditions:

        The above copyright notice and this permission notice shall be included in all
        copies or substantial portions of the Software.

        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
        IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
        FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
        AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
        LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
        OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
        SOFTWARE.

#>




# Global variable used to store session info
# Done for 'ease-of-use'
# This data is volatile and gets destroyed upon disposal (only lives in RAM)
$Global:_FRESHSERVICE_SESSION_INFO_ = @{
    'BaseUrl'    = $null
    'AuthString' = $null
}


#################################################################################################
# DO NOT MODIFY, THIS IS NEEDED TO TALK TO FRESHSERVICE'S API #
function Set-RequiredSecurityProtocol {
    <#
            ~~~*** THIS FUNCTION IS REQUIRED TO RUN EACH TIME
            THIS MODULE IS IMPORTED. DO NOT MODIFY IT. ALLOW IT TO RUN.
            THIS IS TRANSPARENT TO END USER ~~~***
    #>
    try   { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } 
    catch { <# only here to suppress errors #> }
}
# DO NOT MODIFY, THIS IS NEEDED TO TALK TO FRESHSERVICE'S API #
#################################################################################################



function Get-FreshserviceAgent {
    <#
            .SYNOPSIS
            - Can return all agents or only one that is specified
            .DESCRIPTION
            - If no params are specified, all agents are returned
            - Can only use 1 parameter at a time, due to ParameterSetNames
            .PARAMETER Email
            - Email address of agent (ex: test.user@domain.com)
            .PARAMETER MobilePhone
            - Mobile phone of agent, must be in same format it was input as (ex: 111-111-1111)
            .EXAMPLE
            - $interestingAgent = Get-FreshserviceAgent -WorkPhone '111-111-1111'
    #>
    [cmdletbinding(
            DefaultParameterSetName="Default"
    )]
    
    param(
        [Parameter(Mandatory=$false, ParameterSetName="AgentId")]
        [string]$Id,
        
        [Parameter(Mandatory=$false, ParameterSetName="AgentWorkPhone")]
        [ValidateSet("fulltime", "occasional")]
        [string]$State,        
        
        [Parameter(Mandatory=$false, ParameterSetName="AgentEmail")]
        [string]$Email,
        
        [Parameter(Mandatory=$false, ParameterSetName="AgentMobilePhone")]
        [string]$MobilePhone,
        
        [Parameter(Mandatory=$false, ParameterSetName="AgentWorkPhone")]
        [string]$WorkPhone
    )
    
    try {
    
        $queryBase = "/api/v2/agents"
    
        # if no params, return all requesters
        if($PSBoundParameters.Keys.Count -eq 0){

            (New-FreshserviceApiRequest -ApiUrlQuery $queryBase -RequestMethod Get -ContentType application/json).agents

        } else {
                      
            # find which param was used
            $query_ = $null
            switch($PSBoundParameters.Keys){
                "Id"          { $query_ = ("{0}/{1}" -f $queryBase, $Id) }
                "State"       { $query_ = ("{0}?state={1}" -f $queryBase, $State) }
                "Email"       { $query_ = ("{0}?email={1}" -f $queryBase, $Email) }
                "MobilePhone" { $query_ = ("{0}?mobile_phone_number={1}" -f $queryBase, $MobilePhone) }
                "WorkPhone"   { $query_ = ("{0}?work_phone_number={1}" -f $queryBase, $WorkPhone) }
            }
            
            # return info
            (New-FreshserviceApiRequest -ApiUrlQuery $query_ -RequestMethod Get -ContentType application/json).agents
                    
        }
    
    } catch {
    
        $FreshserviceAgentNotFoundException = "[Get-FreshserviceAgent]:Something went wrong attempting to gather agent(s)! Full Error:`r`n`r`n$($_)"
        throw [System.Exception]::new($FreshserviceAgentNotFoundException)
    
    }
        
}


function Get-FreshserviceRequester {
    <#
            .SYNOPSIS
            - Can return all requesters or only one that is specified
            .DESCRIPTION
            - If no params are specified, all requesters are returned
            - Can only use 1 parameter at a time, due to ParameterSetNames
            .PARAMETER Email
            - Email address of requester (ex: test.user@domain.com)
            .PARAMETER MobilePhone
            - Mobile phone of requester, must be in same format it was input as (ex: 111-111-1111)
            .EXAMPLE
            - $interestingRequester = Get-FreshserviceRequester -WorkPhone '111-111-1111'
    #>
    [cmdletbinding(
            DefaultParameterSetName="Default"
    )]
    
    param(
        [Parameter(Mandatory=$false, ParameterSetName="RequesterId")]
        [string]$Id,
        
        [Parameter(Mandatory=$false, ParameterSetName="RequesterEmail")]
        [string]$Email,
        
        [Parameter(Mandatory=$false, ParameterSetName="RequesterMobilePhone")]
        [string]$MobilePhone,
        
        [Parameter(Mandatory=$false, ParameterSetName="RequesterWorkPhone")]
        [string]$WorkPhone
    )
    
    try {
    
        $queryBase = "/api/v2/requesters"
    
        # if no params, return all requesters
        if($PSBoundParameters.Keys.Count -eq 0){

            (New-FreshserviceApiRequest -ApiUrlQuery $queryBase -RequestMethod Get -ContentType application/json).requesters

        } else {
                      
            # find which param was used
            $query_ = $null
            switch($PSBoundParameters.Keys){
                "Id"          { $query_ = ("{0}/{1}" -f $queryBase, $Id) }
                "Email"       { $query_ = ("{0}?email={1}" -f $queryBase, $Email) }
                "MobilePhone" { $query_ = ("{0}?mobile_phone_number={1}" -f $queryBase, $MobilePhone) }
                "WorkPhone"   { $query_ = ("{0}?work_phone_number={1}" -f $queryBase, $WorkPhone) }
            }
            
            # return info
            (New-FreshserviceApiRequest -ApiUrlQuery $query_ -RequestMethod Get -ContentType application/json).requesters
                    
        }
    
    } catch {
    
        $FreshserviceRequesterNotFoundException = "[Get-FreshserviceRequester]:Something went wrong attempting to gather requester(s)! Full Error:`r`n`r`n$($_)"
        throw [System.Exception]::new($FreshserviceRequesterNotFoundException)
    
    }
        
}


function Read-FreshservicePagination {
    <#
            .SYNOPSIS
            - Handles pagination for API returns
            .DESCRIPTION
            - When you query the freshservice api, they return data in "batches" - this function is -
            designed to iterate through those "batches"; concatenating the results into one object for your viewing pleasure
            .EXAMPLE
            - TODO:complete this
    #>
    param(
        [Parameter(Mandatory=$true)]
        [Microsoft.PowerShell.Commands.WebResponseObject]$Pages,
        
        [Parameter(Mandatory=$false)]
        [int]$MaxReturn,
        
        [Parameter(Mandatory)]
        [ValidateSet("tickets")]
        [string]$Type
    )
    
    try {
        
        if (($MaxReturn -gt 1000) -or (-not $PSBoundParameters["MaxReturn"])) { 
            $MaxReturn = 1000 
        }
        
        # Create main object and tie our first page of objects to it
        $AllObjects = @()
        $AllObjects += ($Pages.Content | ConvertFrom-Json).$Type       
        
        $stagingPages = $Pages        
        for($trigger = 1; $trigger -ne 2;) {  
            if ($AllObjects.Count -lt $MaxReturn) {            
                $isNextPage = $null
                $isNextPage = [regex]::Match($stagingPages.Headers["Link"].ToString(), "(?<=\<)(.*?)(?=\>)")                     
                if($isNextPage -ne $null) {            
                    $nextPage       = $isNextPage.Value
                    $stagingPages = New-FreshserviceApiRequest -ApiUrlFull $nextPage -RequestMethod Get -ContentType application/json -AsWebRequest                
                    $AllObjects += ($stagingPages.Content | ConvertFrom-Json).$Type                
                    Start-Sleep -Milliseconds 200                
                } if ($isNextPage -eq $null) { $trigger = 2 }         
            } if ($AllObjects.Count -ge $MaxReturn) { $trigger = 2 }
        } 
       
        # return
        $AllObjects
        
    }  catch {  
    
        throw $_  
        
    }

}


function Get-FreshserviceTicket {
    <#
            .SYNOPSIS
            - Get Freshservice ticket
            .DESCRIPTION
            - ** if no params are supplied, all tickets are returned!!! **
            .PARAMETER TicketFilter
            - Pre-canned filters that come with the API
            - Cannot be used with any other parameter
            .PARAMETER TicketId
            - Ticket number of the ticket you're interested in
            - Cannot be used with any other parameter
            .PARAMETER RequesterEmail
            - Email address of the requester
            - Returns all tickets for that email
            - Cannot be used with any other parameter
            .EXAMPLE
            - TODO:complete this
            .EXAMPLE
            - TODO:complete this
    #>
    [cmdletbinding(
            DefaultParameterSetName="Default"
    )]
    
    param(
        [Parameter(Mandatory=$false, ParameterSetName="Filter")]
        [ValidateSet("new_and_my_open","watching","spam","deleted")]
        [string]$TicketFilter,
    
        [Parameter(Mandatory=$false, ParameterSetName="Id")]
        [string]$TicketId,
        
        [Parameter(Mandatory=$false, ParameterSetName="RequesterEmail")]
        [string]$RequesterEmail
    )
    
    try {
    
        $base = "/api/v2/tickets"
    
        # If no params are used return all tickets
        if($PSBoundParameters.Keys.Count -eq 0){
        
            $stagingTickets = New-FreshserviceApiRequest -ApiUrlQuery ("{0}?per_page=100" -f $base) -RequestMethod Get -ContentType application/json -AsWebRequest
            Read-FreshserviceTicketQueue -Tickets $stagingTickets
        
        } else {
        
            # Sort out which query is being used
            $query_ = $null
            switch($PSBoundParameters.Keys){
                "TicketFilter"   { $query_ = ("{0}?filter={1}&per_page=100" -f $base, $TicketFilter) }
                "TicketId"       { $query_ = ("{0}/{1}" -f $base, $TicketId) }
                "RequesterEmail" { $query_ = ("{0}?email={1}&per_page=100" -f $base, $RequesterEmail) }
            }
            
            # Return query results
            $queryResults = New-FreshserviceApiRequest -ApiUrlQuery $query_ -RequestMethod Get -ContentType application/json -AsWebRequest
            Read-FreshserviceTicketQueue -Tickets $queryResults
        
        } 
                    
    } catch {
    
        $FreshserviceTicketNotFoundException = "[Get-FreshserviceTicket]:Something went wrong attempting to gather ticket info! Full Error:`r`n`r`n$($_)"
        throw [System.Exception]::new($FreshserviceTicketNotFoundException)
    
    }
}


function Get-FreshserviceKnowledgeBase {
    <#
            .SYNOPSIS
            - Get Freshservice solution categories (what I am referring to as Knowledge Base)
            .DESCRIPTION
            - ** if no params are supplied, all categories are returned!!! **
            .PARAMETER %
            - 
            .PARAMETER %
            - 
            .PARAMETER %
            - 
            .EXAMPLE
            - TODO:complete this
            .EXAMPLE
            - TODO:complete this
    #>
    
    try {
    
        $base = "/solution/categories.json"
        (New-FreshserviceApiRequest -ApiUrlQuery $base -RequestMethod Get -ContentType application/json).category
    
    } catch {
    
        $GetFreshserviceKnowledgeBaseException = "[Get-FreshserviceKnowledgeBase]::Sopmething went wrong while locating Knowledge Bases! Full Error:`r`n`r`n$($_)"
        throw [System.Exception]::new($GetFreshserviceKnowledgeBaseException)     
    
    }

}


function Get-FreshserviceTicketCategory {
    <#
            .SYNOPSIS
            - Get Freshservice service categories for tickets
            .DESCRIPTION
            - ** if no params are supplied, all categories are returned!!! **
            .PARAMETER %
            - 
            .PARAMETER %
            - 
            .PARAMETER %
            - 
            .EXAMPLE
            - TODO:complete this
            .EXAMPLE
            - TODO:complete this
    #>
    
    try {
    
        $base = "/catalog/items.json"
        (New-FreshserviceApiRequest -ApiUrlQuery $base -RequestMethod Get -ContentType application/json)
    
    } catch {
    
        $GetFreshserviceTicketCategoryException = "[Get-FreshserviceTicketCategory]::Sopmething went wrong while locating Freshservice Categories! Full Error:`r`n`r`n$($_)"
        throw [System.Exception]::new($GetFreshserviceTicketCategoryException)     
    
    }

}


function New-FreshserviceTicket {
    <#
            ** ** ** ** ** ** **
            *THIS IS IN PROGRESS*
            ** ** ** ** ** ** **
    #>
    <#
            .SYNOPSIS
            - Create new Freshservice ticket
            .DESCRIPTION
            - Creates a Freshservice ticket
            .PARAMETER %
            - 
            - 
            .PARAMETER %
            - 
            - 
            .PARAMETER %
            - 
            - 
            .EXAMPLE
            - TODO:complete this
            .EXAMPLE
            - TODO:complete this
    #>
    [cmdletbinding(
            DefaultParameterSetName = "NewRequester_AgentId"
    )]
    
    param(
        [Parameter(Mandatory=$true, ParameterSetName="NewRequester_AgentId", Position=0)]
        [Parameter(Mandatory=$true, ParameterSetName="NewRequester_AgentEmail", Position=0)]
        [string]$NewRequesterName,
        
        [Parameter(Mandatory=$true, ParameterSetName="ExistingRequester_AgentId", Position=0)]
        [Parameter(Mandatory=$true, ParameterSetName="ExistingRequester_AgentEmail", Position=0)]
        [string]$ExistingRequesterId,        
        
        [Parameter(Mandatory=$true, ParameterSetName="NewRequester_AgentId")]
        [Parameter(Mandatory=$true, ParameterSetName="NewRequester_AgentEmail")]
        [string]$NewRequesterEmail,
        
        [Parameter(Mandatory=$true, ParameterSetName="NewRequester_AgentId")]
        [Parameter(Mandatory=$true, ParameterSetName="NewRequester_AgentEmail")]
        [string]$NewRequesterPhone,
        
        [Parameter(Mandatory=$true, ParameterSetName="NewRequester_AgentId")]
        [Parameter(Mandatory=$true, ParameterSetName="ExistingRequester_AgentId")]
        [string]$AgentId,
        
        [Parameter(Mandatory=$true, ParameterSetName="NewRequester_AgentEmail")]
        [Parameter(Mandatory=$true, ParameterSetName="ExistingRequester_AgentEmail")]
        [string]$AgentEmail,  
        
        [Parameter(Mandatory=$true)]
        [string]$Subject,        
        
        [Parameter(Mandatory=$true)]
        [ValidateSet("Open", "Pending", "Resolved", "Closed")]
        [string]$Status,
        
        [Parameter(Mandatory=$true)]
        [ValidateSet("Low", "Medium", "High", "Urgent")]
        [string]$Priority,
        
        [Parameter(Mandatory=$true)]
        [string]$Description # gets converted to HTML
        
        
    )
    
    try {
    
        $Statuses = @{
            "Open"     = "2"
            "Pending"  = "3"
            "Resolved" = "4"
            "Closed"   = "5"
        }
        
        $Priorities = @{
            "Low"    = "1"
            "Medium" = "2"
            "High"   = "3"
            "Urgent" = "4"
        }
        
        
    
    } catch {
    
    
    
    }

}


function ConvertTo-Base64 {
    <#
            .SYNOPSIS
            - Encodes regular string to base64
            .DESCRIPTION
            - Encodes regular string to base64
            .PARAMETER String
            - The text you would like to encode
            .EXAMPLE
            - ConvertTo-Base64 -StringToEncode "Hello" #returns: SABlAGwAbABvAA==
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$StringToEncode
    )
    
    try { 
        # return encoded text
        [System.Convert]::ToBase64String( 
            [System.Text.Encoding]::UTF8.GetBytes($StringToEncode) 
        )
    } catch {
    
        $ConvertToBase64Exception = "[ConvertTo-Base64]Something went wrong encoding string to base64. Full Error:`r`n`r`n$($_)"
        throw [Exception]::new($ConvertToBase64Exception)
    
    }
    
}


function ConvertFrom-Base64 {
    <#
            .SYNOPSIS
            - Decodes base64 string to plain text
            .DESCRIPTION
            - Decodes base64 string to plain text
            .PARAMETER String
            - The encode string you would like to decoe
            .EXAMPLE
            - ConvertFrom-Base64 -EncodedString "SABlAGwAbABvAA==" #returns: Hello
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$EncodedString
    )
    
    try { 
        # return decoded text
        [System.Text.Encoding]::UTF8.GetString(
            [System.Convert]::FromBase64String($EncodedString)
        )
    } catch {
        $ConvertFromBase64Exception = "[ConvertFrom-Base64]Something went wrong decoding base64 to plain text. Full Error:`r`n`r`n$($_)"
        throw [Exception]::new($ConvertFromBase64Exception)
    }
}


function Confirm-StringIsUri {
    <#
            .SYNOPSIS
            - Verifies that a given string is an acceptable URI/URL
            .DESCRIPTION
            - Verifies that a given string is an acceptable URI/URL
            .PARAMETER String
            - The string that is potentially a URI
            .EXAMPLE
            - Confirm-StringIsUri -String "https://page.host.com/api/v2/tickets?id=0"  # returns true
    #>
    param(
        [string]$String
    )    
    try {
        $null = [System.Uri]::new($String)
        $true
    } catch {
        $false
    }
}


function Connect-Freshservice {
    <#
            .SYNOPSIS
            - Establishes connection to a Freshservice server
            .DESCRIPTION
            ****.IMPORTANT ****
            ** YOU DO NOT NEED TO SUPPLY THE FRESHSERVICE FQDN, JUST THE ROOT DOMAIN: [[ex:] just 'google' not google.freshservice.com] **
            - This function lets you connect to freshservice by either your username/password combo or an API key.
            .PARAMETER ApiKey
            - Api Key of a user account
            ** To get your API key, login to freshservice and go to your account settings, your API key is on the far right side **
            - May not be used with Username/Password combo (due to ParameterSetNames)
            .PARAMETER Username
            - Freshservice username
            - May not be used with '-ApiKey' (due to ParameterSetNames)
            .PARAMETER Password
            - Freshservice password for the user above
            - May not be used with '-ApiKey' (due to ParameterSetNames)
            .EXAMPLE
            - TODO:complete this
            .EXAMPLE
            - TODO:complete this
    #>
    [cmdletbinding(
            DefaultParameterSetName="Default"
    )]
    
    param(
        [Parameter(Mandatory=$true, ParameterSetName="ApiKeyAuth")]
        [string]$ApiKey,
        
        [Parameter(Mandatory=$true, ParameterSetName="UnPwAuth")]
        [string]$Username,
        
        [Parameter(Mandatory=$true, ParameterSetName="UnPwAuth")]
        [string]$Password,
        
        [Parameter(Mandatory=$true)]
        [ValidateScript({
                    ($_ -notlike "*.*")
                    #####################################
                    #NO NEED TO SUPPLY FULL DOMAIN NAME #
                    #example: if google.freshservice.com#
                    #is your URL, only use "google" as  #
                    #the '-Domain' parameter            #
                    #####################################
        })]
        [string]$Domain
    )   
    
    try {
    
        # Clear cached global variables
        $Global:_FRESHSERVICE_SESSION_INFO_.BaseUrl    = $null
        $Global:_FRESHSERVICE_SESSION_INFO_.AuthString = $null

        # to be set below
        $AuthHeader = $null 
        # see if user wants to auth with un/pw or api key 
        switch($PSBoundParameters.Keys){ 
            # (explanation of below) X is a dummy character. When using the API key to Auth, it doesnt matter what you put there
            # ::FROM THE API DOCS::
            # ~'You can use your personal API key to authenticate the request. 
            # if you use the API key, there is no need for a password. 
            # You can use any set of characters as a dummy password.'~
            "ApiKey"   { $AuthHeader = ConvertTo-Base64 -StringToEncode ("{0}:X" -f $ApiKey) }
            "Username" { $AuthHeader = ConvertTo-Base64 -StringToEncode ("{0}:{1}" -f $Username, $Password) }
            $default   { <# do nothing #> }
        }
        
        # Set final auth string 
        $FinalAuthHeader = ("Basic {0}" -f $AuthHeader)    
        # Build URL/URI info
        $BaseUrl         = ("https://{0}.freshservice.com" -f $Domain)
        $Url             = ("{0}/api/v2/tickets" -f $BaseUrl) # just try to grab tickets, if we can, we're authed
        $Uri             = [System.Uri]::new($Url)         
        # Build Header
        $Headers         = @{
            'Authorization' = $FinalAuthHeader
            'Content-Type'  = "application/json" 
        }        
        # Logon test
        $LogonTest       = $null # make sure we know our LogonTest variable is null
        $LogonTest       = (Invoke-RestMethod -Method Get -Uri $Uri -Headers $Headers).tickets
        
        # Return
        if($LogonTest -ne $null){
            $Global:_FRESHSERVICE_SESSION_INFO_.AuthString = $FinalAuthHeader # Set session variables so we can reuse for other commands
            $Global:_FRESHSERVICE_SESSION_INFO_.BaseUrl    = $BaseUrl         #        "  "             "  "              "  "
            $true  # return true if we connected OK
        } else {
            $false # return false if there are errors trying to connect
        }
        
    } catch {
    
        # If errors are encountered
        $ConnectFreshserviceException  = "[Connect-Freshservice]`r`n`r`nSomething went wrong connecting to Freshservice!"
        $ConnectFreshserviceException += "`r`nPlease ensure you are only using 'mydomain' as the '-Domain' parameter, "
        $ConnectFreshserviceException += "not the full Freshservice URL or full domain suffix!!!!`r`nFull Error:`r`n`r`n$($_)`r`n`r`n"
        throw [Exception]::new($ConnectFreshserviceException)
    
    }
    
} #end Connect-Freshservice


function New-FreshserviceApiRequest {
    <#
            .SYNOPSIS
            - Assumes you already have an active connection
            - The 'Connect-Freshservice' cmdlet does not rely on any function
            - Builds the necessary parameters to fulfill a web request 
            .DESCRIPTION
            - Builds the necessary parameters to fulfill a web request (acts a filter when creating new requests, so you don't have to write multiple checks)
            .PARAMETER ApiUrlQuery
            - the ending of the API URL, ex: /api/v2/tickets
            - forward slash at the front is required
            - Since we tie the base URL to a global variable (https://domain.freshservice.com is a base URL), we allow the end user to supply just the suffix/query (/api/v2/tickets is an ApiUrlQuery)
            .PARAMETER ApiUrlQuery
            - Query a full URL (https://domain.freshservice.com/api/v2/tickets is a full URL)
            .PARAMETER RequestMethod
            - REST method you would like to send
            .PARAMETER ContentType
            - REST request content type (goes inside header)
            - Add new content types to the set if needed (to restrict the content that can be transferred cross site
            .PARAMETER AuthorizationHeader
            - Base64 encoded authorization header, which we tie to a global variable (hashtable) during initial connection
            - This is one of the 'checks' we do
            - It is not mandatory, since we tie it to the global variable by default (and check if its null)
            .PARAMETER FreshserviceBaseUrl
            - The base URL of the session, static param that is not required and gathered upon session creation
            - This is another check we do
            - Not mandatory since it is tied to a global var
            .EXAMPLE
            - TODO:complete this
            .EXAMPLE
            - TODO:complete this
    #>
    [cmdletbinding(
            DefaultParameterSetName="Default"
    )]

    param(
        [Parameter(Mandatory=$true, ParameterSetName="ApiUrlQuery")]
        [ValidateScript({
                    ($_.ToString().StartsWith("/"))
                    ###############################
                    # ApiUrlQuery MUST START WITH #
                    #   A FORWARD SLASH '/' !!!   #
                    ###############################
        })]
        [string]$ApiUrlQuery, 
        
        [Parameter(Mandatory=$true, ParameterSetName="FullUrlQuery")]
        [string]$ApiUrlFull,
        
        [Parameter(Mandatory=$true)]
        [ValidateSet("Default","Delete","Get","Head","Merge","Options","Patch","Put","Post","Trace")]
        [string]$RequestMethod,
                
        [Parameter(Mandatory=$true)]
        [ValidateSet("application/json")]
        [string]$ContentType,
        
        [Parameter(Mandatory=$false)]
        [switch]$AsWebRequest,
        
        [Parameter(Mandatory=$false)]
        [string]$AuthorizationHeader = $Global:_FRESHSERVICE_SESSION_INFO_.AuthString,
        
        [Parameter(Mandatory=$false)]
        [string]$FreshserviceBaseUrl = $Global:_FRESHSERVICE_SESSION_INFO_.BaseUrl        
    )
    
    $ErrorActionPreference = "Stop"
    
    if(($AuthorizationHeader -eq $null) -or ($FreshserviceBaseUrl -eq $null)){
    
        $NoFreshserviceSessionsFoundException  = "[New-FreshserviceApiRequest]:No active Freshservice session found! "
        $NoFreshserviceSessionsFoundException += "Please use cmdlet 'Connect-Freshservice' to create a required Freshservice session!"
        throw [System.Exception]::new($NoFreshserviceSessionsFoundException)
        
    } else {    
        
        try {        
        
            $FinalApiUrl      = $null # to be used later (below)
            $QueryType        = $null
            $FirstCatchThrown = $false
            
            switch($PSBoundParameters.Keys) { # sort out what kind of query the user gave us
                "ApiUrlQuery" {
                    $QueryType    = "ApiUrlQuery"
                    $potentialUri = ("{0}{1}" -f $FreshserviceBaseUrl, $ApiUrlQuery)
                    if(Confirm-StringIsUri -String $potentialUri){ $FinalApiUrl = [System.Uri]::new($potentialUri) }
                }
                "ApiUrlFull" {
                    $QueryType = "ApiUrlFull"
                    if(Confirm-StringIsUri -String $ApiUrlFull){ $FinalApiUrl = [System.Uri]::new(($ApiUrlFull)) }
                }
                default { <# do nothing #> }
            }
            
            if($FinalApiUrl -eq $null){
                $NewFreshserviceApiQueryInvalidQueryException = "[New-FreshserviceApiRequest]:Provided query '$($QueryType)' does not contain a valid Uri!"
                throw [System.Exception]::new($NewFreshserviceApiQueryInvalidQueryException)
            } else {             
                # Build Header
                $Headers = @{
                    'Authorization' = $AuthorizationHeader
                    'Content-Type'  = $ContentType
                }        
                try {
                    if($AsWebRequest){
                        Invoke-WebRequest -Method $RequestMethod -Uri $FinalApiUrl -Headers $Headers
                    } 
                    if(-not $AsWebRequest) { 
                        Invoke-RestMethod -Method $RequestMethod -Uri $FinalApiUrl -Headers $Headers # return api request
                    }
                } catch {
                    $NewFreshserviceApiRequestSendFailException = "[New-FreshserviceApiRequest]::Something went wrong while sending your Freshservice API Request! Full Error:`r`n`r`n$($_)"
                    throw [System.Exception]::new($NewFreshserviceApiRequestSendFailException)                    
                }            
            }
        
        } catch {        
        
            $NewFreshserviceApiRequestGeneralException = "[New-FreshserviceApiRequest]::Something went wrong while creating a new Freshservice API Request! Full Error:`r`n`r`n$($_)"
            throw [System.Exception]::new($NewFreshserviceApiRequestGeneralException)
        
        }    
    }
} #end New-FreshserviceApiRequest



##############################################################
#                                                            #
#   END OF MODULE - EXPORT PUBLIC FUNCTIONS BELOW FOR USE    #
#                                                            #
##############################################################
# Listing private functions just for balance
<# removing this for simplicities sake
        $__PrivateFunctions__ = @(
        "ConvertTo-Base64",
        "ConvertFrom-Base64",
        "Confirm-StringIsUri"
        )

        $__PublicFunctions__ = @(
        "Get-FreshserviceTicket",
        "Get-FreshserviceUser",
        "Connect-Freshservice",
        "New-FreshserviceApiRequest"    
        )
#>
try {
    Export-ModuleMember * 
    # DO NOT REMOVE THE BELOW LINE!
    <##> Set-RequiredSecurityProtocol <##>
    # DO NOT REMOVE THE ABOVE LINE!
} catch {
    <# only here to silence import errors in ISE #>
}

#theEnd
