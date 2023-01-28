/// <pre>
/// Copyright (c) Alex Woodhead 2020
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
/// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
/// 
/// License MIT
/// Source: https://github.com/alexatwoodhead/ompare
/// Version: 1.0
/// </pre>
/// Generic Utility to profile any data with SQL Table projection.<br/>
/// For example ScheduleTasks and Production Settings can be exposed for easy comparison across environments.
/// For example an application may contain many configuration tables, where some comparison between environments is needed.
/// Specific columns of interest can be selected.
/// Columns with sensitive information can be ignored.
/// Instance specific values (numeric RowId, timeadded / created) can be excluded from sampling.
/// Simple filtering record on column values is also supported.
/// ie: For a row to be sampled one or more columns require specific values.<br/>
/// One or more columns are used as a unique composite key to identify a row.
/// Extracted rows are sorted by this chosen unique composite key.
/// Opt-in profiling</br>
/// Rules for what and how to profile are stored on target system in Ensemble Lookup SourceCompareSQL
/// <example>
/// ^ompare("Config","SQL", Key[*] + [ "," + Alias ]) = enabled + "," + maxRows + "," + idSpec + "," + rowSpec
/// </example>
/// Key Structure. Delimited by ","
/// <table class="Summary">
///   <tr>
///     <th>Key</th>
///     <th>Alias</th> 
///   </tr>
///   <tr>
///     <td>Table name</td>
///     <td>Mandatory<br/>
///         Can be an exact name of SQL Table OR<br/>
///         have a "*" Wild Card suffix to include multiple tables
///     </td>
///   </tr>
///   <tr>
///     <td>Alias name</td>
///     <td>Optional<br/>
///         Allows multiple rule configurations to be processed for the same table(s)
///     </td>
///   </tr>
/// </table>
/// Value structure. Delimitied by ","
/// <table class="Summary">
///   <tr>
///     <th>Name</th>
///     <th>Comment</th> 
///   </tr>
///   <tr>
///     <td>Enabled</td>
///     <td>"0" (Do not Profile) OR<br/>
///         "1" (Do Profile)</br>
///         Useful to toggle whether a sample rule is active or not
///     </td>
///   </tr>
///   <tr>
///     <td>ExportValues</td>
///     <td>Controls whether Values are exported for detailed pre-record comparison on diff-report service.
///         "" empty means use the <em>IncludeSourceCode</em> flag provided by Schedule to determin whether column values should be exported or not.<br/>
/// 		"0" means NEVER export column values. Only export the signature of values. Overrides <em>IncludeSourceCode</em> flag on Schedule.<br/>
///         "1" means always export column values along with the signature of values. Overrides <em>IncludeSourceCode</em> flag on Schedule.</br>
///         Useful to guard against unintended information sharing.
///     </td>
///   </tr>
///   <tr>
///     <td>Max Rows</td>
///     <td>Numeric number of records to capture for sample. Defaults to first 1000 processed<br/>
///     </td>
///   </tr>
///   <tr>
///     <td>Id Spec</td>
///     <td>One or more column Names delimited by "~" when combined are used as a unique "ID".<br/>
///         By default will use "%ID"<br/>
///         For example if the column "Name" contains unique values, but the source table also has a numeric row ID
///         The "Name" column is used and the "ID" column is suppressed from the sample.
///         The sample rows will be sorted on "Name".<br/>
///         This allows effective differencing of records, that may have been inserted into different environments, in a different insert order with different source numeric IDs
///     </td>
///   </tr>
///   <tr>
///     <td>rowSpec</td>
///     <td>One or more columns to sample.<br/>
///         Delimited by "~"<br/>
///         "*" Wild card to just include all columns. Default vaue.<br/>
///         Exact column names can be specified (Case insensitive)<br/>
///         Wild card suffix can be used on column name for example "Address*" would match "AddressLine1" and "AddressLine2"<br/>
///         "-" minus prefix negates inclusion of a column. For example: "-Address*" would exclude columns "AddressLine1" and "AddressLine2"<br/>
///         The syntax is clumulative so: "*~-Address*" would mean include ALL columns but not "AddressLine1" or "AddressLine2"
///     </td>
///   </tr>
///   <tr>
///     <td>Filter</td>
///     <td>One or more expressions to filter out unwanted records.<br/>
/// Delimited by "~"<br/>
/// By default conditions operate with an implicit "OR" mode.
/// <example>
/// Name=Switch Journal~Name=Purge Tasks
/// </example>
/// Meaning: Where the Name column has the value "Switch Journal" OR "Purge Tasks" then include in sample.<br/>
/// To combine multiple conditions, prefix the series of subsequent columns with "&"
/// <example>
/// ID>5~&ID<10
/// </example>
/// Meaning: Where the ID column has values between 6 and 9<br/>
/// Note the AND sequence operates in groups so that
/// <example>
/// ID>2~&ID<5~ID>9~&ID<15
/// </example>
/// Meaning: Where the ID column has values (between 3 and 4) OR (between 10 and 14) then include in sample.<br/>
/// The following filter operators are currently supported.
/// <ul><li>"<" - Less than</li>
/// <li>">" - More than</li>
/// <li>"!=" - Not Equal</li>
/// <li>"=" - Equal</li>
/// <li>"![" - Does not contain</li>
/// <li>"[" - Contains</li>
/// </ul>
///     </td>
///   </tr>
/// </table>
/// <h3>Example configuration</h3>
/// The following examples demonstrate configurations using existing Scheduled Tasks.
/// Global view for Key and Value.
/// <example>
/// set ^ompare("Config","SQL","%SYS.Ta*,TaskA")="1"
/// </example>
/// <table class="Summary">
///   <tr>
///     <th>Key</th>
///     <th>Value</th>
///     <th>Meaning</th>
///   </tr>
///   <tr>
///    <td>%SYS.Ta*,TaskA</td>
///    <td>1</td>
///    <td>Using wildcard on source Table name.
///        Matches multiple SQL Tables with name starting with "%SYS.Ta".<br/>
///        These resolve to "%SYS.Task" and "%SYS.TaskSuper"
///        Enabled Profile.<br/>
///        Default return maxRows 1000.<br/>
///        Default IDSpec "%ID".<br/>
///        Default "*" return all columns.
///     </td>
///   </tr>
///   <tr>
///     <td>%SYS.Task</td>
///     <td>1,100,Name,Description~TaskClass</td>
///     <td>Match exactly one SQL Table with name <em>%SYS.Task</em>.<br/>
///         Enabled Profile.<br/>
///         Return only first 100 rows.<br/>
///         Use <em>Name</em> column as sample row ID.<br/>
///         Only return values for columns Description and TaskClass
///     </td>
///   </tr>
///   <tr>
///     <td>%SYS.Task,Scheduled Tasks</td>
///     <td>1,500,Name,*~-ID,-Display*</td>
///     <td>Match exactly one SQL Table with name %SYS.Task.<br/>
///         Use an Alias of "Scheduled Tasks" for this table rule.
///         Allows previous defined rule for this table to also be processed independently.<br/>
///         Enabled Profile.<br/>
///         Return only 500 rows.<br/>
///         Use <em>Name</em> column as sample row ID.<br/>
///         Return ALL columns BUT exclude the ID column.
///         Also exclude any columns that startwith Display for example: DisplayDayNextScheduled,
///  DisplayEndDate, DisplayErrorDate, DisplayErrorNumber, DisplayFinished, DisplayInterval
///  DisplayNextScheduled, DisplayNextScheduledBrief, DisplayRun, DisplayRunAfter, DisplayStartDate
///  DisplayStarted, DisplayStatus
///     </td>
///   </tr>
/// </table>	
Class ompare.SourceHandler.SQLTable Extends ompare.SourceHandler.Base
{

/// Ensure this Code doesn't collide with other sub-class implementations of Base
/// Eg: "CLS" abbreviation for class
Parameter TypeCode As %String = "SQL";

/// <!--
/// Do not invoke supporting methods on this class definition
/// do ##class(ompare.SourceHandler.SQLTable).IndexNamespace($Namespace,1)
/// set ^ompare("Config","SQL","%SYS.Task,ScheduleTasks")="1,1,,Name,Description~TaskClass~RunAsUser,Name=Switch Journal~Name=Purge Tasks"
/// set ^ompare("Config","SQL","%SYS.Task,ScheduleTasks")="1,1,,Name,Description~TaskClass~RunAsUser,Name=Switch Journal~&TaskClass="%SYS.Task.PurgeTaskHistory~Name=Purge Tasks~&TaskClass="%SYS.Task.PurgeTaskHistory"
/// set ^ompare("Config","SQL","%SYS.Task,ScheduleTasks")="1,1,,ID~Name,Description~ID~TaskClass~RunAsUser,ID>5~&ID<9"
/// set ^ompare("Config","SQL","%SYS.Task,ScheduleTasks")="1,1,,Name,Description~ID~TaskClass~RunAsUser,TaskClass[Purge"
/// set ^ompare("Config","SQL","%SYS.Task,ScheduleTasks")="1,1,,Name,Description~ID~TaskClass~RunAsUser,TaskClass![Purge"
/// s g="^||DataSrc" f{s g=$Q(@g)  q:g=""  W !,@g} -->
ClassMethod IndexNamespace(namespace = "", logging = 0, includeSource = 0, schedule As ompare.Schedule = {$$$NULLOREF}) As %Status
{
	set overrideIncludeSource=includeSource
	#define RPTType "SQL"
	
	/*****************************
	 Start Template
	******************************/
	#dim tmpStream as %Stream.TmpCharacter
	Set tmpStream=##class(%Stream.TmpCharacter).%New()
	// It is necessary to switch namespace context within the method call as source code may not be 
	// deployed to target namespace
	set ret=$$$OK
	
	Quit:namespace=""
	
	New $NAMESPACE  // Ensures when method exits process will be returned to the original namespace
	
	try {	
		 // Generates <NAMESPACE> error if namespace doesn't exist
		 // Generate <PROTECT> error if user does not have access privilage
		set $NAMESPACE=namespace
	} catch errobj {
		// Name
		// Code
		// Location
		// Data
		if errobj.Name="<NAMESPACE>" {
			set ret=$$$ERROR(5001,"Cannot index namespace "_namespace_". Namespace does not exist.")
		} elseif errobj.Name="" {
			set ret=$$$ERROR(50001,"Cannot index namesapce "_namespace_". User "_$USERNAME_" does not have permission.")
		} else {
			set ret=$$$ERROR(5001,"Unknow error "_errobj.Name_". In code "_errobj.Code_" at location "_errobj.Location)
		}
	}
	Quit:$$$ISERR(ret) ret

	try {
		// Invoke sub-class extension code
		Do IndexerMain
	} catch ex {
		// Always report issue in output
		Do Log("Error","In SourceHandler.ClassDefinition")
		Do Log("  Name:",ex.Name)
		Do Log("  Code:",ex.Code)
		Do Log("  Location:",ex.Location)
		Do Log("  Data:",ex.Data)
		Set ret=ex.AsStatus()
	}
	
	Quit ret
SetSignature(typeName="", signature="",subTypeCode="", subTypeName="")
	Quit:$$$RPTType=""
	Quit:typeName=""
	Quit:signature=""
	if subTypeCode'="",subTypeName'="" {
		set ^||Data($$$RPTType,typeName,subTypeCode,subTypeName)=signature
	} else {
		set ^||Data($$$RPTType,typeName)=signature
	}
	quit
	// To itterate on the names and signatures of a particular subType
	// pass typeName by value required
	// pass signature by reference
	// pass subTypeCode by value required
	// pass subTypeName by reference required
NextSignature(typeName,signature,subTypeCode, subTypeName)
  set signature=""
  // subTypeName may be empty string at start of itteration
  Quit:typeName="" 0
  Quit:subTypeCode="" 0
  set subTypeName=$Order(^||Data($$$RPTType,typeName,subTypeCode,subTypeName),+1,signature)
  Quit:subTypeName="" 0 
  Quit 1
  // Write to stream AND conditionally to DataSrc
WriteLine(stream,data)
  // No Source Control Tokens to intercept
  Do tmpStream.WriteLine(data)
  Do:overrideIncludeSource AddLine($I(line),data)
  Quit
AddLine(line,data)
  Quit:+line=0
  // remove previous data
  if line=1 {
	 kill ^||DataSrcTmp
	 set ^||DataSrcTmp=+$H
  }
  set ^||DataSrcTmp(line)=data
  Quit
SaveLines(sig="")
  quit:sig=""
  if $Data(^||DataSrc(sig)) {
	// if the source record already exists simply update the last referenced date to today
	set ^||DataSrc(sig)=+$H
  } else {
	merge ^||DataSrc(sig)=^||DataSrcTmp
	Kill ^||DataSrcTmp
  }
  Quit 1
Log(label, value)
	W !,label,":",value
	Quit
	
IndexerMain
	/*****************************
	 End Template
	 Add sub-class code and supporting line labels from this point forward.
	******************************/
	set hasClassConfig=$Data(^ompare("Config","SQL"))
	if 'hasClassConfig,$NAMESPACE="%SYS" {
		// Default collect TaskSchedule Information when run in %SYS
		set ^ompare("Config","SQL","%SYS.Task")="1,1,10000,Name,Namespace~Description~RescheduleOnStart~DailyEndTime~DailyFrequency~DailyFrequencyTime~DailyIncrement~DailyStartTime~DisplayRun~DisplayRunAfter~Priority~RunAsUser~Settings~TaskClass"
		// Default collect CPF Information when run in %SYS
		set ^ompare("Config","SQL","Config.Cluster")="1,1,10000,SectionHeader~Name,*~-CPFName~-SectionHeader~-Name~-ID,SectionHeader=Cluster"
		set ^ompare("Config","SQL","Config.ComPorts")="1,1,10000,SectionHeader~Name,*~-CPFName~-SectionHeader~-Name~-ID,SectionHeader=ComPorts"
		set ^ompare("Config","SQL","Config.Conversions")="1,1,10000,SectionHeader~Name,*~-CPFName~-SectionHeader~-Name~-ID,SectionHeader=Conversions"
		set ^ompare("Config","SQL","Config.Databases")="1,1,10000,SectionHeader~Name,*~-CPFName~-SectionHeader~-Name~-ID,SectionHeader=Databases"
		set ^ompare("Config","SQL","Config.Debug")="1,1,10000,SectionHeader~Name,*~-CPFName~-SectionHeader~-Name~-ID,SectionHeader=Debug"
		set ^ompare("Config","SQL","Config.DeviceSubTypes")="1,1,10000,SectionHeader~Name,*~-CPFName~-SectionHeader~-Name~-ID,SectionHeader=DeviceSubTypes"
		set ^ompare("Config","SQL","Config.Devices")="1,1,10000,SectionHeader~Name,*~-CPFName~-SectionHeader~-Name~-ID,SectionHeader=Devices"
		set ^ompare("Config","SQL","Config.ECP")="1,1,10000,SectionHeader~Name,*~-CPFName~-SectionHeader~-Name~-ID,SectionHeader=ECP"
		set ^ompare("Config","SQL","Config.ECPServers")="1,1,10000,SectionHeader~Name,*~-CPFName~-SectionHeader~-Name~-ID,SectionHeader=ECPServers"
		set ^ompare("Config","SQL","Config.Gateways")="1,1,10000,SectionHeader~Name,*~-CPFName~-SectionHeader~-Name~-ID,SectionHeader=Gateways"
		set ^ompare("Config","SQL","Config.IO")="1,1,10000,SectionHeader~Name,*~-CPFName~-SectionHeader~-Name~-ID,SectionHeader=IO"
		set ^ompare("Config","SQL","Config.Journal")="1,1,10000,SectionHeader~Name,*~-CPFName~-SectionHeader~-Name~-ID,SectionHeader=Journal"
		set ^ompare("Config","SQL","Config.LicenseServers")="1,1,10000,SectionHeader~Name,*~-CPFName~-SectionHeader~-Name~-ID,SectionHeader=LicenseServers"
		set ^ompare("Config","SQL","Config.MagTapes")="1,1,10000,SectionHeader~Name,*~-CPFName~-SectionHeader~-Name~-ID,SectionHeader=MagTapes"
		set ^ompare("Config","SQL","Config.MapGlobals")="1,1,10000,SectionHeader~Namespace~Name~-ID,*~-CPFName~-SectionHeader~-Namespace~-Name,SectionHeader=MapGlobals"
		set ^ompare("Config","SQL","Config.MapMirrors")="1,1,10000,SectionHeader~Name,*~-CPFName~-SectionHeader~-Name~-ID,SectionHeader=MapMirrors"
		set ^ompare("Config","SQL","Config.MapPackages")="1,1,10000,SectionHeader~Namespace~Name,*~-CPFName~-SectionHeader~-Namespace~-Name~-ID,SectionHeader=MapPackages"
		set ^ompare("Config","SQL","Config.MapRoutines")="1,1,10000,SectionHeader~Namespace~Name,*~-CPFName~-SectionHeader~-Namespace~-Name~-ID,SectionHeader=MapRoutines"
		set ^ompare("Config","SQL","Config.MirrorMember")="1,1,10000,SectionHeader~Name,*~-CPFName~-SectionHeader~-Name~-ID,SectionHeader=MirrorMember"
		set ^ompare("Config","SQL","Config.Mirrors")="1,1,10000,SectionHeader~Name,*~-CPFName~-SectionHeader~-Name~-ID,SectionHeader=Mirrors"
		set ^ompare("Config","SQL","Config.Miscellaneous")="1,1,10000,SectionHeader~Name,*~-CPFName~-SectionHeader~-Name~-ID,SectionHeader=Miscellaneous"
		set ^ompare("Config","SQL","Config.Monitor")="1,1,10000,SectionHeader~Name,*~-CPFName~-SectionHeader~-Name~-ID,SectionHeader=Monitor"
		set ^ompare("Config","SQL","Config.Namespaces")="1,1,10000,SectionHeader~Name,*~-CPFName~-SectionHeader~-Name~-ID,SectionHeader=Namespaces"
		set ^ompare("Config","SQL","Config.SQL")="1,1,10000,SectionHeader~Name,*~-CPFName~-SectionHeader~-Name~-ID,SectionHeader=SQL"
		set ^ompare("Config","SQL","Config.Shadows")="1,1,10000,SectionHeader~Name,*~-CPFName~-SectionHeader~-Name~-ID,SectionHeader=Shadows"
		set ^ompare("Config","SQL","Config.SqlSysDatatypes")="1,1,10000,SectionHeader~Name,*~-CPFName~-SectionHeader~-Name~-ID,SectionHeader=SqlSysDatatypes"
		set ^ompare("Config","SQL","Config.SqlUserDatatypes")="1,1,10000,SectionHeader~Name,*~-CPFName~-SectionHeader~-Name~-ID,SectionHeader=SqlUserDatatypes"
		set ^ompare("Config","SQL","Config.Startup")="1,1,10000,SectionHeader~Name,*~-CPFName~-SectionHeader~-Name~-ID,SectionHeader=Startup"
		set ^ompare("Config","SQL","Config.Telnet")="1,1,10000,SectionHeader~Name,*~-CPFName~-SectionHeader~-Name~-ID,SectionHeader=Telnet"
		set ^ompare("Config","SQL","Config.WorkQueues")="1,1,10000,SectionHeader~Name,*~-CPFName~-SectionHeader~-Name~-ID,SectionHeader=WorkQueues"
		set ^ompare("Config","SQL","Config.config")="1,1,10000,SectionHeader~Name,*~-CPFName~-SectionHeader~-Name~-ID,SectionHeader=config"
	}
	
	
	// Initialise process
	Kill ^||SQLTableNames,^||SQLTableNamesMatched
	
	// First we create a list of SQL tables that extend %Persistent
	set rs=##class(%ResultSet).%New()
	set rs.ClassName="%Dictionary.ClassDefinitionQuery"
  	set rs.QueryName="SubclassOf"
  	set tSC=rs.Execute("%Persistent")
  	if $$$ISERR(tSC) {
	 	do Log("Error","In SourceHandler.SQLTable. Unable to run %Persistent Query")
	 	quit
  	}
  	for {
		quit:'rs.Next()
  		//
  		set classname=$Get(rs.Data("Name"))
  		continue:classname=""
  		
  		set classdef=##class(%Dictionary.ClassDefinition).%OpenId(classname,0)
  		continue:'$IsObject(classdef)
  		continue:classdef.Abstract=1  // Ignore template classes
  		
  		set sqlTable=$$GetSQLTableName(classname)
  		continue:sqlTable=""
  		// Add to available SQL Tables on the system
  		set ^||SQLTableNames(sqlTable)="" 		
  	}
  	set classdef=""
	
	set tableAndAlias=""
	for {
		set tableAndAlias=$Order(^ompare("Config","SQL",tableAndAlias),+1,rules)
		quit:tableAndAlias=""
		
		// Check rule is enabled
		if '+rules {
			do Log("Info","Ignoring disabled SQL Table and Alais "_tableAndAlias)
			continue	
		}
		// Only process enabled search mask
		//do Log("Info","Processing enabled SQL Table and Alais "_tableAndAlias)
		Do MatchSQLTables(tableAndAlias,rules)	
	}
	set table=""
	for {
		// table variable will be SQL Table name with optional Alias Name
		// delimted by comma
		// This is to support multiple rule profiles for a single table
		set table=$O(^||SQLTableNamesMatched(table))
		quit:table=""
		set alias=""
		for {
			set alias=$O(^||SQLTableNamesMatched(table,alias),1,rules)
			quit:alias=""
			do Log("Info","Processing enabled SQL Table and Alais "_table_" ("_alias_")")
			do IndexSQLTable(table,alias,rules)
		}
	}
	
	// For each matched SQLTable
	// Run extract based on mask parameters
	
	//Do Log("Start",$ZDT($H,3))
	//Do SetSignature("Class1","sig")
	//Do SetSignature("Class1","sig","PROP","TESTPROP")
	//Do Log("End",$ZDT($H,3))
	/***********************
	  End Indexer Specific code
	************************/
	// Tidy up
	Kill ^||SQLTableNames
	Kill ^||SQLTableNamesMatched
	
	Quit
 // Returned the explicit SQL Table name from a class
 // or derives the SQL name that would be used
GetSQLTableName(classname)
	set sqlTable=""
	// Derive SQLTable Name from Classname
  	set sqlTable=classdef.SqlTableName
  	if sqlTable="" {
		// Replace Dot "." for "_" underscore in package name
		set sqlTable=$Tr($P(classname,".",1,$L(classname,".")-1),".","_")_"."_$P(classname,".",$Length(classname,"."))
		// Replace prefix "User" with "SQLUser" for default user table schema
		set:$P(sqlTable,"_")="User" sqlTable="SQLUser_"_$P(sqlTable,"_",2,99)
		// Replace "%" System class prefix with "_" underscore
		//set:$E(sqlTable,1)="%" sqlTable="_"_$E(sqlTable,2,*)
  	}
  	quit sqlTable
 // Sub-Routine that creates a list of SQL Tables
 // That match the given prefix mask
 // Adds entries to process private global ^||SQLTableNamesMatched
 // Do not clear existing entries
 // Only invoked for pattern that is enabled
MatchSQLTables(tableAndAlias,rules)
 set mask=$ZSTRIP($P(tableAndAlias,",",1),"*W")
 set alias=$ZSTRIP($P(tableAndAlias,",",2),"*W")
 set:alias="" alias="_"
 quit:mask=""
 if $E(mask,*)="*" {
	 set (start,next)=$E(mask,1,*-1)
	 // We don't do ALL tables??
	 quit:start=""
	 set startLen=$length(start)
	 
	 if $Data(^||SQLTableNames(start)) {
		// Might as well just set matching rules here
		set ^||SQLTableNamesMatched(start,alias)=rules
	 }
	 
	 for {
		set next=$Order(^||SQLTableNames(next))
		quit:next=""
		// Moved past wild card include section
		quit:start'=$E(next,1,startLen)
		// Check Match is enabled
		set ^||SQLTableNamesMatched(next,alias)=rules
	 }
 } else {
	 // Exact Match
	 if $Data(^||SQLTableNames(mask)) {
		set ^||SQLTableNamesMatched(mask,alias)=rules
	 }
 }
 quit
 // Adds record to temporary area for sorting by record ID
SortNVP(key,value)
 if key="" {
	 Do Log("ERROR","SortNVP Key="_key_" was empty")
	 Quit
 }
 if $Data(^||NVP(key)) {
	 Do Log("ERROR","SortNVP Duplicate Key """_key_""" detected."_$C(10)_"  Existing value="_$G(^||NVP(key))_"."_$C(10)_"  New value="_value)
	 Quit	 
 }
 Do:logging Log("INFO","SortNVP Key="_key_";value="_value)
 set ^||NVP(key)=value
 Quit
 // Outputs ID ordered records into Stream for signature and source output
FlushNVP(oKey,oData)
 set key=""
 for {
	set key=$O(^||NVP(key),1,data)
	quit:key=""
 	Do WriteLine(tmpStream,key_"¬"_data)
 }
 //Kill ^||NVP
 Do tmpStream.Flush()
 Quit
FilterUnknown(FilterUnknownVal, FilterUnknownUnknown = "?",oFilterUnknownUnknownRep)
 set oFilterUnknownUnknownRep="",$P(oFilterUnknownUnknownRep,FilterUnknownUnknown,32)=""
 quit $TR(FilterUnknownVal,$C(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31),oFilterUnknownUnknownRep)
 // <example>
 // Set val=$LB(123,$$LB(
 // Do ##class(ompare.SourceHandler.SQLTable).ToString(val)
 // </exampe>
 // Recursive normalisation of List Columns for embedded objects in SQL
 // The Binary data via GZIP stream causes issues for loading data on target report service
ToString(pToStringVal, pToStringDelim1 = "#", pToStringDelim2 = "@", pToStringUnknown = "?", pToStringStop = 0,oRet,oLl,oI,oListItem)
  set oRet=""
  if $Listvalid(pToStringVal) {
    set oLl=$LISTLENGTH(pToStringVal)
    for oI=1:1:oLl {
      set oListItem=$ListGet(pToStringVal,oI,"")
	  if $Listvalid(pToStringVal) {
	    set oListItem=$$ToString(oListItem,pToStringDelim2,"[",pToStringUnknown)	
	  }
	  set oRet=oRet_$S(oI=1:"",1:pToStringDelim1)_$$FilterUnknown(oListItem,pToStringUnknown)
    }
  } else {
    set oRet=$$FilterUnknown(pToStringVal,pToStringUnknown)	
  }
  quit oRet

 // For each SQL Table of interest
 // process the rules
IndexSQLTable(sqlTable,sqlTableAlias,rules,writeHeaders=1)
 Kill ^||NVP
 Do:logging Log("INFO","Invoke IndexSQLTable with table="_sqlTable_";alias="_sqlTableAlias_";rules="_rules)
 quit:sqlTable=""
 quit:rules=""
 Do tmpStream.Rewind()
 Do tmpStream.Write("")  // Attempt to truncate prior content
 Do tmpStream.Flush()
 Do tmpStream.Clear()
 set line=0
 // Initilaise
 kill cols,colsU,colsUse
 
 //set indexParameters=$Get(^ompare("Config","SQL",rules))
 set overrideIncludeSource=$Piece(rules,",",2)
 if $Piece(rules,",",2)="" {
	 set overrideIncludeSource=includeSource
 }else {
	 set overrideIncludeSource=+$Piece(rules,",",2)
 }
 set maxRows=+$Piece(rules,",",3)
 set:maxRows<1 maxRows=1000
 set idSpec=$Piece(rules,",",4)
 set ideSpecLen=$L(idSpec)
 set rowSpec=$Piece(rules,",",5)
 kill filter set filter=$Piece(rules,",",6)
 set filterCount=0,filterGroup=0
 set filterLen=$L(filter,"~")
 for {
	set filterCount=filterCount+1
	quit:filterCount>filterLen
	set filterData=$P(filter,"~",filterCount)
	
	set operatorPos=9999,operatorNext=0,operatorUse=""
	for operator="<",">","!=","=","![","[" {
		set operatorNext=$F(filterData,operator)
		if operatorNext>0,operatorNext<operatorPos {
			set operatorUse=operator
			set operatorPos=operatorNext
		}
}
	continue:operatorPos=9999
	continue:operatorUse=""
	// Support comparison operators
	// < - less than 
	// > - more than
	// =
	// Support multiple constraints on same column for range query
	// set filter("Age",">",18)=""
	// set filter("Age","<",67)=""
	
	// set filter(filterKey,operator,filterVal)=""
	// 
	
	set filterKey=$ZSTRIP($P(filterData,operatorUse),"<>W")
	continue:filterKey=""
	continue:filterKey="&"
	if $E(filterKey,1)="&" {
		// composite condition
		set filterKey=$E(filterKey,2,*)
	} else {
		set filterGroup=filterGroup+1	
	}
	set filterVal=$ZSTRIP($P(filterData,operatorUse,2,99),"<>W")
	set:filterVal="" filterVal=$C(0) // Support null or empty values
	// All operators MUST match within a given filterGroup
	set filter(filterGroup,filterKey,operatorUse,filterVal)=""
 }
 set:rowSpec="" rowSpec="*"
 // SQL names are case insensitive
 set rowSpec="~"_$ZCVT(rowSpec,"U")_"~"
 set rowSpecLen=$L(rowSpec,"~")
 // Reset from any previous invocation
 kill idList,idSeq
 set idList="",idSeq=0
 for i=1:1:ideSpecLen {
	set id=$ZCVT($ZSTRIP($P(idSpec,"~",i),"*W"),"U")
	continue:id=""
	//set idList=$S($L(idList)=0:"",1:",")_idList  // creating a list of items to slect for 
	set idList(id)=""  // Used to filter out Value Columns where Information is already part of the Key Columns
	set idSeq($I(idSeq))=id  // Used to assemble SubKeys in correct order of rule definition
 }
 // if no ID columns are explicitly defined in the rules
 // then fallback to defaults
 if idSeq<1 {
	 
	 set idList("ID")=""
	 set idSeq(1)="ID"
	 set idListM("ID")="ID"
 }
 
 set rs=##class(%ResultSet).%New("%DynamicQuery:SQL")
 // Decide what the columns are and pre-filter on SQL statement
 //   OR
 // Use select ALL approach
 // ******************
 // TODO - TABLE may have ALIAS defined for IT - Strip ALIAS for select??
 // TODO - Rows to Select??
 
 // MUST NOT LOCK
 set sqlStatement="SELECT %NOLOCK %ID as ID,* FROM "_sqlTable
 set sc=rs.Prepare(sqlStatement)
 Do:logging Log("INFO",sqlStatement)
 if $$$ISERR(sc) {
	Do:logging Log("Error","Unable to Prepare Statement for table "_sqlTable_$Select(sqlTableAlias'="":" as Alias "_sqlTableAlias))
	set rs=""
	quit
 }
 set sc=rs.Execute()
 if $$$ISERR(sc) {
	Do:logging Log("Error","Unable to Execute Statement for table "_sqlTable)
	set rs=""
	quit
 }
 
 // Process Headers
 // On the frist row of the returned resultset extract the headers to create a header record
 
 // Calculate Row Headers for inclusion or exclusion
 // Expand columns to use
 // Case insensitive search for column filtering

 set colCount=rs.GetColumnCount()	
 
 set col=""
 for k=1:1:colCount {
	set col=rs.GetColumnHeader(k)
 	//set col=$O(rs.Data(col))
	continue:col=""
	// If this is not an ID column add for value columns
	if '$Data(idList($ZCVT(col,"U"))) {
		//set:col'?1(1"ID",1.N1".ID") cols(col)=""  // Actual Case names
		//set:col'?1(1"ID",1.N1".ID") colsU($ZCVT(col,"U"))=col  // Capture case insensitive
		//set:col'?1(1"ID",1.N1".ID") cols(col)=""  // Actual Case names
		//set:col'?1(1"ID",1.N1".ID") colsU($ZCVT(col,"U"))=col  // Capture case insensitive
		set:col'?1(1.N1".ID") cols(col)=""  // Actual Case names // Allow ID in Values
		set:col'?1(1.N1".ID") colsU($ZCVT(col,"U"))=col  // Capture case insensitive // Allow ID in Values
	} else {
		set idListM($ZCVT(col,"U"))=col  // Builds a link between case insensitive 	
	}
 }

 if rowSpec["~*~" {// WildCard expand all
	Do:logging Log("INFO","WildCard pattern ""*"" detected expand ALL")
	merge colsUse=colsU  // Does not contain ID columns

 }
 for i=1:1:rowSpecLen {
	set (scol,mcol)=$ZSTRIP($ZCVT($Piece(rowSpec,"~",i),"U"),"*W")
	continue:mcol=""
	continue:mcol="-"
	continue:mcol="*"
	set:$E(scol,1)="-" (scol)=$E(scol,2,*)
	set:$E(scol,*)="*" (scol)=$E(scol,1,*-1)
		
	// exact column match
	if $E(mcol,*)="*" {
		Do:logging Log("INFO","Wild Card match on pattern "_mcol)
		set colStartLen=$Length(scol)
		
		set col=scol
		for {
			set col=$O(colsU(col),1,colMixed)
			quit:col=""
			quit:$E(col,1,colStartLen)'=scol
			// Remove filtered out columns
			if $E(mcol,1)="-" {
				Do:logging Log("INFO","Remove column "_col_" matches "_mcol)
				kill cols(colMixed)
				kill colsU(col)
				kill colsUse(col)
				continue
			} else {
				Do:logging Log("INFO","Include column "_col_" matches "_mcol)
				// Include filtered in columns
				set colsUse(col)=colMixed
				continue
			}
		}
	}
	// If the exact match exists as a column then process it
	if $Data(colsU(scol)) {
		Do:logging Log("INFO","Exact Match on column "_scol_" with match pattern "_mcol)
		set colMixed=$G(colsU(scol))
		if $E(mcol,1)="-" {
			Do:logging Log("INFO","Exclude Single column "_scol_" matches "_mcol)
			kill:colMixed'="" cols(colMixed)
			kill colsU(scol)
			//kill colsUse(scol,"U")
			kill colsUse(scol)
		} else {
			Do:logging Log("INFO","Include Single column "_scol_" matches "_mcol)
			set:colMixed'="" colsUse(scol)=colMixed
		}
	}
 }
	
	// Write Headers
	set col=""
	set key=""
	set data=""
	
	set colSeq=""
	for {
		set colSeq=$O(idSeq(colSeq),1,col)
		quit:colSeq=""
		Do:logging Log("INFO","colSeq "_colSeq_";col="_col)
		set mcol=$G(idListM(col)) // Same as colMixed
		// unexpected - Bad rule configuration
		if mcol="" {
			Do:logging Log("ERROR","Cannot find ID column "_mcol_" in match rule ID specification "_idSpec)
			//kill colsUse  // terminate processing
			continue  
		} else {
			Do:logging Log("INFO","Find ID column "_mcol_" in match rule ID specification "_idSpec)
		}
		set:key'="" key=key_"¬"
		set key=key_mcol
	}
	// followed by data column headers
	set col=""
	for {
		set col=$O(colsUse(col),1,colMixed)
		quit:col=""
    	set data=data_"¬"_colMixed  // Headers ID
 	}
		
 	Do:writeHeaders WriteLine(tmpStream,key_"¬"_data)


 // END PROCESS HEADERS
 set rowCount=0
 for {
	if 'rs.Next(.sc) {
		Do:logging Log("ERROR","ResultSet.Next "_$SYSTEM.Status.GetOneErrorText(sc))
		quit
	}
 	set rowCount=rowCount+1
	if rowCount>maxRows {
		Do:logging Log("WARNING","MaxRows "_maxRows_" encounted")
		quit	
	}

 	// Assumes cols collection is set up
 	if '$Data(colsUse) {
		Do Log("WARNING","No records for table")
		quit
	}
	Do:logging Log("INFO","Data Row "_rowCount)
	// for each filter
	set filterAndGroup=0
	// If there are no filters then just include all records for the table
	set filterRecord=$S($D(filter)>1:1,1:0)
	for {
		set pass=1
		set filterAndGroup=$Order(filter(filterAndGroup))
		quit:filterAndGroup=""
		
		set filterItem=""
		for {
			quit:pass=0
			set filterItem=$Order(filter(filterAndGroup,filterItem))
			quit:filterItem=""
			
			set filterOperator=""
			for {
				quit:pass=0
				set filterOperator=$O(filter(filterAndGroup,filterItem,filterOperator))
				quit:filterOperator=""
				
				set filterValue=""
				for {
					quit:pass=0
					set filterValue=$O(filter(filterAndGroup,filterItem,filterOperator,filterValue))
					quit:filterValue=""
					set filterValueTest=filterValue
					set:filterValue=$C(0) filterValueTest=""
					set filterItemData=rs.Data(filterItem)
					if $E(filterValueTest,*)="*" {  // StartWith
						set filterValueTest=$P(filterValueTest,"*")
						set:filterOperator["=" filterItemData=$E(filterItemData,1,$L(filterValueTest))
					} 
										
					// And / Or ??
					//="<",">","!=","=",![,[
					if filterOperator="<" {
						if filterItemData'<filterValueTest {
							Do:logging Log("INFO","Filtering out row="_rowCount_";Column="_colMixed_";Expected less than "_filterValue_";Actual="_rs.Data(filterItem))
							set pass=0
							quit  // early exit
						}
					} elseif filterOperator=">" {
						if filterItemData'>filterValueTest {
							Do:logging Log("INFO","Filtering out row="_rowCount_";Column="_colMixed_";Expected more than "_filterValue_";Actual="_rs.Data(filterItem))
							set pass=0
							quit  // early exit
						}
					} elseif filterOperator="!=" {
						if filterItemData=filterValueTest {
							Do:logging Log("INFO","Filtering out row="_rowCount_";Column="_colMixed_";Expected not equal"_filterValue_";Actual="_rs.Data(filterItem))
							set pass=0
							quit  // early exit
						}
					} elseif filterOperator="=" {
						if filterItemData'=filterValueTest {
							Do:logging Log("INFO","Filtering out row="_rowCount_";Column="_colMixed_";Expected equal"_filterValue_";Actual="_rs.Data(filterItem))
							set pass=0
							quit  // early exit
						}
					} elseif filterOperator="![" {
						if filterItemData[filterValueTest {
							Do:logging Log("INFO","Filtering out row="_rowCount_";Column="_colMixed_";Expected does not contain "_filterValue_";Actual="_rs.Data(filterItem))
							set pass=0
							quit  // early exit
						}	
					} elseif filterOperator="[" {
						if filterItemData'[filterValueTest {
							Do:logging Log("INFO","Filtering out row="_rowCount_";Column="_colMixed_";Expected contains"_filterValue_";Actual="_rs.Data(filterItem))
							set pass=0
							quit  // early exit
						}	
					}
				}
			}
		}
		set:pass filterRecord=0
		/*
		set filterValue=$Get(filter(filterItem))
		
		if rs.Data(filterItem)'=filterValue {
			Do:logging Log("INFO","Filtering out row="_rowCount_";Column="_colMixed_";Expected="_filterValue_";Actual="_rs.Data(filterItem))
			set filterRecord=1	
		} */
	}
	continue:filterRecord
	
	set key=""
	set col=""
	set colSeq=""
	for {
		set colSeq=$O(idSeq(colSeq),1,col)
		quit:colSeq=""
		continue:col=""
		set mcol=$G(idListM(col)) // Same as colMixed
		// unexpected - Bad rule configuration
		if mcol="" {
			Do:logging Log("ERROR","Cannot find ID column "_col_" in match rule ID specification "_idSpec)
			//kill colsUse  // terminate processing
			continue 
		}else {
		}
		set:key'="" key=key_"¬"
		set key=key_$$ToString($G(rs.Data(mcol)))
	}

	 // Assumes cols collection is set up
	quit:'$Data(colsUse)
	set data=""
	set col=""
	for {
		set col=$O(colsUse(col),1,colMixed)
		quit:col=""
		// append build up record
		//continue:col="ID"  // COLS ID in DATA
		set:data='"" data=data_"¬"
		set data=data_"¬"_$$ToString(rs.Data(colMixed))
	}
	
	
 	Do:logging Log("INFO","Call SortNVP rowCount="_rowCount_";key="_key_";value"_data)
	Do SortNVP(key,data)
	//Do WriteLine(tmpStream,key_"¬"_data)
 }
 if $$$ISERR(sc) {
	Do Log("Error","Processing table rowcount "_rowCount)
	set rs=""
	quit
 }
 Do FlushNVP()  // Outputs sorted records to stream
 set sig=$SYSTEM.Encryption.Base64Encode($SYSTEM.Encryption.SHA1HashStream(tmpStream))
 Do SetSignature(sqlTable_$S(sqlTableAlias'="_":" ("_sqlTableAlias_")",1:""), sig)
 Do SaveLines(sig)
 
 quit
}

/*
/// <example>
/// Set val=$LB(123,$$LB(
/// Do ##class(ompare.SourceHandler.SQLTable).ToString(val)
/// </exampe>
/// Recursive normalisation of List Columns for embedded objects in SQL
/// The Binary data via GZIP stream causes issues for loading data on target report service
/// TODO - Move to line label
ClassMethod ToString(val, delim1 = "#", delim2 = "@", unknown = "?", stop = 0)
{
	set ret=""
	if $Listvalid(val) {
		set ll=$LISTLENGTH(val)
		for i=1:1:ll {
			set listItem=$ListGet(val,i,"")
			if $Listvalid(val) {
				set listItem=..ToString(listItem,delim2,"[",unknown)	
			}
			set ret=ret_$S(i=1:"",1:delim1)_..FilterUnknown(listItem,unknown)
		}
	} else {
		set ret=..FilterUnknown(val,unknown)	
	}
	quit ret
}

ClassMethod FilterUnknown(val, unknown = "?")
{
	quit $TR(val,$C(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31),unknown)
}
*/

/*
ClassMethod TestToString()
{
	set val="123,456,789"
	if ..ToString(val)'="123,456,789" {
		W !,"Error in Test 1"	
	}
	set val=$LB(123,456,789)
	if ..ToString(val)'="123#456#789" {
		W !,"Error in Test 2"	
	}
	
	set val=$LB(123,$LB(456,789),$LB(10,11,12),$LB(14))
	if ..ToString(val)'="123#456@789#10@11@12#14" {
		W !,"Error in Test 3"	
	}
	set val=$LB(123,$LB(456_$C(13),789_$C(9)),$LB(10_$C(22),11_$C(25),12),$LB(14))
	if ..ToString(val)'="123#456@789#10@11@12#14" {
		W !,"Error in Test 4"	
	}
}
*/
}

