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
/// <p>
/// Source indexer for Include (*.inc) documents that contain compiler macros.<br/>
/// Extracts:
/// <ol><li>Implemention signatures for highlevel diffs</li>
/// <li><em>Optionally</em> functional source code lines for full-diff reporting</li>
/// <li>For <em>import</em>, <em>define</em> and <em>deflarg</em> generates value signatures independent of the order in which they are defined</li>
/// <li>In parallel to support difference of sequence sensitive and conditional block a full document diff is also included</li>
/// </ol>
/// Source line leading and trailing whitespace is ignored.<br/>
/// Multi-line <em>Define</em> definitions are followed by their <em>##continue</em> directive
/// <h3>Configuration</h3>
/// To exclude source code from being captured for detailed reports use schedule configuration option IncludeSourceCode=0<br/>
/// To control which <em>include</em> documnts are profiled in each target namespace for analysis 
/// update the <em>ompare</em> or lookup global using Interoperability LookupTables in SMP or directly.
/// When first run in each namespace the following exclude defaults will be established:
/// <example>
/// ^ompare("Config","Exclude","%")=1
/// </example>
/// Where value "1" means exclude and "0" means include.<br/>
/// Exclusions can layer for example to exclude all <em>include</em> documents with prefix "ompare"
/// except do include analysis of any <em>include</em> documents with prefix "ompareV2":
/// <example>
/// ^ompare("Config","Exclude","ompare*.inc")=1
/// ^ompare("Config","Exclude","ompareV2*.inc")=0
/// </example>
Class ompare.SourceHandler.Include Extends ompare.SourceHandler.Base
{

/// Ensure this Code doesn't collide with other sub-class implementations of Base
/// Eg: "CLS" abbreviation for class
Parameter DocumentType As %String = "inc";

/// Main entry point for INC Source Handler
/// Do ##class(ompare.SourceHandler).IndexNamespace("OMPARE-TEST",,1)
ClassMethod IndexNamespace(namespace = "", logging = 0, includeSource = 0, schedule As ompare.Schedule = {$$$NULLOREF}) As %Status
{
	#define RPTType "INC"
	#define RPTSubTypeDefine "INCDF"
	#define RPTSubTypeDef1arg "INCDA"
	#define RPTSubTypeInclude "INCIN"
	#define RPTSubTypeFull "INCFL"
	#define RPTSubTypeConfig "CFG"
	#define RPTItemConfigMapped "IsMapped"
	#define RPTItemConfigSourceControlled "IsSourceControlled"
	#define RPTItemConfigSourceVersion "SrcVer"
	
	if '$IsObject(schedule) {
		set schedule=##class(ompare.Schedule).%New()
	}
	// Testing
    // Do ##class(ompare.SourceHandler.Include).IndexNamespace("Namespace",0,0)
	
	/*****************************
	 Start Template
	******************************/
	#dim tmpStream as %Stream.TmpCharacter
	Set tmpStream=##class(%Stream.TmpCharacter).%New()
	// It is necessary to switch namespace context within the method call as source code may not be 
	// deployed to target namespace
	set ret=$$$OK
	
	Quit:namespace="" $$$ERROR(5001,"Namespace not supplied to Routine Source Handler")
	
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
	try {
		Do IndexerMain
	} catch ex {
		// Always report issue in output
		Do Log("Error","In SourceHandler.Include Definition")
		Do Log("  Name:",ex.Name)
		Do Log("  Code:",ex.Code)
		Do Log("  Location:",ex.Location)
		Do Log("  Data:",ex.Data)
		Set ret=ex.AsStatus()
	}
	Quit ret
SetIsMapped(typeName="")
	quit:$$$RPTType=""
	quit:typeName=""
	quit:'##class(%Dictionary.CompiledMethod).%ExistsId("%Studio.SourceControl.ISC||IsMapped")
	// Assumes if the source control file is present on the filesystem then it is being source controlled
	// Requires both 3rd and 4th key to reuse generic export / import mechanism
	set ^||Data($$$RPTType,typeName,$$$RPTSubTypeConfig,$$$RPTItemConfigMapped)=##class(%Studio.SourceControl.ISC).IsMapped(typeName_".INC")
	quit
SetIsSourceControlled(typeName="")
	quit:$$$RPTType=""
	quit:typeName=""
	quit:$Data(^Sources)<11
	quit:$$SourceControlClass^%occLibrary($Namespace)'="%Studio.SourceControl.ISC"
	// Assumes if the source control file is present on the filesystem then it is being source controlled
	// Requires both 3rd and 4th key to reuse generic export / import mechanism
	set ^||Data($$$RPTType,typeName,$$$RPTSubTypeConfig,$$$RPTItemConfigSourceControlled)=##class(%File).Exists(##class(%Studio.SourceControl.ISC).ExtName(typeName_".INC"))
	quit
SetSourceVersion(typeName,data)
	quit:$$$RPTType=""
	quit:typeName=""
	set data=$ZSTRIP(data,"<>W")
	set:$E(data,1)=":" data=$ZSTRIP($E(data,2,*),"<>W")
	quit:data=""
	// Requires both 3rd and 4th key to reuse generic export / import mechanism
	set ^||Data($$$RPTType,typeName,$$$RPTSubTypeConfig,$$$RPTItemConfigSourceVersion)=data
	quit
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
  // Intercept Source Control Tokens
  // eg: $I + d: //some/org/project/product/BASE/rtn/PRTDR9ORG.rtn#1 $
  // Converts to $I + d$
  set dataNoTokenVersion=""
  if schedule.SrcVersionTokenStart'="" {
	if schedule.SrcVersionTokenEnd'="" {
		set pattern=".E1"""_schedule.SrcVersionTokenStart_"""1.E1"""_schedule.SrcVersionTokenEnd_""""
  		for {
		  quit:data'?@pattern
		  set dataNoTokenVersion=dataNoTokenVersion_$P(data,schedule.SrcVersionTokenStart)_schedule.SrcVersionTokenStart_schedule.SrcVersionTokenEnd
		  set data=$P($P(data,schedule.SrcVersionTokenStart,2,999999),schedule.SrcVersionTokenEnd,2,999999)
	  	}
	} elseif data[schedule.SrcVersionTokenStart {
		// The source control token effectively matches to the end of the line
		set data=$P(data,schedule.SrcVersionTokenStart)	
	}
  }
  // Include remainder of line after token end if token version content removed
  set:$L(dataNoTokenVersion)>0 data=dataNoTokenVersion_data
  
  
  // strip any terminating whitespace from line
  set data=$ZSTRIP(data,">W")
  // reformatting lines section
  Do stream.WriteLine(data)
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
DoSig(incname,stream,subtype,subtypename)
	if stream.Size>0 {
		Do stream.Rewind()
		set sig=$SYSTEM.Encryption.Base64Encode($SYSTEM.Encryption.SHA1HashStream(stream))
		Do SetSignature(incname, sig,subtype,subtypename)
		Do:includeSource SaveLines(sig)
		Do stream.Clear()
	}
	quit
	; Extract name value pair delimeted by some whitespace
DoSplit(data,subtype,subname,subvalue,isContinue)
	set (subtype,subname,subvalue)=""
	if $E(data,1)="#" {
		set subtype=$ZCVT($P($P($P(data,$C(9)),$C(32)),$C(160)),"L")
		set data=$E(data,$L(subtype)+1,*)
	}
	set (subname,subvalue)=""
	set data=$ZSTRIP(data,"<W")
	set subname=$P($P($P(data,$C(9)),$C(32)),$C(160))
	set subvalue=$ZSTRIP($E(data,$L(subname)+1,*),"<>W")
	if $ZCVT($E(subvalue,*-9,*),"L")="##continue" {
		set isContinue=1
		set subvalue=$ZSTRIP($E(subvalue,1,*-10),">W")	
	} else {
		set isContinue=0	
	}
	quit
IndexerMain
	/*****************************
	 End Template
	******************************/
	// Default exclusions in this namespace
	// Start set once in first run namespace
	set hasConfig=0
	set testExclude=""
	for {
		set testExclude=$O(^ompare("Config","Exclude",testExclude))
		quit:testExclude=""
		if $E(testExclude,*-3,*)=".inc" {
			set hasConfig=1
			quit  // exit on first encountered
		}
	}
	if 'hasConfig {
		// ignore system routines
		set ^ompare("Config","Exclude","%*.inc")=1
		set ^ompare("Config","Exclude","HS*.inc")=1
		set ^ompare("Config","Exclude","Ens*.inc")=1
		set ^ompare("Config","Exclude","SchemaMap.inc")=1
	}
	// End set once in first run namespace

	set incname=""
	for {
		set incname=$Order(^rINC(incname))
		quit:incname=""
		
		if $$IsExcluded(incname_".inc",.reason) {
			Do:logging Log("Ignore """_incname_""" matches filter",reason)
			continue	
		}		
		// Simple - Reindex ALL INC on demand
		Do:logging Log("ProcessINC",incname_$C(13,10))
		
		Do Indexinc(incname,tmpStream,includeSource)
	}
	Quit
Indexinc(incname,tmpStream,includeSource)
	Quit:incname=""
	Quit:'$IsObject(tmpStream)
	
	set emptySig=$SYSTEM.Encryption.Base64Encode($SYSTEM.Encryption.SHA1Hash(""))
	// Use tmpStream for Full inc context
	Do tmpStream.Clear()
	
	// Replace existing data
	set line=0
	
	set incStreamPart=##class(%Stream.TmpCharacter).%New()
	
	set k3=0,subtype=0
	for {
		set k3=$O(^rINC(incname,0,k3),1,data)
		quit:k3'?1.N  // Stop if hit "SIZE" node
		
		set data=$ZSTRIP(data,"<>W")
		
		if $L(data)=0 continue  // ignore empty line
		if $E(data,1)=";"  continue // ignore comment
		if $E(data,1,2)="#;"  continue // ignore comment
		if $E(data,1,2)="//"  continue  // ignore comment
		
		Do tmpStream.WriteLine(data)  // Append to full stream
		
		
		
		Do DoSplit(data,.tsubtype,.tsubname,.tsubvalue,.isContinue)
		
		//W !,"data=",data
		//w !,"  tsubtype=",tsubtype
		//W !,"  tsubname=",tsubname
		//W !,"  tsubvalue=",tsubvalue
		//W !,"  isContinue=",isContinue
		//W !,"  subtype=",subtype
		//W !,"----------------"

		// Filter comments
		if subtype=0 {
			
			if tsubtype="#define" {
				set subtype=$$$RPTSubTypeDefine
				Do incStreamPart.Rewind()
				set line=0
				set subtypename=tsubname
				
				// is the end of the line is ##continue
				if 'isContinue {
					Do WriteLine(incStreamPart,tsubvalue)
					Do DoSig(incname,incStreamPart,subtype,tsubname)
					set subtype=0
					
				} else {
					Do WriteLine(incStreamPart,tsubvalue)	
				}
			} elseif tsubtype="#def1arg" {
				set subtype=$$$RPTSubTypeDef1arg
				Do incStreamPart.Rewind()
				set line=0
				Do WriteLine(incStreamPart,tsubvalue)
				Do DoSig(incname,incStreamPart,subtype,tsubname)
				set subtype=0
			} elseif tsubtype="#if" {
				set ifstack=1
				set subtype="#if"
				Do incStreamPart.Rewind()
				set line=0
				// Skip stuff to the corresponding endif	
			} elseif tsubtype="#include" {
				//to do save individual??
				//set subtype=$$$RPTSubTypeInclude
				Do incStreamPart.Rewind()
				set line=0
				Do SetSignature(incname, emptySig,$$$RPTSubTypeInclude,tsubname)
				set subtype=0	
			} else {
				Do:logging Log("ProcessINC",incname_"::Unknown Include condition ",tsubtype)	
			}
		} elseif subtype=$$$RPTSubTypeDefine {
			// Expect this is "continued" by previous line
			Do:$L(data)>0 WriteLine(incStreamPart,data)
			if $E(data,*-9,*)'="##continue" {
				set mode=0
				Do DoSig(incname,incStreamPart,subtype,subtypename)
				set subtype=0
			}	
		} elseif subtype="#if" {
			// Allow for nested IF
			if tsubtype="#endif" {
				set ifstack=ifstack-1
				if ifstack<1 {
					set subtype=0	
				}
			} elseif tsubtype="#if" {
				set ifstack=ifstack+1
			}
		} else {
			Do:logging Log("ProcessINC",incname_"::Unknown subtype",subtype)
		}
	}
	
	do tmpStream.Rewind()
	do incStreamPart.Rewind()
	set line=0
	for {
		quit:tmpStream.AtEnd
		do WriteLine(incStreamPart,tmpStream.ReadLine())	
	}
	do incStreamPart.Rewind()
	set sig=$SYSTEM.Encryption.Base64Encode($SYSTEM.Encryption.SHA1HashStream(incStreamPart))
	do incStreamPart.Rewind()
	Do SetSignature(incname, sig,$$$RPTSubTypeFull,"FULL")
	Do:includeSource SaveLines(sig)
	Do SetSignature(incname, sig)

	Do SetIsMapped(incname)
	Do SetIsSourceControlled(incname)
	Quit
}

}

