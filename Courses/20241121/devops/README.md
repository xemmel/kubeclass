### DevOps

- Project Settings
  - Service Connections
  - *+ New Service Connection*
    - **Azure Resource Manager**
  - **App Reg or mi (manual)**
    - Leave credential as WIF
    - Service Connection Name
  - *Next*
  - Get *Issuer* and *Subject*
  - Keep as draft

### Entra

 - Applications/App Registration
 - *+ New registration*
 - Give it a name
 - **Register**
 - Copy the *Client Id* and the Name and give to the Azure/DevOps people
 - Certificates & Secrets
   - Federated Crendentials
     - + Add Credential
     - select *Other Issuer*
     - Paste *Issuer* and *Subject*
     - Name: devops
     - **Add**



### Azure
  - Goto the relevant subscription
  - Access Control(IAM)
  - NEEDS TO BE OWNER!!!
  - +Add/add role assignment
  - Priviliged ...
    - Choose *Contributor* (Future: if IaC needs to create Role Assignment then you need *Owner*)
    - Next
    - Select Member
    - Search for the app reg name and choose it
    - Review/Assign * 2

### DevOps

  - Service Connection
     - Finish Setup
     - SubscriptionId: ...
     - SubscriptionName: ...
     - ClientId: from Entra
     - Maybe also TenantId: ...
     - Verify and save





