## How to check if you have enabled subscription level consent for SQL Server IaaS Extension registration

1. Open Cloud Shell (https://shell.azure.com)
    1. Select appropriate Azure AD or do initial one-time setup if necessary
2. Switch shell to Bash (if it is on PowerShell)
3. Run the following commands

`az account list -o table`

4. Note and copy subscription IDs you want to run against, for example `6278cbd5-f9b3-4792-aaa4-801c2412681e` 
5. Check the feature `BulkRegistration` state

`az feature list -o table --namespace Microsoft.SqlVirtualMachine --subscription 6278cbd5-f9b3-4792-aaa4-801c2412681e`

You should see something like (it is easier to read)

```
Name                                          RegistrationState
--------------------------------------------  -------------------
Microsoft.SqlVirtualMachine/TestAFECForTPID   NotRegistered
Microsoft.SqlVirtualMachine/BulkRegistration  Unregistered
```

This command will capture Sub ID in the output (removes opportunity to make copy/paste reporting mistakes):

`az feature list -o jsonc --namespace Microsoft.SqlVirtualMachine --subscription 6278cbd5-f9b3-4792-aaa4-801c2412681e`

it will produce something along the lines of
```
[
  {
    "id": "/subscriptions/6278cbd5-f9b3-4792-aaa4-801c2412681e/providers/Microsoft.Features/providers/Microsoft.SqlVirtualMachine/features/TestAFECForTPID",
    "name": "Microsoft.SqlVirtualMachine/TestAFECForTPID",
    "properties": {
      "state": "NotRegistered"
    },
    "type": "Microsoft.Features/providers/features"
  },
  {
    "id": "/subscriptions/6278cbd5-f9b3-4792-aaa4-801c2412681e/providers/Microsoft.Features/providers/Microsoft.SqlVirtualMachine/features/BulkRegistration",
    "name": "Microsoft.SqlVirtualMachine/BulkRegistration",
    "properties": {
      "state": "Unregistered"
    },
    "type": "Microsoft.Features/providers/features"
  }
]
```
The feature state will likely to be in one of the three states `NotRegistred`, `Registered`, `Unregistred`.
