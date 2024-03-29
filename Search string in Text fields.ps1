Import-Function Render-ReportField
Close-Window

$prop =@{
    Parameters = @(
   @{ Name="searchstring"; Title="Enter text to search"; Tooltip="Enter the text to search."; Columns="6"; Placeholder="e.g. Default placeholder" ;value="test"},
   @{ Name="searchpath"; Title="Enter the root path"; Tooltip="Root path whoes child needs to lookup for given string."; Columns="20"; Placeholder="sitecore item path e.g. /sitecore/content" ;value="/sitecore/system/Modules/PowerShell/Script Library/SPE/Reporting"}
)}
$result = Read-Variable @prop
$searchstring = $searchstring.trim()
$searchpath=$searchpath.trim()
$itemsHavingNeededText=@()
get-childitem -path "master:/$searchpath" -recurse | foreach{
    $curritem=$_
    $curritem.fields  | foreach {
        $currfield=$_
        if(($currfield.Type -eq 'Single-Line Text' -or $currfield.Type -eq 'Multi-Line Text' -or $currfield.Type -eq 'text'-or $currfield.Type -eq "Rich Text") -and ($currfield.HasValue)){
            if ($currfield.value -match $searchstring){
                $itemHavingNeededText = [PSCustomObject]@{
                    ID = $curritem.id
                    Path = $curritem.fullpath
                    FieldName = $currfield.name
                    FieldType = $currfield.type
                }
                $itemsHavingNeededText += $itemHavingNeededText
              #write-host  $curritem.fullpath  ', Field: '  $currfield.name ', Field Type: ' $currfield.type
            }
        }
    }
}

$script = Get-Item -Path "master:" -ID "{089509A3-3476-4F71-AD98-21A4D3837966}"
$propsfinal = @{
    Property = @(
         "ID",
          @{Label="Field Name"; Expression={$_.FieldName} },
         @{Label="Field Type"; Expression={$_.FieldType} } ,
        @{Label="Details"; Expression={ Render-ScriptInvoker $script @{itemid=$_.ID; fieldname=$_.'FieldName'} "Field Value" }.GetNewClosure() }
    )
    InfoTitle = "Search Result"
    InfoDescription = "(Looked up $searchstring in $searchpath)"
}
 
$itemsHavingNeededText | show-listview @propsfinal
