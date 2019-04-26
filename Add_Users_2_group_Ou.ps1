
############################################################################
#
#  GIT:                 https://github.com/tenens-fusum/Add-enabled-users-to-group-by-OU
#  Date created:   	23/03/2019
#  Version: 		1.0
#  Description: 	Add enabled users to Group by OU, update membership whithout delete and add all of them
#
############################################################################

#Options
$group='AD_Group'                                       #AD group where users are added
$OU="ou=orgs,dc=corp,dc=psg,dc=loc"                     #AD OU from which users will be addedd

$groupDN=(get-adgroup $group).DistinguishedName  
$users=get-ADGroupMember -Identity $group

foreach ($user in $users)
{
        if (((Get-ADUser $user.SamAccountName -Properties userAccountControl).userAccountControl -NotMatch '512') -and ((Get-ADUser $user.SamAccountName -Properties userAccountControl).userAccountControl -NotMatch '66048'))
 
        {
            Remove-ADGroupMember -Identity $group -Member $user.samaccountname -Confirm:$false
            Write-Host ""$user.SamAccountName" Deleted from $group. Blocked" -ForegroundColor Green
        }

        if($user.distinguishedname -notlike "*$OU*")
         {
             Remove-ADGroupMember -Identity $group -Member $user.samaccountname -Confirm:$false
             Write-Host ""$user.SamAccountName" Deleted from $group. Not in $OU" -ForegroundColor Green
         }
}
$users=@()

$users=Get-ADUser -SearchBase $OU -Filter {(Enabled -eq $true)}    
foreach ($user in $users) 
{   
   if   ((Get-ADUser $user -Properties memberof).memberof -like $groupDN )
{
#Write-Host ""$user.SamAccountName" is already in $group" -ForegroundColor Green
}
Else
{
Add-ADGroupMember -Identity $group -Members $user   
Write-Host "Add "$user.SamAccountName" to $group" -ForegroundColor Green
}
}
