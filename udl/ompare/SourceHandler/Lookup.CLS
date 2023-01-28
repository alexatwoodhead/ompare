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
/// Source Handler for Interoperability Lookup Tables.
/// Builds signature profiles for Keys and their Values.<br/>
/// When first run in each namespace no default exclusions are established.<br/>
/// To exclude a LookupTable use:
/// <example>
/// ^ompare("Config","Exclude","ompare.*.lut")=1
/// ^ompare("Config","Exclude","ompare.Exclude.lut")=0
/// </example>
/// Where value "1" means exclude and "0" means include.<br/>
/// Above exclusions are layered to exclude all lookup tables starting within name <em>ompare</em>
/// except do include analysis of the <em>ompare.Exclude</em> table.
Class ompare.SourceHandler.Lookup Extends ompare.SourceHandler.Base
{

/// Ensure this Code doesn't collide with other sub-class implementations of Base
/// Eg: "CLS" abbreviation for class
Parameter TypeCode As %String = "LUT";

/// Main entry point for Ensemble Lookup Table Source Handler
/// do ##class(ompare.SourceHandler.Lookup).IndexNamespace($namespace,1)
ClassMethod IndexNamespace(namespace = "", logging = 0, includeSource = 0, schedule As ompare.Schedule = {$$$NULLOREF}) As %Status
{
	#define RPTType "LUT"
	#define RPTSubTypeEnsLookupKey "Key"
	
	// Testing
    // Do ##class(ompare.SourceHandler.EnsLookupTable).IndexNamespace("INTEG-MARS",0,0)
	
	/*****************************
	 Start Template
	******************************/
	#dim tmpStream as %Stream.TmpCharacter
	Set tmpStream=##class(%Stream.TmpCharacter).%New()
	// It is necessary to switch namespace context within the method call as source code may not be 
	// deployed to target namespace
	set ret=$$$OK
	
	Quit:namespace="" $$$ERROR(5001,"Namespace not supplied to Lookup Source Handler")
	
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
Log(label, value="")
	W !,label,":",value
	Quit
IsExcluded(name,reason)
	set reason=""
	Quit:name="" 1
	// Change the type extension to uppercase 
	set extension=$ZCVT($P(name,".",$L(name,".")),"L")
	set name=$e(name,1,*-($L(extension)+1))
	// Check Exact match for exlcusion
	if +$G(^ompare("Config","Exclude",name_"."_extension)) {
		set reason=name_"."_extension
		quit 1	
	} elseif $Data(^ompare("Config","Exclude",name_"."_extension)) {
		// Explicitly NOT excluded
		quit 0	
	}
	// now recursively look to exclude by wildcard match.
	set found=0
	set reason=""
	set prefix=$e(name,1,*-1)_"*"
	for {
		set found=+$G(^ompare("Config","Exclude",prefix_"."_extension))
		set:found reason=prefix_"."_extension
		quit:found
		if $Data(^ompare("Config","Exclude",prefix_"."_extension)) {
			// Explicitly NOT excluded
			quit	
		}
		set prefix=$E(prefix,1,*-2)_"*"
		q:prefix="*"
	}
	quit found
	
IndexerMain
	/*****************************
	 End Template
	 Add sub-class code and supporting line labels from this point forward.
	******************************/
	
	set tablename=""
	for {
		set tablename=$Order(^Ens.LookupTable(tablename))
		quit:tablename=""
		if $$IsExcluded(tablename_".lut",.reason) {
			Do:logging Log("Ignore """_tablename_""" matches ",reason)
			continue
		}
		Do:logging Log("IndexLookup "_tablename)
		Do IndexLookup(tablename,tmpStream)
	}
	Quit
IndexLookup(tablename,tmpStream)
	Quit:tablename=""
	Quit:'$IsObject(tmpStream)
	
	Do tmpStream.Clear()

	// Replace existing data
	set line=0
	
	// Simple - Replacing data
	set key=""
	for {
		set key=$Order(^Ens.LookupTable(tablename,key),+1,data)	
		quit:key=""
		
		// Saving the actual values instead of signatures.
		// Rationale: Ensemble Lookups values tend to be much smaller than a corresponding 20 character signature
		// The comparison code for reports will automatically compare the stored values
		// Revert "Null" entries to empty strings on export
		set:data=$C(0) data=""
		Do WriteLine(tmpStream,key_"¬¬"_data)
	}
	// Use a Stream as we don't know how many entries are required in a lookup table
	Do tmpStream.Rewind()
	//Do SetSignature(tablename,$SYSTEM.Encryption.Base64Encode($SYSTEM.Encryption.SHA1HashStream(tmpStream)))
	set sig=$SYSTEM.Encryption.Base64Encode($SYSTEM.Encryption.SHA1HashStream(tmpStream))
	Do SetSignature(tablename, sig)
	Do SaveLines(sig)  // Efficiency when using DataSrc instead of multiple keys for every day when lookups change infrequently
	/***********************
	  End Indexer Specific code
	************************/
	Quit
}

/// Location and Revision of this file in Perforce (Auto-updating)
Parameter SrcVer = "$Id$";

}

