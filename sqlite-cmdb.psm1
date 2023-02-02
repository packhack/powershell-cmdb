add-type -path system.data.sqlite.dll
$dbFile = "C:\99-temp\pisql.db"
$sqlConn = "data source=${dbFile}"
$executeCommand = $FALSE

function piInitDB {
    if (-not(test-path -path $dbFile))
    {
        $connObj = New-Object -typename System.Data.SQLite.SQLiteConnection
        $connObj.ConnectionString = $sqlConn

        $sqlCommands = "create table computers (
            id integer PRIMARY KEY AUTOINCREMENT, fqdn varchar(255), ip varchar(13)
            )", "create table history (
                hid integer PRIMARY KEY AUTOINCREMENT, server_id integer, command text not null, command_date text
            )"
        $connObj.Open()
        $sqlStatement = $connObj.CreateCommand()
    
        foreach ($sqlCommand in $sqlCommands)
        {
            $sqlStatement.CommandText = $sqlCommand
            $sqlStatement.ExecuteNonQuery()
        }

        $connObj.Dispose()
        $sqlStatement.Dispose()
    }
}

function [boolean]piCheckComputer
{
    param(
        [Parameter(Mandatory)]
        [string]$cmdbServer
    )
    if (test-connection -ComputerName ${cmdbserver})
    {
        return $TRUE
    } else {
        return $FALSE
    }
}

function piEnterSql($sqlStatement)
{
    $connObj = New-Object -typename System.Data.SQLite.SQLiteConnection
    $connObj.ConnectionString = $sqlConn
    $connObj.open()

    $sqlCmd = $connObj.CreateCommand()
    $sqlCmd.CommandText($sqlStatement)
    $sqlCmd.ExecuteNonQuery()
    $sqlCmd.Dispose()
    $connObj.Dispose()
}

function piEnterCommand
{
    param(
        [string]$cmdbServer,
        [string]$cmdbCommand
    )
    $connObj = New-Object -typename System.Data.SQLite.SQLiteConnection
    $connObj.ConnectionString = $sqlConn
    $connObj.open()

    if (piCheckComputer -cmdbServer ${cmdbServer}) {
        $sqlCmd = $connObj.CreateCommand()
        $sqlCmd.CommandText = "SELECT id FROM computers WHERE fqdn = '${cmdbServer}'"
    
        if (!($sqlCmd.ExecuteScalar()))
        {
            $computerIP = [System.Net.Dns]::GetHostByName(${cmdbServer}).AddressList.IPAddressToString
            $sqlCmd.CommandText = "INSERT INTO computers(fqdn,ip) VALUES ('${cmdbServer}','${computerIP}')"
            $sqlCmd.ExecuteNonQuery()
            
        }
        
        $getID = "SELECT id FROM computers WHERE fqdn = '${cmdbServer}'"
        $sqlCmd.CommandText = $getID
        $srvID = $sqlCmd.ExecuteScalar()
        $curDate = Get-Date -Format "yyyy-MM-dd HH:m:s"
    
        $sqlCmd.CommandText = "INSERT INTO history(server_id,command,command_date) values ( '${srvID}', '${cmdbCommand}', '${curDate}' )"
        $sqlCmd.ExecuteNonQuery()
        $sqlCmd.Dispose()
        $connObj.Dispose()
    }
}

function piGetHistory
{
    param(
        [string]$cmdbServer
    )
    $connObj = New-Object -typename System.Data.SQLite.SQLiteConnection
    $connObj.ConnectionString = $sqlConn
    $connObj.open()

    $sqlCmd = $connObj.CreateCommand()
    if ($cmdbServer) {
        $sqlCmd.CommandText = "SELECT id,fqdn FROM computers where fqdn = '${cmdbServer}'"
    } else {
        $sqlCmd.CommandText = "SELECT id,fqdn FROM computers"
    }   
    $srvID = $sqlCmd.ExecuteReader()
    while ($srvID.Read())
    {
        $sqlCmd2 = $connObj.CreateCommand()
        $id=$srvID["id"]
        $fqdn = $srvID["fqdn"]
        $sqlCmd2.CommandText = "SELECT command,command_date FROM history WHERE server_id = '${id}'"
        $results = $sqlCmd2.ExecuteReader()

        $row = @()
        while ($results.Read())
        {
         $result = "" | Select fqdn,command,date
         $result.fqdn = $fqdn
         $result.command = $results["command"]
         $result.date = $results["command_date"]
         $row += $result
        }
        $row
        $sqlCmd2.Dispose()
   }
   $connObj.Dispose()
   $sqlCmd.Dispose() 
}
