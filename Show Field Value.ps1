
Get-Item -Path "master:" -ID $itemid |Select-Object -Property *  | show-listview -property $fieldname
