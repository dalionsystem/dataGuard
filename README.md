

# dataGuard

db permission management & audit system

[![100 - commitow](https://img.shields.io/badge/100%20-commitow-lightgreen.svg)](https://100commitow.pl)

> \[!NOTE]
>
> This project is part of the ["100 Commits"](https://100commitow.pl/) competition, which challenges participants to commit to their projects by making at least one commit every day for 100 consecutive days.
>


## About DataGuard 

<div align="center">


  <img src="data-guard-logo.jpg" alt="drawing" class="logo"/>


</div>

Do you know what permissions are currently set on your databases?
Do you know when which permission was granted?
Has someone accidentally granted too many permissions?


## Idea

All authorization configuration should be saved in the authorization management system.
Based on this configuration, the system automatically grants and revokes permissions. Even if the administrator grants permission directly in the database, the system will automatically receive it and send a notification about this fact.
If the permission is added in the configuration, the system will automatically transfer it to the database.


## Benefits
A full audit with real-time permissions, not a post-factum analysis
Granting permissions faster than those broadcast by Active Directory groups

The system is to be a central repository for various databases and will provide a unified system for granting permissions.
Facilitates the transfer of permissions between different environments (DEV, TEST, PROD)


## Progress
- This is PoC only for SQL Server
- Project is written as DacPack project

## How to  deploy/run
### Requirements
- SQL Server 2022
- DataTools
- Visual Studion (unfortunately scripts for running without VS are not yet prepared)

### Deployment
- Deploy Project DataGuard (local.publish.xml)
- Deploy Project DataGuard.dbtest (local.publish.xml)

### Test 
Unit test are writtent in T-SQLt framework (https://tsqlt.org/)  
Quickest way to execute all test is  
>	__EXEC	[tSQLt].[RunAll]__

#### Example result

````
+----------------------+
|Test Execution Summary|
+----------------------+
 
|No|Test Case Name                                                     |Dur(ms)|Result |
+--+-------------------------------------------------------------------+-------+-------+
|1 |[test].[test conf.tDatabase if record change update LastModifiedOn]|     10|Success|
|2 |[test].[test conf.tDatabase try change CreatedBy]                  |      8|Success|
|3 |[test].[test conf.tDatabase try change CreatedOn]                  |      8|Success|
|4 |[test].[test database DataGuard existing]                          |      8|Success|
|5 |[test].[test database TestDataTest not existing]                   |      3|Success|
----------------------------------------------------------------------------------------
Test Case Summary: 5 test case(s) executed, 5 succeeded, 0 skipped, 0 failed, 0 errored.
----------------------------------------------------------------------------------------
````
