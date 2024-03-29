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
/// Source Handler for collecting Global, Routine and Package Mappings that can
/// be used for reporting diffrences of Namespace configuration between instances.
/// No configuration options.
Class ompare.SourceHandler.Mapping Extends ompare.SourceHandler.Base
{

/// Ensure this Code doesn't collide with other sub-class implementations of Base
/// Eg: "CLS" abbreviation for class
Parameter TypeCode As %String = "NSMAP";

/// Do not invoke supporting methods on this class definition
ClassMethod IndexNamespace(namespace = "", logging = 0, includeSource = 0, schedule As ompare.Schedule = {$$$NULLOREF}) As %Status
{
	if '$IsObject(schedule) {
		set schedule=##class(ompare.Schedule).%New()
	}
	#define RPTType "NSMAP"
	#define RPTNameDefault "Default"
	#define RPTNameGlobal "Globals"
	#define RPTNameRoutine "Routines"
	#define RPTNamePackage "Packages"
	
	/*****************************
	 Start Template
	******************************/
	#dim tmpStream as %Stream.TmpCharacter
	Set tmpStream=##class(%Stream.TmpCharacter).%New()
	#dim tmpStreamSub as %Stream.TmpCharacter
	Set tmpStreamSub=##class(%Stream.TmpCharacter).%New()
	// It is necessary to switch namespace context within the method call as source code may not be 
	// deployed to target namespace
	set ret=$$$OK
	
	Quit:namespace="" $$$ERROR(5001,"Namespace not supplied to Mapping Source Handler")
	Quit:'##class(%SYS.Namespace).Exists(namespace) $$$ERROR(5001,"Namespace "_namespace_" does not exist")
	
	New $NAMESPACE  // Ensures when method exits process will be returned to the original namespace
	
	try {	
		 // Generates <NAMESPACE> error if namespace doesn't exist
		 // Generate <PROTECT> error if user does not have access privilage
		set $NAMESPACE="%SYS"  // In this specific scenario need access to the SYS Namespace to run privilaged functionality
	} catch errobj {
		// Name
		// Code
		// Location
		// Data
		set ret=$$$ERROR(5001,"No access for user "_$USERNAME_" to %SYS namespace ")
	}
	Quit:$$$ISERR(ret) ret
	
	// Invoke sub-class extension code
	Do IndexerMain
	
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
  Do tmpStream.WriteLine(data)
  Do:includeSource AddLine($I(line),data)
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
	// Default Section
	Set line=0
	Set tSC=##Class(Config.Namespaces).Get(namespace,.properties)
	Do tmpStream.Clear()
	Do WriteLine(tmpStream,"GlobalDB: "_$G(properties("Globals")))
	Do WriteLine(tmpStream,"RoutineDB: "_$G(properties("Routines")))
	Do WriteLine(tmpStream,"TempDB: "_$G(properties("TempGlobals")))
	// Use a Stream as we don't know how many entries are required in a lookup table
	Do tmpStream.Rewind()
	set sig=$SYSTEM.Encryption.Base64Encode($SYSTEM.Encryption.SHA1HashStream(tmpStream))
	Do SetSignature($$$RPTNameDefault, sig)
	Do:includeSource SaveLines(sig)
	
	// Global Map Section
	// Query: Config.MapGlobals:List(Namespace)
    //   Name, Global, Subscript, Database
    Set line=0
	Do tmpStream.Clear()
	set rs=##class(%ResultSet).%New("Config.MapGlobals:List")
	do rs.Execute(namespace)
	for {
		quit:'rs.Next()
		set rName=$G(rs.Data("Name"))
		continue:rName=""
		set rGlobal=$G(rs.Data("Global"))
		continue:rGlobal=""
		set rSubscript=$G(rs.Data("Subscript"))
		set rDatabase=$G(rs.Data("Database"))
		Do WriteLine(tmpStream,"Global:"_rGlobal)
		Do WriteLine(tmpStream,"  Subscript="_rSubscript)
		Do WriteLine(tmpStream,"  Database="_rDatabase)
	}
	set rs=""
	set sig=$SYSTEM.Encryption.Base64Encode($SYSTEM.Encryption.SHA1HashStream(tmpStream))
	Do SetSignature($$$RPTNameGlobal, sig)
	Do:includeSource SaveLines(sig)

	// Package Map Section
	// Query: Config.MapPackages:List(Namespace)
    //   Name, Package, Database
    Set line=0
    Do tmpStream.Clear()
	set rs=##class(%ResultSet).%New("Config.MapPackages:List")
	do rs.Execute(namespace)
	for {
		quit:'rs.Next()
		set rName=$G(rs.Data("Name"))
		continue:rName=""
		set rPackage=$G(rs.Data("Package"))
		continue:rPackage=""
		set rDatabase=$G(rs.Data("Database"))
		Do WriteLine(tmpStream,"Package:"_rPackage)
		Do WriteLine(tmpStream,"  Database="_rDatabase)
	}
	set rs=""
	set sig=$SYSTEM.Encryption.Base64Encode($SYSTEM.Encryption.SHA1HashStream(tmpStream))
	Do SetSignature($$$RPTNamePackage, sig)
	Do:includeSource SaveLines(sig)

	// Routines Map Section
	// Query: Config.MapRoutines:List(Namespace)
  	//   Name, Routine, Type, Database
	Set line=0
	Do tmpStream.Clear()
	set rs=##class(%ResultSet).%New("Config.MapRoutines:List")
	do rs.Execute(namespace)
	for {
		quit:'rs.Next()
		set rName=$G(rs.Data("Name"))
		continue:rName=""
		set rRoutine=$G(rs.Data("Routine"))
		continue:rRoutine=""
		set rDatabase=$G(rs.Data("Database"))
		Do WriteLine(tmpStream,"Routine:"_rRoutine)
		Do WriteLine(tmpStream,"  Database="_rDatabase)
	}
	set rs=""
	set sig=$SYSTEM.Encryption.Base64Encode($SYSTEM.Encryption.SHA1HashStream(tmpStream))
	Do SetSignature($$$RPTNameRoutine, sig)
	Do:includeSource SaveLines(sig)
	/***********************
	  End Indexer Specific code
	************************/
	Quit
}

}

