function HelloWorld {
    Write-Host "Bienvenue dans WACadmin. Pour commencer, tapez Vérification [V] ou Action [A]."
}
    $this_csv = ".\admin_db.csv"
    $csv = Import-Csv $this_csv -Delimiter ";" <#-header "userName", "Name","Description", "passWord" #>
    #variables globales, listes d'utilisateurs de type PSObject 
    $local_users = Get-LocalUser
    $union = Compare-Object -ReferenceObject $local_users -DifferenceObject $csv -PassThru
    $exclusion = Compare-Object -ReferenceObject $csv -DifferenceObject $local_users -PassThru
    $quedansLeCSV = Compare-Object $local_users $csv -Property Name,FullName,Description,SideIndicator

function UpdateMode{
    param ([PSObject]$csv) 
                ForEach ($User in $csv){

                $username      = $User.userName
                $name          = $User.Name
                $description   = $User.Description
                $pw            = $User.passWord
                echo $username
                $new_pw = ConvertTo-SecureString $pw –asplaintext –force

                Write-Output "Nom d'utilisateur :  $username  nom complet :  $name  Description:  $description"
                New-LocalUser -Name $username -FullName $name -Description $description -Password $new_pw -Verbose
                if(!$?){
                echo "Un utilisateur porte déjà ce nom !"
                }else{
                echo "Le nouvel utilisateur a été créé."
                }
            }
}

function PushProcess{ 
                ForEach ($User in $csv){
                "wac+++++++++++++++"
                $username      = $User.userName
                $name          = $User.Name
                $description   = $User.Description
                $pw            = $User.passWord
                echo $username
                $new_pw = ConvertTo-SecureString $pw –asplaintext –force

                Write-Output "Nom d'utilisateur :  $username  nom complet :  $name  Description:  $description"
                New-LocalUser -Name $username -FullName $name -Description $description -Password $new_pw -Verbose
                if(!$?){
                echo "Un utilisateur porte déjà ce nom !"
                Set-LocalUser -Name $username -FullName $name -Description $description -Password $pw –Verbose
                }else{
                echo "Le nouvel utilisateur a été créé."
                }
            }

}

function PullProcess{
        $a = @()
        ForEach($into in $quedansLeCSV) {
          if($into.sideindicator -eq "=>") {     
          #echo $into.Name
            $item = New-Object PSObject
            $item | Add-Member -type NoteProperty -Name 'userName' -Value $into.Name
            $item | Add-Member -type NoteProperty -Name 'Name' -Value $into.fullName
            $item | Add-Member -type NoteProperty -Name 'Description' -Value $into.Description

            $a += $item
          
          }
        }
        ForEach($outside in $exclusion) {
            if($outside.sideindicator -eq "=>") {     
            #echo $outside.Name
            $item = New-Object PSObject
            $item | Add-Member -type NoteProperty -Name 'userName' -Value $outside.Name
            $item | Add-Member -type NoteProperty -Name 'Name' -Value $outside.FullName
            $item | Add-Member -type NoteProperty -Name 'Description' -Value $outside.Description

            $a += $item
            }
        }

        $a | Export-Csv -Path $this_csv -NoTypeInformation -Delimiter ';'
        "Le Tableau a été exporté au format CSV. FIN DU PROGRAMME."
}

function VerifMode{
    param ([PSObject]$csv)
    
    "Liste des utilisateurs totale"
     ForEach($go in $union) {
          echo $go.Name
     }

     echo "+---------------+"
    "Ces objets sont répertoriés seulement dans le CSV"
     ForEach($into in $quedansLeCSV) {
          if($into.sideindicator -eq "=>") {     
          echo $into.Name
          }
     }

     echo "+---------------+"
     "Ces objets sont répertoriés seulement dans la base ADMIN."
     ForEach($outside in $exclusion) {
          if($outside.sideindicator -eq "=>") {     
          echo $outside.Name
          }
     }
}

function ActionMode{
"Tapez Push [P], Pull [M], Informations [i] ou Fin [F]"
}

HelloWorld
$wac_choix = Read-Host "Votre choix :"


if(($wac_choix -eq 'v') -or ($wac_choix -eq 'V')){
"+----- Mode Verification -----+"
$csv = Import-Csv .\admin_db.csv -Delimiter ";"
    VerifMode $csv
     $wac_choix = 'a'
}

if(($wac_choix -eq 'a') -or ($wac_choix -eq 'A')){
"+----- Mode Action -----+"
ActionMode
$wac_action = Read-Host "Votre choix :"
        if(($wac_action -eq 'u') -or ($wac_action -eq 'U')){
            #UpdateMode $csv
        }
        if(($wac_action -eq 'p') -or ($wac_action -eq 'P')){
            PushProcess
        }
        if(($wac_action -eq 'm') -or ($wac_action -eq 'M')){
            PullProcess   
        }
        if(($wac_action -eq 'i') -or ($wac_action -eq 'I')){
            "PUSH permet de transferer du CSV a la BASE ADMIN. les utilisateurs non sychronisés, PULL permet de de transferer de la BASE ADMIN. au CSV les utilisateurs non sychronisés"
            "FIN du programme."
        }
}

#clear

#Remove-LocalUser -Name ""
