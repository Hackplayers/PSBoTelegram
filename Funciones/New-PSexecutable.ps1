function New-PSExecutable 
{ param(
    [string]$Scriptname=$(throw "Mandatory param -scriptname is missing."),
    [string]$Filename,
    [switch]$KeepAlive
) 
$code=@" 
using System; using System.Diagnostics;
using System.Windows.Forms;

using System.Management.Automation.Runspaces;

using System.Management.Automation;

namespace CosmosKey.Powershell.Utils

{

    class RunEmbedded

    {

        private static string codeB64 = "@@@";
        private static string funcName = "CosmosKeyRunEmbedded";

        private static Pipeline pipe;

        private static Runspace rs = RunspaceFactory.CreateRunspace();
         static void Main(string[] args)

        {

            try
            {
                rs.Open();
                pipe = rs.CreatePipeline();
                String script = System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(codeB64));
                System.Text.StringBuilder sb = new System.Text.StringBuilder();
                sb.AppendLine("function " + funcName + " {");
                sb.AppendLine(script);
                sb.AppendLine("}");
                sb.AppendLine("[reflection.assembly]::loadwithpartialname('System.Xml')");
                sb.AppendLine("[reflection.assembly]::loadwithpartialname('System.Management')");
                sb.AppendLine("[reflection.assembly]::loadwithpartialname('System.DirectoryServices')");
                sb.AppendLine("[reflection.assembly]::loadwithpartialname('System.Data')");             
                sb.Append(funcName);
                foreach(string arg in args){
                    sb.Append(" ");
                    if(arg.StartsWith("-")){
                        sb.Append(arg);
                    } else if (arg.Contains(" ")){
                        sb.Append("\"" + arg + "\"");
                    } else {
                        sb.Append(arg);
                    }
                }
                sb.AppendLine("");
                pipe.Commands.AddScript(sb.ToString());
                ZZZ
                CloseRunspace();
            }
            catch (Exception) { ;}
        }
        private static void CloseRunspace(){

            pipe.StopAsync();
            rs.CloseAsync();
        }
    }

}

"@

    if(test-path $scriptname){

        $script:scriptFilename = get-item $scriptname

    } else {

        throw "Can't find script file"

    }

    if([string]::IsNullOrEmpty($filename)){

        $filename = $scriptFilename.Name.ToLower() -replace ".ps1",".exe"

        $filename = "$pwd\$filename"

    }

    Write-Host "Source script file:   $($scriptFilename.FullName)"

    Write-Host "Output executable :   $filename"

    $scriptBytes = [io.file]::ReadAllBytes($scriptFilename.FullName)

    $b64 = [convert]::tobase64string($scriptBytes)

    $newCode = $code -replace "@@@",$b64

    if($KeepAlive){

        $newCode = $newCode -replace "ZZZ","pipe.InvokeAsync();Application.Run();"

    } else {

        $newCode = $newCode -replace "ZZZ","pipe.Invoke();"

    }

    $formsAssembly = [reflection.assembly]::LoadWithPartialName("System.Windows.Forms")
    Add-Type $newCode -OutputAssembly $filename -OutputType WindowsApplication -ReferencedAssemblies $formsAssembly.Location 
}


